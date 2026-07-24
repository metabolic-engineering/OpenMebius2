classdef MFAIterationServiceStub < handle

    properties (SetAccess = private)
        Result
        CallCount (1, 1) double = 0
        LastInput = []
        LastInitialIndependentValues double = []
        LastLinearEqualityMatrix double = zeros(0, 0)
        LastLinearEqualityRightHandSide double = zeros(0, 1)
    end

    methods

        function obj = MFAIterationServiceStub(result)

            obj.Result = result;

        end

        function result = run(obj, input, options)

            arguments
                obj
                input
                options.InitialIndependentValues double = []
                options.LinearEqualityMatrix double = zeros(0, 0)
                options.LinearEqualityRightHandSide double = zeros(0, 1)
                options.MessageReporter function_handle = @(~, ~) []
            end

            obj.CallCount = obj.CallCount + 1;
            obj.LastInput = input;
            obj.LastInitialIndependentValues = ...
                options.InitialIndependentValues;
            obj.LastLinearEqualityMatrix = ...
                options.LinearEqualityMatrix;
            obj.LastLinearEqualityRightHandSide = ...
                options.LinearEqualityRightHandSide;
            result = obj.Result;

        end

    end

end
