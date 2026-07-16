classdef AnalysisNotificationObserverStub < handle

    properties (SetAccess = private)
        EventCount (1, 1) double = 0
        LastEvent = []
        LogText (:, 1) string = strings(0, 1)
    end

    methods

        function publish(obj, eventData)

            obj.EventCount = obj.EventCount + 1;
            obj.LastEvent = eventData;

        end

        function write(obj, text)

            obj.LogText(end + 1, 1) = string(text);

        end

    end

end
