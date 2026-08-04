classdef TracerConfigurationServiceStub < handle

    properties
        Result = []
        Exception = []
        LastOperation (1, 1) string = ""
        Experiments
        Position (1, 2) double = [NaN, NaN]
        EditorTable table = table()
        CurrentTracerTable table = table()
    end

    methods

        function result = prepare( ...
                obj, experiments, currentTracerTable, position)

            obj.LastOperation = "prepare";
            obj.Experiments = experiments;
            obj.CurrentTracerTable = currentTracerTable;
            obj.Position = position;
            result = obj.complete();

        end

        function result = load(obj, experiments, position)

            obj.LastOperation = "load";
            obj.Experiments = experiments;
            obj.Position = position;
            result = obj.complete();

        end

        function result = apply(obj, position, editorTable)

            obj.LastOperation = "apply";
            obj.Position = position;
            obj.EditorTable = editorTable;
            result = obj.complete();

        end

    end

    methods (Access = private)

        function result = complete(obj)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
