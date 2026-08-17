classdef ModelWorkspaceValidator
    % MODELWORKSPACEVALIDATOR Validates editable model workspace tables.

    methods

        function validateLabelConfiguration(~, labelTable, ratioTables)
            required = ["Name", "Num"];

            if ~all(ismember(required, string(labelTable.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:LabelConfiguration:InvalidLabelTable", ...
                    "Label settings must contain Name and Num columns.");
            end

            fields = fieldnames(ratioTables);

            if numel(fields) ~= height(labelTable)
                error( ...
                    "OpenMebius2:LabelConfiguration:RatioCountMismatch", ...
                    "A ratio table is required for each label configuration row.");
            end

            for fieldIndex = 1:numel(fields)
                value = ratioTables.(fields{fieldIndex});

                if ~istable(value) || ~all(ismember( ...
                        ["Label", "Ratio"], ...
                        string(value.Properties.VariableNames)))
                    error( ...
                        "OpenMebius2:LabelConfiguration:InvalidRatioTable", ...
                        "Each ratio setting must contain Label and Ratio columns.");
                end

            end

        end

        function [isValid, errorRows] = validateAtomTable(~, atomTable)
            errors = false(size(atomTable));

            for row = 1:height(atomTable)

                for column = 1:width(atomTable)
                    value = atomTable{row, column};
                    errors(row, column) = ...
                        ~isnumeric(value) || ~isinteger(value) || value < 0;
                end

            end

            errorRows = find(any(errors, 2));
            isValid = ~any(errors, "all");
        end

        function [errors, errorRows] = validateReactionTransition( ...
                obj, reactionTable, transitionTable)

            arguments
                obj
                reactionTable table
                transitionTable table
            end

            errors = strings(0, 1);
            errorRows = zeros(1, 0);
            count = min(height(reactionTable), height(transitionTable));

            for row = 1:count
                reactionReactants = reactionTable.Reactants{row};
                reactionProducts = reactionTable.Products{row};
                transitionReactants = transitionTable.Reactants{row};
                transitionProducts = transitionTable.Products{row};

                % Invalid expressions are reported by ModelReactionParser.
                if isempty(reactionReactants) || isempty(reactionProducts) || ...
                        isempty(transitionReactants) || ...
                        isempty(transitionProducts)
                    continue
                end

                if numel(reactionReactants) ~= numel(transitionReactants) || ...
                        numel(reactionProducts) ~= numel(transitionProducts)
                    errors(end + 1, 1) = ...
                        "Reaction and Transition mismatch at row " + row + ...
                        ": the numbers of reactants and products must agree."; %#ok<AGROW>
                    errorRows(end + 1) = row; %#ok<AGROW>
                end

                if reactionTable.Reversible(row) ~= ...
                        transitionTable.Reversible(row)
                    errors(end + 1, 1) = ...
                        "Reversibility mismatch between Reaction and " + ...
                        "Transition at row " + row + "."; %#ok<AGROW>
                    errorRows(end + 1) = row; %#ok<AGROW>
                end
            end

            [carbonErrors, carbonRows] = obj.validateCarbonCounts( ...
                reactionTable, transitionTable);
            errors = [errors; carbonErrors];
            errorRows = [errorRows, carbonRows];

        end % validateReactionTransition

    end

    methods (Access = private)

        function [errors, errorRows] = validateCarbonCounts( ...
                obj, reactionTable, transitionTable)

            [reactantNames, reactantCounts, reactantRows] = ...
                obj.collectCarbonOccurrences( ...
                reactionTable.Reactants, transitionTable.Reactants);
            [productNames, productCounts, productRows] = ...
                obj.collectCarbonOccurrences( ...
                reactionTable.Products, transitionTable.Products);
            names = [reactantNames; productNames];
            counts = [reactantCounts; productCounts];
            rows = [reactantRows; productRows];
            errors = strings(0, 1);
            errorRows = zeros(1, 0);

            for metabolite = unique(names, "stable").'
                occurrence = names == metabolite;

                if numel(unique(counts(occurrence))) <= 1
                    continue
                end

                affectedRows = unique(rows(occurrence), "stable");
                errors(end + 1, 1) = ...
                    "Carbon count mismatch for metabolite " + ...
                    metabolite + "."; %#ok<AGROW>
                errorRows = [errorRows, affectedRows.']; %#ok<AGROW>
            end

        end % validateCarbonCounts

        function [names, counts, rows] = collectCarbonOccurrences( ...
                ~, reactions, transitions)

            names = strings(0, 1);
            counts = zeros(0, 1);
            rows = zeros(0, 1);

            for row = 1:min(numel(reactions), numel(transitions))
                reactionSide = reactions{row};
                transitionSide = transitions{row};
                pairCount = min(numel(reactionSide), numel(transitionSide));

                for component = 1:pairCount
                    names(end + 1, 1) = string( ...
                        reactionSide{component}); %#ok<AGROW>
                    counts(end + 1, 1) = strlength(string( ...
                        transitionSide{component})); %#ok<AGROW>
                    rows(end + 1, 1) = row; %#ok<AGROW>
                end
            end

        end % collectCarbonOccurrences

    end

end
