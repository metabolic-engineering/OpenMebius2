classdef ResultRangePlotWorkspaceStub < handle

    properties
        BatchIDs (:, 1) string = strings(0, 1)
        Overviews (:, 1) cell = cell(0, 1)
        CalledBatchIDs (:, 1) string = strings(0, 1)
    end

    methods

        function addOverview(obj, batchID, overview)

            obj.BatchIDs(end + 1, 1) = batchID;
            obj.Overviews{end + 1, 1} = overview;

        end

        function overview = getFluxOverView(obj, batchID)

            obj.CalledBatchIDs(end + 1, 1) = batchID;
            index = find(obj.BatchIDs == batchID, 1);

            if isempty(index)
                overview = table();
                return
            end

            overview = obj.Overviews{index};

        end

    end

end
