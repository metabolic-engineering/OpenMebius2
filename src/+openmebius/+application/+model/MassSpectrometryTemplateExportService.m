classdef MassSpectrometryTemplateExportService < handle
    % MASSSPECTROMETRYTEMPLATEEXPORTSERVICE Exports an MS workbook template.

    properties (Access = private)
        Repository
    end

    methods

        function obj = MassSpectrometryTemplateExportService(options)

            arguments
                options.Repository = openmebius.infrastructure.model ...
                    .MassSpectrometryTemplateRepository()
            end

            obj.Repository = options.Repository;

        end % constructor

        function result = export(obj, model, outputPath)

            arguments
                obj
                model
                outputPath (1, 1) string
            end

            openmebius.application.model ...
                .MassSpectrometryTemplateExportService ...
                .validateModel(model);
            openmebius.application.model ...
                .MassSpectrometryTemplateExportService ...
                .validateOutputPath(outputPath);

            sheetName = "MS";
            templateData = model.getTemplateMSTable();
            obj.Repository.write( ...
                outputPath, templateData, SheetName = sheetName);

            result = openmebius.application.model ...
                .MassSpectrometryTemplateExportResult( ...
                OutputPath = outputPath, ...
                SheetName = sheetName, ...
                Messages = [ ...
                "Template Excel file exported successfully."
                "Template output: " + outputPath]);

        end % export

    end % methods

    methods (Static, Access = private)

        function validateModel(model)

            if isempty(model)
                error( ...
                    "OpenMebius2:MSTemplate:ModelUnavailable", ...
                    "Model is not loaded. Please load a model before " + ...
                    "exporting a template Excel file.");
            end

            if isa(model, "handle") && ~isvalid(model)
                error( ...
                    "OpenMebius2:MSTemplate:ModelUnavailable", ...
                    "Model is not available.");
            end

        end % validateModel

        function validateOutputPath(outputPath)

            if strlength(strtrim(outputPath)) == 0
                error( ...
                    "OpenMebius2:MSTemplate:EmptyOutputPath", ...
                    "Template output path is empty.");
            end

            [outputDirectory, ~, extension] = fileparts(outputPath);

            if outputDirectory ~= "" && ~isfolder(outputDirectory)
                error( ...
                    "OpenMebius2:MSTemplate:DirectoryNotFound", ...
                    "Template output directory does not exist: %s", ...
                    outputDirectory);
            end

            if ~strcmpi(extension, ".xlsx")
                error( ...
                    "OpenMebius2:MSTemplate:InvalidExtension", ...
                    "Template output must use the .xlsx extension.");
            end

        end % validateOutputPath

    end % methods (Static, Access = private)

end % classdef
