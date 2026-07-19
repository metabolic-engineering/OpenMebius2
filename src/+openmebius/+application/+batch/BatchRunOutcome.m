classdef BatchRunOutcome < openmebius.application.OperationOutcome
    % BATCHRUNOUTCOME Result of one complete batch-run command.

    properties (SetAccess = private)
        ElapsedTime (1, 1) duration
    end

    methods

        function obj = BatchRunOutcome(succeeded, elapsedTime, options)

            arguments
                succeeded (1, 1) logical
                elapsedTime (1, 1) duration
                options.Canceled (1, 1) logical = false
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj@openmebius.application.OperationOutcome( ...
                succeeded, ...
                Canceled = options.Canceled, ...
                ErrorMessage = options.ErrorMessage, ...
                Exception = options.Exception);
            obj.ElapsedTime = elapsedTime;

        end % constructor

    end % methods

end % classdef
