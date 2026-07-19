classdef StoichiometricMatrixBuilder
    % STOICHIOMETRICMATRIXBUILDER Builds MFA matrices from parsed tables.

    methods
        function constraints = build(~, reactionIndex, metabolites, biomass)
            arguments
                ~
                reactionIndex (1, 1) ...
                    openmebius.domain.model.StoichiometricReactionIndex
                metabolites table
                biomass table
            end

            reactions = reactionIndex.Reactions;
            reactionNames = [reactions.Properties.RowNames; {'biomass'}]';
            internal = metabolites( ...
                string(metabolites.Type) == "metabolite", :);
            internalNames = string(internal.Metabolite);
            matrix = zeros(height(internal), height(reactions) + 1);
            for i = 1:height(internal)
                name = internalNames(i);
                matrix(i, 1:end - 1) = ...
                    openmebius.mfa.StoichiometricMatrixBuilder ...
                        .countOccurrences(name, reactions.Products) - ...
                    openmebius.mfa.StoichiometricMatrixBuilder ...
                        .countOccurrences(name, reactions.Reactants);
            end

            matrix(:, end) = openmebius.mfa.StoichiometricMatrixBuilder ...
                .buildBiomassColumn(internalNames, biomass);
            matrix = [matrix; zeros(1, size(matrix, 2))];
            matrix(end, end) = 1;
            rowNames = [internalNames; "biomass"];
            types = [repmat("metabolite", height(internal), 1); "biomass"];

            substrateNames = string(metabolites.Metabolite( ...
                string(metabolites.Type) == "substrate"));
            efflux = openmebius.mfa.StoichiometricMatrixBuilder ...
                .findEfflux(reactions, substrateNames);
            efflux = openmebius.mfa.StoichiometricMatrixBuilder ...
                .removeIndependent(efflux, reactions);
            matrix = [matrix; openmebius.mfa.StoichiometricMatrixBuilder ...
                .reactionRows(efflux, reactionNames)];
            rowNames = [rowNames; string(efflux(:))];
            types = [types; repmat("efflux", numel(efflux), 1)];

            constraintMatrix = array2table( ...
                matrix, VariableNames = reactionNames, ...
                RowNames = cellstr(rowNames));
            independent = openmebius.mfa.StoichiometricMatrixBuilder ...
                .findIndependent(constraintMatrix, reactionIndex);
            independentTable = array2table( ...
                openmebius.mfa.StoichiometricMatrixBuilder ...
                    .reactionRows(independent, reactionNames), ...
                VariableNames = reactionNames, RowNames = independent);
            systemMatrix = [constraintMatrix; independentTable];
            types = [types; repmat("independent", numel(independent), 1)];

            constraints = ...
                openmebius.domain.model.StoichiometricConstraintModel( ...
                    constraintMatrix, systemMatrix, types);
        end
    end

    methods (Static, Access = private)
        function counts = countOccurrences(metabolite, lists)
            counts = zeros(1, numel(lists));
            for i = 1:numel(lists)
                counts(i) = sum(strcmp(metabolite, lists{i}), "all");
            end
        end

        function column = buildBiomassColumn(metabolites, biomass)
            column = zeros(numel(metabolites), 1);
            for i = 1:height(biomass)
                index = find(metabolites == string(biomass.Precursor{i}));
                column(index) = -biomass.Biomass(i);
            end
        end

        function names = findEfflux(reactions, substrates)
            selected = false(height(reactions), 1);
            for i = 1:height(reactions)
                reactants = string(reactions.Reactants{i});
                products = string(reactions.Products{i});
                compounds = [reactants(:); products(:)];
                selected(i) = any(ismember(compounds, substrates));
            end
            rowNames = string(reactions.Properties.RowNames);
            names = cellstr(rowNames(selected));
        end

        function names = removeIndependent(names, reactions)
            if ~isempty(names)
                selected = reactions(names, :);
                names = names(~selected.Independent);
            end
        end

        function rows = reactionRows(names, reactionNames)
            rows = zeros(numel(names), numel(reactionNames));
            for i = 1:numel(names)
                rows(i, strcmp(reactionNames, names{i})) = 1;
            end
        end

        function names = findIndependent(matrixTable, reactionIndex)
            matrix = matrixTable{:, :};
            reactionCount = height(reactionIndex.Reactions);
            reversible = unique(reactionIndex.ReversiblePairs(:));
            reversible = intersect(reversible, 1:reactionCount, "stable");
            irreversible = setdiff(1:reactionCount, reversible, "stable");
            order = [reversible', irreversible, reactionCount + 1:size(matrix, 2)];
            [~, reorderedPivots] = rref(matrix(:, order));
            pivots = order(reorderedPivots);
            names = matrixTable.Properties.VariableNames( ...
                ~ismember(1:size(matrix, 2), pivots));
        end
    end
end
