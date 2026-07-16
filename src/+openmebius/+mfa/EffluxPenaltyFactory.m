classdef EffluxPenaltyFactory
    % EFFLUXPENALTYFACTORY
    % Maps model substrate reactions to an immutable efflux penalty.

    methods

        function penalty = create( ...
                ~, model, substrateList, experimentalValues, ...
                standardDeviations, freeMask)

            arguments
                ~
                model
                substrateList
                experimentalValues double
                standardDeviations double
                freeMask
            end

            substrateList = string(substrateList(:));
            experimentalValues = experimentalValues(:);
            standardDeviations = standardDeviations(:);
            freeMask = logical(freeMask(:));
            itemCount = numel(substrateList);

            if isempty(freeMask)
                penalty = openmebius.mfa.EffluxPenalty();
                return;
            end

            if numel(freeMask) ~= itemCount
                error( ...
                    "OpenMebius2:EffluxPenaltyFactory:DimensionMismatch", ...
                    "Efflux data must match the substrate list length.");
            end

            selectedIndices = find(freeMask);

            if isempty(selectedIndices)
                penalty = openmebius.mfa.EffluxPenalty();
                return;
            end

            if numel(experimentalValues) ~= itemCount || ...
                    numel(standardDeviations) ~= itemCount
                error( ...
                    "OpenMebius2:EffluxPenaltyFactory:DimensionMismatch", ...
                    "Efflux data must match the substrate list length.");
            end

            stoichiometry = model.getSBefore();
            reactionNames = ...
                string(stoichiometry.Properties.VariableNames);
            reactionIndices = nan(numel(selectedIndices), 1);

            for i = 1:numel(selectedIndices)
                substrate = substrateList(selectedIndices(i));
                reactionID = ...
                    string(model.findSubstrateRxnIDFromMetaboliteIrrev( ...
                    substrate));
                reactionIndex = find(reactionNames == reactionID, 1);

                if isempty(reactionIndex)
                    error( ...
                        "OpenMebius2:EffluxPenaltyFactory:ReactionNotFound", ...
                        "Selected efflux reaction was not found in the " + ...
                        "stoichiometry matrix: %s.", ...
                        reactionID);
                end

                reactionIndices(i) = reactionIndex;
            end

            penalty = openmebius.mfa.EffluxPenalty( ...
                ReactionIndices = reactionIndices, ...
                ExperimentalValues = ...
                    experimentalValues(selectedIndices), ...
                StandardDeviations = ...
                    standardDeviations(selectedIndices));

        end % create

    end % methods

end % classdef
