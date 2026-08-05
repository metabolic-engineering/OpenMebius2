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

            try
                [fvaLowerBound, fvaUpperBound] = ...
                    openmebius.application.analysis ...
                    .MFAAnalysisSettingsMapper.mapFVABounds(config);
            catch ME
                result = openmebius.application.analysis ...
                    .MFAAnalysisSettingsMapper.failure( ...
                    "input", "FVA bounds", ME);
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
                FVALowerBound = fvaLowerBound, ...
                FVAUpperBound = fvaUpperBound, ...
                InstationaryInputSpecification = specification);
            result = openmebius.application.analysis ...
                .MFAAnalysisSettingsMappingResult.success(settings);

        end % tryFromBatchConfig

    end % methods (Static)

    methods (Static, Access = private)

        function [lowerBound, upperBound] = mapFVABounds(config)

            defaults = openmebius.domain.batch.BatchConfig ...
                .defaultConfig();
            lowerBound = defaults.fluxLB;
            upperBound = defaults.fluxUB;

            if isfield(config, 'fluxLB') && ~isempty(config.fluxLB)
                lowerBound = config.fluxLB;
            end

            if isfield(config, 'fluxUB') && ~isempty(config.fluxUB)
                upperBound = config.fluxUB;
            end

            if ~(isnumeric(lowerBound) || islogical(lowerBound)) || ...
                    ~isscalar(lowerBound) || ...
                    ~(isnumeric(upperBound) || islogical(upperBound)) || ...
                    ~isscalar(upperBound)
                error( ...
                    "OpenMebius2:MFAAnalysisSettingsMapper:" + ...
                    "InvalidFVABounds", ...
                "FVA bounds must be numeric scalars.");
            end

            lowerBound = double(lowerBound);
            upperBound = double(upperBound);

            if ~isfinite(lowerBound) || ~isfinite(upperBound) || ...
                    lowerBound > upperBound
                error( ...
                    "OpenMebius2:MFAAnalysisSettingsMapper:" + ...
                    "InvalidFVABounds", ...
                    "FVA bounds must be finite and the lower bound " + ...
                "must not exceed the upper bound.");
            end

        end % mapFVABounds

        function result = failure(stage, context, exception)

            message = "Invalid " + string(context) + ...
                " settings: " + string(exception.message);
            result = openmebius.application.analysis ...
                .MFAAnalysisSettingsMappingResult.failure( ...
                stage, message);

        end

    end % methods (Static, Access = private)

end
