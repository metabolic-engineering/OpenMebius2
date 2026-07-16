classdef MFAInputValidationModelStub

    properties
        ReactionIDs (:, 1) string = ["EX_A"; "EX_B"]
        ReactionTypes (:, 1) string = ["efflux"; "efflux"]
        Substrates (:, 1) string = ["A"; "B"]
    end

    methods

        function stoichiometry = getSBefore(obj)

            reactionCount = numel(obj.ReactionIDs);
            stoichiometry = array2table( ...
                eye(reactionCount), ...
                VariableNames = cellstr( ...
                "V" + string(1:reactionCount)), ...
                RowNames = cellstr(obj.ReactionIDs));

        end

        function reactionTypes = getSType(obj)

            reactionTypes = [obj.ReactionTypes; "independent"];

        end

        function reactionTypes = getConstraintTypes(obj)

            reactionTypes = obj.ReactionTypes;

        end

        function substrate = getSubstrateNameFromRxnID( ...
                obj, reactionID)

            index = find(obj.ReactionIDs == string(reactionID), 1);
            substrate = obj.Substrates(index);

        end

    end

end
