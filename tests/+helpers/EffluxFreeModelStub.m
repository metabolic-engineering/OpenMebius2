classdef EffluxFreeModelStub < handle

    properties (SetAccess = private)
        Substrates (:, 1) string
        ReactionIDs (:, 1) string
        Independent (:, 1) logical
        SetCount (1, 1) double = 0
    end

    methods

        function obj = EffluxFreeModelStub( ...
                substrates, reactionIDs, independent)

            obj.Substrates = string(substrates(:));
            obj.ReactionIDs = string(reactionIDs(:));
            obj.Independent = logical(independent(:));

        end

        function reactionID = ...
                findSubstrateRxnIDFromMetaboliteIrrev(obj, substrate)

            index = find(obj.Substrates == string(substrate), 1);
            reactionID = obj.ReactionIDs(index);

        end

        function value = getReactionIndependent(obj, reactionID)

            index = find(obj.ReactionIDs == string(reactionID), 1);
            value = obj.Independent(index);

        end

        function setReactionIndependent(obj, reactionID, independent)

            index = find(obj.ReactionIDs == string(reactionID), 1);
            obj.Independent(index) = logical(independent);
            obj.SetCount = obj.SetCount + 1;

        end

        function makeEffluxFree(obj, substrates)

            for substrate = string(substrates(:)).'
                reactionID = ...
                    obj.findSubstrateRxnIDFromMetaboliteIrrev(substrate);
                index = find(obj.ReactionIDs == reactionID, 1);
                obj.Independent(index) = true;
            end

        end

    end

end
