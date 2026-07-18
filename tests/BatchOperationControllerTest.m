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

            testCase.verifyEqual(outcome.Status, "finished");
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

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyTrue(batch.SaveCalled);
            testCase.verifyEqual(batch.SavedTable, tableData);

        end

        function removesSelectedBatches(testCase)

            batch = helpers.BatchOperationStub();
            controller = openmebius.application.batch ...
                .BatchOperationController();

            outcome = controller.remove( ...
                batch, ["batch-a"; "batch-b"]);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyEqual( ...
                batch.RemovedIds, ["batch-a"; "batch-b"]);

        end

        function capturesBatchOperationFailure(testCase)

            batch = helpers.BatchOperationStub();
            batch.Exception = MException( ...
                "OpenMebius2:Test:BatchOperationFailed", ...
                "Batch operation failed.");
            controller = openmebius.application.batch ...
                .BatchOperationController();

            outcome = controller.autoFill(batch);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                outcome.ErrorMessage, "Batch operation failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:BatchOperationFailed");

        end

    end % methods (Test)

end % classdef
