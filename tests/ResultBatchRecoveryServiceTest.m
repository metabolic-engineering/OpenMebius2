classdef ResultBatchRecoveryServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ResultBatchRecoveryServiceTest.sourcePath());

        end

    end

    methods (Test)

        function recoversOnlyResultsMissingFromBatch(testCase)

            batch = helpers.RecoverableBatchStub();
            batch.Data = table( ...
                "bat_existing", "Existing", "exp-existing", "", ...
                'VariableNames', ...
                {'ID', 'Name', 'Experiment', 'Description'});
            result = helpers.ResultIndexStub();
            result.ResultIDs = ["bat_existing"; "bat_recovered"];
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.iteration = 41;
            result.BatchSnapshots = {struct( ...
                'ID', "bat_recovered", ...
                'Name', "", ...
                'Experiments', ["exp-a"; "exp-b"], ...
                'Description', "Recovered description", ...
                'ConfigJson', string(jsonencode(config)), ...
                'ContentHash', "sha256:recovered", ...
                'Status', "error")};
            service = openmebius.application.result ...
                .ResultBatchRecoveryService();

            recoveredIds = service.recover(batch, result);

            testCase.verifyEqual(recoveredIds, "bat_recovered");
            testCase.verifyEqual( ...
                result.RequestedSnapshotIDs, "bat_recovered");
            testCase.verifyNumElements(batch.RecoveredEntries, 1);
            entry = batch.RecoveredEntries{1};
            testCase.verifyEqual(entry.Name, "exp-a + exp-b");
            testCase.verifyNotEqual(entry.Name, entry.ID);
            testCase.verifyEqual(entry.Experiments, ["exp-a"; "exp-b"]);
            testCase.verifyEqual(entry.Description, "Recovered description");
            testCase.verifyEqual(entry.Config.iteration, 41);
            testCase.verifyEqual(string(entry.Config.status), "error");
            testCase.verifyEqual(entry.ContentHash, "sha256:recovered");

        end

        function preservesStoredBatchName(testCase)

            batch = helpers.RecoverableBatchStub();
            result = helpers.ResultIndexStub();
            result.ResultIDs = "bat_recovered";
            result.BatchSnapshots = {struct( ...
                'ID', "bat_recovered", ...
                'Name', "My batch", ...
                'Experiments', "exp-a", ...
                'Description', "", ...
                'ConfigJson', "", ...
                'ContentHash', "", ...
                'Status', "finished")};
            service = openmebius.application.result ...
                .ResultBatchRecoveryService();

            service.recover(batch, result);

            testCase.verifyEqual( ...
                batch.RecoveredEntries{1}.Name, "My batch");

        end

        function legacyResultDoesNotUseFileIdAsName(testCase)

            batch = helpers.RecoverableBatchStub();
            result = helpers.ResultIndexStub();
            result.ResultIDs = "legacy_file_name";
            result.BatchSnapshots = {struct( ...
                'ID', "legacy_file_name", ...
                'Name', "", ...
                'Experiments', strings(0, 1), ...
                'Description', "", ...
                'ConfigJson', "", ...
                'ContentHash', "", ...
                'Status', "finished")};
            service = openmebius.application.result ...
                .ResultBatchRecoveryService();

            service.recover(batch, result);

            entry = batch.RecoveredEntries{1};
            testCase.verifyEqual(entry.ID, "legacy_file_name");
            testCase.verifyEqual(entry.Name, "Recovered result");
            testCase.verifyNotEqual(entry.Name, entry.ID);

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
