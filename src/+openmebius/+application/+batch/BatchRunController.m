classdef BatchRunController < handle
    % BATCHRUNCONTROLLER Coordinates a user-requested complete batch run.

    properties (Access = private)
        Runner (1, 1) function_handle = @(~, ~) "error"
        Canceler (1, 1) function_handle = @(~) []
        Clock (1, 1) function_handle = @() datetime("now")
    end

    methods

        function obj = BatchRunController(options)

            arguments
                options.Runner (1, 1) function_handle = ...
                    @(batch, resultDirectory) ...
                    runBatch(batch, resultDirectory)
                options.Canceler (1, 1) function_handle = ...
                    @(batch) cancelBatch(batch)
                options.Clock (1, 1) function_handle = @() datetime("now")
            end

            obj.Runner = options.Runner;
            obj.Canceler = options.Canceler;
            obj.Clock = options.Clock;

        end % constructor

        function outcome = run(obj, batch, resultDirectory)

            startedAt = obj.Clock();

            try
                status = obj.normalizeStatus( ...
                    obj.Runner(batch, resultDirectory));
                elapsedTime = obj.Clock() - startedAt;

                switch status
                    case "finished"
                        outcome = openmebius.application.batch ...
                            .BatchRunOutcome(status, elapsedTime);

                    case "canceled"
                        outcome = openmebius.application.batch ...
                            .BatchRunOutcome(status, elapsedTime);

                    case "error"
                        outcome = openmebius.application.batch ...
                            .BatchRunOutcome( ...
                                status, ...
                                elapsedTime, ...
                                ErrorMessage = ...
                                    "One or more batch jobs failed.");
                end
            catch exception
                outcome = openmebius.application.batch.BatchRunOutcome( ...
                    "error", ...
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

        function status = normalizeStatus(status)

            status = lower(strtrim(string(status)));

            if ~isscalar(status) || ...
                    ~ismember(status, ["finished", "canceled", "error"])
                error( ...
                    "OpenMebius2:BatchRunController:UnknownStatus", ...
                    "Batch execution returned an unsupported status.");
            end

        end % normalizeStatus

    end % methods (Static, Access = private)

end % classdef
