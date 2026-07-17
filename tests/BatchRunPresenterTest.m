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
                    "finished", elapsedTime));
            canceled = presenter.presentRunOutcome( ...
                openmebius.application.batch.BatchRunOutcome( ...
                    "canceled", elapsedTime));

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
                "error", ...
                seconds(2), ...
                ErrorMessage = "Run failed.");

            viewModel = presenter.presentRunOutcome(outcome);

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyEqual(viewModel.CompletionStatus, "error");
            testCase.verifyEqual(viewModel.Notification.Level, "error");
            testCase.verifyEqual(viewModel.ErrorMessage, "Run failed.");

        end

    end % methods (Test)

end % classdef
