classdef AnalysisRunRepositoryStub < handle

    properties
        StartSuccess (1, 1) logical = true
        StartMessage (1, 1) string = ""
        CompletionErrors (:, 1) string = strings(0, 1)
        StartedMetadata = struct
        CompletedMetadata = struct
        CompletedAtUtc (1, 1) string = ""
        CompletedIsError (1, 1) logical = false
        CompletedIsCanceled (1, 1) logical = false
        StartCallCount (1, 1) double = 0
        CompletionCallCount (1, 1) double = 0
    end

    methods

        function [isSuccess, message] = writeStarted( ...
                obj, ~, ~, metadata)

            obj.StartCallCount = obj.StartCallCount + 1;
            obj.StartedMetadata = metadata;
            isSuccess = obj.StartSuccess;
            message = obj.StartMessage;

        end

        function errors = writeCompleted( ...
                obj, ~, ~, metadata, finishedAtUtc, ...
                isError, isCanceled)

            obj.CompletionCallCount = obj.CompletionCallCount + 1;
            obj.CompletedMetadata = metadata;
            obj.CompletedAtUtc = finishedAtUtc;
            obj.CompletedIsError = isError;
            obj.CompletedIsCanceled = isCanceled;
            errors = obj.CompletionErrors;

        end

    end

end
