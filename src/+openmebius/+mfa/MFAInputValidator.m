classdef MFAInputValidator
    % MFAINPUTVALIDATOR
    % Validates and aligns MFA efflux and experimental MDV inputs.

    methods

        function result = validateEfflux( ...
                ~, model, experiments, experimentList, config)

            info = experiments.getInfoTable();

            if isempty(info)
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "No information available for efflux validation.");
                return;
            end

            try
                growthRate = mean(info{experimentList, "mu"}, 1);
            catch
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "Information table is not valid.");
                return;
            end

            if ~all(growthRate > 0)
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "No growth rate available for efflux validation.");
                return;
            end

            try
                stoichiometry = model.getSBefore();
                reactionIDs = string( ...
                    stoichiometry.Properties.RowNames(:));
                reactionTypes = string(model.getSType());
                reactionTypes = reactionTypes(:);

                if numel(reactionIDs) ~= numel(reactionTypes)
                    result = openmebius.mfa ...
                        .MFAInputValidationResult.failure( ...
                        "Reaction identifiers and types do not match.");
                    return;
                end

                effluxReactionIDs = ...
                    reactionIDs(reactionTypes == "efflux");
                substrates = strings(numel(effluxReactionIDs), 1);

                for i = 1:numel(effluxReactionIDs)
                    substrates(i) = string( ...
                        model.getSubstrateNameFromRxnID( ...
                        effluxReactionIDs(i)));
                end
            catch
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "Model data is not valid for efflux validation.");
                return;
            end

            if numel(unique(substrates)) ~= numel(substrates)
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "Substrates were duplicated.");
                return;
            end

            try
                uptake = experiments.getUptakeTable();
                efflux = mean( ...
                    uptake{experimentList, substrates}, 1).';
            catch
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "Efflux data is not valid.");
                return;
            end

            if any(isnan(efflux))
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "Some efflux values are NaN. Please check the " + ...
                    "experimental data.");
                return;
            end

            standardDeviations = zeros(0, 1);
            freeMask = false(0, 1);
            isPerturbated = isfield(config, "perturbateEfflux") && ...
                isscalar(config.perturbateEfflux) && ...
                logical(config.perturbateEfflux);

            if isPerturbated
                [standardDeviations, freeMask, errorMessage] = ...
                    openmebius.mfa.MFAInputValidator ...
                    .alignPerturbationConfiguration( ...
                    substrates, config);

                if strlength(errorMessage) > 0
                    result = openmebius.mfa ...
                        .MFAInputValidationResult.failure( ...
                        errorMessage);
                    return;
                end
            end

            value = struct;
            value.GrowthRate = growthRate;
            value.SubstrateList = substrates;
            value.Efflux = efflux;
            value.EffluxStandardDeviation = standardDeviations;
            value.EffluxFree = freeMask;
            result = ...
                openmebius.mfa.MFAInputValidationResult.success(value);

        end % validateEfflux

        function result = validateMDV( ...
                ~, experimentalMDV, fragmentLabels, fragmentMask)

            if isempty(experimentalMDV)
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "MDV experimental data is not available.");
                return;
            end

            fragmentLabels = string(fragmentLabels(:));
            fragmentMask = logical(fragmentMask(:));

            if numel(fragmentLabels) ~= size(experimentalMDV, 1) || ...
                    numel(fragmentMask) ~= size(experimentalMDV, 1)
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "MDV fragment labels and mask must match the " + ...
                    "experimental data row count.");
                return;
            end

            usedMDV = experimentalMDV(fragmentMask, :);
            usedFragmentLabels = fragmentLabels(fragmentMask);
            nanRows = any(isnan(usedMDV), 2);

            if any(nanRows)
                invalidLabels = usedFragmentLabels(nanRows);
                invalidLabels = invalidLabels(invalidLabels ~= "");
                invalidLabels = unique(invalidLabels);
                result = ...
                    openmebius.mfa.MFAInputValidationResult.failure( ...
                    "MDV experimental data contains NaN values in " + ...
                    "the following fragments: " + ...
                    strjoin(invalidLabels, ", ") + ".");
                return;
            end

            result = openmebius.mfa.MFAInputValidationResult.success();

        end % validateMDV

    end % methods

    methods (Static, Access = private)

        function [standardDeviations, freeMask, errorMessage] = ...
                alignPerturbationConfiguration(substrates, config)

            standardDeviations = zeros(0, 1);
            freeMask = false(0, 1);
            errorMessage = "";

            if ~isfield(config, "efflux") || ...
                    ~isstruct(config.efflux) || ...
                    ~all(isfield(config.efflux, ...
                    ["substrate", "selection", "substrateSD"]))
                errorMessage = ...
                    "Efflux perturbation configuration is incomplete.";
                return;
            end

            configuredSubstrates = string( ...
                config.efflux.substrate(:));
            configuredSelection = config.efflux.selection(:);
            configuredStandardDeviations = ...
                config.efflux.substrateSD(:);

            if isempty(configuredSubstrates)
                errorMessage = ...
                    "No substrate selected for efflux perturbation.";
                return;
            end

            if numel(configuredSubstrates) ~= ...
                    numel(configuredSelection) || ...
                    numel(configuredSubstrates) ~= ...
                    numel(configuredStandardDeviations)
                errorMessage = "Efflux perturbation substrate, " + ...
                    "selection, and standard-deviation counts must match.";
                return;
            end

            if numel(unique(configuredSubstrates)) ~= ...
                    numel(configuredSubstrates)
                errorMessage = "Efflux perturbation substrates " + ...
                    "must be unique.";
                return;
            end

            [isConfigured, configuredIndex] = ismember( ...
                substrates, configuredSubstrates);

            if ~any(isConfigured)
                errorMessage = ...
                    "No matching substrate found for efflux perturbation.";
                return;
            end

            standardDeviations = nan(numel(substrates), 1);
            freeMask = false(numel(substrates), 1);
            standardDeviations(isConfigured) = double( ...
                configuredStandardDeviations( ...
                configuredIndex(isConfigured)));
            freeMask(isConfigured) = logical( ...
                configuredSelection(configuredIndex(isConfigured)));
            selectedStandardDeviations = ...
                standardDeviations(freeMask);

            if any(selectedStandardDeviations <= 0)
                errorMessage = "Efflux standard deviation must be " + ...
                    "positive for perturbation.";
                return;
            end

            if any(isnan(selectedStandardDeviations))
                errorMessage = "Efflux standard deviation contains " + ...
                    "NaN values for perturbation.";
            end

        end % alignPerturbationConfiguration

    end % methods (Static, Access = private)

end % classdef
