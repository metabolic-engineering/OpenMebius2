classdef ModelOperationController < handle
    % MODELOPERATIONCONTROLLER Runs model-area commands.

    properties (Access = private)
        TemplateModelLoadService
    end

    methods

        function obj = ModelOperationController(options)

            arguments
                options.TemplateModelLoadService = ...
                    openmebius.application.model.TemplateModelLoadService()
            end

            obj.TemplateModelLoadService = ...
                options.TemplateModelLoadService;

        end % constructor

        function outcome = loadTemplate(obj, modelLocation)

            arguments
                obj
                modelLocation openmebius.domain.model.ModelLocation
            end

            try
                result = obj.TemplateModelLoadService.load(modelLocation);
                outcome = openmebius.application.model ...
                    .ModelOperationOutcome( ...
                        "finished", Result = result);
            catch exception
                outcome = openmebius.application.model ...
                    .ModelOperationOutcome( ...
                        "error", ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % loadTemplate

    end % methods

end % classdef
