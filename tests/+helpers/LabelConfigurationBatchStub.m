classdef LabelConfigurationBatchStub < handle

    properties
        Called (1, 1) logical = false
        Experiments
    end

    methods

        function updateExperimentalData(obj, experiments)

            obj.Called = true;
            obj.Experiments = experiments;

        end

    end

end
