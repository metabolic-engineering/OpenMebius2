classdef LabelConfigurationLaunchOutcome < openmebius.application.OperationOutcome
    % LABELCONFIGURATIONLAUNCHOUTCOME LabelConfig preparation result.

    properties (SetAccess = private)
        State
    end

    methods

        function obj = LabelConfigurationLaunchOutcome(succeeded, options)

            arguments
                succeeded (1, 1) logical
                options.State = []
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj@openmebius.application.OperationOutcome( ...
                succeeded, ...
                ErrorMessage = options.ErrorMessage, ...
                Exception = options.Exception);
            obj.State = options.State;

        end % constructor

    end % methods

end % classdef
