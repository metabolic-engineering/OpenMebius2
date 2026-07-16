classdef InitialFluxSettingsMapper
    % INITIALFLUXSETTINGSMAPPER
    % Maps persisted Batch configuration to typed initial-flux settings.

    methods (Static)

        function settings = fromBatchConfig(config)

            arguments
                config (1, 1) struct
            end

            if ~isfield(config, 'iteration') || ...
                    isempty(config.iteration)
                error( ...
                    "OpenMebius2:InitialFluxSettingsMapper:" + ...
                    "MissingIterationCount", ...
                    "Batch configuration requires an iteration count.");
            end

            candidate = config.iteration;

            if ~(isnumeric(candidate) || islogical(candidate)) || ...
                    ~isscalar(candidate)
                error( ...
                    "OpenMebius2:InitialFluxSettingsMapper:" + ...
                    "InvalidIterationCount", ...
                    "Batch iteration count must be a numeric scalar.");
            end

            settings = openmebius.mfa.InitialFluxSettings( ...
                IterationCount = double(candidate));

        end % fromBatchConfig

    end % methods (Static)

end
