classdef ExperimentValidationReport
    % EXPERIMENTVALIDATIONREPORT Result of an experiment data operation.

    properties (SetAccess = private)
        IsValid (1, 1) logical
        ErrorMessage (1, 1) string
        Messages (:, 1) string
        Warnings (:, 1) string
    end

    methods

        function obj = ExperimentValidationReport(options)

            arguments
                options.IsValid (1, 1) logical
                options.ErrorMessage (1, 1) string = ""
                options.Messages (:, 1) string = strings(0, 1)
                options.Warnings (:, 1) string = strings(0, 1)
            end

            if options.IsValid && options.ErrorMessage ~= ""
                error( ...
                    "OpenMebius2:ExperimentValidationReport:" + ...
                    "UnexpectedErrorMessage", ...
                "A valid report cannot contain an error message.");
            end

            if ~options.IsValid && options.ErrorMessage == ""
                error( ...
                    "OpenMebius2:ExperimentValidationReport:" + ...
                    "MissingErrorMessage", ...
                "An invalid report must contain an error message.");
            end

            obj.IsValid = options.IsValid;
            obj.ErrorMessage = options.ErrorMessage;
            obj.Messages = options.Messages(:);
            obj.Warnings = options.Warnings(:);

        end % constructor

    end % methods

    methods (Static)

        function obj = success(message, options)

            arguments
                message (1, 1) string = ""
                options.Warnings (:, 1) string = strings(0, 1)
            end

            messages = strings(0, 1);

            if message ~= ""
                messages = message;
            end

            obj = openmebius.domain.experiment ...
                .ExperimentValidationReport( ...
                IsValid = true, ...
                Messages = messages, ...
                Warnings = options.Warnings);

        end % success

        function obj = failure(errorMessage, options)

            arguments
                errorMessage (1, 1) string
                options.Warnings (:, 1) string = strings(0, 1)
            end

            obj = openmebius.domain.experiment ...
                .ExperimentValidationReport( ...
                IsValid = false, ...
                ErrorMessage = errorMessage, ...
                Warnings = options.Warnings);

        end % failure

    end % methods (Static)

end % classdef
