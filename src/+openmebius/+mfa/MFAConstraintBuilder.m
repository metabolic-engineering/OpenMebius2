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
            [reactionIDs, reactionTypes] = ...
                openmebius.mfa.MFAConstraintBuilder ...
                .constraintMetadata(model, stoichiometry);
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

            [reactionIDs, reactionTypes] = ...
                openmebius.mfa.MFAConstraintBuilder ...
                .constraintMetadata(model, stoichiometry);
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

    methods (Static, Access = private)

        function [reactionIDs, reactionTypes] = ...
                constraintMetadata(model, stoichiometry)

            reactionIDs = string(stoichiometry.Properties.RowNames);
            reactionIDs = reactionIDs(:);
            reactionTypes = string(model.getSType());
            reactionTypes = reactionTypes(:);
            rowCount = size(stoichiometry, 1);

            if numel(reactionIDs) ~= rowCount
                error( ...
                    "OpenMebius2:MFAConstraintBuilder:" + ...
                    "MissingConstraintIdentifiers", ...
                    "Each stoichiometry row must have an identifier.");
            end

            if numel(reactionTypes) < rowCount
                error( ...
                    "OpenMebius2:MFAConstraintBuilder:" + ...
                    "ConstraintTypeDimensionMismatch", ...
                    "The model must provide a type for every " + ...
                    "stoichiometry constraint.");
            end

            reactionTypes = reactionTypes(1:rowCount);

        end % constraintMetadata

    end % methods (Static, Access = private)

end % classdef
