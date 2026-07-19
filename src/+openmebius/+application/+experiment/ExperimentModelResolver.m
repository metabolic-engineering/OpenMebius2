classdef ExperimentModelResolver
    % EXPERIMENTMODELRESOLVER Resolves a model without direct construction.

    properties (Access = private)
        ModelRepository
    end

    methods

        function obj = ExperimentModelResolver(options)
            arguments
                options.ModelRepository = ...
                    openmebius.infrastructure.model.ModelRepository()
            end
            obj.ModelRepository = options.ModelRepository;
        end

        function [model, directory] = resolve(obj, modelInput)
            if isa(modelInput, 'EMUModel')
                model = modelInput;
                if ~isvalid(model)
                    error( ...
                        "OpenMebius2:ExperimentModelResolver:InvalidModel", ...
                        "The model object is invalid.");
                end
                directory = model.getModelLocation().Directory;
                return
            end

            location = openmebius.domain.model.ModelLocation ...
                .fromInput(modelInput);
            directory = location.Directory;
            if directory == ""
                error( ...
                    "OpenMebius2:ExperimentModelResolver:EmptyDirectory", ...
                    "The model directory is empty.");
            end
            model = obj.ModelRepository.load(location);
        end

    end

end
