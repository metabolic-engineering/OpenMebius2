classdef ExperimentComparisonServiceStub < handle

    properties
        Catalog = []
        Selection = []
        Exception = []
        LastOperation (1, 1) string = ""
        Experiments
        ExperimentNames (1, :) string = strings(1, 0)
        DataNames (1, :) string = strings(1, 0)
    end

    methods

        function result = loadCatalog(obj, experiments)

            obj.LastOperation = "catalog";
            obj.Experiments = experiments;
            obj.throwIfNeeded();
            result = obj.Catalog;

        end

        function result = loadSelection( ...
                obj, experiments, experimentNames, dataNames)

            obj.LastOperation = "selection";
            obj.Experiments = experiments;
            obj.ExperimentNames = reshape(string(experimentNames), 1, []);
            obj.DataNames = reshape(string(dataNames), 1, []);
            obj.throwIfNeeded();
            result = obj.Selection;

        end

    end

    methods (Access = private)

        function throwIfNeeded(obj)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

        end

    end

end
