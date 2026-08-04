classdef RecordingHdf5ResultRepository < handle

    properties
        MetadataSuccess (1, 1) logical = true
        MetadataMessage (1, 1) string = ""
        CompletionSuccess logical = true
        CompletionMessage string = ""
        MetadataCallCount (1, 1) double = 0
        CompletionCallCount (1, 1) double = 0
        CompletionErrorStates logical = logical.empty(0, 1)
    end

    methods

        function [isSuccess, msg] = writeAnalysisMetadata(obj, ~, ~)

            obj.MetadataCallCount = obj.MetadataCallCount + 1;
            isSuccess = obj.MetadataSuccess;
            msg = obj.MetadataMessage;

        end

        function [isSuccess, msg] = writeRunCompletion( ...
                obj, ~, ~, isError, ~)

            obj.CompletionCallCount = obj.CompletionCallCount + 1;
            obj.CompletionErrorStates(end + 1, 1) = logical(isError);
            resultIndex = min( ...
                obj.CompletionCallCount, ...
                numel(obj.CompletionSuccess));
            messageIndex = min( ...
                obj.CompletionCallCount, ...
                numel(obj.CompletionMessage));
            isSuccess = obj.CompletionSuccess(resultIndex);
            msg = obj.CompletionMessage(messageIndex);

        end

    end

end
