classdef MFAInputValidationResult
    % MFAINPUTVALIDATIONRESULT
    % Immutable outcome of validating one MFA input group.

    properties (SetAccess = private)
        IsValid (1, 1) logical
        ErrorMessage (1, 1) string
        Value (1, 1) struct
    end

    methods

        function obj = MFAInputValidationResult(options)

            arguments
                options.IsValid (1, 1) logical
                options.ErrorMessage (1, 1) string = ""
                options.Value (1, 1) struct = struct
            end

            if options.IsValid && strlength(options.ErrorMessage) > 0
                error( ...
                    "OpenMebius2:MFAInputValidation:" + ...
                    "UnexpectedErrorMessage", ...
                    "A successful validation result cannot contain an " + ...
                "error message.");
            end

            if ~options.IsValid && strlength(options.ErrorMessage) == 0
                error( ...
                    "OpenMebius2:MFAInputValidation:" + ...
                    "MissingErrorMessage", ...
                    "A failed validation result must contain an error " + ...
                "message.");
            end

            obj.IsValid = options.IsValid;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Value = options.Value;

        end % constructor

    end % methods

    methods (Static)

        function result = success(value)

            arguments
                value (1, 1) struct = struct
            end

            result = openmebius.mfa.MFAInputValidationResult( ...
                IsValid = true, ...
                Value = value);

        end % success

        function result = failure(message)

            arguments
                message (1, 1) string
            end

            result = openmebius.mfa.MFAInputValidationResult( ...
                IsValid = false, ...
                ErrorMessage = message);

        end % failure

    end % methods (Static)

end % classdef
