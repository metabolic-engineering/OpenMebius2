classdef StoichiometricReactionIndex
    % STOICHIOMETRICREACTIONINDEX Expanded reaction and transition index.

    properties (SetAccess = private)
        SourceReactions table
        Reactions table
        Transitions table
        ModelTable table
        ReversiblePairs (:, 2) double = zeros(0, 2)
    end

    methods
        function obj = StoichiometricReactionIndex( ...
                modelTable, sourceReactions, sourceTransitions)
            arguments
                modelTable table
                sourceReactions table
                sourceTransitions table
            end

            [obj.Reactions, obj.Transitions, obj.ReversiblePairs] = ...
                obj.expandReversible(sourceReactions, sourceTransitions);
            obj.SourceReactions = sourceReactions;
            obj.ModelTable = obj.expandModelTable( ...
                modelTable, sourceReactions, obj.Reactions);
        end

        function value = reaction(obj, index)
            if nargin == 2
                value = obj.Reactions(index, :);
            else
                value = obj.Reactions;
            end
        end

        function value = transition(obj, index)
            if nargin == 2
                value = obj.Transitions(index, :);
            else
                value = obj.Transitions;
            end
        end

        function index = find(obj, reactionID)
            index = find(strcmp( ...
                obj.Reactions.Properties.RowNames, reactionID));
        end

        function index = findSource(obj, reactionID)
            index = find(strcmp( ...
                obj.SourceReactions.Properties.RowNames, reactionID));
        end

        function index = counterReaction(obj, reactionID)
            reactionIndex = obj.find(reactionID);
            index = nan;
            if isempty(reactionIndex)
                return
            end
            [row, column] = find( ...
                obj.ReversiblePairs == reactionIndex, 1);
            if ~isempty(row)
                index = obj.ReversiblePairs(row, 3 - column);
            end
        end

        function indices = involving(obj, compound, productOnly)
            arguments
                obj
                compound string
                productOnly (1, 1) logical = false
            end
            indices = zeros(0, 1);
            for i = 1:height(obj.Reactions)
                inProducts = ismember(compound, obj.Reactions.Products{i});
                inReactants = ismember(compound, obj.Reactions.Reactants{i});
                if inProducts || (~productOnly && inReactants)
                    indices(end + 1, 1) = i; %#ok<AGROW>
                end
            end
        end
    end

    methods (Static, Access = private)
        function [reactions, transitions, pairs] = ...
                expandReversible(sourceReactions, sourceTransitions)
            reactions = sourceReactions;
            transitions = sourceTransitions;
            reversible = find(sourceReactions.Reversible);
            count = numel(reversible);
            reverseIndices = reversible + (1:count)';
            forwardIndices = reverseIndices - 1;

            for i = 1:count
                reactions = ...
                    openmebius.domain.model.StoichiometricReactionIndex ...
                        .insertRow(reactions, ...
                            reactions(forwardIndices(i), :), ...
                            reverseIndices(i));
                transitions = ...
                    openmebius.domain.model.StoichiometricReactionIndex ...
                        .insertRow(transitions, ...
                            transitions(forwardIndices(i), :), ...
                            reverseIndices(i));
            end

            for i = 1:count
                reverseIndex = reverseIndices(i);
                reactants = reactions.Reactants(reverseIndex);
                transitionReactants = transitions.Reactants(reverseIndex);
                reactions.Reactants(reverseIndex) = reactions.Products(reverseIndex);
                reactions.Products(reverseIndex) = reactants;
                transitions.Reactants(reverseIndex) = transitions.Products(reverseIndex);
                transitions.Products(reverseIndex) = transitionReactants;
            end
            pairs = [forwardIndices, reverseIndices];
        end

        function expanded = expandModelTable( ...
                modelTable, sourceReactions, reactions)
            expanded = table( ...
                Size = [0, width(modelTable)], ...
                VariableNames = modelTable.Properties.VariableNames, ...
                VariableTypes = modelTable.Properties.VariableTypes);
            for i = 1:height(sourceReactions)
                expanded = [expanded; modelTable(i, :)]; %#ok<AGROW>
                if ~sourceReactions.Reversible(i)
                    continue
                end
                row = modelTable(i, :);
                row.Reaction = {openmebius.domain.model ...
                    .StoichiometricReactionIndex.reverseExpression(row.Reaction{1})};
                row.Transition = {openmebius.domain.model ...
                    .StoichiometricReactionIndex.reverseExpression(row.Transition{1})};
                row.Properties.RowNames{1} = ...
                    char(string(row.Properties.RowNames{1}) + "_rev_tmp");
                expanded = [expanded; row]; %#ok<AGROW>
            end
            expanded.Properties.RowNames = reactions.Properties.RowNames;
        end

        function value = reverseExpression(value)
            parts = strsplit(value, ' ');
            arrow = find(strcmp(parts, '<=>'), 1);
            if ~isempty(arrow)
                value = strjoin( ...
                    [parts(arrow + 1:end), {'<=>'}, parts(1:arrow - 1)], ' ');
            end
        end

        function inserted = insertRow(source, row, index)
            rowNames = source.Properties.RowNames;
            row.Properties.RowNames = ...
                {char(string(rowNames{index - 1}) + "_rev")};
            inserted = [source(1:index - 1, :); row; source(index:end, :)];
        end
    end
end
