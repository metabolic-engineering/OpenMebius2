classdef FluxVariabilitySolverStub < handle

    properties (SetAccess = private)
        Result
        EqualityMatrix double = []
        EqualityRightHandSide double = []
        LowerBounds double = []
        UpperBounds double = []
        ReverseCounterpartIndices double = []
        CallCount (1, 1) double = 0
    end

    methods

        function obj = FluxVariabilitySolverStub(result)

            obj.Result = result;

        end

        function result = solve( ...
                obj, equalityMatrix, equalityRightHandSide, ...
                lowerBounds, upperBounds, reverseCounterpartIndices)

            obj.CallCount = obj.CallCount + 1;
            obj.EqualityMatrix = equalityMatrix;
            obj.EqualityRightHandSide = equalityRightHandSide;
            obj.LowerBounds = lowerBounds;
            obj.UpperBounds = upperBounds;
            obj.ReverseCounterpartIndices = ...
                reverseCounterpartIndices;
            result = obj.Result;

        end

    end

end
