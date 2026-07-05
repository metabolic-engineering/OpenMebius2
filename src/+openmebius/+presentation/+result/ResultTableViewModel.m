classdef ResultTableViewModel
    % RESULTTABLEVIEWMODEL
    % ViewModel for ResultSubTable / ResultMainTable.
    %
    % This class must not depend on App Designer components.

    properties (SetAccess = private)
        Data table
        ColumnEditable logical
        StyleRules struct
    end

    methods

        function obj = ResultTableViewModel(options)

            arguments
                options.Data table = table()
                options.ColumnEditable logical = false(1, 0)
                options.StyleRules struct = struct( ...
                    "Target", {}, ...
                    "Rows", {}, ...
                    "Columns", {}, ...
                    "StyleKey", {}, ...
                    "Value", {})
            end

            obj.Data = options.Data;
            obj.ColumnEditable = options.ColumnEditable;
            obj.StyleRules = options.StyleRules;

        end % constructor

    end % methods

end % classdef
