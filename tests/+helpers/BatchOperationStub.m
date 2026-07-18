classdef BatchOperationStub < handle

    properties
        Data table = table( ...
            "batch-a", ...
            "Batch A", ...
            "exp-a", ...
            "", ...
            VariableNames = ["ID", "Name", "Experiment", "Description"])
        ColumnEditable logical = [false, true, false, true]
        Status (:, 1) string = "ready"
        AutoFillCalled (1, 1) logical = false
        SaveCalled (1, 1) logical = false
        SavedTable table = table()
        RemovedIds (:, 1) string = strings(0, 1)
        Exception = []
    end

    methods

        function autoFillBatch(obj)

            obj.throwIfRequested();
            obj.AutoFillCalled = true;

        end

        function updateBatchFromGUI(obj, tableData)

            obj.throwIfRequested();
            obj.SavedTable = tableData;
            obj.Data = tableData;

        end

        function saveBatchFile(obj)

            obj.throwIfRequested();
            obj.SaveCalled = true;

        end

        function removeBatch(obj, batchId)

            obj.throwIfRequested();
            obj.RemovedIds(end + 1, 1) = string(batchId);

        end

        function [data, columnEditable] = getBatchForGUI(obj)

            data = obj.Data;
            columnEditable = obj.ColumnEditable;

        end

        function status = getBatchStatus(obj, ids)

            status = repmat(obj.Status(1), numel(ids), 1);

        end

    end

    methods (Access = private)

        function throwIfRequested(obj)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

        end

    end

end % classdef
