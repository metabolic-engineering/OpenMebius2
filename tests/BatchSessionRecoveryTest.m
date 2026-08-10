classdef BatchSessionRecoveryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(BatchSessionRecoveryTest.sourcePath());

        end

    end

    methods (Test)

        function recoveredEntryIsPersistedInBatchJson(testCase)

            directory = string(tempname);
            mkdir(directory);
            cleanup = onCleanup(@() ...
                BatchSessionRecoveryTest.removeDirectory(directory));
            experiments = helpers.BatchExperimentNotificationStub(directory);
            session = openmebius.application.batch.BatchSession(experiments);
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.status = 'finished';
            entry = struct( ...
                'ID', "bat_recovered", ...
                'Name', "Recovered batch", ...
                'Experiments', "exp-a", ...
                'Description', "Recovered description", ...
                'Config', config, ...
                'ContentHash', "sha256:result");

            recoveredIds = session.recoverBatches({entry});

            testCase.verifyEqual(recoveredIds, "bat_recovered");
            testCase.verifyTrue(isfile(fullfile(directory, "batch.json")));
            reloaded = openmebius.application.batch.BatchSession(experiments);
            batchTable = reloaded.getBatch();
            testCase.verifyEqual(height(batchTable), 1);
            testCase.verifyEqual(batchTable.id, "bat_recovered");
            testCase.verifyEqual(batchTable.name, "Recovered batch");
            testCase.verifyEqual(string(batchTable.exp{1}), "exp-a");
            testCase.verifyEqual( ...
                string(batchTable.config.status), "finished");
            testCase.verifyEqual(batchTable.contentHash, "sha256:result");

            clear cleanup

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
            'src');

        end

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, 's');
            end

        end

    end

end
