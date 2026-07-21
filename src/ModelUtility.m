classdef ModelUtility < handle

    methods (Static)

        function reversedReaction = flipReversibleReaction(reaction, options)
            % FLIPREVERSIBLEREACTION Flip reversible reaction strings "A <=> B" -> "B <=> A"

            arguments
                reaction (:, 1) string
                options.NotificationReporter (1, 1) function_handle = @(~) []
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
                    options.NotificationReporter( ...
                        openmebius.core.notification.Message( ...
                            "The provided reaction is not reversible: " + ...
                            reaction(k), ...
                            "warning", ...
                            Code = "model.reaction.not-reversible", ...
                            Source = "ModelUtility", ...
                            Audience = "developer", ...
                            Kind = "diagnostic"));
                end

            end

        end

    end

end
