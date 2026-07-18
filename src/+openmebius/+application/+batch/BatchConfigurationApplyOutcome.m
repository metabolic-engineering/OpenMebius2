classdef BatchConfigurationApplyOutcome
    % BATCHCONFIGURATIONAPPLYOUTCOME Result of applying RunConfig edits.

    properties (SetAccess = private)
        Status (1, 1) string
        ErrorMessage (1, 1) string
        Exception
    end

    methods

        function obj = BatchConfigurationApplyOutcome(status, options)

            arguments
                status (1, 1) string {mustBeMember( ...
                    status, ["finished", "error"])}
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj.Status = status;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Exception = options.Exception;

        end % constructor

    end % methods

end % classdef
