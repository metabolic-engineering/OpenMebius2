classdef SubstrateEMUModelStub < handle

    properties
        PreparationCount (1, 1) double = 0
        EMUTemplate struct
        TracerDefinitions table
    end

    methods

        function obj = SubstrateEMUModelStub()

            obj.EMUTemplate = struct;
            obj.EMUTemplate.APattern = [1, 10];
            obj.EMUTemplate.BPattern = [2, 20];
            obj.TracerDefinitions = table( ...
                ["A-label"; "B-label"], ...
                VariableNames = {'Name'});

        end

        function substrateEMUsAll(obj)

            obj.PreparationCount = obj.PreparationCount + 1;

        end

        function value = getLabelStructEMU(obj)

            value = obj.EMUTemplate;

        end

        function value = getTableLabelView(obj)

            value = obj.TracerDefinitions;

        end

    end

end
