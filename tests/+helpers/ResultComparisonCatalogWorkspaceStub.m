classdef ResultComparisonCatalogWorkspaceStub < handle

    properties
        Data (1, :) cell = cell(1, 0)
        Mask (1, :) logical = false(1, 0)
        RequestedIDs (1, :) string = strings(1, 0)
        ReadStatus (1, 4) logical = true(1, 4)
    end

    methods

        function [data, mask] = loadResultFiles(obj, ids, options)

            arguments
                obj
                ids (1, :) string
                options.readstatus (1, 4) logical = true(1, 4)
            end

            obj.RequestedIDs = ids;
            obj.ReadStatus = options.readstatus;
            data = obj.Data;
            mask = obj.Mask;

        end

    end

end
