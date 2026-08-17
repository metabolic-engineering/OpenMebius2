classdef BatchOperationControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function autoFillsBatch(testCase)

            batch = helpers.BatchOperationStub();
            controller = openmebius.application.batch ...
                .BatchOperationController();

            outcome = controller.autoFill(batch);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyTrue(batch.AutoFillCalled);
            testCase.verifyEmpty(outcome.Exception);

        end

        function updatesAndSavesBatch(testCase)

            batch = helpers.BatchOperationStub();
            controller = openmebius.application.batch ...
                .BatchOperationController();
            tableData = batch.Data;
            tableData.Name = "Updated";

            outcome = controller.save(batch, tableData);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyTrue(batch.SaveCalled);
            testCase.verifyEqual(batch.SavedTable, tableData);

        end

        function removesSelectedBatches(testCase)

            batch = helpers.BatchOperationStub();
            artifactRepository = helpers.ResultArtifactRepositoryStub();
            controller = openmebius.application.batch ...
                .BatchOperationController( ...
                ArtifactRepository = artifactRepository);
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(string(tempdir));

            outcome = controller.remove( ...
                batch, ["batch-a"; "batch-b"], resultLocation);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual( ...
                batch.RemovedIds, ["batch-a"; "batch-b"]);
            testCase.verifyEqual( ...
                artifactRepository.DeletedBatchIds, ...
                ["batch-a"; "batch-b"]);

        end

        function removesResultArtifactsForEveryBatchStatus(testCase)

            batch = helpers.BatchOperationStub();
            batch.Status = [ ...
                "ready"; "finished"; "error"; "warning"; "canceled"];
            batchIds = "batch-" + batch.Status;
            artifactRepository = helpers.ResultArtifactRepositoryStub();
            controller = openmebius.application.batch ...
                .BatchOperationController( ...
                ArtifactRepository = artifactRepository);
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(string(tempdir));

            outcome = controller.remove( ...
                batch, batchIds, resultLocation);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual( ...
                artifactRepository.DeletedBatchIds, ...
                batchIds);
            testCase.verifyEqual(batch.RemovedIds, batchIds);

        end

        function removesExistingArtifactsForReadyBatch(testCase)

            directory = string(tempname);
            mkdir(directory);
            cleanup = onCleanup(@() rmdir(directory, 's'));
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(directory);
            artifacts = resultLocation.resultArtifactFiles("batch-ready");

            for artifact = artifacts'
                fileId = fopen(artifact, 'w');
                testCase.assertGreaterThanOrEqual(fileId, 0);
                fileCleanup = onCleanup(@() fclose(fileId));
                fprintf(fileId, 'test');
                clear fileCleanup
            end

            batch = helpers.BatchOperationStub();
            batch.Status = "ready";
            controller = openmebius.application.batch ...
                .BatchOperationController();

            outcome = controller.remove( ...
                batch, "batch-ready", resultLocation);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyFalse(any(isfile(artifacts)));
            testCase.verifyEqual(batch.RemovedIds, "batch-ready");
            clear cleanup

        end

        function requiresResultLocationForEveryBatchRemoval(testCase)

            batch = helpers.BatchOperationStub();
            batch.Status = "ready";
            controller = openmebius.application.batch ...
                .BatchOperationController();

            outcome = controller.remove(batch, "batch-a");

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:BatchRemoval:MissingResultLocation");
            testCase.verifyEmpty(batch.RemovedIds);

        end

        function duplicatesSelectedBatches(testCase)

            batch = helpers.BatchOperationStub();
            controller = openmebius.application.batch ...
                .BatchOperationController();
            tableData = batch.Data;
            tableData.Name = "Edited before duplicate";

            outcome = controller.duplicate( ...
                batch, ["batch-a"; "batch-b"], tableData);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual( ...
                batch.DuplicatedIds, ["batch-a"; "batch-b"]);
            testCase.verifyEqual(batch.SavedTable, tableData);
            testCase.verifyFalse(batch.SaveCalled);

        end

        function movesAndSavesSelectedBatches(testCase)

            batch = helpers.BatchOperationStub();
            controller = openmebius.application.batch ...
                .BatchOperationController();
            tableData = batch.Data;
            tableData.Description = "Edited before move";

            outcome = controller.move( ...
                batch, ["batch-a"; "batch-b"], "up", tableData);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual( ...
                batch.MovedIds, ["batch-a"; "batch-b"]);
            testCase.verifyEqual(batch.MoveDirection, "up");
            testCase.verifyEqual(batch.SavedTable, tableData);
            testCase.verifyTrue(batch.SaveCalled);

        end

        function capturesBatchOperationFailure(testCase)

            batch = helpers.BatchOperationStub();
            batch.Exception = MException( ...
                "OpenMebius2:Test:BatchOperationFailed", ...
                "Batch operation failed.");
            controller = openmebius.application.batch ...
                .BatchOperationController();

            outcome = controller.autoFill(batch);

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual( ...
                outcome.ErrorMessage, "Batch operation failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:BatchOperationFailed");

        end

        function addsParallelExperimentSelection(testCase)

            batch = helpers.BatchOperationStub();
            controller = openmebius.application.batch ...
                .BatchOperationController();
            selection = openmebius.domain.batch ...
                .BatchExperimentSelection( ...
                Mode = "parallel", ...
                Experiments = ["exp-a"; "exp-b"], ...
                AddAsParallel = true);

            outcome = controller.applyExperimentSelection( ...
                batch, selection);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(batch.AddedNames, "exp-a, exp-b");
            testCase.verifyEqual( ...
                batch.AddedExperiments{1}, {selection.Experiments'});
            testCase.verifyTrue(batch.AddedConfigs{1}.isParallel);
            testCase.verifyEqual( ...
                batch.AddedConfigs{1}.numExperiments, 2);

        end

        function addsIndividualExperimentSelections(testCase)

            batch = helpers.BatchOperationStub();
            controller = openmebius.application.batch ...
                .BatchOperationController();
            selection = openmebius.domain.batch ...
                .BatchExperimentSelection( ...
                Mode = "parallel", ...
                Experiments = ["exp-a"; "exp-b"], ...
                AddAsParallel = false);

            outcome = controller.applyExperimentSelection( ...
                batch, selection);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual( ...
                batch.AddedNames, ["exp-a"; "exp-b"]);
            testCase.verifyEqual(numel(batch.AddedConfigs), 2);

        end

        function editsInstationaryExperimentSelection(testCase)

            batch = helpers.BatchOperationStub();
            controller = openmebius.application.batch ...
                .BatchOperationController();
            selection = openmebius.domain.batch ...
                .BatchExperimentSelection( ...
                Mode = "inst-mfa", ...
                Experiments = ["exp-a"; "exp-b"], ...
                BatchId = "batch-a");

            outcome = controller.applyExperimentSelection( ...
                batch, selection);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(batch.EditedId, "batch-a");
            testCase.verifyEqual(batch.EditedName, "exp-a, exp-b");
            testCase.verifyTrue(batch.EditedConfig.isINSTMFA);
            testCase.verifyFalse(batch.EditedConfig.isParallel);

        end

    end % methods (Test)

end % classdef
