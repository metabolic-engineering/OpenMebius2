classdef ReactionExpression
    % REACTIONEXPRESSION Domain operations for reaction expressions.

    methods (Static)

        function [reversed, isReversible] = reverseReversible(reactions)
            % REVERSEREVERSIBLE Reverse expressions such as A <=> B.

            arguments
                reactions string
            end

            reversed = reactions;
            isReversible = false(size(reactions));
            reversiblePattern = "^\s*(.*)\s*<=>\s*(.*)\s*$";

            for reactionIndex = 1:numel(reactions)
                tokens = regexp( ...
                    reactions(reactionIndex), ...
                    reversiblePattern, ...
                    "tokens", ...
                "once");

                if isempty(tokens)
                    continue
                end

                reactants = strtrim(string(tokens{1}));
                products = strtrim(string(tokens{2}));
                reversed(reactionIndex) = ...
                    products + " <=> " + reactants;
                isReversible(reactionIndex) = true;
            end

        end % reverseReversible

    end % methods (Static)

end % classdef
