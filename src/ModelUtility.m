classdef ModelUtility < handle

    methods (Static)

        function reversedReaction = flipReversibleReaction(reaction)
            % FLIPREVERSIBLEREACTION Flip reversible reaction strings "A <=> B" -> "B <=> A"

            arguments
                reaction (:, 1) string
            end

            reversedReaction = reaction;

            reversiblePattern = "^\s*(.*)\s*<=>\s*(.*)\s*$";

            for k = 1:numel(reaction)
                tok = regexp(reaction(k), reversiblePattern, 'tokens', 'once');

                if ~isempty(tok)
                    reactants = strtrim(tok{1});
                    products = strtrim(tok{2});
                    reversedReaction(k) = products + " <=> " + reactants;
                else
                    warning('The provided reaction is not reversible: %s', reaction(k));
                end

            end

        end

    end

end
