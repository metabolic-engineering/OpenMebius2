classdef InstationaryInputSpecificationMapper
    % INSTATIONARYINPUTSPECIFICATIONMAPPER
    % Maps persisted Batch INST-MFA settings to a typed specification.

    methods (Static)

        function specification = fromBatchConfig(config)

            arguments
                config (1, 1) struct
            end

            if ~isfield(config, 'INSTMFA') || ...
                    ~isstruct(config.INSTMFA) || ...
                    ~isscalar(config.INSTMFA)
                openmebius.application.analysis ...
                    .InstationaryInputSpecificationMapper ...
                    .throwMissingConfiguration();
            end

            instationaryConfig = config.INSTMFA;

            if ~isfield(instationaryConfig, 'poolSize') || ...
                    ~isfield(instationaryConfig, 'timePoints')
                openmebius.application.analysis ...
                    .InstationaryInputSpecificationMapper ...
                    .throwMissingConfiguration();
            end

            poolMetabolites = strings(0, 1);

            if isfield(instationaryConfig, 'poolMetabolite') && ...
                    ~isempty(instationaryConfig.poolMetabolite)
                poolMetabolites = ...
                    string(instationaryConfig.poolMetabolite(:));
            end

            specification = openmebius.mfa ...
                .InstationaryInputSpecification( ...
                PoolMetabolites = poolMetabolites, ...
                PoolSizes = double(instationaryConfig.poolSize(:)), ...
                TimePoints = double(instationaryConfig.timePoints(:)));

        end % fromBatchConfig

    end % methods (Static)

    methods (Static, Access = private)

        function throwMissingConfiguration()

            error( ...
                "OpenMebius2:InstationaryInputSpecificationMapper:" + ...
                "MissingConfiguration", ...
                "INST-MFA configuration requires poolSize and " + ...
            "timePoints fields.");

        end

    end % methods (Static, Access = private)

end
