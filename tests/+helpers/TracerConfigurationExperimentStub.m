classdef TracerConfigurationExperimentStub < handle

    properties
        EditorTable table = table()
        TracerTable table = table()
        Called (1, 1) logical = false
        Position (1, 2) double = [NaN, NaN]
    end

    methods

        function editorTable = createTableTracerConfig(obj, position)

            obj.Called = true;
            obj.Position = position;
            editorTable = obj.EditorTable;

        end

        function tracerTable = getTracerTable(obj)

            tracerTable = obj.TracerTable;

        end

    end

end
