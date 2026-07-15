classdef SubstrateEMUExperimentsStub

    properties
        TracerTable table
    end

    methods

        function obj = SubstrateEMUExperimentsStub(tracerTable)

            obj.TracerTable = tracerTable;

        end

        function value = getTracerTable(obj)

            value = obj.TracerTable;

        end

    end

end
