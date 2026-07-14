classdef MessageState < handle
    % MESSAGESTATE
    % Tracks the latest operation message for legacy IO and solver objects.

    properties

        isError (1, 1) logical = false
        logLevel (1, 1) string {mustBeMember(logLevel, ["Debug", "Info", "Success", "Notice", "Warning", "Error", "Fatal"])} = "Info"

    end

    properties (Access = protected)

        msg (1, 1) string = ""

    end

    properties (Dependent)

        statusMsg (1, 1) string
        DateText (1, 1) string
        errorMsg (1, 1) string

    end

    properties (Access = private)

        level (1, 1) string {mustBeMember(level, ["Debug", "Info", "Success", "Notice", "Warning", "Error", "Fatal"])} = "Info"

    end

    methods

        function statusMsg = get.statusMsg(obj)

            statusMsg = join( ...
                openmebius.infrastructure.logging.Logger ...
                .formatDatedLines(obj.msg, obj.level), ...
                newline);

        end

        function errorMsg = get.errorMsg(obj)

            errorMsg = obj.statusMsg;

        end

        function DateText = get.DateText(~)

            DateText = openmebius.infrastructure.logging.Logger ...
                .timestampText();

        end

        function dispNormalMsg(~, text, level, logLevel)

            if ~openmebius.infrastructure.logging.Logger ...
                    .shouldLog(level, logLevel)
                return
            end

            openmebius.infrastructure.logging.Logger.writeText( ...
                join( ...
                openmebius.infrastructure.logging.Logger ...
                .formatDatedLines(text, level), ...
                newline));

        end

        function updateMsg(obj, text, level, logLevel)

            if ~openmebius.infrastructure.logging.Logger ...
                    .shouldLog(level, logLevel)
                return
            end

            obj.level = openmebius.infrastructure.logging.Logger ...
                .normalizeLevel(level);
            obj.msg = openmebius.infrastructure.logging.Logger ...
                .messageText(text);
            obj.dispMsg();

        end

        function msg = returnDateMsg(~, text, level)

            msg = join( ...
                openmebius.infrastructure.logging.Logger ...
                .formatDatedLines(text, level), ...
                newline);

        end

        function reset(obj)

            obj.isError = false;
            obj.msg = "";

        end

    end

    methods (Access = private)

        function dispMsg(obj)

            openmebius.infrastructure.logging.Logger.writeText( ...
                obj.statusMsg);

        end

    end

end
