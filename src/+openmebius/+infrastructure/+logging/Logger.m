classdef Logger
    % LOGGER
    % Centralizes log formatting, level filtering, and application log files.

    methods (Static)

        function levels = levels()

            levels = ["Debug", "Info", "Success", "Notice", ...
                "Warning", "Error", "Fatal"];

        end % levels

        function level = normalizeLevel(level)

            try
                normalized = openmebius.core.notification.Severity ...
                    .normalize(level);
            catch
                error( ...
                    "OpenMebius2:Logger:InvalidLevel", ...
                    "Log level must be Debug, Info, Success, Notice, Warning, Error, or Fatal.");
            end

            level = upper(extractBefore(normalized, 2)) + ...
                extractAfter(normalized, 1);

        end % normalizeLevel

        function tf = shouldLog(level, threshold)

            import openmebius.infrastructure.logging.Logger

            level = Logger.normalizeLevel(level);
            threshold = Logger.normalizeLevel(threshold);

            allLevels = Logger.levels();
            levelIndex = find(allLevels == level, 1);
            thresholdIndex = find(allLevels == threshold, 1);

            tf = levelIndex >= thresholdIndex;

        end % shouldLog

        function text = formatMessage(message, level)

            import openmebius.infrastructure.logging.Logger

            level = Logger.normalizeLevel(level);
            message = Logger.messageText(message);

            if Logger.isFormattedLogText(message)
                text = message;
                return
            end

            text = Logger.levelToken(level) + char(9) + message;

        end % formatMessage

        function text = formatDatedMessage(message, level, options)

            arguments
                message
                level
                options.Timestamp (1, 1) datetime = datetime("now")
            end

            import openmebius.infrastructure.logging.Logger

            message = Logger.messageText(message);

            if Logger.isFormattedLogText(message)
                text = message;
                return
            end

            text = "[" + Logger.timestampText(options.Timestamp) + "]" + ...
                char(9) + ...
                Logger.formatMessage(message, level);

        end % formatDatedMessage

        function lines = formatDatedLines(messages, level, options)

            arguments
                messages
                level
                options.Timestamp (1, 1) datetime = datetime("now")
            end

            import openmebius.infrastructure.logging.Logger

            messages = string(messages);

            if isempty(messages)
                messages = "";
            end

            partsByMessage = cell(numel(messages), 1);
            numberOfLines = 0;

            for i = 1:numel(messages)

                message = messages(i);

                if ismissing(message)
                    message = "";
                end

                parts = splitlines(message);

                if isempty(parts)
                    parts = "";
                end

                if numel(parts) > 1 && parts(end) == ""
                    parts(end) = [];
                end

                partsByMessage{i} = parts(:);
                numberOfLines = numberOfLines + numel(parts);

            end

            lines = strings(numberOfLines, 1);
            lineIndex = 1;

            for i = 1:numel(partsByMessage)

                parts = partsByMessage{i};

                for j = 1:numel(parts)
                    lines(lineIndex) = Logger.formatDatedMessage( ...
                        parts(j), ...
                        level, ...
                        Timestamp = options.Timestamp);
                    lineIndex = lineIndex + 1;
                end

            end

        end % formatDatedLines

        function token = levelToken(level)

            import openmebius.infrastructure.logging.Logger

            token = "[" + upper(Logger.normalizeLevel(level)) + "]";

        end % levelToken

        function message = messageText(message)

            message = string(message);

            if isempty(message)
                message = "";
            else
                message = message(1);
            end

            if ismissing(message)
                message = "";
            end

        end % messageText

        function tf = isFormattedLogText(message)

            message = openmebius.infrastructure.logging.Logger ...
                .messageText(message);

            tf = ~isempty(regexp( ...
                char(message), ...
                '^\[[^\]]+\]\t\[[A-Z]+\]\t', ...
                'once'));

        end % isFormattedLogText

        function text = timestampText(timestamp)

            arguments
                timestamp (1, 1) datetime = datetime("now")
            end

            text = string(timestamp, "yyyy-MM-dd HH:mm:ss");

        end % timestampText

        function writeText(text)

            disp(string(text));

        end % writeText

        function writeIndented(text)

            openmebius.infrastructure.logging.Logger.writeText( ...
                "                          " + string(text));

        end % writeIndented

        function pathFile = defaultLogFile()

            directory = openmebius.infrastructure.logging.Logger ...
                .defaultLogDirectory();

            pathFile = string(fullfile(directory, "openmebius2.log"));

        end % defaultLogFile

        function directory = defaultLogDirectory()

            directory = string(System.getCacheDirectory());

        end % defaultLogDirectory

        function pathFile = configureDefaultDiary()

            import openmebius.infrastructure.logging.Logger

            pathFile = Logger.configureDiary(Logger.defaultLogFile());

        end % configureDefaultDiary

        function pathFile = configureDiary(pathFile)

            pathFile = string(pathFile);
            directory = string(fileparts(pathFile));

            if directory == ""
                directory = ".";
            end

            if ~isfolder(directory)

                try
                    mkdir(directory);
                catch ME
                    error( ...
                        "OpenMebius2:Logger:CreateDirectoryFailed", ...
                        "Could not create log directory: %s. %s", ...
                        directory, ...
                        ME.message);
                end

            end

            try
                diary(char(pathFile));
            catch ME
                error( ...
                    "OpenMebius2:Logger:ConfigureDiaryFailed", ...
                    "Could not set log file: %s. %s", ...
                    pathFile, ...
                    ME.message);
            end

        end % configureDiary

        function lines = readTail(pathFile, options)

            arguments
                pathFile (1, 1) string
                options.MaxLines (1, 1) double {mustBeInteger, mustBePositive} = 5000
            end

            pathFile = string(pathFile);

            if ~isfile(pathFile)
                lines = "Log file not found.";
                return
            end

            text = string(fileread(pathFile));

            if strlength(text) == 0
                lines = strings(0, 1);
                return
            end

            lines = splitlines(text);

            if ~isempty(lines) && lines(end) == ""
                lines(end) = [];
            end

            n = numel(lines);
            startIndex = max(1, n - options.MaxLines + 1);
            lines = lines(startIndex:end);

        end % readTail

        function copyDefaultLogTo(directory)

            import openmebius.infrastructure.logging.Logger

            directory = string(directory);

            if ~isfolder(directory)
                error( ...
                    "OpenMebius2:Logger:DirectoryNotFound", ...
                    "The directory %s does not exist.", ...
                    directory);
            end

            sourceFile = Logger.defaultLogFile();
            destinationFile = string(fullfile(directory, "openmebius2.log"));

            [isCopied, message] = copyfile(sourceFile, destinationFile);

            if ~isCopied
                error( ...
                    "OpenMebius2:Logger:CopyFailed", ...
                    "Failed to save log file: %s", ...
                    message);
            end

        end % copyDefaultLogTo

    end % methods

end % classdef
