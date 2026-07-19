classdef BatchRunController < handle
    % BATCHRUNCONTROLLER Coordinates a user-requested complete batch run.

    properties (Access = private)
        Runner (1, 1) function_handle = @(~, ~) ...
            openmebius.application.batch.BatchExecutionResult(false)
        Canceler (1, 1) function_handle = @(~) []
        Clock (1, 1) function_handle = @() datetime("now")
    end

    methods

        function obj = BatchRunController(options)

            arguments
                options.Runner (1, 1) function_handle = ...
                    @(batch, resultDirectory, reporters) ...
                    runBatch( ...
                        batch, ...
                        resultDirectory, ...
                        ProgressReporter = reporters.Progress, ...
                        NotificationReporter = reporters.Notification, ...
                        ResultReporter = reporters.Result)
                options.Canceler (1, 1) function_handle = ...
                    @(batch) cancelBatch(batch)
                options.Clock (1, 1) function_handle = @() datetime("now")
            end

            obj.Runner = options.Runner;
            obj.Canceler = options.Canceler;
            obj.Clock = options.Clock;

        end % constructor

        function outcome = run(obj, batch, resultDirectory, options)

            arguments
                obj (1, 1) openmebius.application.batch.BatchRunController
                batch
                resultDirectory
                options.ProgressReporter (1, 1) function_handle = @(~) []
                options.NotificationReporter (1, 1) function_handle = @(~) []
                options.ResultReporter (1, 1) function_handle = @(~) []
            end

            startedAt = obj.Clock();

            try
                reporters = struct( ...
                    Progress = options.ProgressReporter, ...
                    Notification = options.NotificationReporter, ...
                    Result = options.ResultReporter);
                execution = obj.executeRunner( ...
                    batch, resultDirectory, reporters);
                obj.assertExecutionResult(execution);
                elapsedTime = obj.Clock() - startedAt;

                if execution.isSuccess()
                    outcome = openmebius.application.batch ...
                        .BatchRunOutcome(true, elapsedTime);
                elseif execution.isCanceled()
                    outcome = openmebius.application.batch ...
                        .BatchRunOutcome( ...
                            false, elapsedTime, Canceled = true);
                else
                    outcome = openmebius.application.batch ...
                        .BatchRunOutcome( ...
                            false, ...
                            elapsedTime, ...
                            ErrorMessage = execution.ErrorMessage, ...
                            Exception = execution.Exception);
                end
            catch exception
                outcome = openmebius.application.batch.BatchRunOutcome( ...
                    false, ...
                    obj.Clock() - startedAt, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end % run

        function cancel(obj, batch)

            obj.Canceler(batch);

        end % cancel

    end % methods

    methods (Static, Access = private)

        function assertExecutionResult(result)

            if ~isa(result, ...
                    'openmebius.application.batch.BatchExecutionResult')
                error( ...
                    "OpenMebius2:BatchRunController:InvalidResult", ...
                    "Batch execution must return BatchExecutionResult.");
            end

        end % assertExecutionResult

    end % methods (Static, Access = private)

    methods (Access = private)

        function result = executeRunner( ...
                obj, batch, resultDirectory, reporters)

            if nargin(obj.Runner) == 2
                result = obj.Runner(batch, resultDirectory);
                return
            end

            result = obj.Runner(batch, resultDirectory, reporters);

        end % executeRunner

    end % methods (Access = private)

end % classdef
