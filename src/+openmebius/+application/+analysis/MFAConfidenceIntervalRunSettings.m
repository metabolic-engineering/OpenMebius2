classdef MFAConfidenceIntervalRunSettings
    % MFACONFIDENCEINTERVALRUNSETTINGS Application settings for one CI run.

    properties (SetAccess = private)
        ConfidenceIntervalSettings (1, 1) openmebius.mfa ...
            .ConfidenceIntervalSettings
        IterationSettings (1, 1) openmebius.mfa.MFAIterationSettings
    end

    methods

        function obj = MFAConfidenceIntervalRunSettings(options)

            arguments
                options.ConfidenceIntervalSettings (1, 1) ...
                    openmebius.mfa.ConfidenceIntervalSettings = ...
                    openmebius.mfa.ConfidenceIntervalSettings()
                options.IterationSettings (1, 1) openmebius.mfa ...
                    .MFAIterationSettings = ...
                    openmebius.mfa.MFAIterationSettings()
            end

            obj.ConfidenceIntervalSettings = ...
                options.ConfidenceIntervalSettings;
            obj.IterationSettings = options.IterationSettings ...
                .withAnalysisMode( ...
                openmebius.mfa.MFAAnalysisMode.SteadyState);

        end

    end

end
