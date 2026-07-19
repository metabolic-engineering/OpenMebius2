classdef StoichiometricNetwork
    % STOICHIOMETRICNETWORK Query facade over reaction and constraint data.

    properties (SetAccess = private)
        ReactionIndex
        Constraints
        Metabolites table
    end

    methods
        function obj = StoichiometricNetwork( ...
                reactionIndex, constraints, metabolites)
            obj.ReactionIndex = reactionIndex;
            obj.Constraints = constraints;
            obj.Metabolites = metabolites;
        end

        function value = getModelTableRev(obj)
            value = obj.ReactionIndex.ModelTable;
        end
        function value = getModelRxnRev(obj, index)
            if nargin == 2
                value = obj.ReactionIndex.reaction(index);
            else
                value = obj.ReactionIndex.reaction();
            end
        end
        function value = getModelRxnRevIdx(obj, reactionID)
            value = obj.ReactionIndex.find(reactionID);
        end
        function value = getModelTransRev(obj, index)
            if nargin == 2
                value = obj.ReactionIndex.transition(index);
            else
                value = obj.ReactionIndex.transition();
            end
        end
        function value = getS(obj)
            value = obj.Constraints.SystemMatrix;
        end
        function value = getSBefore(obj)
            value = obj.Constraints.ConstraintMatrix;
        end
        function value = getSType(obj)
            value = cellstr(obj.Constraints.SystemTypes);
        end
        function value = getConstraintTypes(obj)
            value = cellstr(obj.Constraints.ConstraintTypes);
        end
        function value = getIdxRev(obj)
            value = obj.ReactionIndex.ReversiblePairs;
        end
        function value = getDOF(obj)
            value = obj.Constraints.degreeOfFreedom();
        end

        function value = getReactionIndependent(obj, reactionID)
            index = obj.ReactionIndex.findSource(reactionID);
            if isempty(index)
                error("Reaction ID was not found: %s.", reactionID);
            end
            value = obj.ReactionIndex.SourceReactions.Independent(index);
        end

        function metabolite = getSubstrateNameFromRxnID(obj, reactionID)
            metabolite = strings(0, 1);
            index = obj.ReactionIndex.find(reactionID);
            if isempty(index)
                return
            end
            reaction = obj.ReactionIndex.Reactions(index, :);
            substrate = string(obj.Metabolites.Metabolite( ...
                string(obj.Metabolites.Type) == "substrate"));
            reactants = string(reaction.Reactants{1});
            products = string(reaction.Products{1});
            compounds = [reactants(:); products(:)];
            metabolite = substrate(ismember(substrate, compounds));
        end

        function reactionID = ...
                findSubstrateRxnIDFromMetaboliteIrrev(obj, metabolite)
            reactionID = strings(0, 1);
            reactions = obj.ReactionIndex.SourceReactions;
            for i = 1:height(reactions)
                reactants = string(reactions.Reactants{i});
                products = string(reactions.Products{i});
                compounds = [reactants(:); products(:)];
                if ismember(metabolite, compounds)
                    reactionID = string(reactions.Properties.RowNames{i});
                    return
                end
            end
        end

        function value = findCounterReaction(obj, reactionID)
            value = obj.ReactionIndex.counterReaction(reactionID);
        end
        function value = findReaction(obj, compound, productOnly)
            if nargin < 3
                productOnly = false;
            end
            value = obj.ReactionIndex.involving(compound, productOnly);
        end
        function value = isSubstrateMetabolite(obj, compound)
            substrate = string(obj.Metabolites.Metabolite( ...
                string(obj.Metabolites.Type) == "substrate"));
            value = ismember(compound, substrate);
        end
    end
end
