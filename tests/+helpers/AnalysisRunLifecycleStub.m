classdef AnalysisRunLifecycleStub < handle

    properties
        StartSucceeded (1, 1) logical = true
        StartMessage (1, 1) string = ""
        FinishErrors (:, 1) string = strings(0, 1)
        StartCallCount (1, 1) double = 0
        FinishCallCount (1, 1) double = 0
    end

    methods

        function [metadata, isSuccess, message] = start(obj, varargin)

            obj.StartCallCount = obj.StartCallCount + 1;
            metadata = struct(Run = obj.StartCallCount);
            isSuccess = obj.StartSucceeded;
            message = obj.StartMessage;

        end

        function errors = finish(obj, varargin)

            obj.FinishCallCount = obj.FinishCallCount + 1;
            errors = obj.FinishErrors;

        end

    end

end
