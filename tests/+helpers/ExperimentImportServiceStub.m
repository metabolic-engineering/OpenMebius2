classdef ExperimentImportServiceStub < handle

    properties
        ImportResult
        ReloadResult
        Exception = []
        LastOperation (1, 1) string = ""
        Inputs cell = cell(0, 1)
    end

    methods

        function result = importFiles(obj, varargin)

            obj.LastOperation = "importFiles";
            obj.Inputs = varargin;
            obj.throwIfNeeded();
            result = obj.ImportResult;

        end

        function result = reload(obj, varargin)

            obj.LastOperation = "reload";
            obj.Inputs = varargin;
            obj.throwIfNeeded();
            result = obj.ReloadResult;

        end

    end

    methods (Access = private)

        function throwIfNeeded(obj)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

        end

    end

end
