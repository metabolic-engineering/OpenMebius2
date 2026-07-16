classdef IOModel < openmebius.application.model.ModelWorkspace
    % IOMODEL Compatibility adapter for the legacy model API.

    methods

        function obj = IOModel(modelInput, options)

            arguments
                modelInput
                options.ModelRepository = ...
                    openmebius.infrastructure.model.ModelRepository()
            end

            obj@openmebius.application.model.ModelWorkspace( ...
                modelInput, ...
                ModelRepository = options.ModelRepository);

        end

    end

end
