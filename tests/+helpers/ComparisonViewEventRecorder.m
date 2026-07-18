classdef ComparisonViewEventRecorder < handle

    properties
        Closed (1, 1) logical = false
        Notifications (:, 1) cell = cell(0, 1)
    end

    methods

        function recordClosed(obj, ~, ~)

            obj.Closed = true;

        end

        function recordNotification(obj, ~, event)

            obj.Notifications{end + 1, 1} = event.Notification;

        end

    end

end
