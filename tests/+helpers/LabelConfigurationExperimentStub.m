classdef LabelConfigurationExperimentStub < handle

    properties
        Called (1, 1) logical = false
        Model
    end

    methods

        function updateModel(obj, model)

            obj.Called = true;
            obj.Model = model;

        end

    end

end
