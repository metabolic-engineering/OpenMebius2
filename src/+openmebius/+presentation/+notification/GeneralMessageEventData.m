classdef GeneralMessageEventData < event.EventData
    % GENERALMESSAGEEVENTDATA
    % Carries a Notification through the legacy GeneralMsg event contract.

    properties (SetAccess = private)
        data (1, 1) struct = struct
        Notification
    end

    methods

        function obj = GeneralMessageEventData(notification)

            arguments
                notification (1, 1) openmebius.presentation ...
                    .notification.Notification
            end

            obj.Notification = notification;
            obj.data = struct( ...
                status = notification.Level, ...
                msg = notification.Message);

        end

    end

end
