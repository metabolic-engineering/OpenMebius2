classdef RunConfigEventRecorder < handle

    properties
        AppliedCount (1, 1) double = 0
        ClosedCount (1, 1) double = 0
        Notifications cell = {}
    end

    properties (Access = private)
        Listeners event.listener = event.listener.empty(0, 1)
    end

    methods

        function attach(obj, app)

            obj.Listeners(end + 1, 1) = addlistener( ...
                app, "Applied", @(~, ~) obj.recordApplied());
            obj.Listeners(end + 1, 1) = addlistener( ...
                app, "Closed", @(~, ~) obj.recordClosed());
            obj.Listeners(end + 1, 1) = addlistener( ...
                app, ...
                "NotificationRequested", ...
                @(~, event) obj.recordNotification(event));

        end % attach

        function delete(obj)

            for listenerIndex = 1:numel(obj.Listeners)
                try
                    if isvalid(obj.Listeners(listenerIndex))
                        delete(obj.Listeners(listenerIndex));
                    end
                catch
                end
            end

        end % delete

    end % methods

    methods (Access = private)

        function recordApplied(obj)

            obj.AppliedCount = obj.AppliedCount + 1;

        end % recordApplied

        function recordClosed(obj)

            obj.ClosedCount = obj.ClosedCount + 1;

        end % recordClosed

        function recordNotification(obj, event)

            obj.Notifications{end + 1} = event.Notification;

        end % recordNotification

    end % methods (Access = private)

end % classdef
