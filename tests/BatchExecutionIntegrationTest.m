classdef BatchExecutionIntegrationTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(BatchExecutionIntegrationTest.sourcePath());

        end

    end

    methods (Test)

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
            batch = Batch( ...
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
            listener = addlistener( ...
                batch, ...
                'ProgressUpdate', ...
                @(~, eventData) observer.publish(eventData));
            listenerCleanup = onCleanup(@() delete(listener));
            buildCountBeforeRun = numel(provenanceBuilder.BatchIds);

            status = batch.runBatch(resultDirectory);

            updatedTable = batch.getBatch();
            testCase.verifyEqual(status, "finished");
            testCase.verifyEqual( ...
                string(updatedTable.config.status), "finished");
            testCase.verifyEqual(observer.EventCount, 1);
            testCase.verifyEqual( ...
                observer.LastEvent.data.status, "finished");
            testCase.verifyEqual(observer.LastEvent.data.rate, 1);
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
