classdef MessageReporter < handle
    % MESSAGEREPORTER Writes core messages to the configured log sink.

    properties (Access = private)
        LogWriter (1, 1) function_handle = ...
            @(text) openmebius.infrastructure.logging.Logger.writeText(text)
        Clock (1, 1) function_handle = @() datetime("now")
        LogLevel (1, 1) string = "Info"
    end

    methods

        function obj = MessageReporter(options)

            arguments
                options.LogWriter (1, 1) function_handle = ...
                    @(text) openmebius.infrastructure.logging ...
                    .Logger.writeText(text)
                options.Clock (1, 1) function_handle = @() datetime("now")
                options.LogLevel (1, 1) string = "Info"
            end

            obj.LogWriter = options.LogWriter;
            obj.Clock = options.Clock;
            obj.LogLevel = openmebius.infrastructure.logging ...
                .Logger.normalizeLevel(options.LogLevel);

        end

        function message = report(obj, level, text)

            arguments
                obj (1, 1) openmebius.infrastructure.logging.MessageReporter
                level (1, 1) string
                text (1, 1) string
            end

            level = lower(openmebius.infrastructure.logging.Logger ...
                .normalizeLevel(level));
            message = openmebius.core.notification.Message( ...
                text, level, Timestamp = obj.Clock());

            if openmebius.infrastructure.logging.Logger.shouldLog( ...
                    message.Level, obj.LogLevel)
                lines = openmebius.infrastructure.logging.Logger ...
                    .formatDatedLines( ...
                    message.Text, ...
                    message.Level, ...
                    Timestamp = message.Timestamp);
                obj.LogWriter(join(lines, newline));
            end

        end

    end

end
