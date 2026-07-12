classdef Logger
    % LOGGER
    % Centralizes log formatting, level filtering, and application log files.

    methods (Static)

        function levels = levels()

            levels = ["Debug", "Info", "Notice", "Warning", "Error", "Fatal"];

        end % levels

        function level = normalizeLevel(level)

            level = string(level);

            if isempty(level) || ismissing(level(1)) || strlength(level(1)) == 0
                level = "Info";
            else
                level = lower(strtrim(level(1)));
            end

            switch level

                case "debug"
                    level = "Debug";

                case {"info", "information"}
                    level = "Info";

                case "notice"
                    level = "Notice";

                case {"warn", "warning"}
                    level = "Warning";

                case {"err", "error", "exception"}
                    level = "Error";

                case "fatal"
                    level = "Fatal";

                otherwise
                    error( ...
                        "OpenMebius2:Logger:InvalidLevel", ...
                        "Log level must be Debug, Info, Notice, Warning, Error, or Fatal.");
            end

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
            message = Logger.firstString(message);

            text = level + ": " + message;

        end % formatMessage

        function text = formatDatedMessage(message, level, options)

            arguments
                message
                level
                options.Timestamp (1, 1) datetime = datetime("now")
            end

            import openmebius.infrastructure.logging.Logger

            text = Logger.timestampText(options.Timestamp) + " " + ...
                Logger.formatMessage(message, level);

        end % formatDatedMessage

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

    methods (Static, Access = private)

        function value = firstString(value)

            value = string(value);

            if isempty(value)
                value = "";
            else
                value = value(1);
            end

            if ismissing(value)
                value = "";
            end

        end % firstString

    end % methods

end % classdef
