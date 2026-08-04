classdef LabelConfigContext
    % LABELCONFIGCONTEXT Initial state passed to LabelConfig.

    properties (SetAccess = private)
        LabelTable table
        RatioTables struct
        Action openmebius.presentation.model.LabelConfigAction
    end

    methods

        function obj = LabelConfigContext(options)

            arguments
                options.LabelTable table
                options.RatioTables struct
                options.Action = []
            end

            obj.LabelTable = options.LabelTable;
            obj.RatioTables = options.RatioTables;

            if isempty(options.Action)
                obj.Action = openmebius.presentation.model ...
                    .LabelConfigAction( ...
                    options.LabelTable, options.RatioTables);
            else
                obj.Action = options.Action;
            end

        end % constructor

    end % methods

end % classdef
