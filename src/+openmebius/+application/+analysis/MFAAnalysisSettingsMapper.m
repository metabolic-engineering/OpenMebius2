classdef MFAAnalysisSettingsMapper
    % MFAANALYSISSETTINGSMAPPER
    % Maps one persisted Batch configuration at the application boundary.

    methods (Static)

        function result = tryFromBatchConfig(config)

            arguments
                config (1, 1) struct
            end

            try
                preparationSettings = openmebius.application.analysis ...
                    .MFAInputPreparationSettingsMapper ...
                    .fromBatchConfig(config);
            catch ME
                result = openmebius.application.analysis ...
                    .MFAAnalysisSettingsMapper.failure( ...
                    "input", "input preparation", ME);
                return
            end

            try
                initialFluxSettings = openmebius.application.analysis ...
                    .InitialFluxSettingsMapper.fromBatchConfig(config);
            catch ME
                result = openmebius.application.analysis ...
                    .MFAAnalysisSettingsMapper.failure( ...
                    "initial", "initial flux", ME);
                return
            end

            try
                iterationSettings = openmebius.application.analysis ...
                    .MFAIterationSettingsMapper.fromBatchConfig(config);
            catch ME
                result = openmebius.application.analysis ...
                    .MFAAnalysisSettingsMapper.failure( ...
                    "input", "iteration", ME);
                return
            end

            specification = [];

            if iterationSettings.AnalysisMode.isInstationary()
                try
                    specification = openmebius.application.analysis ...
                        .InstationaryInputSpecificationMapper ...
                        .fromBatchConfig(config);
                catch ME
                    result = openmebius.application.analysis ...
                        .MFAAnalysisSettingsMapper.failure( ...
                        "instationary", "instationary input", ME);
                    return
                end
            end

            settings = openmebius.application.analysis ...
                .MFAAnalysisSettings( ...
                InputPreparationSettings = preparationSettings, ...
                InitialFluxSettings = initialFluxSettings, ...
                IterationSettings = iterationSettings, ...
                InstationaryInputSpecification = specification);
            result = openmebius.application.analysis ...
                .MFAAnalysisSettingsMappingResult.success(settings);

        end % tryFromBatchConfig

    end % methods (Static)

    methods (Static, Access = private)

        function result = failure(stage, context, exception)

            message = "Invalid " + string(context) + ...
                " settings: " + string(exception.message);
            result = openmebius.application.analysis ...
                .MFAAnalysisSettingsMappingResult.failure( ...
                stage, message);

        end

    end % methods (Static, Access = private)

end
