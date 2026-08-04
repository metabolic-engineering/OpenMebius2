classdef LabelConfigurationEditorState
    % LABELCONFIGURATIONEDITORSTATE Initial domain data for LabelConfig.

    properties (SetAccess = private)
        LabelTable table
        RatioTables struct
    end

    methods

        function obj = LabelConfigurationEditorState( ...
                labelTable, ratioTables)

            arguments
                labelTable table
                ratioTables struct
            end

            if height(labelTable) ~= numel(fieldnames(ratioTables))
                error( ...
                    "OpenMebius2:LabelConfigurationEditorState:" + ...
                    "InconsistentData", ...
                    "Label rows and ratio table entries must have " + ...
                "the same length.");
            end

            obj.LabelTable = labelTable;
            obj.RatioTables = ratioTables;

        end % constructor

    end % methods

end % classdef
