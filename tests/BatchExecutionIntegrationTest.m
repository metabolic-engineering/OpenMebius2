classdef BatchExecutionIntegrationTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(BatchExecutionIntegrationTest.sourcePath());

        end

    end

    methods (Test)

        function runningSkipsReopenedFinishedBatch(testCase)

            experimentDirectory = string(tempname);
            resultDirectory = string(tempname);
            mkdir(experimentDirectory);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                BatchExecutionIntegrationTest.removeDirectories( ...
                [experimentDirectory; resultDirectory]));
            experiments = helpers.BatchExperimentRunStub( ...
                experimentDirectory);
            provenanceBuilder = ...
                helpers.AnalysisProvenanceBuilderStub();
            runService = helpers.BatchRunServiceQueueStub("finished");
            batch = openmebius.application.batch.BatchSession( ...
                experiments, ...
                AnalysisProvenanceBuilder = provenanceBuilder);
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.status = 'finished';
            batch.addBatch( ...
                "Batch A", ...
                {"experiment-a"}, ...
                "", ...
                config);
            batch.saveBatchFile();

            repository = ...
                openmebius.infrastructure.batch.BatchJsonRepository();
            [storedTable, isError, message] = repository.load( ...
                experiments.getExperimentLocation(), ...
                "batch.json");
            testCase.assertFalse(isError, string(message));
            storedTable.contentHash = "sha256:stored-before-upgrade";
            repository.save( ...
                experiments.getExperimentLocation(), ...
                "batch.json", ...
                storedTable);

            reopenedBatch = openmebius.application.batch.BatchSession( ...
                experiments, ...
                AnalysisProvenanceBuilder = provenanceBuilder, ...
                BatchRunService = runService);
            reopenedTable = reopenedBatch.getBatch();

            testCase.verifyEqual( ...
                string(reopenedTable.config.status), "finished");
            testCase.verifyEqual( ...
                reopenedTable.contentHash, ...
                "sha256:stored-before-upgrade");

            result = reopenedBatch.runBatch(resultDirectory);
            tableAfterRun = reopenedBatch.getBatch();

            testCase.verifyTrue(result.isSuccess());
            testCase.verifyEqual(runService.CallCount, 0);
            testCase.verifyEqual( ...
                string(tableAfterRun.config.status), "finished");
            testCase.verifyEqual( ...
                tableAfterRun.contentHash, ...
                "sha256:stored-before-upgrade");

        end

        function runBatchPublishesProgressAndSavesCheckpoint(testCase)

            experimentDirectory = string(tempname);
            resultDirectory = string(tempname);
            mkdir(experimentDirectory);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                BatchExecutionIntegrationTest.removeDirectories( ...
                [experimentDirectory; resultDirectory]));
            experiments = helpers.BatchExperimentRunStub( ...
                experimentDirectory);
            provenanceBuilder = ...
                helpers.AnalysisProvenanceBuilderStub();
            runService = helpers.BatchRunServiceQueueStub("finished");
            batch = openmebius.application.batch.BatchSession( ...
                experiments, ...
                AnalysisProvenanceBuilder = provenanceBuilder, ...
                BatchRunService = runService);
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.deleteResultFile = false;
            batch.addBatch( ...
                "Batch A", ...
                {"experiment-a"}, ...
                "", ...
                config);
            observer = helpers.AnalysisNotificationObserverStub();
            buildCountBeforeRun = numel(provenanceBuilder.BatchIds);

            result = batch.runBatch( ...
                resultDirectory, ...
                ProgressReporter = ...
                @(progress) observer.publish(progress));

            updatedTable = batch.getBatch();
            testCase.verifyTrue(result.isSuccess());
            testCase.verifyEqual( ...
                string(updatedTable.config.status), "finished");
            testCase.verifyEqual(observer.EventCount, 1);
            testCase.verifyEqual( ...
                observer.LastEvent.status, "finished");
            testCase.verifyEqual(observer.LastEvent.rate, 1);
            batchFile = fullfile(experimentDirectory, "batch.json");
            testCase.verifyTrue(isfile(batchFile));
            document = jsondecode(fileread(batchFile));
            testCase.verifyEqual( ...
                string(document.batches.config.status), "finished");
            testCase.verifyEqual(runService.CallCount, 1);
            testCase.verifyEqual( ...
                numel(provenanceBuilder.BatchIds), ...
                buildCountBeforeRun + 1);
            testCase.verifyEqual( ...
                provenanceBuilder.BatchIds(end), updatedTable.id);

        end

    end

    methods (Static, Access = private)

        function removeDirectories(directories)

            for directory = string(directories(:))'

                if isfolder(directory)
                    rmdir(directory, 's');
                end

            end

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
