classdef ExperimentPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsCalculationStarted(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();

            viewModel = presenter.presentCalculationStarted();

            testCase.verifyEqual(viewModel.SectionStatus, "running");
            testCase.verifyEmpty(viewModel.Notifications);

        end

        function presentsEachSuccessMessageOnce(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            result = struct("Messages", ["Tables updated."; "MDV updated."]);
            outcome = openmebius.application.experiment ...
                .ExperimentCalculationOutcome( ...
                    "finished", Result = result);

            viewModel = presenter.presentCalculationOutcome(outcome);

            messages = cellfun( ...
                @(notification) notification.Message, ...
                viewModel.Notifications);
            testCase.verifyEqual(viewModel.SectionStatus, "finished");
            testCase.verifyEqual( ...
                messages, ["Tables updated."; "MDV updated."]);

        end

        function presentsFailureAsAlert(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            outcome = openmebius.application.experiment ...
                .ExperimentCalculationOutcome( ...
                    "error", ErrorMessage = "Calculation failed.");

            viewModel = presenter.presentCalculationOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual( ...
                notification.Title, "MDV calculation failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

    end % methods (Test)

end % classdef
