classdef MFAConstraintMetadata
    % MFACONSTRAINTMETADATA IDs and types aligned to constraint rows.

    properties (SetAccess = private)
        ReactionIDs (:, 1) string
        ReactionTypes (:, 1) string
    end

    methods

        function obj = MFAConstraintMetadata(reactionIDs, reactionTypes)

            arguments
                reactionIDs string
                reactionTypes string
            end

            reactionIDs = string(reactionIDs(:));
            reactionTypes = string(reactionTypes(:));

            if numel(reactionIDs) ~= numel(reactionTypes)
                error( ...
                    "OpenMebius2:MFAConstraintMetadata:TypeDimensionMismatch", ...
                    "Each constraint row must have exactly one type.");
            end

            if any(ismissing(reactionIDs) | strlength(reactionIDs) == 0)
                error( ...
                    "OpenMebius2:MFAConstraintMetadata:MissingIdentifiers", ...
                    "Each constraint row must have a nonempty identifier.");
            end

            if any(ismissing(reactionTypes) | strlength(reactionTypes) == 0)
                error( ...
                    "OpenMebius2:MFAConstraintMetadata:MissingTypes", ...
                    "Each constraint row must have a nonempty type.");
            end

            obj.ReactionIDs = reactionIDs;
            obj.ReactionTypes = lower(reactionTypes);

        end % constructor

        function reactionIDs = reactionIDsOfType(obj, type)

            arguments
                obj (1, 1) openmebius.mfa.MFAConstraintMetadata
                type (1, 1) string
            end

            reactionIDs = obj.ReactionIDs( ...
                obj.ReactionTypes == lower(type));

        end % reactionIDsOfType

    end % methods

    methods (Static)

        function metadata = fromModel(model, stoichiometry)

            arguments
                model
                stoichiometry table
            end

            if ~ismethod(model, 'getConstraintTypes')
                error( ...
                    "OpenMebius2:MFAConstraintMetadata:MissingTypeProvider", ...
                    "The model must expose getConstraintTypes().");
            end

            reactionIDs = string(stoichiometry.Properties.RowNames);
            reactionTypes = string(model.getConstraintTypes());
            metadata = openmebius.mfa.MFAConstraintMetadata( ...
                reactionIDs, reactionTypes);

        end % fromModel

    end % methods (Static)

end % classdef
