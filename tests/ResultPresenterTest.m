classdef ResultPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsGeneratedReport(testCase)

            presenter = openmebius.presentation.result.ResultPresenter();
            report = struct("Created", true);
            operationResult = struct( ...
                "Report", report, ...
                "Messages", ["Generated."; "Opened."]);
            outcome = openmebius.application.result ...
                .ResultOperationOutcome( ...
                    "finished", Result = operationResult);

            viewModel = presenter.presentReportOutcome(outcome);
            messages = cellfun( ...
                @(notification) notification.Message, ...
                viewModel.Notifications);

            testCase.verifyEqual(viewModel.Report, report);
            testCase.verifyEqual(messages, ["Generated."; "Opened."]);

        end

        function presentsUnavailableDeployedReportAsWarning(testCase)

            presenter = openmebius.presentation.result.ResultPresenter();
            exception = MException( ...
                "OpenMebius2:Report:UnavailableInDeployed", ...
                "Report generation is unavailable.");
            outcome = openmebius.application.result ...
                .ResultOperationOutcome( ...
                    "error", ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);

            viewModel = presenter.presentReportOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(notification.Level, "warning");
            testCase.verifyFalse(notification.ShowAlert);

        end

        function presentsUnexpectedReportFailureAsAlert(testCase)

            presenter = openmebius.presentation.result.ResultPresenter();
            exception = MException( ...
                "OpenMebius2:Test:Unexpected", ...
                "Unexpected failure.");
            outcome = openmebius.application.result ...
                .ResultOperationOutcome( ...
                    "error", ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);

            viewModel = presenter.presentReportOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual( ...
                notification.Title, "Report generation failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

        function presentsKnownExportFailureWithoutAlert(testCase)

            presenter = openmebius.presentation.result.ResultPresenter();
            exception = MException( ...
                "OpenMebius2:ResultExport:EmptySelection", ...
                "Please select a result to save.");
            outcome = openmebius.application.result ...
                .ResultOperationOutcome( ...
                    "error", ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);

            viewModel = presenter.presentExportOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyFalse(notification.ShowAlert);

        end

        function presentsReloadAndMissingSelection(testCase)

            presenter = openmebius.presentation.result.ResultPresenter();

            reloadViewModel = presenter.presentReloaded();
            selectionViewModel = ...
                presenter.presentExportSelectionRequired();

            testCase.verifyEqual( ...
                reloadViewModel.Notifications{1}.Message, ...
                "Result data reloaded");
            testCase.verifyEqual( ...
                selectionViewModel.Notifications{1}.Level, ...
                "warning");

        end

        function presentsResultSuggestion(testCase)

            presenter = openmebius.presentation.result.ResultPresenter();
            suggestion = struct("Value", 1);
            result = openmebius.application.result ...
                .ResultSuggestionResult( ...
                    Suggestion = suggestion, ...
                    BatchID = "batch-1", ...
                    BatchName = "First");
            outcome = openmebius.application.result ...
                .ResultOperationOutcome("finished", Result = result);

            viewModel = presenter.presentSuggestionOutcome(outcome);

            testCase.verifyEqual(viewModel.Suggestion, suggestion);
            testCase.verifyEmpty(viewModel.Notifications);

        end

        function presentsSuggestionSelectionErrorAsWarning(testCase)

            presenter = openmebius.presentation.result.ResultPresenter();
            exception = MException( ...
                "OpenMebius2:ResultSuggestion:SelectionRequired", ...
                "Please select one result.");
            outcome = openmebius.application.result ...
                .ResultOperationOutcome( ...
                    "error", ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);

            viewModel = presenter.presentSuggestionOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(notification.Level, "warning");
            testCase.verifyFalse(notification.ShowAlert);

        end

        function presentsUnexpectedSuggestionFailureAsAlert(testCase)

            presenter = openmebius.presentation.result.ResultPresenter();
            exception = MException( ...
                "OpenMebius2:Test:Unexpected", ...
                "Unexpected failure.");
            outcome = openmebius.application.result ...
                .ResultOperationOutcome( ...
                    "error", ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);

            viewModel = presenter.presentSuggestionOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual( ...
                notification.Title, "Suggestion load failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

    end % methods (Test)

end % classdef
