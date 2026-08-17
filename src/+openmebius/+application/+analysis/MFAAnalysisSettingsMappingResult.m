classdef MFAAnalysisSettingsMappingResult
    % MFAANALYSISSETTINGSMAPPINGRESULT
    % Successful settings or a classified configuration failure.

    properties (SetAccess = private)
        Settings = []
        IsValid (1, 1) logical
        FailureStage (1, 1) string
        ErrorMessage (1, 1) string
    end

    methods

        function obj = MFAAnalysisSettingsMappingResult(options)

            arguments
                options.Settings = []
                options.IsValid (1, 1) logical
                options.FailureStage (1, 1) string {mustBeMember( ...
                    options.FailureStage, ...
                    ["", "input", "initial", "instationary"])} = ""
                options.ErrorMessage (1, 1) string = ""
            end

            hasSettings = isa( ...
                options.Settings, ...
                'openmebius.application.analysis.MFAAnalysisSettings');
            hasFailure = options.FailureStage ~= "" && ...
                strlength(options.ErrorMessage) > 0;

            if options.IsValid ~= hasSettings || ...
                    options.IsValid == hasFailure
                error( ...
                    "OpenMebius2:MFAAnalysisSettingsMapping:" + ...
                    "InconsistentResult", ...
                    "A successful mapping must contain settings and a " + ...
                    "failed mapping must contain a classified error.");
            end

            obj.Settings = options.Settings;
            obj.IsValid = options.IsValid;
            obj.FailureStage = options.FailureStage;
            obj.ErrorMessage = options.ErrorMessage;

        end

    end

    methods (Static)

        function result = success(settings)

            result = openmebius.application.analysis ...
                .MFAAnalysisSettingsMappingResult( ...
                Settings = settings, ...
                IsValid = true);

        end

        function result = failure(stage, message)

            result = openmebius.application.analysis ...
                .MFAAnalysisSettingsMappingResult( ...
                IsValid = false, ...
                FailureStage = string(stage), ...
                ErrorMessage = string(message));

        end

    end

end
