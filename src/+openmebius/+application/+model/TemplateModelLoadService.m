classdef TemplateModelLoadService < handle

    properties (Access = private)
        ModelRepository
    end

    methods

        function obj = TemplateModelLoadService(options)

            arguments
                options.ModelRepository = ...
                    openmebius.infrastructure.model.ModelRepository()
            end

            obj.ModelRepository = options.ModelRepository;

        end

        function result = load(obj, modelLocation)

            arguments
                obj
                modelLocation openmebius.domain.model.ModelLocation
            end

            openmebius.application.model.TemplateModelLoadService ...
                .validateModelDirectory(modelLocation);

            model = obj.ModelRepository.load(modelLocation);

            messages = [
                "Model folder found in " + modelLocation.Directory
                "Model loaded successfully."
                ];

            result = openmebius.application.model.TemplateModelLoadResult( ...
                Model = model, ...
                ModelLocation = modelLocation, ...
                Messages = messages);

        end

    end

    methods (Static, Access = private)

        function validateModelDirectory(modelLocation)

            modelDirectory = modelLocation.Directory;

            if modelDirectory == ""
                error( ...
                    "OpenMebius2:TemplateModel:EmptyDirectory", ...
                    "Template model directory is empty.");
            end

            if ~isfolder(modelDirectory)
                error( ...
                    "OpenMebius2:TemplateModel:DirectoryNotFound", ...
                    "Template model directory does not exist: %s", ...
                    modelDirectory);
            end

            entries = dir(modelDirectory);
            names = string({entries.name});
            names = names(names ~= "." & names ~= "..");

            if isempty(names)
                error( ...
                    "OpenMebius2:TemplateModel:DirectoryEmpty", ...
                    "Template model directory is empty: %s", ...
                    modelDirectory);
            end

        end

    end

end
