classdef BatchRunControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function returnsNormalizedFinishedOutcome(testCase)

            command = helpers.BatchRunCommandStub();
            command.RunStatus = " FINISHED ";
            controller = BatchRunControllerTest.createController(command);

            outcome = controller.run(struct(), "result");

            testCase.verifyTrue(command.RunCalled);
            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyEqual(outcome.ElapsedTime, seconds(0));
            testCase.verifyEmpty(outcome.Exception);

        end

        function preservesCanceledAndReturnedErrorStatuses(testCase)

            command = helpers.BatchRunCommandStub();
            controller = BatchRunControllerTest.createController(command);
            command.RunStatus = "canceled";

            canceled = controller.run(struct(), "result");

            command.RunStatus = "error";
            failed = controller.run(struct(), "result");

            testCase.verifyEqual(canceled.Status, "canceled");
            testCase.verifyEqual(failed.Status, "error");
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

            testCase.verifyEqual(outcome.Status, "error");
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
