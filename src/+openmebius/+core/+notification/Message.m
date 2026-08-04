classdef Message
    % MESSAGE Presentation-independent application notification.

    properties (SetAccess = private)
        Text (1, 1) string
        Level (1, 1) string
        Timestamp (1, 1) datetime
        EventId (1, 1) string
        CorrelationId (1, 1) string
        Code (1, 1) string
        Title (1, 1) string
        DiagnosticText (1, 1) string
        Source (1, 1) string
        Context (1, 1) struct
        Audience (1, 1) string
        Attention (1, 1) string
        Kind (1, 1) string
    end

    methods

        function obj = Message(text, level, options)

            arguments
                text (1, 1) string
                level (1, 1) string
                options.Timestamp (1, 1) datetime = datetime("now")
                options.EventId (1, 1) string = ""
                options.CorrelationId (1, 1) string = ""
                options.Code (1, 1) string = "general.message"
                options.Title (1, 1) string = ""
                options.DiagnosticText (1, 1) string = ""
                options.Source (1, 1) string = ""
                options.Context (1, 1) struct = struct()
                options.Audience (1, 1) string = "user"
                options.Attention (1, 1) string = "passive"
                options.Kind (1, 1) string = "notification"
            end

            try
                level = openmebius.core.notification.Severity.normalize(level);
            catch cause
                error( ...
                    "OpenMebius2:Message:InvalidLevel", ...
                    "Unsupported message level: %s. %s", ...
                    level, string(cause.message));
            end

            audience = lower(strtrim(options.Audience));
            attention = lower(strtrim(options.Attention));
            kind = lower(strtrim(options.Kind));

            mustBeMember(audience, ["user", "operator", "developer"]);
            mustBeMember(attention, ["passive", "action-required"]);
            mustBeMember(kind, [ ...
                                    "notification", "diagnostic", "progress", "audit"]);

            eventId = strtrim(options.EventId);

            if eventId == ""
                eventId = string(char(java.util.UUID.randomUUID()));
            end

            obj.Text = text;
            obj.Level = level;
            obj.Timestamp = options.Timestamp;
            obj.EventId = eventId;
            obj.CorrelationId = strtrim(options.CorrelationId);
            obj.Code = strtrim(options.Code);
            obj.Title = options.Title;
            obj.DiagnosticText = options.DiagnosticText;
            obj.Source = strtrim(options.Source);
            obj.Context = options.Context;
            obj.Audience = audience;
            obj.Attention = attention;
            obj.Kind = kind;

        end

    end

end
