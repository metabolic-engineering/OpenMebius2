classdef TextFileSink < handle
    % TEXTFILESINK Appends formatted notifications to a rotating text log.

    properties (Constant)
        Name = "file"
    end

    properties (SetAccess = private)
        Path (1, 1) string
        MaxBytes (1, 1) double
        BackupCount (1, 1) double
    end

    properties (Access = private)
        RotationDeferred (1, 1) logical = false
    end

    methods

        function obj = TextFileSink(options)

            arguments
                options.Path (1, 1) string = ...
                    openmebius.infrastructure.logging.Logger.defaultLogFile()
                options.MaxBytes (1, 1) double ...
                    {mustBePositive} = 5 * 1024 * 1024
                options.BackupCount (1, 1) double ...
                    {mustBeInteger, mustBeNonnegative} = 3
            end

            obj.Path = options.Path;
            obj.MaxBytes = options.MaxBytes;
            obj.BackupCount = options.BackupCount;
            obj.ensureDirectory();

        end % constructor

        function write(obj, message)

            arguments
                obj
                message (1, 1) openmebius.core.notification.Message
            end

            lines = openmebius.infrastructure.logging.Logger ...
                .formatDatedLines( ...
                message.Text, ...
                message.Level, ...
                Timestamp = message.Timestamp);
            obj.rotateIfNeeded(strlength(join(lines, newline)) + 1);

            fileId = fopen(char(obj.Path), "a");

            if fileId < 0
                error( ...
                    "OpenMebius2:Notification:LogOpenFailed", ...
                    "Could not open notification log: %s", obj.Path);
            end

            cleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>
            fprintf(fileId, "%s\n", char(join(lines, newline)));

        end % write

    end % methods

    methods (Access = private)

        function ensureDirectory(obj)

            directory = string(fileparts(obj.Path));

            if directory ~= "" && ~isfolder(directory)
                mkdir(directory);
            end

        end % ensureDirectory

        function rotateIfNeeded(obj, incomingLength)

            if obj.RotationDeferred || ~isfile(obj.Path)
                return
            end

            info = dir(char(obj.Path));

            if isempty(info) || info.bytes + incomingLength <= obj.MaxBytes
                return
            end

            if obj.BackupCount == 0

                try
                    delete(char(obj.Path));
                catch
                    obj.RotationDeferred = true;
                end

                return
            end

            oldest = obj.Path + "." + string(obj.BackupCount);

            if isfile(oldest)

                try
                    delete(char(oldest));
                catch
                    obj.RotationDeferred = true;
                    return
                end

            end

            for backupIndex = obj.BackupCount - 1:-1:1
                source = obj.Path + "." + string(backupIndex);

                if isfile(source) && ~obj.tryMove( ...
                        source, ...
                        obj.Path + "." + string(backupIndex + 1))
                    obj.RotationDeferred = true;
                    return
                end

            end

            if ~obj.tryMove(obj.Path, obj.Path + ".1")
                % A previous diary session or another process can keep the
                % file open on Windows. Continue appending for this session
                % and retry rotation when a new sink is constructed.
                obj.RotationDeferred = true;
            end

        end % rotateIfNeeded

        function success = tryMove(~, source, destination)

            try
                [success, ~] = movefile( ...
                    char(source), char(destination), "f");
            catch
                success = false;
            end

        end % tryMove

    end % methods (Access = private)

end % classdef
