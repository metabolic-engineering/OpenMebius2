classdef MassSpectrometryTemplateRepositoryStub < handle

    properties
        Called (1, 1) logical = false
        OutputPath (1, 1) string = ""
        TemplateData = []
        SheetName (1, 1) string = ""
        Exception = []
    end

    methods

        function write(obj, outputPath, templateData, options)

            arguments
                obj
                outputPath (1, 1) string
                templateData
                options.SheetName (1, 1) string = "MS"
            end

            obj.Called = true;
            obj.OutputPath = outputPath;
            obj.TemplateData = templateData;
            obj.SheetName = options.SheetName;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

        end

    end

end
