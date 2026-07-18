classdef ResultPlotWorkspaceStub < handle

    properties
        ConfidenceIntervalData = []
        Called (1, 1) logical = false
        BatchID (1, 1) string = ""
        ReactionID (1, 1) string = ""
    end

    methods

        function data = getCIReaction(obj, batchID, reactionID)

            obj.Called = true;
            obj.BatchID = batchID;
            obj.ReactionID = reactionID;
            data = obj.ConfidenceIntervalData;

        end

    end

end
