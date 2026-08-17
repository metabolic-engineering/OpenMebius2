classdef ExperimentEditServiceStub < handle

    properties
        Result
        Exception = []
        LastOperation (1, 1) string = ""
        Inputs cell = cell(0, 1)
    end

    methods

        function result = saveInfo(obj, varargin)

            result = obj.execute("saveInfo", varargin);

        end

        function result = saveTracer(obj, varargin)

            result = obj.execute("saveTracer", varargin);

        end

        function result = saveAll(obj, varargin)

            result = obj.execute("saveAll", varargin);

        end

        function result = copyTracerToAllEntries(obj, varargin)

            result = obj.execute("copyTracerToAllEntries", varargin);

        end

    end

    methods (Access = private)

        function result = execute(obj, operation, inputs)

            obj.LastOperation = operation;
            obj.Inputs = inputs;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
