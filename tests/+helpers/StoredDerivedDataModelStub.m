classdef StoredDerivedDataModelStub

    properties
        MSTable table
        TargetMetabolites (:, 1) string
    end

    methods

        function obj = StoredDerivedDataModelStub(msTable, targets)

            obj.MSTable = msTable;
            obj.TargetMetabolites = string(targets(:));

        end

        function value = getMSTable(obj)

            value = obj.MSTable;

        end

        function value = getTargetMetaboliteList(obj)

            value = obj.TargetMetabolites;

        end

    end

end % classdef
