classdef BatchExperimentSelectionEditorPresenterTest < ...
        matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsParallelEditor(testCase)

            presenter = openmebius.presentation.batch ...
                .BatchExperimentSelectionEditorPresenter();
            request = openmebius.application.batch ...
                .BatchExperimentSelectionEditorRequest( ...
                    ["exp-a"; "exp-b"], "parallel");
            outcome = openmebius.application.batch ...
                .BatchExperimentSelectionEditorOutcome( ...
                    true, Result = request);

            viewModel = presenter.presentParallelEditor(outcome);

            testCase.verifyTrue(viewModel.IsAvailable);
            testCase.verifyEqual( ...
                viewModel.ExperimentNames, ["exp-a"; "exp-b"]);
            testCase.verifyEqual(viewModel.Mode, "parallel");
            testCase.verifyEqual(viewModel.BatchId, "");
            testCase.verifyEmpty(viewModel.Notifications);

        end

        function presentsInstMfaEditorFailure(testCase)

            presenter = openmebius.presentation.batch ...
                .BatchExperimentSelectionEditorPresenter();
            exception = MException( ...
                "OpenMebius2:Test:ChildEditorFailed", ...
                "Child editor failed.");
            outcome = openmebius.application.batch ...
                .BatchExperimentSelectionEditorOutcome( ...
                    false, ...
                    ErrorMessage = "Child editor failed.", ...
                    Exception = exception);

            viewModel = presenter.presentINSTMFAEditor(outcome);

            testCase.verifyFalse(viewModel.IsAvailable);
            testCase.verifyNumElements(viewModel.Notifications, 1);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Level, "error");
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Title, ...
                "INST-MFA experiment editor error");
            testCase.verifyTrue(viewModel.Notifications{1}.ShowAlert);

        end

    end % methods (Test)

end % classdef
