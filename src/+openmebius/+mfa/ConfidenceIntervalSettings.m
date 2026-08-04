classdef ConfidenceIntervalSettings
    % CONFIDENCEINTERVALSETTINGS Typed settings for CI calculation.

    properties (SetAccess = private)
        Enabled (1, 1) logical
        Method (1, 1) openmebius.mfa.ConfidenceIntervalMethod
        MonteCarloSettings (1, 1) openmebius.mfa ...
            .MonteCarloConfidenceIntervalSettings
        GridSearchSettings (1, 1) openmebius.mfa ...
            .GridSearchConfidenceIntervalSettings
    end

    methods

        function obj = ConfidenceIntervalSettings(options)

            arguments
                options.Enabled (1, 1) logical = false
                options.Method (1, 1) openmebius.mfa ...
                    .ConfidenceIntervalMethod = openmebius.mfa ...
                    .ConfidenceIntervalMethod.MonteCarlo
                options.MonteCarloSettings (1, 1) openmebius.mfa ...
                    .MonteCarloConfidenceIntervalSettings = ...
                    openmebius.mfa ...
                    .MonteCarloConfidenceIntervalSettings()
                options.GridSearchSettings (1, 1) openmebius.mfa ...
                    .GridSearchConfidenceIntervalSettings = ...
                    openmebius.mfa ...
                    .GridSearchConfidenceIntervalSettings()
            end

            obj.Enabled = options.Enabled;
            obj.Method = options.Method;
            obj.MonteCarloSettings = options.MonteCarloSettings;
            obj.GridSearchSettings = options.GridSearchSettings;

        end

    end

end
