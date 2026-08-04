classdef SlackSink < handle
    % SLACKSINK Best-effort remote delivery for allow-listed event codes.

    properties (Constant)
        Name = "slack"
    end

    properties (SetAccess = private)
        Notifier (1, 1) openmebius.infrastructure.notification ...
            .SlackWebhookNotifier
    end

    methods

        function obj = SlackSink(notifier)

            arguments
                notifier (1, 1) openmebius.infrastructure.notification ...
                    .SlackWebhookNotifier = ...
                    openmebius.infrastructure.notification ...
                    .SlackWebhookNotifier()
            end

            obj.Notifier = notifier;

        end % constructor

        function write(obj, message)

            arguments
                obj
                message (1, 1) openmebius.core.notification.Message
            end

            if ~obj.Notifier.canNotify()
                return
            end

            context = message.Context;
            title = message.Title;

            if startsWith(message.Code, "batch.")
                title = "OpenMebius2 Batch Run";
            elseif title == ""
                title = "OpenMebius2 Notification";
            end

            result = obj.Notifier.send( ...
                message.Text, ...
                Title = title, ...
                Status = obj.contextString(context, "Status", message.Level), ...
                ProjectName = obj.contextString(context, "ProjectName", ""), ...
                BatchStatus = obj.contextString( ...
                    context, "BatchStatus", message.Level), ...
                DeltaTime = obj.contextDuration( ...
                    context, "DeltaTime", seconds(0)));

            if ~result.Success && ~result.Skipped
                error( ...
                    "OpenMebius2:Notification:SlackDeliveryFailed", ...
                    "%s", result.Message);
            end

        end % write

    end % methods

    methods (Static, Access = private)

        function value = contextString(context, name, fallback)

            value = string(fallback);

            if isfield(context, name)
                candidate = string(context.(name));

                if ~isempty(candidate) && ~ismissing(candidate(1))
                    value = candidate(1);
                end
            end

        end % contextString

        function value = contextDuration(context, name, fallback)

            value = fallback;

            if isfield(context, name) && ...
                    isa(context.(name), "duration") && ...
                    isscalar(context.(name))
                value = context.(name);
            end

        end % contextDuration

    end % methods (Static, Access = private)

end % classdef
