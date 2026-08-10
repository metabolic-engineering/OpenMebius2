classdef ResultIndexStub < handle

    properties
        ResultIDs (:, 1) string = strings(0, 1)
        RequestedIDs (1, :) string = strings(1, 0)
        BatchSnapshots cell = cell(0, 1)
        RequestedSnapshotIDs (:, 1) string = strings(0, 1)
    end

    methods

        function ids = getResultIDs(obj)

            ids = obj.ResultIDs;

        end

        function snapshots = getBatchSnapshots(obj, ids)

            obj.RequestedSnapshotIDs = string(ids(:));
            snapshots = obj.BatchSnapshots;

        end

        function [data, mask] = loadResultFiles(obj, batchIds)

            obj.RequestedIDs = batchIds;
            data = repmat({struct()}, size(batchIds));
            mask = true(size(batchIds));

        end

        function values = getRSS(~, data)

            values = ones(size(data));

        end

        function values = getIsPassedChi2Test(~, data)

            values = true(size(data));

        end

    end

end
