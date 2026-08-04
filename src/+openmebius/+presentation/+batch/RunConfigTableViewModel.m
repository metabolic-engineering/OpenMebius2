classdef RunConfigTableViewModel
    % RUNCONFIGTABLEVIEWMODEL Typed table presentation data.

    properties (SetAccess = private)
        Data table
        ColumnName (1, :) cell
        RowName (1, :) cell
        ColumnEditable (1, :) logical
        Metadata
    end

    methods

        function obj = RunConfigTableViewModel(options)

            arguments
                options.Data table = table()
                options.ColumnName (1, :) cell = {}
                options.RowName (1, :) cell = {}
                options.ColumnEditable (1, :) logical = false(1, 0)
                options.Metadata = []
            end

            obj.Data = options.Data;
            obj.ColumnName = options.ColumnName;
            obj.RowName = options.RowName;
            obj.ColumnEditable = options.ColumnEditable;
            obj.Metadata = options.Metadata;

        end % constructor

    end % methods

end % classdef
