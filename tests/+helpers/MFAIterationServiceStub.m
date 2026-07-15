classdef MFAIterationServiceStub < handle

    properties (SetAccess = private)
        Result
        CallCount (1, 1) double = 0
    end

    methods

        function obj = MFAIterationServiceStub(result)

            obj.Result = result;

        end

        function result = run(obj, varargin)

            obj.CallCount = obj.CallCount + 1;
            result = obj.Result;

        end

    end

end
