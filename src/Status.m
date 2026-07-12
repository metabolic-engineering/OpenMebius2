classdef Status < handle

    properties

        isError (1, 1) logical = false;
        logLevel (1, 1) string {mustBeMember(logLevel, ["Debug", "Info", "Notice", "Warning", "Error", "Fatal"])} = "Info";

    end

    properties (Access = protected)

        msg (1, 1) string = "";

    end

    properties (Dependent)

        statusMsg (1, 1) string
        DateText (1, 1) string;

    end

    properties (Access = private)

        level (1, 1) string {mustBeMember(level, ["Debug", "Info", "Notice", "Warning", "Error", "Fatal"])} = "Info";

    end

    properties (Dependent)

        errorMsg (1, 1) string;

    end

    methods

        function statusMsg = get.statusMsg(obj)

            % Get the log message
            statusMsg = obj.DateText + " " + obj.msg;

        end

        function errorMsg = get.errorMsg(obj)

            errorMsg = obj.statusMsg;

        end

        function DateText = get.DateText(~)

            DateText = openmebius.infrastructure.logging.Logger ...
                .timestampText();

        end

        function dispNormalMsg(~, text, level, logLevel)
            % DISPNORMALMSG Display a normal message
            %
            % DISPNORMALMSG(OBJ, TEXT) Display a normal message with the text TEXT.
            %
            % Parameters
            % ----------
            % text: (1 x 1) string
            %     The text message to be displayed.
            %
            % Example
            % -------
            % dispNormalMsg(obj, "This is a normal message");
            % >>                    This is a normal message

            if ~openmebius.infrastructure.logging.Logger ...
                    .shouldLog(level, logLevel)
                return;
            end

            openmebius.infrastructure.logging.Logger.writeIndented(text);

        end %dispNormalMsg

        function updateMsg(obj, text, level, logLevel)

            if ~openmebius.infrastructure.logging.Logger ...
                    .shouldLog(level, logLevel)
                return;
            end

            obj.level = openmebius.infrastructure.logging.Logger ...
                .normalizeLevel(level);
            obj.msg = obj.returnMsg(text, obj.level);
            dispMsg(obj);

        end %updateMsg

        function msg = returnDateMsg(~, text, level)

            msg = openmebius.infrastructure.logging.Logger ...
                .formatDatedMessage(text, level);

        end %returnDateMsg

        function reset(obj)

            obj.isError = false;
            obj.msg = "";

        end % reset

    end

    methods (Access = private)

        function msg = returnMsg(~, text, level)

            msg = openmebius.infrastructure.logging.Logger ...
                .formatMessage(text, level);

        end

        function dispMsg(obj)

            openmebius.infrastructure.logging.Logger.writeText( ...
                obj.statusMsg);

        end

    end

end
