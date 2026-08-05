classdef ResultPlotWorkspaceStub < handle

    properties
        ConfidenceIntervalData = []
        OptimizationStateData = []
        Called (1, 1) logical = false
        OptimizationCalled (1, 1) logical = false
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

        function data = getOptimizationState(obj, batchID)

            obj.OptimizationCalled = true;
            obj.BatchID = batchID;
            data = obj.OptimizationStateData;

        end

    end

end
