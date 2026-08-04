classdef WorkflowResultStub < handle

    properties (SetAccess = private)
        Result
        CallCount (1, 1) double = 0
        LastArguments (1, :) cell = cell(1, 0)
    end

    methods

        function obj = WorkflowResultStub(result)

            obj.Result = result;

        end

        function result = run(obj, varargin)

            obj.CallCount = obj.CallCount + 1;
            obj.LastArguments = varargin;
            result = obj.Result;

        end

    end

end
