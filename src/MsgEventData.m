classdef MsgEventData < event.EventData

    properties
        Message string
        Level (1, 1) string {mustBeMember(Level, ["Debug", "Info", "Success", "Notice", "Warning", "Error", "Fatal"])} = "Info"
        Timestamp datetime % 生の時刻（ローカルタイムゾーン）
        Caller string % ログ発生元
        DateStr string % 例: "2025-09-24"
        DateTimeStr string % 例: "2025-09-24 10:35:52"
    end

    methods

        function obj = MsgEventData(message, level, caller)

            if nargin < 2 || strlength(string(level)) == 0
                level = "Info";
            end

            if nargin < 3
                caller = "EMUModel";
            end

            obj.Message = string(message);
            obj.Level = openmebius.infrastructure.logging.Logger ...
                .normalizeLevel(level);
            % ローカルタイムゾーンの現在時刻を採用（表示を統一）
            t = datetime('now', 'TimeZone', 'local');
            obj.Timestamp = t;
            obj.Caller = string(caller);
            % ▼ ここでフォーマット統一
            obj.DateStr = string(t, "yyyy-MM-dd");
            obj.DateTimeStr = openmebius.infrastructure.logging.Logger ...
                .timestampText(t);
        end

        function text = toLogText(obj)

            text = openmebius.infrastructure.logging.Logger ...
                .formatDatedMessage( ...
                obj.Caller + ": " + obj.Message, ...
                obj.Level, ...
                Timestamp = obj.Timestamp);

        end

    end

end
