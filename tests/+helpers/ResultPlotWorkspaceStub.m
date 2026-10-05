classdef ResultPlotWorkspaceStub < handle

    properties
        ConfidenceIntervalData = []
        OptimizationStateData = []
        Called (1, 1) logical = false
        OptimizationCalled (1, 1) logical = false
        IncludeExitFlags (1, 1) logical = true
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

        function data = getOptimizationState(obj, batchID, options)

            arguments
                obj
                batchID
                options.IncludeExitFlags (1, 1) logical = true
            end

            obj.OptimizationCalled = true;
            obj.IncludeExitFlags = options.IncludeExitFlags;
            obj.BatchID = batchID;
            data = obj.OptimizationStateData;

        end

    end

end
