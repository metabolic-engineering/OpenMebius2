classdef Message
    % MESSAGE Presentation-independent application notification.

    properties (SetAccess = private)
        Text (1, 1) string
        Level (1, 1) string
        Timestamp (1, 1) datetime
    end

    methods

        function obj = Message(text, level, options)

            arguments
                text (1, 1) string
                level (1, 1) string
                options.Timestamp (1, 1) datetime = datetime("now")
            end

            level = lower(strtrim(level));

            if ~ismember(level, [ ...
                    "debug", "info", "notice", "warning", ...
                    "error", "fatal", "success"])
                error( ...
                    "OpenMebius2:Message:InvalidLevel", ...
                    "Unsupported message level: %s", level);
            end

            obj.Text = text;
            obj.Level = level;
            obj.Timestamp = options.Timestamp;

        end

    end

end
