classdef WorkspaceTableViewModel
    % WORKSPACETABLEVIEWMODEL Complete display state for one UITable.

    properties (SetAccess = private)
        Data table
        ColumnName (1, :) cell
        RowName (1, :) cell
        ColumnEditable (1, :) logical
        ErrorRows (:, 1) double
    end

    methods

        function obj = WorkspaceTableViewModel(options)

            arguments
                options.Data table = table()
                options.ColumnEditable logical = false
                options.ErrorRows double = zeros(0, 1)
            end

            data = options.Data;
            editable = logical(options.ColumnEditable);

            if isscalar(editable)
                editable = repmat(editable, 1, width(data));
            else
                editable = reshape(editable, 1, []);
            end

            if numel(editable) ~= width(data)
                error( ...
                    "OpenMebius2:WorkspaceTableViewModel:" + ...
                    "InvalidEditableColumns", ...
                "ColumnEditable must contain one value per column.");
            end

            errorRows = unique(options.ErrorRows(:), "stable");

            if any(~isfinite(errorRows) | ...
                    errorRows ~= fix(errorRows) | ...
                    errorRows < 1 | errorRows > height(data))
                error( ...
                    "OpenMebius2:WorkspaceTableViewModel:" + ...
                    "InvalidErrorRows", ...
                "ErrorRows must reference rows in the table.");
            end

            obj.Data = data;
            obj.ColumnName = reshape( ...
                cellstr(string(data.Properties.VariableNames)), 1, []);
            obj.RowName = reshape( ...
                cellstr(string(data.Properties.RowNames)), 1, []);
            obj.ColumnEditable = editable;
            obj.ErrorRows = errorRows;

        end % constructor

    end % methods

end % classdef
