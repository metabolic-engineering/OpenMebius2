classdef MFAConfidenceIntervalRunSettingsMapper
    % MFACONFIDENCEINTERVALRUNSETTINGSMAPPER Maps Batch config at boundary.

    methods (Static)

        function settings = fromBatchConfig(config)

            arguments
                config (1, 1) struct
            end

            iterationConfig = config;

            if ~isfield(iterationConfig, 'isINSTMFA') || ...
                    isempty(iterationConfig.isINSTMFA)
                iterationConfig.isINSTMFA = false;
            end

            settings = openmebius.application.analysis ...
                .MFAConfidenceIntervalRunSettings( ...
                ConfidenceIntervalSettings = ...
                    openmebius.application.analysis ...
                    .ConfidenceIntervalSettingsMapper ...
                    .fromBatchConfig(config), ...
                IterationSettings = openmebius.application.analysis ...
                    .MFAIterationSettingsMapper.fromBatchConfig( ...
                    iterationConfig));

        end

    end

end
