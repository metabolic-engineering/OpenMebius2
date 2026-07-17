classdef ResultOperationOutcome
    % RESULTOPERATIONOUTCOME Result of a result-area command.

    properties (SetAccess = private)
        Status (1, 1) string
        Result
        ErrorMessage (1, 1) string
        Exception
    end

    methods

        function obj = ResultOperationOutcome(status, options)

            arguments
                status (1, 1) string {mustBeMember( ...
                    status, ["finished", "error"])}
                options.Result = []
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj.Status = status;
            obj.Result = options.Result;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Exception = options.Exception;

        end % constructor

    end % methods

end % classdef
