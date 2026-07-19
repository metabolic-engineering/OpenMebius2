classdef BatchConfigurationApplyOutcome < openmebius.application.OperationOutcome
    % BATCHCONFIGURATIONAPPLYOUTCOME Result of applying RunConfig edits.

    properties (SetAccess = private)
    end

    methods

        function obj = BatchConfigurationApplyOutcome(succeeded, options)

            arguments
                succeeded (1, 1) logical
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj@openmebius.application.OperationOutcome( ...
                succeeded, ...
                ErrorMessage = options.ErrorMessage, ...
                Exception = options.Exception);

        end % constructor

    end % methods

end % classdef
