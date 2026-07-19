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

            text = join(obj.toLogLines(), newline);

        end % method toLogText

        function lines = toLogLines(obj)

            lines = openmebius.infrastructure.logging.Logger ...
                .formatDatedLines( ...
                obj.Message, ...
                obj.Level, ...
                Timestamp = obj.Timestamp);

        end % method toLogLines

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

        function obj = fromMessage(message, options)

            arguments
                message (1, 1) openmebius.core.notification.Message
                options.Title (1, 1) string = ""
                options.ShowAlert (1, 1) logical = false
            end

            obj = openmebius.presentation.notification.Notification( ...
                message.Text, ...
                message.Level, ...
                Title = options.Title, ...
                Timestamp = message.Timestamp, ...
                ShowAlert = options.ShowAlert);

        end

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

            try
                level = lower( ...
                    openmebius.infrastructure.logging.Logger ...
                    .normalizeLevel(level));
            catch
                error( ...
                    "OpenMebius2:Notification:InvalidLevel", ...
                    "Notification level must be a supported Logger level.");
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

                case "debug"
                    title = "Debug";

                case "notice"
                    title = "Notice";

                case "fatal"
                    title = "Fatal Error";

                otherwise
                    title = "Notification";
            end

        end % method defaultTitle

    end % methods (Static)

end % classdef
