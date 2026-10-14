classdef InheritedResultRepositoryTest < matlab.unittest.TestCase
    properties
        Location
        Repository
    end
    methods (TestMethodSetup)
        function setup(testCase)
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
            fixture = matlab.unittest.fixtures.TemporaryFolderFixture();
            testCase.applyFixture(fixture);
            folder = fixture.Folder;
            testCase.Location = openmebius.domain.result.ResultLocation(string(folder));
            testCase.Repository = openmebius.infrastructure.result.InheritedResultRepository();
        end
    end
    methods (Test)

        function bulkWritePreservesTypesShapesAndExistingMetadata(testCase)
            data = helpers.inheritedOptimizationData();
            data.model.modelReaction = ["基質 → 中間体"; "中間体 → 生成物"];
            for type = ["int8", "uint8", "int16", "uint16", "int32", "uint32", ...
                    "int64", "uint64", "single", "double"]
                data.fluxResult.iteration0001.(type) = cast(reshape(1:24, 2, 3, 4), type);
            end
            data.fluxResult.iteration0001.nonfinite = [NaN, Inf; -Inf, 1];
            file = testCase.Location.resultFile('bat_types');
            writer = openmebius.infrastructure.result.Hdf5ResultRepository();
            writer.writeDataset(file, '/metadata/batch/name', "Keep this metadata", DataType = 'string');
            writer.writeDataset(file, '/ID', "old", DataType = 'string');
            writer.writeDataset(file, '/status', int8([1 1 1 1]), DataType = 'int8');
            testCase.verifyFalse(testCase.Repository.writeOptimization(file, data, 'bat_types'));
            testCase.verifyEqual(string(h5read(file, '/metadata/batch/name')), "Keep this metadata");
            testCase.verifyEqual(string(h5read(file, '/ID')), "bat_types");
            testCase.verifyEqual(h5read(file, '/status'), int8([1 1 0 0]));
            saved = testCase.Repository.readSource(testCase.Location, 'bat_types', ...
                openmebius.domain.batch.BatchConfig.defaultConfig(), 'exp-a');
            testCase.verifyEqual(saved.Data, data);
            % The writer must release all its handles on return.
            fileId = H5F.open(file, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            cleanup = onCleanup(@() H5F.close(fileId));
            testCase.verifyEqual(H5F.get_obj_count(fileId, 'H5F_OBJ_ALL'), 1);
        end

        function canceledBulkWriteLeavesIncompleteStatusAndCanBeRetried(testCase)
            data = helpers.inheritedOptimizationData();
            value = data.fluxResult.iteration0001;
            for index = 3:501
                data.fluxResult.(sprintf('iteration%04d', index)) = value;
            end
            file = testCase.Location.resultFile('bat_cancel');
            messages = [];
            cancel = false;
            isCanceled = testCase.Repository.writeOptimization(file, data, 'bat_cancel', ...
                ProgressReporter = @recordProgress, CancellationRequested = @cancellationRequested);
            testCase.verifyTrue(isCanceled);
            testCase.verifyEqual(messages, [0, 500]);
            testCase.verifyEqual(h5read(file, '/status'), int8([0 0 0 0]));
            testCase.verifyError(@() testCase.Repository.readSource(testCase.Location, 'bat_cancel', ...
                openmebius.domain.batch.BatchConfig.defaultConfig(), 'exp-a'), ...
                'OpenMebius2:Inheritance:IncompleteOptimization');
            testCase.verifyFalse(testCase.Repository.writeOptimization(file, data, 'bat_cancel'));
            testCase.verifyEqual(h5read(file, '/status'), int8([1 1 0 0]));
            testCase.verifyEqual(h5read(file, '/fluxResult/0501/flux'), value.flux);

            function recordProgress(current, total)
                testCase.verifyEqual(total, 501);
                messages(end + 1) = current;
                cancel = current == 500;
            end

            function value = cancellationRequested()
                value = cancel;
            end
        end

        function inheritCommandPersistsNewBatchAndLeavesOriginalUntouched(testCase)
            experiments = helpers.BatchExperimentRunStub(testCase.Location.Directory);
            provenance = helpers.AnalysisProvenanceBuilderStub();
            session = openmebius.application.batch.BatchSession(experiments, ...
                AnalysisProvenanceBuilder = provenance);
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.status = 'finished';
            session.addBatch('Original', {"experiment-a"}, 'description', config);
            before = session.getBatch();
            sourceId = before.id(1);
            testCase.Repository.writeOptimization(testCase.Location.resultFile(sourceId), ...
                helpers.inheritedOptimizationData(), sourceId);
            controller = openmebius.application.batch.BatchOperationController();
            messages = strings(0, 1);
            outcome = controller.inherit(session, sourceId, session.getBatchForGUI(), testCase.Location, ...
                ProgressReporter = @recordProgress);
            testCase.verifyTrue(outcome.isSuccess(), outcome.ErrorMessage);
            after = session.getBatch();
            testCase.verifyEqual(height(after), 2);
            testCase.verifyEqual(after(1, :), before);
            testCase.verifyNotEqual(after.id(2), sourceId);
            testCase.verifyEqual(string(after.config(2).inheritedFrom), sourceId);
            testCase.verifyEqual(string(after.config(2).status), "ready");
            reloaded = openmebius.application.batch.BatchSession(experiments, ...
                AnalysisProvenanceBuilder = provenance);
            testCase.verifyEqual(reloaded.getBatch().id, after.id);
            testCase.verifyEqual(string(reloaded.getBatchConfig(after.id(2)).inheritedFrom), sourceId);
            saved = testCase.Repository.load(testCase.Location, after.id(2));
            testCase.verifyEqual(saved.SourceID, sourceId);
            testCase.verifyEqual(h5read(testCase.Location.resultFile(sourceId), '/status'), int8([1 1 0 0]));
            testCase.verifyTrue(any(contains(messages, 'Reading optimization results')));
            testCase.verifyTrue(any(contains(messages, 'Saving the inherited optimization')));
            testCase.verifyEqual(messages(end), "Saving the new batch...");

            function recordProgress(message)
                messages(end + 1, 1) = string(message);
            end
        end

        function readsManyIterationsWithProgressAndPreservesDatasetShapes(testCase)
            data = helpers.inheritedOptimizationData();
            value = data.fluxResult.iteration0001;
            value.MDV = reshape(1:24, 3, 4, 2);
            value.finiteDifferenceStepSizeCandidates = [1e-4, 1e-6, 1e-8];
            value.finiteDifferenceStepSizeObjectives = [NaN; Inf; 3];
            value.finiteDifferenceStepSizeExitflags = int32([1; -2; 0]);
            data.fluxResult.iteration0001 = value;
            file = testCase.Location.resultFile('bat_many');
            testCase.Repository.writeOptimization(file, data, 'bat_many');
            fileId = H5F.open(file, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
            cleanup = onCleanup(@() H5F.close(fileId));
            for iteration = 3:205
                H5O.copy(fileId, '/fluxResult/0001', fileId, ...
                    sprintf('/fluxResult/%04d', iteration), 'H5P_DEFAULT', 'H5P_DEFAULT');
            end
            clear cleanup
            writer = openmebius.infrastructure.result.Hdf5ResultRepository();
            writer.writeDataset(file, '/RSSIndex', 205:-1:1);
            writer.writeDataset(file, '/RSS', ones(1, 205));
            messages = strings(0, 1);
            snapshot = testCase.Repository.readSource(testCase.Location, 'bat_many', ...
                openmebius.domain.batch.BatchConfig.defaultConfig(), 'exp-a', ...
                ProgressReporter = @recordProgress);
            testCase.verifyNumElements(fieldnames(snapshot.Data.fluxResult), 205);
            testCase.verifyTrue(any(contains(messages, '(100/205)')));
            testCase.verifyTrue(any(contains(messages, '(200/205)')));
            testCase.verifyTrue(any(contains(messages, '(205/205)')));
            copied = snapshot.Data.fluxResult.iteration0205;
            for field = string(fieldnames(value))'
                testCase.verifyEqual(copied.(field), ...
                    h5read(file, '/fluxResult/0001/' + field));
            end
            testCase.Repository.save(testCase.Location, 'bat_copy', snapshot);
            loaded = testCase.Repository.load(testCase.Location, 'bat_copy');
            testCase.verifyEqual(loaded, snapshot);
            delete(file);
            testCase.verifyFalse(isfile(file));

            function recordProgress(message)
                messages(end + 1, 1) = string(message);
            end
        end

        function invalidMultiSelectionDoesNotAddPartialBatches(testCase)
            experiments = helpers.BatchExperimentRunStub(testCase.Location.Directory);
            session = openmebius.application.batch.BatchSession(experiments, ...
                AnalysisProvenanceBuilder = helpers.AnalysisProvenanceBuilderStub());
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            session.addBatch('Valid', {"experiment-a"}, '', config);
            session.addBatch('Missing result', {"experiment-a"}, '', config);
            before = session.getBatch();
            testCase.Repository.writeOptimization(testCase.Location.resultFile(before.id(1)), ...
                helpers.inheritedOptimizationData(), before.id(1));
            testCase.verifyError(@() session.inheritBatches(before.id, testCase.Location), ...
                'OpenMebius2:Inheritance:MissingResult');
            testCase.verifyEqual(session.getBatch(), before);
            testCase.verifyFalse(isfolder(fullfile(testCase.Location.Directory, '.inheritance')));
        end
        function snapshotSurvivesSourceRemovalAndResetsOptionalResults(testCase)
            data = helpers.inheritedOptimizationData();
            source = testCase.Location.resultFile('bat_source');
            testCase.Repository.writeOptimization(source, data, 'bat_source');
            writer = openmebius.infrastructure.result.Hdf5ResultRepository();
            writer.writeDataset(source, '/CI/iteration', 100);
            writer.writeDataset(source, '/status', int8([1 1 1 0]), DataType = 'int8');
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.iteration = 2;
            snapshot = testCase.Repository.readSource( ...
                testCase.Location, 'bat_source', config, 'exp-a');
            testCase.Repository.save(testCase.Location, 'bat_inherited', snapshot);
            artifacts = openmebius.infrastructure.result.ResultArtifactRepository();
            artifacts.deleteBatchArtifacts(testCase.Location, 'bat_source');
            saved = testCase.Repository.load(testCase.Location, 'bat_inherited');
            testCase.verifyEqual(saved.Data, snapshot.Data);
            target = testCase.Location.resultFile('bat_inherited');
            testCase.Repository.writeOptimization(target, saved.Data, 'bat_inherited');
            testCase.verifyEqual(string(h5read(target, '/ID')), "bat_inherited");
            testCase.verifyEqual(h5read(target, '/status'), int8([1 1 0 0]));
            testCase.verifyEqual(h5read(target, '/fluxResult/0002/flux'), [5; 0.6]);
            testCase.verifyEqual(h5read(target, '/fluxResult/0002/time'), int32(126));
            info = h5info(target);
            testCase.verifyFalse(any(string({info.Groups.Name}) == '/CI'));
            artifacts.deleteBatchArtifacts(testCase.Location, 'bat_inherited', PreserveInheritance = true);
            testCase.verifyTrue(isfile(testCase.Location.inheritanceFile('bat_inherited')));
            artifacts.deleteBatchArtifacts(testCase.Location, 'bat_inherited');
            testCase.verifyFalse(isfile(testCase.Location.inheritanceFile('bat_inherited')));
        end

        function usesResultConfigurationInsteadOfEditedBatch(testCase)
            source = testCase.Location.resultFile('bat_source');
            testCase.Repository.writeOptimization(source, helpers.inheritedOptimizationData(), 'bat_source');
            writer = openmebius.infrastructure.result.Hdf5ResultRepository();
            original = openmebius.domain.batch.BatchConfig.defaultConfig();
            original.iteration = 2;
            writer.writeDataset(source, '/metadata/batch/configJson', string(jsonencode(original)), DataType = 'string');
            writer.writeDataset(source, '/metadata/experiments/names', "exp-original", DataType = 'string');
            fallback = original;
            fallback.iteration = 999;
            snapshot = testCase.Repository.readSource(testCase.Location, 'bat_source', fallback, 'exp-edited');
            testCase.verifyEqual(snapshot.Config.iteration, 2);
            testCase.verifyEqual(snapshot.Experiments, "exp-original");
        end

        function rejectsMissingAndIncompleteResults(testCase)
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            testCase.verifyError(@() testCase.Repository.readSource( ...
                testCase.Location, 'missing', config, 'exp'), 'OpenMebius2:Inheritance:MissingResult');
            writer = openmebius.infrastructure.result.Hdf5ResultRepository();
            writer.writeDataset(testCase.Location.resultFile('incomplete'), '/status', ...
                int8([1 0 0 0]), DataType = 'int8');
            testCase.verifyError(@() testCase.Repository.readSource( ...
                testCase.Location, 'incomplete', config, 'exp'), 'OpenMebius2:Inheritance:IncompleteOptimization');
        end

        function unchangedExcelContentsMayHaveDifferentHashesAndCIIsAllowed(testCase)
            snapshot.Config = openmebius.domain.batch.BatchConfig.defaultConfig();
            snapshot.ModelHash = "model-hash";
            snapshot.ExperimentHashes = "experiment-hash";
            config = snapshot.Config;
            config.inheritedFrom = 'bat_source';
            config.isCalcCI = true;
            config.CIConf.MC.iteration = 80;
            config.CIConf.grid.points = 20;
            config.CIConf.grid.iteration = 60;
            config.CIConf.grid.parallelIterations = true;
            provenance = struct('modelSha256', "model-hash", 'experimentSha256', "experiment-hash");
            testCase.Repository.validateInputs(snapshot, config, provenance);
            changed = config;
            changed.iteration = 5;
            testCase.verifyError(@() testCase.Repository.validateInputs(snapshot, changed, provenance), ...
                'OpenMebius2:Inheritance:ChangedConfiguration');
            provenance.modelSha256 = "changed";
            provenance.experimentSha256 = "resaved-workbook";
            testCase.Repository.validateInputs(snapshot, config, provenance);
            snapshot.Experiments = "exp-original";
            provenance.experimentNames = "exp-other";
            testCase.verifyError(@() testCase.Repository.validateInputs(snapshot, config, provenance), ...
                'OpenMebius2:Inheritance:ChangedInputs');
        end
    end
end
