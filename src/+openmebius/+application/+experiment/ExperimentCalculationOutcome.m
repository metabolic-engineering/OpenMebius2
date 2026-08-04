classdef ExperimentCalculationOutcome < openmebius.application.OperationOutcome
    % EXPERIMENTCALCULATIONOUTCOME Result of an MDV calculation command.

    properties (SetAccess = private)
        Result
    end

    methods

        function obj = ExperimentCalculationOutcome(succeeded, options)

            arguments
                succeeded (1, 1) logical
                options.Result = []
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj@openmebius.application.OperationOutcome( ...
                succeeded, ...
                ErrorMessage = options.ErrorMessage, ...
                Exception = options.Exception);
            obj.Result = options.Result;

        end % constructor

    end % methods

end % classdef
