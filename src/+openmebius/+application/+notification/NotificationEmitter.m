classdef NotificationEmitter < handle
    % NOTIFICATIONEMITTER Creates typed messages and publishes through a port.

    properties (Access = private)
        Publisher (1, 1) function_handle = @(~) []
        Clock (1, 1) function_handle = @() datetime("now")
        Source (1, 1) string = ""
    end

    methods

        function obj = NotificationEmitter(options)

            arguments
                options.Publisher (1, 1) function_handle = @(~) []
                options.Clock (1, 1) function_handle = @() datetime("now")
                options.Source (1, 1) string = ""
            end

            obj.Publisher = options.Publisher;
            obj.Clock = options.Clock;
            obj.Source = options.Source;

        end % constructor

        function message = report(obj, level, text, options)

            arguments
                obj
                level (1, 1) string
                text (1, 1) string
                options.Code (1, 1) string = "general.message"
                options.Title (1, 1) string = ""
                options.DiagnosticText (1, 1) string = ""
                options.Context (1, 1) struct = struct()
                options.Audience (1, 1) string = "user"
                options.Attention (1, 1) string = "passive"
                options.Kind (1, 1) string = "notification"
                options.CorrelationId (1, 1) string = ""
            end

            message = openmebius.core.notification.Message( ...
                text, ...
                level, ...
                Timestamp = obj.Clock(), ...
                Code = options.Code, ...
                Title = options.Title, ...
                DiagnosticText = options.DiagnosticText, ...
                Source = obj.Source, ...
                Context = options.Context, ...
                Audience = options.Audience, ...
                Attention = options.Attention, ...
                Kind = options.Kind, ...
                CorrelationId = options.CorrelationId);
            obj.Publisher(message);

        end % report

        function publish(obj, message)

            arguments
                obj
                message (1, 1) openmebius.core.notification.Message
            end

            obj.Publisher(message);

        end % publish

        function callback = reporter(obj)

            callback = @(message) obj.publish(message);

        end % reporter

    end % methods

end % classdef
