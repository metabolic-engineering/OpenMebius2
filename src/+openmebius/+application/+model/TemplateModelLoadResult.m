classdef TemplateModelLoadResult

    properties (SetAccess = private)
        Model
        ModelLocation openmebius.domain.model.ModelLocation
        Messages (:, 1) string
    end

    methods

        function obj = TemplateModelLoadResult(options)

            arguments
                options.Model
                options.ModelLocation openmebius.domain.model.ModelLocation
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Model = options.Model;
            obj.ModelLocation = options.ModelLocation;
            obj.Messages = options.Messages;

        end

    end

end
