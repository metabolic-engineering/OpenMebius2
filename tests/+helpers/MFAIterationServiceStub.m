classdef MFAIterationServiceStub < handle

    properties (SetAccess = private)
        Result
        CallCount (1, 1) double = 0
        LastInput = []
        LastInitialIndependentValues double = []
        LastLinearEqualityMatrix double = zeros(0, 0)
        LastLinearEqualityRightHandSide double = zeros(0, 1)
        ReportOnRun (1, 1) logical = false
    end

    methods

        function obj = MFAIterationServiceStub(result, options)

            arguments
                result
                options.ReportOnRun (1, 1) logical = false
            end

            obj.Result = result;
            obj.ReportOnRun = options.ReportOnRun;

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

            if obj.ReportOnRun
                options.MessageReporter( ...
                    "info", "MFA iteration service invoked.");
            end

            result = obj.Result;

        end

    end

end
