classdef ResultRepository < handle
    % RESULTREPOSITORY
    % Opens result objects and writes result export artifacts.

    properties (Access = private)
        Hdf5ResultRepository
    end

    methods

        function obj = ResultRepository(options)

            arguments
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result ...
                    .Hdf5ResultRepository()
            end

            obj.Hdf5ResultRepository = ...
                options.Hdf5ResultRepository;

        end % constructor

        function result = open(obj, resultLocation)

            arguments
                obj
                resultLocation openmebius.domain.result.ResultLocation
            end

            result = IOResult( ...
                resultLocation, ...
                ResultRepository = obj, ...
                Hdf5ResultRepository = obj.Hdf5ResultRepository);

            if isempty(result) || ~isvalid(result)
                error( ...
                    "OpenMebius2:ResultRepository:InvalidResultObject", ...
                    "Failed to create IOResult.");
            end

        end % open

        function assertResultDirectory(~, resultLocation)

            arguments
                ~
                resultLocation openmebius.domain.result.ResultLocation
            end

            if ~resultLocation.directoryExists()
                error( ...
                    "OpenMebius2:ResultRepository:DirectoryNotFound", ...
                    "Result directory does not exist: %s", ...
                    resultLocation.Directory);
            end

        end % assertResultDirectory

        function [isSuccess, msg] = writeExcelTable(~, pathFile, tableData, sheetName, options)

            arguments
                ~
                pathFile (1, 1) string
                tableData table
                sheetName (1, 1) string = ""
                options.WriteRowNames (1, 1) logical = true
                options.WriteVariableNames (1, 1) logical = true
            end

            [isSuccess, msg] = openmebius.infrastructure.filesystem.ExcelFileStore ...
                .writeTable( ...
                pathFile, ...
                tableData, ...
                sheetName, ...
                WriteRowNames = options.WriteRowNames, ...
                WriteVariableNames = options.WriteVariableNames);

        end % writeExcelTable

        function [isSuccess, msg] = writeCsvTable(~, pathFile, tableData, options)

            arguments
                ~
                pathFile (1, 1) string
                tableData table
                options.WriteRowNames (1, 1) logical = true
                options.WriteVariableNames (1, 1) logical = true
            end

            isSuccess = true;
            msg = "";

            try
                writetable( ...
                    tableData, ...
                    pathFile, ...
                    WriteRowNames = options.WriteRowNames, ...
                    WriteVariableNames = options.WriteVariableNames);
            catch ME
                isSuccess = false;
                msg = string(ME.message);
            end

        end % writeCsvTable

    end % methods

end % classdef
