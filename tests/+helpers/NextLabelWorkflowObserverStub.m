classdef NextLabelWorkflowObserverStub < handle

    properties (SetAccess = private)
        CallCount (1, 1) double = 0
        LastMDV double = []
        LastEMUCount (1, 1) double = 0
        CompletedCount (1, 1) double = 0
    end

    methods

        function [lowerBounds, upperBounds, output] = ...
                calculate(obj, mdv, substrateEMUs)

            obj.CallCount = obj.CallCount + 1;
            obj.LastMDV = mdv;
            obj.LastEMUCount = numel(substrateEMUs);
            lowerBounds = [mdv; obj.LastEMUCount];
            upperBounds = lowerBounds + 1;
            output = struct(Call = obj.CallCount);

        end

        function complete(obj, ~, ~, ~)

            obj.CompletedCount = obj.CompletedCount + 1;

        end

    end

end
