classdef MFAConstraintBuilder
    % MFACONSTRAINTBUILDER
    % Builds MFA right-hand sides and identifies free-efflux constraints.

    methods

        function rightHandSide = buildRightHandSide( ...
                ~, model, growthRate, substrateList, efflux)

            arguments
                ~
                model
                growthRate (1, 1) double
                substrateList
                efflux (:, 1) double
            end

            if ~isfinite(growthRate)
                error( ...
                    "OpenMebius2:MFAConstraintBuilder:" + ...
                    "InvalidGrowthRate", ...
                "The growth rate must be finite.");
            end

            substrateList = string(substrateList(:));

            if numel(substrateList) ~= numel(efflux)
                error( ...
                    "OpenMebius2:MFAConstraintBuilder:" + ...
                    "EffluxDimensionMismatch", ...
                "Each substrate must have one efflux value.");
            end

            stoichiometry = model.getSBefore();
            metadata = openmebius.mfa.MFAConstraintMetadata ...
                .fromModel(model, stoichiometry);
            reactionIDs = metadata.ReactionIDs;
            reactionTypes = metadata.ReactionTypes;
            biomassIndex = find(reactionIDs == "biomass", 1);

            if isempty(biomassIndex)
                error( ...
                    "OpenMebius2:MFAConstraintBuilder:" + ...
                    "MissingBiomassConstraint", ...
                "The stoichiometry must contain a biomass constraint.");
            end

            rightHandSide = zeros(size(stoichiometry, 2), 1);

            if biomassIndex > numel(rightHandSide)
                error( ...
                    "OpenMebius2:MFAConstraintBuilder:" + ...
                    "RightHandSideDimensionMismatch", ...
                    "The stoichiometry does not provide enough right-hand " + ...
                "side entries for its constraints.");
            end

            rightHandSide(biomassIndex) = growthRate;
            effluxRows = find(reactionTypes == "efflux");

            for rowIndex = reshape(effluxRows, 1, [])
                reactionID = reactionIDs(rowIndex);
                substrate = string( ...
                    model.getSubstrateNameFromRxnID(reactionID));
                substrateIndex = find( ...
                    substrateList == substrate, ...
                    1, ...
                "first");

                if ~isempty(substrateIndex)
                    rightHandSide(rowIndex) = efflux(substrateIndex);
                end

            end

        end % buildRightHandSide

        function mask = effluxFreeConstraintRowMask( ...
                ~, model, stoichiometry, substrateList, freeMask)

            arguments
                ~
                model
                stoichiometry table
                substrateList
                freeMask
            end

            rowCount = size(stoichiometry, 1);
            mask = false(rowCount, 1);
            freeMask = logical(freeMask(:));

            if isempty(freeMask) || ~any(freeMask)
                return;
            end

            substrateList = string(substrateList(:));

            if numel(freeMask) ~= numel(substrateList)
                error( ...
                    "OpenMebius2:MFAConstraintBuilder:" + ...
                    "FreeEffluxDimensionMismatch", ...
                "The free-efflux mask must match the substrate list.");
            end

            metadata = openmebius.mfa.MFAConstraintMetadata ...
                .fromModel(model, stoichiometry);
            reactionIDs = metadata.ReactionIDs;
            reactionTypes = metadata.ReactionTypes;
            freeSubstrates = substrateList(freeMask);
            effluxRows = find(reactionTypes == "efflux");

            for rowIndex = reshape(effluxRows, 1, [])
                substrate = string( ...
                    model.getSubstrateNameFromRxnID( ...
                    reactionIDs(rowIndex)));
                mask(rowIndex) = any(freeSubstrates == substrate);
            end

        end % effluxFreeConstraintRowMask

    end % methods

end % classdef
