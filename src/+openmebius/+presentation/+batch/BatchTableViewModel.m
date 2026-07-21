classdef BatchTableViewModel

    properties (SetAccess = private)
        Data table
        RawData table
        ColumnEditable logical
        StyleRules struct
    end

    methods

        function obj = BatchTableViewModel(options)

            arguments
                options.Data table = table()
                options.RawData table = table()
                options.ColumnEditable logical = false(1, 0)
                options.StyleRules struct = struct( ...
                    "Rows", {}, ...
                    "Columns", {}, ...
                    "StyleKey", {})
            end

            obj.Data = options.Data;

            if isempty(options.RawData)
                obj.RawData = options.Data;
            else
                obj.RawData = options.RawData;
            end

            obj.ColumnEditable = options.ColumnEditable;
            obj.StyleRules = options.StyleRules;

        end % constructor

    end % methods

end % classdef
