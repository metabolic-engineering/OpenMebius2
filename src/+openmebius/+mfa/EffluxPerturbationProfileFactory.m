classdef EffluxPerturbationProfileFactory
    % EFFLUXPERTURBATIONPROFILEFACTORY
    % Maps selected substrate effluxes to internal flux indices.

    methods

        function profile = create( ...
                ~, model, substrateList, experimentalValues, ...
                standardDeviations, freeMask, options)

            arguments
                ~
                model
                substrateList
                experimentalValues double
                standardDeviations double
                freeMask
                options.GrowthRate (1, 1) double = NaN
                options.GrowthRateStandardDeviation (1, 1) double = NaN
                options.GrowthRateFree (1, 1) logical = false
            end

            substrateList = string(substrateList(:));
            experimentalValues = experimentalValues(:);
            standardDeviations = standardDeviations(:);
            freeMask = logical(freeMask(:));
            itemCount = numel(substrateList);

            if isempty(freeMask) && ~options.GrowthRateFree
                profile = ...
                    openmebius.mfa.EffluxPerturbationProfile();
                return
            end

            if isempty(freeMask)
                freeMask = false(itemCount, 1);
            end

            if numel(freeMask) ~= itemCount
                error( ...
                    "OpenMebius2:EffluxPerturbationProfileFactory:" + ...
                    "DimensionMismatch", ...
                    "Efflux data must match the substrate list length.");
            end

            selectedIndices = find(freeMask);

            if isempty(selectedIndices) && ~options.GrowthRateFree
                profile = ...
                    openmebius.mfa.EffluxPerturbationProfile();
                return
            end

            if numel(experimentalValues) ~= itemCount || ...
                    numel(standardDeviations) ~= itemCount
                error( ...
                    "OpenMebius2:EffluxPerturbationProfileFactory:" + ...
                    "DimensionMismatch", ...
                    "Efflux data must match the substrate list length.");
            end

            if ~ismethod(model, 'getSBefore') || ...
                    ~ismethod( ...
                    model, 'findSubstrateRxnIDFromMetaboliteIrrev')
                error( ...
                    "OpenMebius2:EffluxPerturbationProfileFactory:" + ...
                    "InvalidModel", ...
                    "The model must expose efflux-reaction mapping " + ...
                    "methods.");
            end

            stoichiometry = model.getSBefore();

            if ~istable(stoichiometry)
                error( ...
                    "OpenMebius2:EffluxPerturbationProfileFactory:" + ...
                    "InvalidStoichiometry", ...
                    "The model stoichiometry must be a table.");
            end

            reactionNames = ...
                string(stoichiometry.Properties.VariableNames);
            measurementCount = numel(selectedIndices) + ...
                double(options.GrowthRateFree);
            reactionIndices = nan(measurementCount, 1);
            counterReactionIndices = nan(measurementCount, 1);
            selectedReactionIDs = strings(measurementCount, 1);
            selectedExperimentalValues = nan(measurementCount, 1);
            selectedStandardDeviations = nan(measurementCount, 1);

            for i = 1:numel(selectedIndices)
                substrate = substrateList(selectedIndices(i));
                reactionID = string( ...
                    model.findSubstrateRxnIDFromMetaboliteIrrev( ...
                    substrate));

                if ~isscalar(reactionID) || ismissing(reactionID) || ...
                        strlength(reactionID) == 0
                    error( ...
                        "OpenMebius2:" + ...
                        "EffluxPerturbationProfileFactory:" + ...
                        "InvalidReactionID", ...
                        "The model returned an invalid efflux reaction " + ...
                        "ID for substrate: %s.", ...
                        substrate);
                end

                reactionIndex = find(reactionNames == reactionID, 1);

                if isempty(reactionIndex)
                    error( ...
                        "OpenMebius2:" + ...
                        "EffluxPerturbationProfileFactory:" + ...
                        "ReactionNotFound", ...
                        "Selected efflux reaction was not found in the " + ...
                        "stoichiometry matrix: %s.", ...
                        reactionID);
                end

                reactionIndices(i) = reactionIndex;
                counterReactionIndices(i) = ...
                    openmebius.mfa.EffluxPerturbationProfileFactory ...
                    .counterReactionIndex(model, reactionIndex);
                selectedReactionIDs(i) = reactionID;
                selectedExperimentalValues(i) = ...
                    experimentalValues(selectedIndices(i));
                selectedStandardDeviations(i) = ...
                    standardDeviations(selectedIndices(i));
            end

            if options.GrowthRateFree
                growthRateIndex = find(reactionNames == "biomass", 1);

                if isempty(growthRateIndex)
                    error( ...
                        "OpenMebius2:" + ...
                        "EffluxPerturbationProfileFactory:" + ...
                        "BiomassReactionNotFound", ...
                        "The biomass reaction required for growth-rate " + ...
                        "perturbation was not found.");
                end

                reactionIndices(end) = growthRateIndex;
                selectedReactionIDs(end) = "biomass";
                selectedExperimentalValues(end) = options.GrowthRate;
                selectedStandardDeviations(end) = ...
                    options.GrowthRateStandardDeviation;
            end

            profile = openmebius.mfa.EffluxPerturbationProfile( ...
                ReactionIDs = selectedReactionIDs, ...
                ReactionIndices = reactionIndices, ...
                CounterReactionIndices = counterReactionIndices, ...
                ExperimentalValues = selectedExperimentalValues, ...
                StandardDeviations = selectedStandardDeviations);

        end % create

    end % methods

    methods (Static, Access = private)

        function counterIndex = counterReactionIndex( ...
                model, reactionIndex)

            counterIndex = NaN;

            if ~ismethod(model, 'getIdxRev')
                return
            end

            reversiblePairs = model.getIdxRev();
            [pairIndex, pairColumn] = find( ...
                reversiblePairs == reactionIndex, 1);

            if isempty(pairIndex)
                return
            end

            counterIndex = reversiblePairs( ...
                pairIndex, 3 - pairColumn);

        end

    end % methods (Static, Access = private)

end % classdef
