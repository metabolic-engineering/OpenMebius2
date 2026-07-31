classdef NotificationDispatcher < handle
    % NOTIFICATIONDISPATCHER Routes each typed notification to registered sinks.

    properties (SetAccess = private)
        Policy (1, 1) openmebius.infrastructure.notification.RoutingPolicy
    end

    properties (Access = private)
        Sinks (1, :) cell = {}
        DisabledSinkNames (:, 1) string = strings(0, 1)
        DeliveredEventIds (:, 1) string = strings(0, 1)
        MaxTrackedEventIds (1, 1) double = 2048
        EmergencyWriter (1, 1) function_handle = ...
            @(text) fprintf(2, "%s\n", char(string(text)))
    end

    methods

        function obj = NotificationDispatcher(options)

            arguments
                options.Policy (1, 1) openmebius.infrastructure ...
                    .notification.RoutingPolicy = ...
                    openmebius.infrastructure.notification.RoutingPolicy()
                options.EmergencyWriter (1, 1) function_handle = ...
                    @(text) fprintf(2, "%s\n", char(string(text)))
                options.MaxTrackedEventIds (1, 1) double ...
                    {mustBeInteger, mustBePositive} = 2048
            end

            obj.Policy = options.Policy;
            obj.EmergencyWriter = options.EmergencyWriter;
            obj.MaxTrackedEventIds = options.MaxTrackedEventIds;

        end % constructor

        function addSink(obj, sink)

            name = obj.sinkName(sink);
            obj.removeSink(name);
            obj.Sinks{end + 1} = sink;

        end % addSink

        function removeSink(obj, name)

            name = lower(strtrim(string(name)));
            keep = true(size(obj.Sinks));

            for sinkIndex = 1:numel(obj.Sinks)
                keep(sinkIndex) = obj.sinkName(obj.Sinks{sinkIndex}) ~= name;
            end

            obj.Sinks = obj.Sinks(keep);
            obj.DisabledSinkNames( ...
                obj.DisabledSinkNames == name) = [];

        end % removeSink

        function publish(obj, message)

            arguments
                obj
                message (1, 1) openmebius.core.notification.Message
            end

            if ismember(message.EventId, obj.DeliveredEventIds)
                return
            end

            obj.remember(message.EventId);

            for sinkIndex = 1:numel(obj.Sinks)
                sink = obj.Sinks{sinkIndex};
                sinkName = obj.sinkName(sink);

                if ismember(sinkName, obj.DisabledSinkNames) || ...
                        ~obj.Policy.shouldRoute(message, sinkName)
                    continue
                end

                try
                    sink.write(message);
                catch cause
                    obj.reportSinkFailure(sinkName, message, cause);
                    obj.DisabledSinkNames(end + 1, 1) = sinkName;
                end

            end

        end % publish

        function callback = reporter(obj)

            callback = @(message) obj.publish(message);

        end % reporter

    end % methods

    methods (Access = private)

        function remember(obj, eventId)

            obj.DeliveredEventIds(end + 1, 1) = eventId;
            overflow = numel(obj.DeliveredEventIds) - obj.MaxTrackedEventIds;

            if overflow > 0
                obj.DeliveredEventIds(1:overflow) = [];
            end

        end % remember

        function reportSinkFailure(obj, sinkName, message, cause)

            text = "Notification sink '" + sinkName + ...
                "' failed for " + message.Code + ": " + ...
                string(cause.message);

            try
                obj.EmergencyWriter(text);
            catch
                % Delivery failure reporting must never affect application work.
            end

        end % reportSinkFailure

        function name = sinkName(~, sink)

            if ~isobject(sink) || ~isprop(sink, "Name") || ...
                    ~ismethod(sink, "write")
                error( ...
                    "OpenMebius2:Notification:InvalidSink", ...
                "A notification sink must expose Name and write(message).");
            end

            name = lower(strtrim(string(sink.Name)));

            if name == ""
                error( ...
                    "OpenMebius2:Notification:InvalidSinkName", ...
                "A notification sink must have a non-empty name.");
            end

        end % sinkName

    end % methods (Access = private)

end % classdef
