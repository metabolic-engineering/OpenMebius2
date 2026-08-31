classdef ResultDiffWorkspaceStub < handle

    properties
        Snapshots (:, 1) cell = cell(0, 1)
        RequestedIDs (:, 1) string = strings(0, 1)
    end

    methods

        function snapshots = getBatchSnapshots(obj, ids)

            obj.RequestedIDs = string(ids(:));
            snapshots = obj.Snapshots;

        end

    end

end
