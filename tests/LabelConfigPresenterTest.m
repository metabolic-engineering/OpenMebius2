classdef LabelConfigPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsEditorState(testCase)

            labelTable = table( ...
                {"Uniform"}, {1}, ...
                VariableNames = ["Name", "Num"]);
            ratioTables = struct(Uniform = table());
            state = openmebius.application.model ...
                .LabelConfigurationEditorState( ...
                labelTable, ratioTables);
            outcome = openmebius.application.model ...
                .LabelConfigurationLaunchOutcome( ...
                true, State = state);
            presenter = openmebius.presentation.model ...
                .LabelConfigPresenter();

            viewModel = presenter.presentLaunchOutcome(outcome);

            testCase.verifyTrue(viewModel.IsAvailable);
            testCase.verifyEqual(viewModel.LabelTable, labelTable);
            testCase.verifyEqual(viewModel.RatioTables, ratioTables);
            testCase.verifyEmpty(viewModel.Notifications);

        end

        function presentsFailureAsNotification(testCase)

            exception = MException( ...
                "OpenMebius2:Test:LabelConfigurationLaunchFailed", ...
                "Label configuration launch failed.");
            outcome = openmebius.application.model ...
                .LabelConfigurationLaunchOutcome( ...
                false, ...
                ErrorMessage = string(exception.message), ...
                Exception = exception);
            presenter = openmebius.presentation.model ...
                .LabelConfigPresenter();

            viewModel = presenter.presentLaunchOutcome(outcome);

            testCase.verifyFalse(viewModel.IsAvailable);
            testCase.verifyNumElements(viewModel.Notifications, 1);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Title, ...
                "Label configuration error");
            testCase.verifyTrue(viewModel.Notifications{1}.ShowAlert);

        end

    end % methods (Test)

end % classdef
