classdef ResultInformationWorkspaceStub < handle

    properties
        Data (1, 1) struct = struct
        Snapshot (1, 1) struct = struct
        IsAvailable (1, 1) logical = true
    end

    methods

        function [data, mask] = loadResultFiles(obj, ~, options)

            arguments
                obj
                ~
                options.readstatus (1, 4) logical = true(1, 4) %#ok<INUSA>
            end

            data = {obj.Data};
            mask = obj.IsAvailable;

        end

        function snapshots = getBatchSnapshots(obj, ~)

            snapshots = {obj.Snapshot};

        end

    end

end
