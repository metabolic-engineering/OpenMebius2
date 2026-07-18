classdef BatchConfigurationLaunchOutcome
    % BATCHCONFIGURATIONLAUNCHOUTCOME Session preparation result.

    properties (SetAccess = private)
        Status (1, 1) string
        Session
        ErrorMessage (1, 1) string
        Exception
    end

    methods

        function obj = BatchConfigurationLaunchOutcome(status, options)

            arguments
                status (1, 1) string {mustBeMember( ...
                    status, ["finished", "error"])}
                options.Session = []
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj.Status = status;
            obj.Session = options.Session;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Exception = options.Exception;

        end % constructor

    end % methods

end % classdef
