classdef NotificationEventData < event.EventData
    % NOTIFICATIONEVENTDATA Carries a presentation notification.

    properties (SetAccess = private)
        Notification
    end

    methods

        function obj = NotificationEventData(notification)

            arguments
                notification (1, 1) openmebius.presentation ...
                    .notification.Notification
            end

            obj.Notification = notification;

        end % constructor

    end % methods

end % classdef
