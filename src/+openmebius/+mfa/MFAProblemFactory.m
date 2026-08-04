classdef MFAProblemFactory
    % MFAPROBLEMFACTORY
    % Maps named stoichiometry data to a validated MFAProblem.

    methods

        function problem = create( ...
                ~, stoichiometryTable, systemType, rightHandSide, ...
                lowerBounds, upperBounds)

            arguments
                ~
                stoichiometryTable table
                systemType
                rightHandSide (:, 1) double
                lowerBounds (:, 1) double
                upperBounds (:, 1) double
            end

            systemType = string(systemType(:));
            rowNames = string(stoichiometryTable.Properties.RowNames);
            reactionNames = ...
                string(stoichiometryTable.Properties.VariableNames);

            if numel(systemType) ~= height(stoichiometryTable)
                error( ...
                    "OpenMebius2:MFAProblem:SystemTypeDimensionMismatch", ...
                    "System types must match stoichiometry rows.");
            end

            if numel(rowNames) ~= height(stoichiometryTable)
                error( ...
                    "OpenMebius2:MFAProblem:MissingRowNames", ...
                    "Stoichiometry rows must have reaction names.");
            end

            independentMask = systemType == "independent";
            independentReactionNames = rowNames(independentMask);
            boundaryReactionMask = ...
                ismember(reactionNames, independentReactionNames)';
            problem = openmebius.mfa.MFAProblem( ...
                Stoichiometry = table2array(stoichiometryTable), ...
                RightHandSide = rightHandSide, ...
                LowerBounds = lowerBounds, ...
                UpperBounds = upperBounds, ...
                IndependentMask = independentMask, ...
                BoundaryReactionMask = boundaryReactionMask);

        end % create

    end % methods

end % classdef
