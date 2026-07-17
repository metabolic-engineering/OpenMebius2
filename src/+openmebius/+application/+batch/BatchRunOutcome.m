classdef BatchRunOutcome
    % BATCHRUNOUTCOME Result of one complete batch-run command.

    properties (SetAccess = private)
        Status (1, 1) string
        ElapsedTime (1, 1) duration
        ErrorMessage (1, 1) string
        Exception
    end

    methods

        function obj = BatchRunOutcome(status, elapsedTime, options)

            arguments
                status (1, 1) string {mustBeMember( ...
                    status, ["finished", "canceled", "error"])}
                elapsedTime (1, 1) duration
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj.Status = status;
            obj.ElapsedTime = elapsedTime;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Exception = options.Exception;

        end % constructor

        function rethrowFailure(obj)

            if obj.Status ~= "error" || isempty(obj.Exception)
                return
            end

            rethrow(obj.Exception);

        end % rethrowFailure

    end % methods

end % classdef
