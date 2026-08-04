classdef MFAWorkflowObserverStub < handle

    properties
        ProgressIndices (1, :) double = zeros(1, 0)
        ProgressTotals (1, :) double = zeros(1, 0)
        CompletedIndices (1, :) double = zeros(1, 0)
        CancelAfter (1, 1) double = inf
    end

    methods

        function reportProgress(obj, index, total)

            obj.ProgressIndices(end + 1) = index;
            obj.ProgressTotals(end + 1) = total;

        end

        function complete(obj, index, ~)

            obj.CompletedIndices(end + 1) = index;

        end

        function tf = cancellationRequested(obj)

            tf = numel(obj.CompletedIndices) >= obj.CancelAfter;

        end

    end

end
