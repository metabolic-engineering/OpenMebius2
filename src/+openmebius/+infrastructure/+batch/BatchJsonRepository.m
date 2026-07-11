classdef BatchJsonRepository
    % BATCHJSONREPOSITORY
    % Reads and writes batch JSON files.

    methods

        function save(~, experimentLocation, fileName, batchTable)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                fileName (1, 1) string
                batchTable table
            end

            filenameBatch = experimentLocation.batchFile(fileName);

            batchJsonData = openmebius.infrastructure.batch.BatchJsonMapper.toJsonData(batchTable);

            openmebius.infrastructure.batch.BatchJsonRepository.writeJsonAtomically( ...
                filenameBatch, ...
                batchJsonData);

        end % save

        function [batchTable, isError, msg] = load( ...
                ~, ...
                experimentLocation, ...
                fileName, ...
                variableNames)

            if nargin < 4
                variableNames = openmebius.infrastructure.batch.BatchJsonMapper.defaultVariableNames();
            end

            ioInstance = IO(experimentLocation.Directory);
            filenameBatch = experimentLocation.batchFile(fileName);

            batchData = ioInstance.importJSONFile(filenameBatch);
            msg = ioInstance.statusMsg();
            isError = ioInstance.isError;

            if isError
                batchTable = openmebius.infrastructure.batch.BatchJsonMapper.emptyTable(variableNames);
                return
            end

            batchTable = openmebius.infrastructure.batch.BatchJsonMapper.toTable(batchData, variableNames);

        end % load

    end % methods

    methods (Static, Access = private)

        function writeJsonAtomically(pathFile, data)

            pathFile = string(pathFile);
            targetDirectory = string(fileparts(pathFile));

            if targetDirectory == ""
                targetDirectory = ".";
            end

            tempFile = string(tempname(targetDirectory));
            tempFileCleanup = onCleanup( ...
                @() openmebius.infrastructure.batch.BatchJsonRepository.deleteIfExists( ...
                tempFile));

            jsonText = char(jsonencode(data));
            jsonBytes = unicode2native(jsonText, 'UTF-8');

            [fid, openMessage] = fopen(tempFile, 'w');

            if fid < 0
                error( ...
                    "OpenMebius2:BatchJsonRepository:OpenTempFileFailed", ...
                    "Temporary batch JSON file cannot be opened: %s (%s)", ...
                    tempFile, ...
                    openMessage);
            end

            try
                numWritten = fwrite(fid, jsonBytes, 'uint8');
                closeStatus = fclose(fid);
                fid = -1;
            catch ME

                if fid >= 0
                    fclose(fid);
                end

                rethrow(ME);
            end

            if numWritten ~= numel(jsonBytes)
                error( ...
                    "OpenMebius2:BatchJsonRepository:ShortWrite", ...
                    "Batch JSON write was incomplete: %s", ...
                    tempFile);
            end

            if closeStatus ~= 0
                error( ...
                    "OpenMebius2:BatchJsonRepository:CloseTempFileFailed", ...
                    "Temporary batch JSON file cannot be closed: %s", ...
                    tempFile);
            end

            [isMoved, moveMessage] = movefile(tempFile, pathFile, 'f');

            if ~isMoved
                error( ...
                    "OpenMebius2:BatchJsonRepository:ReplaceFileFailed", ...
                    "Batch JSON file cannot be replaced: %s (%s)", ...
                    pathFile, ...
                    moveMessage);
            end

            clear tempFileCleanup

        end % writeJsonAtomically

        function deleteIfExists(pathFile)

            if isfile(pathFile)
                delete(pathFile);
            end

        end % deleteIfExists

    end % methods

end % classdef
