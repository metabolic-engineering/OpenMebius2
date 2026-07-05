classdef Notification

    properties (SetAccess = private)
        Message (1, 1) string
        Level (1, 1) string
        Title (1, 1) string
        Timestamp (1, 1) datetime
        ShowAlert (1, 1) logical
    end

    methods

        function obj = Notification(message, level, options)

            arguments
                message (1, 1) string
                level (1, 1) string = "info"
                options.Title (1, 1) string = ""
                options.Timestamp (1, 1) datetime = datetime("now")
                options.ShowAlert (1, 1) logical = false
            end

            level = ...
                openmebius.presentation.notification.Notification.normalizeLevel( ...
                level);

            if options.Title == ""
                title = ...
                    openmebius.presentation.notification.Notification.defaultTitle( ...
                    level);
            else
                title = options.Title;
            end

            obj.Message = message;
            obj.Level = level;
            obj.Title = title;
            obj.Timestamp = options.Timestamp;
            obj.ShowAlert = options.ShowAlert;

        end % method Notification

        function text = toLogText(obj)

            stamp = string(datestr(obj.Timestamp, "yyyy-mm-dd HH:MM:SS"));
            text = "[" + stamp + "] [" + upper(obj.Level) + "] " + obj.Message;

        end % method toLogText

        function icon = alertIcon(obj)

            switch obj.Level

                case "info"
                    icon = "info";

                case "warning"
                    icon = "warning";

                case "error"
                    icon = "error";

                case "success"
                    icon = "success";

                otherwise
                    icon = "info";

            end

        end % method alertIcon

    end % methods

    methods (Static)

        function obj = info(message, options)

            arguments
                message (1, 1) string
                options.Title (1, 1) string = ""
                options.ShowAlert (1, 1) logical = false
            end

            obj = openmebius.presentation.notification.Notification( ...
                message, ...
                "info", ...
                Title = options.Title, ...
                ShowAlert = options.ShowAlert);

        end % method info

        function obj = warning(message, options)

            arguments
                message (1, 1) string
                options.Title (1, 1) string = ""
                options.ShowAlert (1, 1) logical = false
            end

            obj = openmebius.presentation.notification.Notification( ...
                message, ...
                "warning", ...
                Title = options.Title, ...
                ShowAlert = options.ShowAlert);

        end % method warning

        function obj = error(message, options)

            arguments
                message (1, 1) string
                options.Title (1, 1) string = ""
                options.ShowAlert (1, 1) logical = false
            end

            obj = openmebius.presentation.notification.Notification( ...
                message, ...
                "error", ...
                Title = options.Title, ...
                ShowAlert = options.ShowAlert);

        end % method error

        function obj = success(message, options)

            arguments
                message (1, 1) string
                options.Title (1, 1) string = ""
                options.ShowAlert (1, 1) logical = false
            end

            obj = openmebius.presentation.notification.Notification( ...
                message, ...
                "success", ...
                Title = options.Title, ...
                ShowAlert = options.ShowAlert);

        end % method success

        function obj = fromException(exception, options)

            arguments
                exception
                options.Title (1, 1) string = "Error"
                options.ShowAlert (1, 1) logical = false
            end

            obj = openmebius.presentation.notification.Notification.error( ...
                string(exception.message), ...
                Title = options.Title, ...
                ShowAlert = options.ShowAlert);

        end % method fromException

        function obj = fromBatchStatus(message, batchStatus)

            arguments
                message (1, 1) string
                batchStatus (1, 1) string
            end

            status = lower(strtrim(batchStatus));

            switch status

                case {"ready", "running", "finished"}
                    level = "info";

                case "warning"
                    level = "warning";

                case {"error", "question"}
                    level = "error";

                otherwise
                    level = "warning";
            end

            obj = openmebius.presentation.notification.Notification( ...
                message, ...
                level);

        end % method fromBatchStatus

        function level = normalizeLevel(level)

            level = lower(strtrim(string(level)));

            if any(level == ["info", "information"])
                level = "info";

            elseif any(level == ["warn", "warning"])
                level = "warning";

            elseif any(level == ["err", "error", "exception"])
                level = "error";

            elseif any(level == ["ok", "success", "finished", "complete", "completed"])
                level = "success";

            else
                error( ...
                    "OpenMebius2:Notification:InvalidLevel", ...
                "Notification level must be info, warning, error, or success.");
            end

        end % method normalizeLevel

        function title = defaultTitle(level)

            switch level

                case "info"
                    title = "Information";

                case "warning"
                    title = "Warning";

                case "error"
                    title = "Error";

                case "success"
                    title = "Success";

                otherwise
                    title = "Notification";
            end

        end % method defaultTitle

    end % methods (Static)

end % classdef
