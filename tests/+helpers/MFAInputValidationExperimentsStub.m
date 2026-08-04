classdef MFAInputValidationExperimentsStub

    properties
        InfoTable table
        UptakeTable table
    end

    methods

        function obj = MFAInputValidationExperimentsStub( ...
                infoTable, uptakeTable)

            obj.InfoTable = infoTable;
            obj.UptakeTable = uptakeTable;

        end

        function info = getInfoTable(obj)

            info = obj.InfoTable;

        end

        function uptake = getUptakeTable(obj)

            uptake = obj.UptakeTable;

        end

    end

end
