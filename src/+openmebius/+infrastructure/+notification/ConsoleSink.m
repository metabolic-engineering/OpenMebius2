classdef ConsoleSink < handle
    % CONSOLESINK Writes normal messages to stdout and failures to stderr.

    properties (Constant)
        Name = "console"
    end

    properties (Access = private)
        OutputWriter (1, 1) function_handle = @(~) []
        ErrorWriter (1, 1) function_handle = @(~) []
    end

    methods

        function obj = ConsoleSink(options)

            arguments
                options.OutputWriter (1, 1) function_handle = ...
                    @(text) fprintf(1, "%s\n", char(string(text)))
                options.ErrorWriter (1, 1) function_handle = ...
                    @(text) fprintf(2, "%s\n", char(string(text)))
            end

            obj.OutputWriter = options.OutputWriter;
            obj.ErrorWriter = options.ErrorWriter;

        end % constructor

        function write(obj, message)

            arguments
                obj
                message (1, 1) openmebius.core.notification.Message
            end

            lines = openmebius.infrastructure.logging.Logger ...
                .formatDatedLines( ...
                    message.Text, ...
                    message.Level, ...
                    Timestamp = message.Timestamp);
            text = join(lines, newline);

            if openmebius.core.notification.Severity.atLeast( ...
                    message.Level, "warning")
                obj.ErrorWriter(text);
            else
                obj.OutputWriter(text);
            end

        end % write

    end % methods

end % classdef
