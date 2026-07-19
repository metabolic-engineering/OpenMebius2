classdef ExperimentSubstrateModelStub

    properties
        tableAtom table = table()
    end

    properties (Access = private)
        SubstrateTable table
    end

    methods

        function obj = ExperimentSubstrateModelStub(metabolites)

            obj.SubstrateTable = table( ...
                string(metabolites(:)), ...
                VariableNames = "Metabolite");

        end

        function data = getSubstrateTable(obj)

            data = obj.SubstrateTable;

        end

        function data = getAtomTable(obj)

            data = obj.tableAtom;

        end

    end

end % classdef
