classdef LabelConfigContext
    % LABELCONFIGCONTEXT Initial state passed to LabelConfig.

    properties (SetAccess = private)
        LabelTable table
        RatioTables struct
    end

    methods

        function obj = LabelConfigContext(options)

            arguments
                options.LabelTable table
                options.RatioTables struct
            end

            obj.LabelTable = options.LabelTable;
            obj.RatioTables = options.RatioTables;

        end % constructor

    end % methods

end % classdef
