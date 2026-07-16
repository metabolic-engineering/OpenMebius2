classdef ModelValidationReport
    % MODELVALIDATIONREPORT Result of validating a model edit operation.

    properties (SetAccess = private)
        IsValid (1, 1) logical
        ErrorMessage (1, 1) string
        Messages (:, 1) string
        Warnings (:, 1) string
        InvalidRows (:, 1) double
    end

    methods

        function obj = ModelValidationReport(options)

            arguments
                options.IsValid (1, 1) logical
                options.ErrorMessage (1, 1) string = ""
                options.Messages (:, 1) string = strings(0, 1)
                options.Warnings (:, 1) string = strings(0, 1)
                options.InvalidRows (:, 1) double = zeros(0, 1)
            end

            if options.IsValid && options.ErrorMessage ~= ""
                error( ...
                    "OpenMebius2:ModelValidationReport:" + ...
                    "UnexpectedErrorMessage", ...
                    "A valid report cannot contain an error message.");
            end

            if ~options.IsValid && options.ErrorMessage == ""
                error( ...
                    "OpenMebius2:ModelValidationReport:" + ...
                    "MissingErrorMessage", ...
                    "An invalid report must contain an error message.");
            end

            invalidRows = unique(options.InvalidRows(:), "stable");

            if any(~isfinite(invalidRows)) || ...
                    any(invalidRows < 1) || ...
                    any(fix(invalidRows) ~= invalidRows)
                error( ...
                    "OpenMebius2:ModelValidationReport:InvalidRows", ...
                    "Invalid row indices must be positive integers.");
            end

            obj.IsValid = options.IsValid;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Messages = options.Messages(:);
            obj.Warnings = options.Warnings(:);
            obj.InvalidRows = invalidRows;

        end % constructor

    end % methods

    methods (Static)

        function obj = success(message, options)

            arguments
                message (1, 1) string = ""
                options.Warnings (:, 1) string = strings(0, 1)
                options.InvalidRows (:, 1) double = zeros(0, 1)
            end

            messages = strings(0, 1);

            if message ~= ""
                messages = message;
            end

            obj = openmebius.domain.model.ModelValidationReport( ...
                IsValid = true, ...
                Messages = messages, ...
                Warnings = options.Warnings, ...
                InvalidRows = options.InvalidRows);

        end % success

        function obj = failure(errorMessage, options)

            arguments
                errorMessage (1, 1) string
                options.Warnings (:, 1) string = strings(0, 1)
                options.InvalidRows (:, 1) double = zeros(0, 1)
            end

            obj = openmebius.domain.model.ModelValidationReport( ...
                IsValid = false, ...
                ErrorMessage = errorMessage, ...
                Warnings = options.Warnings, ...
                InvalidRows = options.InvalidRows);

        end % failure

    end % methods (Static)

end % classdef
