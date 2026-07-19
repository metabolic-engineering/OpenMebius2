classdef GeneralMessagePublisher
    % GENERALMESSAGEPUBLISHER
    % Formats logs and bridges notifications to GeneralMsg event data.

    properties (Access = private)
        Reporter openmebius.infrastructure.logging.MessageReporter
    end

    methods

        function obj = GeneralMessagePublisher(options)

            arguments
                options.LogWriter (1, 1) function_handle = ...
                    @(text) openmebius.infrastructure.logging ...
                    .Logger.writeText(text)
                options.Clock (1, 1) function_handle = ...
                    @() datetime("now")
                options.LogLevel (1, 1) string = "Info"
            end

            obj.Reporter = openmebius.infrastructure.logging ...
                .MessageReporter( ...
                    LogWriter = options.LogWriter, ...
                    Clock = options.Clock, ...
                    LogLevel = options.LogLevel);

        end

        function notification = report( ...
                obj, level, message, eventPublisher)

            arguments
                obj (1, 1) openmebius.presentation.notification ...
                    .GeneralMessagePublisher
                level (1, 1) string
                message (1, 1) string
                eventPublisher (1, 1) function_handle
            end

            notification = obj.write(level, message);
            eventPublisher( ...
                openmebius.presentation.notification ...
                .GeneralMessageEventData(notification));

        end

        function notification = write(obj, level, message)

            arguments
                obj (1, 1) openmebius.presentation.notification ...
                    .GeneralMessagePublisher
                level (1, 1) string
                message (1, 1) string
            end

            coreMessage = obj.Reporter.report(level, message);
            notification = openmebius.presentation.notification ...
                .Notification.fromMessage(coreMessage);

        end

    end

end
