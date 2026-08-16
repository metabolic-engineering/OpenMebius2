classdef StoichiometricConstraintModel
    % STOICHIOMETRICCONSTRAINTMODEL Validated MFA constraint matrices.

    properties (SetAccess = private)
        ConstraintMatrix table
        SystemMatrix table
        ConstraintTypes (:, 1) string
        SystemTypes (:, 1) string
    end

    methods

        function obj = StoichiometricConstraintModel( ...
                constraintMatrix, systemMatrix, systemTypes)

            arguments
                constraintMatrix table
                systemMatrix table
                systemTypes (:, 1) string
            end

            if height(systemMatrix) ~= width(systemMatrix)
                error( ...
                    "OpenMebius2:StoichiometricConstraintModel:NonSquareSystem", ...
                    "Stoichiometric system matrix must be square.");
            end

            if numel(systemTypes) ~= height(systemMatrix)
                error( ...
                    "OpenMebius2:StoichiometricConstraintModel:TypeCountMismatch", ...
                    "Every stoichiometric row must have a constraint type.");
            end

            obj.ConstraintMatrix = constraintMatrix;
            obj.SystemMatrix = systemMatrix;
            obj.ConstraintTypes = systemTypes(1:height(constraintMatrix));
            obj.SystemTypes = systemTypes;
        end

        function value = degreeOfFreedom(obj)
            value = width(obj.ConstraintMatrix) - height(obj.ConstraintMatrix);
        end

    end

end
