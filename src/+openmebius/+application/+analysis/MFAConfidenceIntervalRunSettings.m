classdef MFAConfidenceIntervalRunSettings
    % MFACONFIDENCEINTERVALRUNSETTINGS Application settings for one CI run.

    properties (SetAccess = private)
        ConfidenceIntervalSettings (1, 1) openmebius.mfa ...
            .ConfidenceIntervalSettings
        IterationSettings (1, 1) openmebius.mfa.MFAIterationSettings
        GridSearchSelectedReactionIDs (:, 1) string
        UseAllGridSearchReactions (1, 1) logical
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
                options.GridSearchSelectedReactionIDs (:, 1) string = ...
                    strings(0, 1)
                options.UseAllGridSearchReactions ...
                    (1, 1) logical = true
            end

            obj.ConfidenceIntervalSettings = ...
                options.ConfidenceIntervalSettings;
            obj.IterationSettings = options.IterationSettings ...
                .withAnalysisMode( ...
                openmebius.mfa.MFAAnalysisMode.SteadyState);
            obj.GridSearchSelectedReactionIDs = ...
                options.GridSearchSelectedReactionIDs;
            obj.UseAllGridSearchReactions = ...
                options.UseAllGridSearchReactions;

        end

    end

end
