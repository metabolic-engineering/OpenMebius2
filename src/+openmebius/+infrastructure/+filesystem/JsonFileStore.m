classdef JsonFileStore
    % JSONFILESTORE
    % Reads and writes JSON files without depending on legacy status state.
    % object.

    methods

        function data = read(~, pathFile)

            arguments
                ~
                pathFile (1, 1) string
            end

            pathFile = string(pathFile);

            if ~isfile(pathFile)
                error( ...
                    "OpenMebius2:JsonFileStore:FileNotFound", ...
                    "The file %s does not exist.", ...
                    pathFile);
            end

            try
                data = jsondecode(fileread(pathFile));
            catch ME
                error( ...
                    "OpenMebius2:JsonFileStore:InvalidJson", ...
                    "The file %s is not a valid JSON file. %s", ...
                    pathFile, ...
                    ME.message);
            end

        end % read

        function writeAtomically(~, pathFile, data)

            arguments
                ~
                pathFile (1, 1) string
                data
            end

            pathFile = string(pathFile);
            targetDirectory = string(fileparts(pathFile));

            if targetDirectory == ""
                targetDirectory = ".";
            end

            if ~isfolder(targetDirectory)
                error( ...
                    "OpenMebius2:JsonFileStore:DirectoryNotFound", ...
                    "The directory %s does not exist.", ...
                    targetDirectory);
            end

            tempFile = string(tempname(targetDirectory));
            tempFileCleanup = onCleanup( ...
                @() openmebius.infrastructure.filesystem.JsonFileStore ...
                .deleteIfExists(tempFile));

            jsonText = char(jsonencode(data));
            jsonBytes = unicode2native(jsonText, 'UTF-8');

            [fid, openMessage] = fopen(tempFile, 'w');

            if fid < 0
                error( ...
                    "OpenMebius2:JsonFileStore:OpenTempFileFailed", ...
                    "Temporary JSON file cannot be opened: %s (%s)", ...
                    tempFile, ...
                    openMessage);
            end

            try
                numWritten = fwrite(fid, jsonBytes, 'uint8');
                closeStatus = fclose(fid);
            catch ME

                if fid >= 0
                    fclose(fid);
                end

                rethrow(ME);
            end

            if numWritten ~= numel(jsonBytes)
                error( ...
                    "OpenMebius2:JsonFileStore:ShortWrite", ...
                    "JSON write was incomplete: %s", ...
                    tempFile);
            end

            if closeStatus ~= 0
                error( ...
                    "OpenMebius2:JsonFileStore:CloseTempFileFailed", ...
                    "Temporary JSON file cannot be closed: %s", ...
                    tempFile);
            end

            [isMoved, moveMessage] = movefile(tempFile, pathFile, 'f');

            if ~isMoved
                error( ...
                    "OpenMebius2:JsonFileStore:ReplaceFileFailed", ...
                    "JSON file cannot be replaced: %s (%s)", ...
                    pathFile, ...
                    moveMessage);
            end

            clear tempFileCleanup

        end % writeAtomically

    end % methods

    methods (Static, Access = private)

        function deleteIfExists(pathFile)

            if isfile(pathFile)
                delete(pathFile);
            end

        end % deleteIfExists

    end % methods

end % classdef
