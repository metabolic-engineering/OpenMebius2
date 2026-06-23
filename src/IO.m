classdef IO < handle & Status

    properties
        % The file directory
        fileDirectory (1, 1) string = "";
        logLevel (1, 1) string {mustBeMember(logLevel, ["Debug", "Info", "Notice", "Warning", "Error", "Fatal"])} = "Info";
        isEmpty (1, 1) logical = false;

    end

    properties (Dependent)
        % The file name
        fileList (1, 1) string;
        % Directory
        dirList (1, 1) string;
    end

    methods

        function obj = IO(fileDirectory)

            % Set the file directory
            obj.fileDirectory = fileDirectory;

            if ~isfolder(obj.fileDirectory)
                obj.isError = true;
                updateMsg(obj, "The directory " + obj.fileDirectory + " does not exist.", "Error", obj.logLevel);
                return;
            end

            updateMsg(obj, "The directory " + obj.fileDirectory + " exists.", "Info", obj.logLevel);

            isEmptyDir(obj);

        end

        function fileList = get.fileList(obj)

            % Get the file list
            fileList = dir(obj.fileDirectory);
            % Filter the file list not isdir
            fileList = fileList(~[fileList.isdir]);
            % Convert to string array
            fileList = string({fileList.name});

        end

        function dirList = get.dirList(obj)

            % Get the directory list
            dirList = dir(obj.fileDirectory);
            % Filter the directory list isdir
            dirList = dirList([dirList.isdir]);
            % Remove . and ..
            dirList = dirList(~ismember({dirList.name}, {'.', '..'}));

            % Convert to string array
            dirList = string({dirList.name});

        end

        function fileList = getFileList(obj, fileType)

            % Get the file list
            fileList = obj.fileList;
            % Filter the file list by file type
            fileList = fileList(endsWith(fileList, fileType));

        end

        function reset(obj)

            % Reset the status
            obj.isError = false;
            obj.msg = "";

        end

        function isExistFiles(obj, filePath)

            % Check if the files exist
            for i = 1:length(filePath)
                isExistFile(obj, fileNames(i));

                if obj.isError
                    break;
                end

            end

            obj.reset();

        end

        function tf = isExistFile(obj, pathFile)

            % Split filepath to filename and extension
            [~, name, ext] = fileparts(pathFile);
            fileName = name + ext;
            tf = false;

            % Check if the file exists
            if ~any(obj.fileList == fileName)
                obj.isError = true;
                updateMsg(obj, "The file " + pathFile + " does not exist.", "Error", obj.logLevel);
            else
                tf = true;
                obj.reset();
            end

        end

        function isEmptyDir(obj)

            % Check if the directory is empty
            if isempty(obj.fileList) && isempty(obj.dirList)
                obj.isEmpty = true;
            else
                obj.isEmpty = false;
            end

        end

        function data = importJSONFile(obj, pathFile)

            isExistFile(obj, pathFile);

            % If the file does not exist, return
            if obj.isError
                data = struct();
                return
            end

            % Import the data
            try
                data = jsondecode(fileread(pathFile));
            catch
                obj.isError = true;
                updateMsg(obj, "The file " + pathFile + " is not a valid JSON file.", "Error", obj.logLevel);
                data = struct();
                return
            end

            obj.reset();

            msg = pathFile + " is successfully imported.";
            updateMsg(obj, msg, "Info", obj.logLevel);

        end

        function exportJSONFile(obj, pathFile, data)

            % Export the data
            try
                fid = fopen(pathFile, 'w');
                fwrite(fid, jsonencode(data));
                fclose(fid);
            catch
                obj.isError = true;
                updateMsg(obj, "The data cannot be exported to the file " + pathFile + ".", "Error", obj.logLevel);
                return
            end

            obj.reset();

            updateMsg(obj, "The data is successfully exported to " + pathFile + ".", "Info", obj.logLevel);

        end

        function checkVariable(obj, variableNames, refVariableNames)

            arguments
                obj;
                variableNames (1, :) string;
                refVariableNames (1, :) string;
            end

            % Check the variable names
            if ~isequal(variableNames, refVariableNames)
                obj.isError = true;
                msg = "The variable names [" + join(variableNames, ", ") + "] are not matched with the correct variable names [" + join(refVariableNames, ", ") + "].";
                updateMsg(obj, msg, "Error", obj.logLevel);
                return
            end

            obj.reset();

        end

        function data = importExcelFile(obj, pathFile, Sheet, options)

            arguments
                obj;
                pathFile (1, 1) string;
                Sheet (1, 1) string = "";
                options.ReadRowNames (1, 1) logical = true;
                options.ReadVariableNames (1, 1) logical = true;
                options.checkVariable (1, 1) logical = true;
                options.refTypes (1, :) string = [];
                options.refVariableNames (1, :) string = [];
            end

            isExistFile(obj, pathFile);

            % If the file does not exist, return
            if obj.isError
                data = table();
                updateMsg(obj, "The file " + pathFile + " does not exist.", "Error", obj.logLevel);
                return
            end

            % Import the data
            try
                data = readtable( ...
                    pathFile, ...
                    'Sheet', Sheet, ...
                    'ReadRowNames', options.ReadRowNames, ...
                    'ReadVariableNames', options.ReadVariableNames ...
                );

                if ~isempty(options.refTypes)
                    data.Properties.VariableTypes = options.refTypes;
                end

            catch
                obj.isError = true;
                updateMsg(obj, "The file " + pathFile + " is not a valid Excel file.", "Error", obj.logLevel);
                data = table();
                return
            end

            if options.checkVariable
                obj.checkVariable(string(data.Properties.VariableNames), options.refVariableNames);

                if obj.isError
                    data = table();
                    return
                end

            end

            obj.reset();

            msg = pathFile + "/" + Sheet + " is successfully imported.";
            updateMsg(obj, msg, "Info", obj.logLevel);
        end % importExcelFile

        function [isSuccess, msg] = exportExcelFile(~, pathFile, excelData, Sheet, options)

            arguments
                ~;
                pathFile (1, 1) string;
                excelData;
                Sheet (1, 1) string = "";
                options.WriteRowNames (1, 1) logical = true;
                options.WriteVariableNames (1, 1) logical = true;
            end

            isSuccess = true;
            msg = "";

            try
                writetable( ...
                    excelData, ...
                    pathFile, ...
                    'Sheet', Sheet, ...
                    'WriteRowNames', options.WriteRowNames, ...
                    'WriteVariableNames', options.WriteVariableNames, ...
                    'PreserveFormat', true ...
                );
            catch ME
                isSuccess = false;
                msg = ME.message;
                return
            end

        end % exportExcelFile

        function [isSuccess, msg] = writeHDF5File(~, pathFile, pathData, data, options)

            arguments
                ~;
                pathFile (1, 1) string;
                pathData (1, 1) string;
                data;
                options.DataType (1, 1) string ...
                    {mustBeMember(options.DataType, ...
                     ["int8", "uint8", "int16", "uint16", "int32", "uint32", "int64", "uint64", "single", "double", "string"])} ...
                    = "double";
            end

            isSuccess = true;

            try
                h5read(pathFile, pathData);
            catch

                try
                    h5create(pathFile, pathData, size(data), 'DataType', options.DataType);
                catch
                    isSuccess = false;
                    msg = "The dataset " + pathData + " cannot be created in the file " + pathFile + ".";
                    return
                end

            end

            try
                h5write(pathFile, pathData, data);
            catch
                isSuccess = false;
                msg = "The data cannot be written to the dataset " + pathData + " in the file " + pathFile + ".";
                return
            end

        end % writeHDF5File

        function data = pasteDataFromClipboard(obj, copiedData)

            % If the copied data is empty, return
            if isempty(copiedData)
                data = [];
                return
            end

            % Convert the copied data to a matrix
            data = convertCellToMatrix(obj, copiedData);

        end % pasteDataFromClipboard

        function hash = getHashFromFile(obj, pathFile, options)
            % GETHASHFROMFILE Get the hash from the file
            %
            % getHashFromFile(obj, pathFile)
            %
            % Parameters
            % ----------
            % pathFile: (1, 1) string
            %     The path of the file
            %
            % Returns
            % -------
            % hash: (1, 1) string
            %     The hash of the file
            %
            % Examples
            % --------
            % >> obj = IO("C:\Users\");
            % >> pathFile = "C:\Users\user\file.txt";
            % >> hash = obj.getHashFromFile(pathFile);
            % >> disp(hash)
            % "8b1b6f8b1252e1a29b1a8120aa5fd3f4b6361f378052f9303fab52983a523f6a"

            arguments
                obj;
                pathFile (1, 1) string;
                options.Algorithm (1, 1) string {mustBeMember(options.Algorithm, ["SHA256", "SHA1", "MD5"])} = "SHA256";
            end

            % Check if the file exists
            if ~isfile(pathFile)
                hash = "";
                return
            end

            data = readBinaryFile(obj, pathFile);

            hash = utils.sha256_uint8(data);

        end % getHashFromFile

        function data = readBinaryFile(~, filepath)
            %READBINARYFILE Reads a binary file and returns its contents as a uint8 array.
            %  data = readBinaryFile(filepath)
            %
            %  Input:
            %   filepath - A string specifying the path to the binary file to be read.
            %
            %  Output:
            %   data - A uint8 array containing the contents of the binary file.

            fid = fopen(filepath, 'rb');

            if fid == -1
                error('Unable to open file: %s', filepath);
            end

            cleanupObj = onCleanup(@() fclose(fid));

            data = fread(fid, Inf, '*uint8');
        end

        function saveHashFile(obj, pathFile)
            % SAVEHASHFILE Save the hash of the file to the file
            %
            % saveHashFile(obj, pathFile)
            %
            % Parameters
            % ----------
            % pathFile: (1, 1) string
            %     The path of the file
            %
            % Examples
            % --------
            % >> obj = IO("C:\Users\");
            % >> pathFile = "C:\Users\user\file.txt";
            % >> obj.saveHashFile(pathFile);

            % Get the hash of the file
            hash = getHashFromFile(obj, pathFile);

            % Save the hash to the file
            % Remove the file extension
            [path, name, ~] = fileparts(pathFile);
            hashFile = fullfile(path, name + ".hash");

            try
                fid = fopen(hashFile, 'w');
                fprintf(fid, hash);
                fclose(fid);
            catch
                return
            end

        end % saveHashFile

    end % methods (public)

    methods (Access = private)

        function data = convertCellToMatrix(obj, data)

            % separate the data by newline
            dataCellLine = split(data, newline);

            % Remove the end of the line if it is empty
            if isempty(dataCellLine{end})
                dataCellLine = dataCellLine(1:end - 1);
            end

            data = separateColumnData(obj, dataCellLine);

        end % convertCellToMatrix

        function matrix = separateColumnData(~, data)

            numLine = length(data);

            for i = 1:numLine

                % separate the data by tab
                iDataCell = split(data(i), char(9));

                if i == 1
                    numColumn = length(iDataCell);
                    dataCellTab = cell(numLine, numColumn);
                end

                dataCellTab(i, :) = iDataCell;

            end % for row

            matrix = cellfun(@str2double, dataCellTab);

        end % separateColumnData

    end % methods (private)

end % classdef
