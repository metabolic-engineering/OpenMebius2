classdef ExperimentImportOutcome
    % EXPERIMENTIMPORTOUTCOME Result of an experiment import command.

    properties (SetAccess = private)
        Status (1, 1) string
        Result
        ErrorMessage (1, 1) string
        Exception
    end

    methods

        function obj = ExperimentImportOutcome(status, options)

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

        function rethrowFailure(obj)

            if obj.Status ~= "error" || isempty(obj.Exception)
                return
            end

            rethrow(obj.Exception);

        end % rethrowFailure

    end % methods

end % classdef
