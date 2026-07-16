classdef InstationaryInputFactory
    % INSTATIONARYINPUTFACTORY
    % Aligns configured pool sizes to the EMU model metabolite order.

    methods

        function input = create(~, model, specification)

            arguments
                ~
                model
                specification (1, 1) openmebius.mfa ...
                    .InstationaryInputSpecification
            end

            modelMetabolites = ...
                string(model.getMetaboliteTableMetabolite());
            modelMetabolites = modelMetabolites(:);

            if isempty(modelMetabolites)
                error( ...
                    "OpenMebius2:InstationaryInputFactory:" + ...
                    "MissingModelMetabolites", ...
                    "No model metabolites are available for INST-MFA " + ...
                    "pool-size alignment.");
            end

            configuredPoolSizes = specification.PoolSizes;
            poolSizes = ...
                openmebius.mfa.InstationaryInputFactory.alignPoolSizes( ...
                modelMetabolites, configuredPoolSizes, ...
                specification.PoolMetabolites);
            input = openmebius.mfa.InstationaryInput( ...
                PoolSizes = poolSizes, ...
                TimePoints = specification.TimePoints);

        end % create

    end % methods

    methods (Static, Access = private)

        function poolSizes = alignPoolSizes( ...
                modelMetabolites, configuredPoolSizes, ...
                configuredMetabolites)

            hasMetaboliteNames = ~isempty(configuredMetabolites);

            if ~hasMetaboliteNames
                if numel(configuredPoolSizes) ~= numel(modelMetabolites)
                    error( ...
                        "OpenMebius2:InstationaryInputFactory:" + ...
                        "PoolSizeCountMismatch", ...
                        "The number of INST-MFA pool-size values must " + ...
                        "match the number of model metabolites.");
                end

                poolSizes = configuredPoolSizes;
                return;
            end

            if numel(configuredMetabolites) ~= ...
                    numel(configuredPoolSizes)
                error( ...
                    "OpenMebius2:InstationaryInputFactory:" + ...
                    "ConfiguredPoolSizeCountMismatch", ...
                    "The number of INST-MFA pool-size metabolites must " + ...
                    "match the number of pool-size values.");
            end

            poolSizes = nan(numel(modelMetabolites), 1);

            for i = 1:numel(modelMetabolites)
                matchedIndex = find( ...
                    configuredMetabolites == modelMetabolites(i), ...
                    1, ...
                    "first");

                if ~isempty(matchedIndex)
                    poolSizes(i) = configuredPoolSizes(matchedIndex);
                end
            end

            missingMetabolites = modelMetabolites(isnan(poolSizes));

            if ~isempty(missingMetabolites)
                error( ...
                    "OpenMebius2:InstationaryInputFactory:" + ...
                    "MissingPoolSizes", ...
                    "INST-MFA pool sizes are missing for: %s.", ...
                    strjoin(missingMetabolites, ", "));
            end

        end % alignPoolSizes

    end % methods (Static, Access = private)

end % classdef
