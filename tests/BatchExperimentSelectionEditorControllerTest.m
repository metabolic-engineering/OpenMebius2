classdef BatchExperimentSelectionEditorControllerTest < ...
        matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function preparesParallelEditor(testCase)

            controller = openmebius.application.batch ...
                .BatchExperimentSelectionEditorController();

            outcome = controller.prepareParallel( ...
                helpers.MSViewExperimentsStub());

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyClass( ...
                outcome.Result, ...
                ['openmebius.application.batch.' ...
                 'BatchExperimentSelectionEditorRequest']);
            testCase.verifyEqual( ...
                outcome.Result.ExperimentNames, ...
                ["Experiment A"; "Experiment B"]);
            testCase.verifyEqual(outcome.Result.Mode, "parallel");
            testCase.verifyEqual(outcome.Result.BatchId, "");

        end

        function preparesInstMfaEditor(testCase)

            session = BatchExperimentSelectionEditorControllerTest ...
                .createSession("batch-a");
            controller = openmebius.application.batch ...
                .BatchExperimentSelectionEditorController();

            outcome = controller.prepareINSTMFA(session);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyEqual(outcome.Result.Mode, "inst-mfa");
            testCase.verifyEqual(outcome.Result.BatchId, "batch-a");

        end

        function rejectsInstMfaEditorForMultipleBatches(testCase)

            session = BatchExperimentSelectionEditorControllerTest ...
                .createSession(["batch-a"; "batch-b"]);
            controller = openmebius.application.batch ...
                .BatchExperimentSelectionEditorController();

            outcome = controller.prepareINSTMFA(session);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:" + ...
                "BatchExperimentSelectionEditorController:" + ...
                "MultipleBatchesForINSTMFA");

        end

        function capturesExperimentCatalogFailure(testCase)

            controller = openmebius.application.batch ...
                .BatchExperimentSelectionEditorController();

            outcome = controller.prepareParallel([]);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyNotEmpty(outcome.Exception);

        end

    end % methods (Test)

    methods (Static, Access = private)

        function session = createSession(batchIds)

            session = openmebius.application.batch ...
                .BatchConfigurationSession( ...
                    helpers.RunConfigBatchStub(), ...
                    helpers.MSViewExperimentsStub(), ...
                    batchIds);

        end

    end % methods (Static, Access = private)

end % classdef
