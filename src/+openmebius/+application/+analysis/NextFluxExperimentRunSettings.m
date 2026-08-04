classdef NextFluxExperimentRunSettings
    % NEXTFLUXEXPERIMENTRUNSETTINGS Settings for next-flux suggestion.

    properties (SetAccess = private)
        ConfidenceIntervalRunSettings (1, 1) openmebius.application ...
            .analysis.MFAConfidenceIntervalRunSettings
        NextLabelSettings (1, 1) openmebius.mfa ...
            .NextLabelExperimentSettings
    end

    methods

        function obj = NextFluxExperimentRunSettings(options)

            arguments
                options.ConfidenceIntervalRunSettings (1, 1) ...
                    openmebius.application.analysis ...
                    .MFAConfidenceIntervalRunSettings = ...
                    openmebius.application.analysis ...
                    .MFAConfidenceIntervalRunSettings()
                options.NextLabelSettings (1, 1) openmebius.mfa ...
                    .NextLabelExperimentSettings = ...
                    openmebius.mfa.NextLabelExperimentSettings()
            end

            obj.ConfidenceIntervalRunSettings = ...
                options.ConfidenceIntervalRunSettings;
            obj.NextLabelSettings = options.NextLabelSettings;

        end

    end

end
