classdef LegacyFileAccess
    % LEGACYFILEACCESS
    % Status-aware adapter used while legacy file methods are being removed.

    methods (Static)

        function initializeDirectory(statusObj, directory)

            directory = string(directory);

            try
                openmebius.infrastructure.filesystem.DirectoryStore ...
                    .assertDirectoryExists(directory);
            catch
                statusObj.isError = true;
                updateMsg(statusObj, ...
                    "The directory " + directory + " does not exist.", ...
                    "Error", ...
                    statusObj.logLevel);
                return
            end

            updateMsg(statusObj, ...
                "The directory " + directory + " exists.", ...
                "Info", ...
                statusObj.logLevel);

        end % initializeDirectory

        function data = importJSONFile(statusObj, pathFile)

            try
                data = openmebius.infrastructure.filesystem.JsonFileStore() ...
                    .read(pathFile);
            catch ME
                statusObj.isError = true;
                msg = openmebius.infrastructure.legacy.LegacyFileAccess ...
                    .legacyJsonMessage(pathFile, ME);
                updateMsg(statusObj, msg, "Error", statusObj.logLevel);
                data = struct();
                return
            end

            reset(statusObj);
            updateMsg(statusObj, ...
                string(pathFile) + " is successfully imported.", ...
                "Info", ...
                statusObj.logLevel);

        end % importJSONFile

        function exportJSONFile(statusObj, pathFile, data)

            try
                openmebius.infrastructure.filesystem.JsonFileStore() ...
                    .writeAtomically(pathFile, data);
            catch
                statusObj.isError = true;
                updateMsg(statusObj, ...
                    "The data cannot be exported to the file " + ...
                    string(pathFile) + ".", ...
                    "Error", ...
                    statusObj.logLevel);
                return
            end

            reset(statusObj);
            updateMsg(statusObj, ...
                "The data is successfully exported to " + string(pathFile) + ".", ...
                "Info", ...
                statusObj.logLevel);

        end % exportJSONFile

        function data = importExcelFile(statusObj, pathFile, sheetName, options)

            arguments
                statusObj
                pathFile (1, 1) string
                sheetName (1, 1) string = ""
                options.ReadRowNames (1, 1) logical = true
                options.readRowName (1, 1) logical = true
                options.ReadVariableNames (1, 1) logical = true
                options.checkVariable (1, 1) logical = true
                options.refTypes (1, :) string = []
                options.refVariableNames (1, :) string = []
            end

            try
                data = openmebius.infrastructure.filesystem.ExcelFileStore ...
                    .readTable( ...
                    pathFile, ...
                    sheetName, ...
                    ReadRowNames = options.ReadRowNames && options.readRowName, ...
                    ReadVariableNames = options.ReadVariableNames, ...
                    CheckVariable = options.checkVariable, ...
                    RefTypes = options.refTypes, ...
                    RefVariableNames = options.refVariableNames);
            catch ME
                statusObj.isError = true;
                msg = openmebius.infrastructure.legacy.LegacyFileAccess ...
                    .legacyExcelMessage(pathFile, ME);
                updateMsg(statusObj, msg, "Error", statusObj.logLevel);
                data = table();
                return
            end

            reset(statusObj);
            updateMsg(statusObj, ...
                string(pathFile) + "/" + string(sheetName) + ...
                " is successfully imported.", ...
                "Info", ...
                statusObj.logLevel);

        end % importExcelFile

        function [isSuccess, msg] = exportExcelFile(pathFile, excelData, sheetName, options)

            arguments
                pathFile (1, 1) string
                excelData
                sheetName (1, 1) string = ""
                options.WriteRowNames (1, 1) logical = true
                options.WriteVariableNames (1, 1) logical = true
            end

            [isSuccess, msg] = openmebius.infrastructure.filesystem.ExcelFileStore ...
                .writeTable( ...
                pathFile, ...
                excelData, ...
                sheetName, ...
                WriteRowNames = options.WriteRowNames, ...
                WriteVariableNames = options.WriteVariableNames);

        end % exportExcelFile

        function [isSuccess, msg] = writeHDF5File(pathFile, pathData, data, options)

            arguments
                pathFile (1, 1) string
                pathData (1, 1) string
                data
                options.DataType (1, 1) string = "double"
            end

            [isSuccess, msg] = openmebius.infrastructure.filesystem.Hdf5FileStore ...
                .writeDataset( ...
                pathFile, ...
                pathData, ...
                data, ...
                DataType = options.DataType);

        end % writeHDF5File

        function hash = getHashFromFile(pathFile, options)

            arguments
                pathFile (1, 1) string
                options.Algorithm (1, 1) string = "SHA256"
            end

            hash = openmebius.infrastructure.filesystem.FileHasher ...
                .hashFile(pathFile, Algorithm = options.Algorithm);

        end % getHashFromFile

        function saveHashFile(pathFile)

            openmebius.infrastructure.filesystem.FileHasher.saveHashFile(pathFile);

        end % saveHashFile

    end % methods

    methods (Static, Access = private)

        function msg = legacyJsonMessage(pathFile, cause)

            switch string(cause.identifier)
                case "OpenMebius2:JsonFileStore:FileNotFound"
                    msg = "The file " + string(pathFile) + " does not exist.";
                otherwise
                    msg = "The file " + string(pathFile) + ...
                        " is not a valid JSON file.";
            end

        end % legacyJsonMessage

        function msg = legacyExcelMessage(pathFile, cause)

            switch string(cause.identifier)
                case "OpenMebius2:ExcelFileStore:FileNotFound"
                    msg = "The file " + string(pathFile) + " does not exist.";
                case "OpenMebius2:ExcelFileStore:VariableMismatch"
                    msg = string(cause.message);
                otherwise
                    msg = "The file " + string(pathFile) + ...
                        " is not a valid Excel file.";
            end

        end % legacyExcelMessage

    end % methods

end % classdef
