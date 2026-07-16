classdef MFAIterationRunnerStub < handle

    properties (SetAccess = private)
        Result
        CallCount (1, 1) double = 0
        LastProblem = []
        LastRightHandSide double = []
        LastObjective = []
        LastOptions = []
    end

    methods

        function obj = MFAIterationRunnerStub(result)

            obj.Result = result;

        end

        function result = run( ...
                obj, problem, rightHandSide, objective, options, varargin)

            obj.CallCount = obj.CallCount + 1;
            obj.LastProblem = problem;
            obj.LastRightHandSide = rightHandSide;
            obj.LastObjective = objective;
            obj.LastOptions = options;
            result = obj.Result;

        end

    end

end
