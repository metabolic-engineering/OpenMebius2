classdef OperationOutcome
    % OPERATIONOUTCOME Common success, cancellation, and failure contract.

    properties (SetAccess = private)
        Succeeded (1, 1) logical
        Canceled (1, 1) logical
        ErrorMessage (1, 1) string
        Exception
    end

    methods

        function obj = OperationOutcome(succeeded, options)

            arguments
                succeeded (1, 1) logical
                options.Canceled (1, 1) logical = false
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            if succeeded && options.Canceled
                error( ...
                    "OpenMebius2:OperationOutcome:InvalidState", ...
                "A successful operation cannot be canceled.");
            end

            obj.Succeeded = succeeded;
            obj.Canceled = options.Canceled;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Exception = options.Exception;

        end

        function tf = isSuccess(obj)
            tf = obj.Succeeded;
        end

        function tf = isCanceled(obj)
            tf = obj.Canceled;
        end

        function tf = isFailure(obj)
            tf = ~obj.Succeeded && ~obj.Canceled;
        end

        function rethrowFailure(obj)

            if ~obj.isFailure() || isempty(obj.Exception)
                return
            end

            rethrow(obj.Exception);

        end

    end

end
