classdef MFAInputValidator
    % MFAINPUTVALIDATOR
    % Validates and aligns MFA efflux and experimental MDV inputs.

    methods

        function result = validateEfflux( ...
                ~, model, experiments, experimentList, settings)

            arguments
                ~
                model
                experiments
                experimentList
                settings (1, 1) openmebius.mfa ...
                    .EffluxPerturbationSettings
            end

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
                metadata = openmebius.mfa.MFAConstraintMetadata ...
                    .fromModel(model, stoichiometry);
                effluxReactionIDs = ...
                    metadata.reactionIDsOfType("efflux");
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
            growthRateStandardDeviation = NaN;
            growthRateFree = false;

            if settings.Enabled
                growthRateFree = settings.GrowthRateFree;

                if growthRateFree
                    growthRateStandardDeviation = ...
                        settings.GrowthRateStandardDeviation;

                    if ~isfinite(growthRateStandardDeviation) || ...
                            growthRateStandardDeviation <= 0
                        result = openmebius.mfa ...
                            .MFAInputValidationResult.failure( ...
                            "Growth-rate (mu) standard deviation must " + ...
                        "be positive and finite for perturbation.");
                        return;
                    end

                end

                [standardDeviations, freeMask, errorMessage] = ...
                    openmebius.mfa.MFAInputValidator ...
                    .alignPerturbationConfiguration( ...
                    substrates, settings, growthRateFree);

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
            value.GrowthRateStandardDeviation = ...
                growthRateStandardDeviation;
            value.GrowthRateFree = growthRateFree;
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
                alignPerturbationConfiguration( ...
                substrates, settings, allowEmpty)

            standardDeviations = zeros(0, 1);
            freeMask = false(0, 1);
            errorMessage = "";

            configuredSubstrates = settings.Substrates;
            configuredSelection = settings.FreeSelection;
            configuredStandardDeviations = settings.StandardDeviations;

            if isempty(configuredSubstrates)

                if allowEmpty
                    standardDeviations = nan(numel(substrates), 1);
                    freeMask = false(numel(substrates), 1);
                else
                    errorMessage = ...
                        "No substrate selected for efflux perturbation.";
                end

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
