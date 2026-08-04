classdef LabelConfigurationUpdateServiceStub < handle

    properties
        Called (1, 1) logical = false
        Model
        Experiments
        Batch
        LabelTable table = table()
        RatioTables struct = struct()
        Result = openmebius.application.model ...
            .LabelConfigurationUpdateResult()
        Exception = []
    end

    methods

        function result = apply(obj, model, experiments, batch, ...
                labelTable, ratioTables)

            obj.Called = true;
            obj.Model = model;
            obj.Experiments = experiments;
            obj.Batch = batch;
            obj.LabelTable = labelTable;
            obj.RatioTables = ratioTables;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
