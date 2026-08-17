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
        DuplicatedIds (:, 1) string = strings(0, 1)
        MovedIds (:, 1) string = strings(0, 1)
        MoveDirection (1, 1) string = ""
        AddedNames (:, 1) string = strings(0, 1)
        AddedExperiments (:, 1) cell = cell(0, 1)
        AddedDescriptions (:, 1) string = strings(0, 1)
        AddedConfigs (:, 1) cell = cell(0, 1)
        EditedId (1, 1) string = ""
        EditedName (1, 1) string = ""
        EditedExperiments cell = cell(0, 1)
        EditedDescription (1, 1) string = ""
        EditedConfig struct = struct()
        Exception = []
        RequestedStatusIds (:, 1) string = strings(0, 1)
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

        function duplicateBatches(obj, batchIds)

            obj.throwIfRequested();
            obj.DuplicatedIds = string(batchIds(:));

        end

        function moveBatches(obj, batchIds, direction)

            obj.throwIfRequested();
            obj.MovedIds = string(batchIds(:));
            obj.MoveDirection = string(direction);

        end

        function addBatch(obj, name, experiments, description, config)

            obj.throwIfRequested();
            obj.AddedNames(end + 1, 1) = string(name);
            obj.AddedExperiments{end + 1, 1} = experiments;
            obj.AddedDescriptions(end + 1, 1) = string(description);
            obj.AddedConfigs{end + 1, 1} = config;

        end

        function editBatch( ...
                obj, batchId, name, experiments, description, config)

            obj.throwIfRequested();
            obj.EditedId = string(batchId);
            obj.EditedName = string(name);
            obj.EditedExperiments = experiments;
            obj.EditedDescription = string(description);
            obj.EditedConfig = config;

        end

        function [data, columnEditable] = getBatchForGUI(obj)

            data = obj.Data;
            columnEditable = obj.ColumnEditable;

        end

        function status = getBatchStatus(obj, ids)

            obj.RequestedStatusIds = string(ids(:));

            if isscalar(obj.Status)
                status = repmat(obj.Status, numel(ids), 1);
            else
                status = obj.Status(:);
            end

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
