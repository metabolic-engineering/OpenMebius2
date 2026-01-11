classdef Status < handle

    properties

        isError (1, 1) logical = false;

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

        function DateText = get.DateText(~)

            DateText = string(datetime(), 'yyyy-MM-dd HH:mm:ss');

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

            if strcmp(logLevel, "Fatal")
                list = "Fatal";
            elseif strcmp(logLevel, "Error")
                list = ["Fatal", "Error"];
            elseif strcmp(logLevel, "Warning")
                list = ["Fatal", "Error", "Warning"];
            elseif strcmp(logLevel, "Notice")
                list = ["Fatal", "Error", "Warning", "Notice"];
            elseif strcmp(logLevel, "Info")
                list = ["Fatal", "Error", "Warning", "Notice", "Info"];
            elseif strcmp(logLevel, "Debug")
                list = ["Fatal", "Error", "Warning", "Notice", "Info", "Debug"];
            end

            if ~ismember(level, list)
                return;
            else

                % 20 spaces
                space = "                          ";
                disp(space + text);

            end

        end %dispNormalMsg

        function updateMsg(obj, text, level, logLevel)

            if strcmp(logLevel, "Fatal")
                list = "Fatal";
            elseif strcmp(logLevel, "Error")
                list = ["Fatal", "Error"];
            elseif strcmp(logLevel, "Warning")
                list = ["Fatal", "Error", "Warning"];
            elseif strcmp(logLevel, "Notice")
                list = ["Fatal", "Error", "Warning", "Notice"];
            elseif strcmp(logLevel, "Info")
                list = ["Fatal", "Error", "Warning", "Notice", "Info"];
            elseif strcmp(logLevel, "Debug")
                list = ["Fatal", "Error", "Warning", "Notice", "Info", "Debug"];
            end

            if ~ismember(level, list)
                return;
            else
                obj.level = level;
                obj.msg = obj.returnMsg(text, obj.level);
                dispMsg(obj);

            end

        end %updateMsg

        function msg = returnDateMsg(obj, text, level)

            msg = returnMsg(obj, text, level);
            msg = obj.DateText + " " + msg;

        end %returnDateMsg

    end

    methods (Access = private)

        function msg = returnMsg(~, text, level)

            % Return the text message
            msg = level + ": " + text;

        end

        function dispMsg(obj)

            disp(obj.statusMsg);

        end

    end

end
