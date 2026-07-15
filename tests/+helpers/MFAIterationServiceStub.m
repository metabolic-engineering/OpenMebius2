classdef MFAIterationServiceStub < handle

    properties (SetAccess = private)
        Result
        CallCount (1, 1) double = 0
        LastInput = []
    end

    methods

        function obj = MFAIterationServiceStub(result)

            obj.Result = result;

        end

        function result = run(obj, input, varargin)

            obj.CallCount = obj.CallCount + 1;
            obj.LastInput = input;
            result = obj.Result;

        end

    end

end
