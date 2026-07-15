classdef WorkflowResultStub < handle

    properties (SetAccess = private)
        Result
        CallCount (1, 1) double = 0
    end

    methods

        function obj = WorkflowResultStub(result)

            obj.Result = result;

        end

        function result = run(obj, varargin)

            obj.CallCount = obj.CallCount + 1;
            result = obj.Result;

        end

    end

end
