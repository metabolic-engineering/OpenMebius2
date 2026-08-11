classdef RoutingPolicy < handle
    % ROUTINGPOLICY Selects notification destinations without producer flags.

    properties
        Mode (1, 1) string = "desktop"
        DeveloperMode (1, 1) logical = false
        ConsoleEnabled (1, 1) logical = true
        FileMinimumLevel (1, 1) string = "debug"
        DesktopConsoleMinimumLevel (1, 1) string = "warning"
        CliConsoleMinimumLevel (1, 1) string = "info"
        UiLogMinimumLevel (1, 1) string = "info"
        SlackCodes (:, 1) string = [ ...
                                        "batch.completed"; "batch.failed"; "batch.canceled"]
    end

    methods

        function obj = RoutingPolicy(options)

            arguments
                options.Mode (1, 1) string = "desktop"
                options.DeveloperMode (1, 1) logical = false
                options.ConsoleEnabled (1, 1) logical = true
                options.FileMinimumLevel (1, 1) string = "debug"
                options.DesktopConsoleMinimumLevel (1, 1) string = "warning"
                options.CliConsoleMinimumLevel (1, 1) string = "info"
                options.UiLogMinimumLevel (1, 1) string = "info"
                options.SlackCodes (:, 1) string = [ ...
                                                        "batch.completed"; "batch.failed"; "batch.canceled"]
            end

            mode = lower(strtrim(options.Mode));
            mustBeMember(mode, ["desktop", "cli", "test"]);
            obj.Mode = mode;
            obj.DeveloperMode = options.DeveloperMode;
            obj.ConsoleEnabled = options.ConsoleEnabled;
            obj.FileMinimumLevel = openmebius.core.notification ...
                .Severity.normalize(options.FileMinimumLevel);
            obj.DesktopConsoleMinimumLevel = openmebius.core.notification ...
                .Severity.normalize(options.DesktopConsoleMinimumLevel);
            obj.CliConsoleMinimumLevel = openmebius.core.notification ...
                .Severity.normalize(options.CliConsoleMinimumLevel);
            obj.UiLogMinimumLevel = openmebius.core.notification ...
                .Severity.normalize(options.UiLogMinimumLevel);
            obj.SlackCodes = string(options.SlackCodes(:));

        end % constructor

        function tf = shouldRoute(obj, message, sinkName)

            arguments
                obj
                message (1, 1) openmebius.core.notification.Message
                sinkName (1, 1) string
            end

            sinkName = lower(strtrim(sinkName));

            switch sinkName
                case "file"
                    tf = openmebius.core.notification.Severity.atLeast( ...
                        message.Level, obj.FileMinimumLevel);

                case "console"

                    if ~obj.ConsoleEnabled || obj.Mode == "test"
                        tf = false;
                    elseif obj.Mode == "cli"
                        tf = openmebius.core.notification.Severity.atLeast( ...
                            message.Level, obj.CliConsoleMinimumLevel);
                    else
                        tf = openmebius.core.notification.Severity.atLeast( ...
                            message.Level, ...
                            obj.DesktopConsoleMinimumLevel);
                    end

                case "ui-log"
                    tf = obj.Mode == "desktop" && ...
                        message.Kind ~= "progress" && ...
                        (message.Audience ~= "developer" || ...
                        obj.DeveloperMode) && ...
                        openmebius.core.notification.Severity.atLeast( ...
                        message.Level, obj.UiLogMinimumLevel);

                case "ui-alert"
                    isMessageOnlySeverity = ismember( ...
                        message.Level, ["warning", "error"]);
                    tf = obj.Mode == "desktop" && ...
                        message.Audience == "user" && ...
                        ~isMessageOnlySeverity && ...
                        (message.Attention == "action-required" || ...
                        message.Level == "fatal");

                case "slack"
                    tf = ismember(message.Code, obj.SlackCodes);

                otherwise
                    tf = false;
            end

        end % shouldRoute

    end % methods

end % classdef
