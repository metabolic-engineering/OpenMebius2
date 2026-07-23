classdef BatchTableSelectionMapper
    % BATCHTABLESELECTIONMAPPER Maps UITable selections to batch IDs.

    methods (Static)

        function batchIds = selectedBatchIds(tableData, selection)

            arguments
                tableData table
                selection double
            end

            if isempty(selection)
                error( ...
                    "OpenMebius2:BatchTableSelectionMapper:" + ...
                    "EmptySelection", ...
                "Select at least one batch to configure.");
            end

            if size(selection, 2) < 1 || ...
                    any(~isfinite(selection(:, 1))) || ...
                    any(selection(:, 1) ~= fix(selection(:, 1)))
                error( ...
                    "OpenMebius2:BatchTableSelectionMapper:" + ...
                    "InvalidSelection", ...
                "Batch table selection is invalid.");
            end

            if ~ismember( ...
                    "ID", string(tableData.Properties.VariableNames))
                error( ...
                    "OpenMebius2:BatchTableSelectionMapper:" + ...
                    "MissingIdColumn", ...
                "Batch table does not contain an ID column.");
            end

            rows = unique(selection(:, 1), "stable");

            if any(rows < 1 | rows > height(tableData))
                error( ...
                    "OpenMebius2:BatchTableSelectionMapper:" + ...
                    "SelectionOutOfRange", ...
                "Batch table selection is out of range.");
            end

            batchIds = string(tableData.ID(rows));
            batchIds = batchIds(:);

        end % selectedBatchIds

    end % methods (Static)

end % classdef
