classdef ModelTableEditor
    % MODELTABLEEDITOR Applies row-level edits to the model workspace table.

    methods (Static)

        function [updatedTable, insertedRow] = addReaction( ...
                modelTable, reactionID, afterRow)

            arguments
                modelTable table
                reactionID (1, 1) string
                afterRow double = []
            end

            openmebius.presentation.model.ModelTableEditor ...
                .assertModelTable(modelTable);

            reactionID = strtrim(reactionID);

            if reactionID == ""
                error( ...
                    "OpenMebius2:ModelTableEditor:ReactionIDRequired", ...
                    "Reaction ID is required.");
            end

            rowNames = string(modelTable.Properties.RowNames);

            if any(rowNames == reactionID)
                error( ...
                    "OpenMebius2:ModelTableEditor:DuplicateReactionID", ...
                    "Reaction ID '%s' already exists.", reactionID);
            end

            if isempty(afterRow)
                afterRow = height(modelTable);
            else
                afterRow = afterRow(1);
            end

            if ~isscalar(afterRow) || ~isfinite(afterRow) || ...
                    afterRow < 0 || afterRow > height(modelTable) || ...
                    fix(afterRow) ~= afterRow
                error( ...
                    "OpenMebius2:ModelTableEditor:InvalidInsertionRow", ...
                    "The reaction insertion row is invalid.");
            end

            newRow = openmebius.presentation.model.ModelTableEditor ...
                .emptyReactionRow(modelTable);
            newRow.Properties.RowNames = cellstr(reactionID);
            insertedRow = afterRow + 1;

            updatedTable = [ ...
                modelTable(1:afterRow, :); ...
                newRow; ...
                modelTable(insertedRow:end, :)];

        end % addReaction

        function [updatedTable, selectedRow] = removeReactions( ...
                modelTable, rows)

            arguments
                modelTable table
                rows double
            end

            openmebius.presentation.model.ModelTableEditor ...
                .assertModelTable(modelTable);

            rows = unique(rows(:), "stable");

            if isempty(rows)
                updatedTable = modelTable;
                selectedRow = zeros(0, 1);
                return
            end

            if any(~isfinite(rows)) || any(rows < 1) || ...
                    any(rows > height(modelTable)) || ...
                    any(fix(rows) ~= rows)
                error( ...
                    "OpenMebius2:ModelTableEditor:InvalidRemovalRow", ...
                    "The selected reaction row is invalid.");
            end

            firstRemovedRow = min(rows);
            updatedTable = modelTable;
            updatedTable(rows, :) = [];

            if isempty(updatedTable)
                selectedRow = zeros(0, 1);
            else
                selectedRow = min(firstRemovedRow, height(updatedTable));
            end

        end % removeReactions

        function reactionID = nextReactionID(modelTable)

            arguments
                modelTable table
            end

            baseID = "new_reaction";
            reactionID = baseID;
            rowNames = string(modelTable.Properties.RowNames);
            suffix = 2;

            while any(rowNames == reactionID)
                reactionID = baseID + "_" + suffix;
                suffix = suffix + 1;
            end

        end % nextReactionID

    end

    methods (Static, Access = private)

        function assertModelTable(modelTable)

            required = ["Reaction", "Transition", "Independent", "x", "y"];

            if ~all(ismember( ...
                    required, string(modelTable.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:ModelTableEditor:InvalidTable", ...
                    "The model table must contain Reaction, Transition, " + ...
                    "Independent, x, and y columns.");
            end

        end % assertModelTable

        function row = emptyReactionRow(modelTable)

            if isempty(modelTable)
                row = table( ...
                    {''}, ...
                    {''}, ...
                    false, ...
                    NaN, ...
                    NaN, ...
                    VariableNames = [ ...
                    "Reaction", "Transition", "Independent", "x", "y"]);
                row = row(:, modelTable.Properties.VariableNames);
                return
            end

            row = modelTable(1, :);
            row.Reaction = {''};
            row.Transition = {''};
            row.Independent = false;
            row.x = NaN;
            row.y = NaN;

        end % emptyReactionRow

    end

end
