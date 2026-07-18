classdef LabelConfigurationModelStub < handle

    properties
        Called (1, 1) logical = false
        LabelTable table = table()
        RatioTables struct = struct()
    end

    methods

        function updateLabelConfiguration(obj, labelTable, ratioTables)

            obj.Called = true;
            obj.LabelTable = labelTable;
            obj.RatioTables = ratioTables;

        end

    end

end
