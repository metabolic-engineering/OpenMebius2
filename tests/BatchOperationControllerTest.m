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
            controller = openmebius.application.batch ...
                .BatchOperationController();

            outcome = controller.remove( ...
                batch, ["batch-a"; "batch-b"]);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual( ...
                batch.RemovedIds, ["batch-a"; "batch-b"]);

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
