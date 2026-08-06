classdef ResultComparisonCatalogServiceStub < handle

    properties
        Catalog openmebius.application.result.ResultComparisonCatalog
        Exception = []
    end

    methods

        function obj = ResultComparisonCatalogServiceStub()

            obj.Catalog = openmebius.application.result ...
                .ResultComparisonCatalog();

        end

        function catalog = load(obj, ~, ~)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            catalog = obj.Catalog;

        end

    end

end
