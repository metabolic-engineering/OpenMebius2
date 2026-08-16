classdef BatchRunPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsRunAndCancelRequests(testCase)

            presenter = openmebius.presentation.batch.BatchPresenter();

            running = presenter.presentRunStarted();
            canceling = presenter.presentCancelRequested();

            testCase.verifyEqual(running.SectionStatus, "running");
            testCase.verifyEqual( ...
                running.Notification.Message, "Batch jobs are running...");
            testCase.verifyEqual(canceling.SectionStatus, "");
            testCase.verifyThat( ...
                canceling.Notification.Message, ...
                matlab.unittest.constraints.ContainsSubstring( ...
            "Canceling batch jobs"));

        end

        function presentsFinishedAndCanceledOutcomes(testCase)

            presenter = openmebius.presentation.batch.BatchPresenter();
            elapsedTime = seconds(5);

            finished = presenter.presentRunOutcome( ...
                openmebius.application.batch.BatchRunOutcome( ...
                true, elapsedTime));
            canceled = presenter.presentRunOutcome( ...
                openmebius.application.batch.BatchRunOutcome( ...
                false, elapsedTime, Canceled = true));

            testCase.verifyEqual(finished.SectionStatus, "finished");
            testCase.verifyEqual(finished.CompletionStatus, "finished");
            testCase.verifyEqual(finished.ElapsedTime, elapsedTime);
            testCase.verifyEqual( ...
                finished.Notification.Message, ...
            "All batch jobs are completed.");
            testCase.verifyEqual(canceled.SectionStatus, "finished");
            testCase.verifyEqual(canceled.CompletionStatus, "canceled");

        end

        function presentsFailedOutcome(testCase)

            presenter = openmebius.presentation.batch.BatchPresenter();
            outcome = openmebius.application.batch.BatchRunOutcome( ...
                false, ...
                seconds(2), ...
                ErrorMessage = "Run failed.");

            viewModel = presenter.presentRunOutcome(outcome);

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyEqual(viewModel.CompletionStatus, "error");
            testCase.verifyEqual(viewModel.Notification.Level, "error");
            testCase.verifyEqual(viewModel.ErrorMessage, "Run failed.");

        end

        function presentsProgressValueWithoutLegacyEventData(testCase)

            presenter = openmebius.presentation.batch.BatchPresenter();
            progress = struct( ...
                id = "bat_1", ...
                status = "finished", ...
                rate = 0.5);
            currentTable = table( ...
                "bat_1", ...
                "Batch 1", ...
                'VariableNames', ["ID", "Name"]);

            viewModel = presenter.presentProgress( ...
                progress, currentTable);

            testCase.verifyEqual(viewModel.BatchId, "bat_1");
            testCase.verifyEqual(viewModel.Status, "finished");
            testCase.verifyEqual(viewModel.Rate, 0.5);
            testCase.verifyEqual(viewModel.StyleRules.Rows, 1);

        end

        function presentsCanceledProgressAsWarning(testCase)

            presenter = openmebius.presentation.batch.BatchPresenter();
            progress = struct( ...
                id = "bat_1", ...
                status = "canceled", ...
                rate = 0.5);
            currentTable = table( ...
                "bat_1", ...
                "Batch 1", ...
                'VariableNames', ["ID", "Name"]);

            viewModel = presenter.presentProgress( ...
                progress, currentTable);

            testCase.verifyEqual(viewModel.Status, "canceled");
            testCase.verifyEqual(viewModel.StyleRules.StyleKey, "warning");
            testCase.verifyEqual(viewModel.Notification.Level, "warning");

        end

        function presentsRunningAnalysisProgressWithoutNotification(testCase)

            presenter = openmebius.presentation.batch.BatchPresenter();
            progress = struct( ...
                id = "bat_1", ...
                status = "running", ...
                rate = 0.25, ...
                message = "Monte Carlo: 1/4");
            currentTable = table( ...
                "bat_1", ...
                "Batch 1", ...
                'VariableNames', ["ID", "Name"]);

            viewModel = presenter.presentProgress( ...
                progress, currentTable);

            testCase.verifyEqual(viewModel.Rate, 0.25);
            testCase.verifyEqual(viewModel.Message, "Monte Carlo: 1/4");
            testCase.verifyEqual(viewModel.StyleRules.StyleKey, "info");
            testCase.verifyEmpty(viewModel.Notification);

        end

    end % methods (Test)

end % classdef
