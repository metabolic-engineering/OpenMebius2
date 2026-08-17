classdef BatchRunControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function returnsSuccessfulOutcome(testCase)

            command = helpers.BatchRunCommandStub();
            command.RunResult = openmebius.application.batch ...
                .BatchExecutionResult(true);
            controller = BatchRunControllerTest.createController(command);

            outcome = controller.run(struct(), "result");

            testCase.verifyTrue(command.RunCalled);
            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(outcome.ElapsedTime, seconds(0));
            testCase.verifyEmpty(outcome.Exception);

        end

        function preservesCanceledAndReturnedFailureOutcomes(testCase)

            command = helpers.BatchRunCommandStub();
            controller = BatchRunControllerTest.createController(command);
            command.RunResult = openmebius.application.batch ...
                .BatchExecutionResult(false, Canceled = true);

            canceled = controller.run(struct(), "result");

            command.RunResult = openmebius.application.batch ...
                .BatchExecutionResult( ...
                false, ...
                ErrorMessage = "One or more batch jobs failed.");
            failed = controller.run(struct(), "result");

            testCase.verifyTrue(canceled.isCanceled());
            testCase.verifyTrue(failed.isFailure());
            testCase.verifyEqual( ...
                failed.ErrorMessage, "One or more batch jobs failed.");
            testCase.verifyEmpty(failed.Exception);

        end

        function capturesAndCanRethrowExecutionFailure(testCase)

            command = helpers.BatchRunCommandStub();
            command.RunException = MException( ...
                "OpenMebius2:Test:BatchFailed", "Run failed.");
            controller = BatchRunControllerTest.createController(command);

            outcome = controller.run(struct(), "result");

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual(outcome.ErrorMessage, "Run failed.");
            testCase.verifyError( ...
                @() outcome.rethrowFailure(), ...
                "OpenMebius2:Test:BatchFailed");

        end

        function forwardsCancellation(testCase)

            command = helpers.BatchRunCommandStub();
            controller = BatchRunControllerTest.createController(command);

            controller.cancel(struct());

            testCase.verifyTrue(command.CancelCalled);

        end

        function forwardsExplicitRunReporters(testCase)

            recorder = helpers.BatchExecutionRecorder();
            fixedTime = datetime(2026, 1, 1);
            controller = openmebius.application.batch.BatchRunController( ...
                Runner = @runWithReporters, ...
                Clock = @() fixedTime);

            outcome = controller.run( ...
                struct(), ...
                "result", ...
                ProgressReporter = ...
                @(value) recorder.recordProgress(value), ...
                NotificationReporter = ...
                @(value) recorder.recordMessage(value), ...
                ResultReporter = ...
                @(value) recorder.recordResult(value));

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(recorder.Progress{1}, "progress");
            testCase.verifyEqual(recorder.MessageCount, 1);
            testCase.verifyEqual(recorder.ResultCount, 1);

            function result = runWithReporters(~, ~, reporters)
                reporters.Progress("progress");
                reporters.Notification("notification");
                reporters.Result("result");
                result = openmebius.application.batch ...
                    .BatchExecutionResult(true);
            end

        end

    end % methods (Test)

    methods (Static, Access = private)

        function controller = createController(command)

            fixedTime = datetime(2026, 1, 1);
            controller = openmebius.application.batch.BatchRunController( ...
                Runner = @(batch, resultDirectory) ...
                command.run(batch, resultDirectory), ...
                Canceler = @(batch) command.cancel(batch), ...
                Clock = @() fixedTime);

        end

    end % methods (Static, Access = private)

end % classdef
