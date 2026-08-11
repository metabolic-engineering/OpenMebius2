classdef RecoverableBatchStub < handle

    properties
        Data table = table( ...
            strings(0, 1), strings(0, 1), strings(0, 1), strings(0, 1), ...
            'VariableNames', ...
            {'ID', 'Name', 'Experiment', 'Description'})
        RecoveredEntries cell = cell(0, 1)
    end

    methods

        function data = getBatchForGUI(obj)

            data = obj.Data;

        end

        function ids = recoverBatches(obj, entries)

            obj.RecoveredEntries = entries;
            ids = strings(numel(entries), 1);

            for index = 1:numel(entries)
                ids(index) = string(entries{index}.ID);
            end

        end

    end

end
