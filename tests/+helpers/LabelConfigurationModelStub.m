classdef LabelConfigurationModelStub < handle

    properties
        Called (1, 1) logical = false
        LabelTable table = table()
        RatioTables struct = struct()
        ThrowOnRead (1, 1) logical = false
    end

    methods

        function updateLabelConfiguration(obj, labelTable, ratioTables)

            obj.Called = true;
            obj.LabelTable = labelTable;
            obj.RatioTables = ratioTables;

        end

        function labelTable = getTableLabelView(obj)

            obj.throwReadFailureIfRequested();
            labelTable = obj.LabelTable;

        end

        function ratioTables = getLabelStructView(obj)

            obj.throwReadFailureIfRequested();
            ratioTables = obj.RatioTables;

        end

    end

    methods (Access = private)

        function throwReadFailureIfRequested(obj)

            if obj.ThrowOnRead
                error( ...
                    "OpenMebius2:Test:LabelConfigurationReadFailed", ...
                    "Label configuration could not be read.");
            end

        end

    end

end
