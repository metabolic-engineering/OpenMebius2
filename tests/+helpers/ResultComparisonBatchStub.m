classdef ResultComparisonBatchStub < handle

    properties
        Data table = table()
        Statuses (:, 1) string = strings(0, 1)
        RequestedIDs (:, 1) string = strings(0, 1)
    end

    methods

        function data = getBatchForGUI(obj)

            data = obj.Data;

        end

        function statuses = getBatchStatus(obj, ids)

            obj.RequestedIDs = string(ids(:));
            statuses = obj.Statuses;

        end

    end

end
