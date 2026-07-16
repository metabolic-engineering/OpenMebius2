classdef BatchRunCallbackRecorder < handle

    properties
        MessageCount (1, 1) double = 0
        ResultCount (1, 1) double = 0
    end

    methods

        function recordMessage(obj, ~)

            obj.MessageCount = obj.MessageCount + 1;

        end

        function recordResult(obj, ~)

            obj.ResultCount = obj.ResultCount + 1;

        end

    end

end
