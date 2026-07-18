classdef LabelConfigurationLaunchOutcome
    % LABELCONFIGURATIONLAUNCHOUTCOME LabelConfig preparation result.

    properties (SetAccess = private)
        Status (1, 1) string
        State
        ErrorMessage (1, 1) string
        Exception
    end

    methods

        function obj = LabelConfigurationLaunchOutcome(status, options)

            arguments
                status (1, 1) string {mustBeMember( ...
                    status, ["finished", "error"])}
                options.State = []
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj.Status = status;
            obj.State = options.State;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Exception = options.Exception;

        end % constructor

    end % methods

end % classdef
