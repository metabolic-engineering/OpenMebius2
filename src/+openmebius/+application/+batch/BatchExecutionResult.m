classdef BatchExecutionResult < openmebius.application.OperationOutcome
    % BATCHEXECUTIONRESULT Result returned by the batch execution pipeline.

    methods

        function obj = BatchExecutionResult(succeeded, options)

            arguments
                succeeded (1, 1) logical
                options.Canceled (1, 1) logical = false
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj@openmebius.application.OperationOutcome( ...
                succeeded, ...
                Canceled = options.Canceled, ...
                ErrorMessage = options.ErrorMessage, ...
                Exception = options.Exception);

        end

    end

end
