classdef ExperimentComparisonWorkspaceStub < handle

    properties
        Collection
    end

    methods

        function obj = ExperimentComparisonWorkspaceStub(collection)

            obj.Collection = collection;

        end

        function collection = getCollection(obj)

            collection = obj.Collection;

        end

    end

end
