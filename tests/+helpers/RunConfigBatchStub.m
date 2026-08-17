classdef RunConfigBatchStub < handle

    properties
        Config struct = ...
            openmebius.domain.batch.BatchConfig.defaultConfig()
        ConfigUpdateCount (1, 1) double = 0
        FragmentUpdateCount (1, 1) double = 0
        LastFragmentSelections = []
        FailFragmentUpdate (1, 1) logical = false
        Name (1, 1) string = "Batch A"
        Description (1, 1) string = ""
        MetadataUpdateCount (1, 1) double = 0
    end

    methods

        function tableData = getBatchForGUI(obj)

            tableData = table( ...
                "batch-a", ...
                obj.Name, ...
                "exp-a", ...
                obj.Description, ...
                VariableNames = ...
                ["ID", "Name", "Experiment", "Description"]);

        end

        function updateBatchFromGUI(obj, tableData)

            obj.Name = string(tableData.Name(1));
            obj.Description = string(tableData.Description(1));
            obj.MetadataUpdateCount = obj.MetadataUpdateCount + 1;

        end

        function config = getBatchConfig(obj, ids)

            config = repmat(obj.Config, numel(ids), 1);

            if isscalar(ids)
                config = config(1);
            end

        end

        function updateBatchConfig(obj, ~, config)

            obj.Config = config(1);
            obj.ConfigUpdateCount = obj.ConfigUpdateCount + 1;

        end

        function selections = getBatchMSFragmentSelections(~, batchIDs)

            selections = repmat(struct( ...
                BatchID = "", ...
                ExperimentNames = "exp-a", ...
                FragmentNames = ["fragment-a"; "fragment-b"], ...
                Selection = [false; true]), ...
                1, numel(batchIDs));

            for batchIndex = 1:numel(batchIDs)
                selections(batchIndex).BatchID = batchIDs(batchIndex);
            end

        end

        function updateBatchMSFragmentSelections(obj, selections)

            obj.LastFragmentSelections = selections;
            obj.FragmentUpdateCount = obj.FragmentUpdateCount + 1;

            if obj.FailFragmentUpdate
                error( ...
                    "OpenMebius2:Test:FragmentUpdateFailed", ...
                    "Fragment update failed.");
            end

        end

        function tableData = getBatchGridReactionTable(obj, ~)

            reactionIDs = ["R1"; "R2"];
            reactions = ["A -> B"; "B -> C"];
            selection = true(2, 1);
            stored = obj.Config.CIConf.grid.reactions;
            storedIDs = string(stored.id(:));
            [isStored, storedIndex] = ismember(reactionIDs, storedIDs);

            if any(isStored)
                storedSelection = logical(stored.select(:));
                selection(isStored) = ...
                    storedSelection(storedIndex(isStored));
            end

            tableData = table( ...
                selection, reactionIDs, reactions, ...
                VariableNames = ["Select", "ID", "Reaction"]);

        end

    end

end % classdef
