classdef MassSpectrometryTemplateExportServiceStub < handle

    properties
        Called (1, 1) logical = false
        Model = []
        OutputPath (1, 1) string = ""
        Result = []
        Exception = []
    end

    methods

        function result = export(obj, model, outputPath)

            obj.Called = true;
            obj.Model = model;
            obj.OutputPath = outputPath;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
