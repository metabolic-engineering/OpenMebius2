classdef BatchConfigurationLaunchOutcome < openmebius.application.OperationOutcome
    % BATCHCONFIGURATIONLAUNCHOUTCOME Session preparation result.

    properties (SetAccess = private)
        Session
    end

    methods

        function obj = BatchConfigurationLaunchOutcome(succeeded, options)

            arguments
                succeeded (1, 1) logical
                options.Session = []
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj@openmebius.application.OperationOutcome( ...
                succeeded, ...
                ErrorMessage = options.ErrorMessage, ...
                Exception = options.Exception);
            obj.Session = options.Session;

        end % constructor

    end % methods

end % classdef
