classdef RecordingResultManifestRepository < handle

    properties
        StartedSuccess (1, 1) logical = true
        StartedMessage (1, 1) string = ""
        CompletedSuccess (1, 1) logical = true
        CompletedMessage (1, 1) string = ""
        StartedCallCount (1, 1) double = 0
        CompletedCallCount (1, 1) double = 0
        CompletedIsError (1, 1) logical = false
    end

    methods

        function [isSuccess, msg] = writeStarted(obj, ~, ~)

            obj.StartedCallCount = obj.StartedCallCount + 1;
            isSuccess = obj.StartedSuccess;
            msg = obj.StartedMessage;

        end

        function [isSuccess, msg] = writeCompleted( ...
                obj, ~, ~, ~, isError, ~)

            obj.CompletedCallCount = obj.CompletedCallCount + 1;
            obj.CompletedIsError = logical(isError);
            isSuccess = obj.CompletedSuccess;
            msg = obj.CompletedMessage;

        end

    end

end
