classdef ExcelFileStore
    % EXCELFILESTORE
    % Reads and writes tabular Excel data without legacy status state.

    methods (Static)

        function data = readTable(pathFile, sheetName, options)

            arguments
                pathFile (1, 1) string
                sheetName (1, 1) string = ""
                options.ReadRowNames (1, 1) logical = true
                options.ReadVariableNames (1, 1) logical = true
                options.CheckVariable (1, 1) logical = true
                options.RefTypes (1, :) string = []
                options.RefVariableNames (1, :) string = []
            end

            if ~isfile(pathFile)
                error( ...
                    "OpenMebius2:ExcelFileStore:FileNotFound", ...
                    "The file %s does not exist.", ...
                    pathFile);
            end

            try
                data = readtable( ...
                    pathFile, ...
                    "Sheet", sheetName, ...
                    "ReadRowNames", options.ReadRowNames, ...
                    "ReadVariableNames", options.ReadVariableNames);
            catch ME
                error( ...
                    "OpenMebius2:ExcelFileStore:InvalidExcel", ...
                    "The file %s is not a valid Excel file. %s", ...
                    pathFile, ...
                    string(ME.message));
            end

            if ~isempty(options.RefTypes)
                data.Properties.VariableTypes = options.RefTypes;
            end

            if options.CheckVariable
                openmebius.infrastructure.filesystem.ExcelFileStore ...
                    .assertVariables( ...
                    string(data.Properties.VariableNames), ...
                    options.RefVariableNames);
            end

        end % readTable

        function [isSuccess, msg] = writeTable(pathFile, excelData, sheetName, options)

            arguments
                pathFile (1, 1) string
                excelData
                sheetName (1, 1) string = ""
                options.WriteRowNames (1, 1) logical = true
                options.WriteVariableNames (1, 1) logical = true
            end

            isSuccess = true;
            msg = "";

            try
                writetable( ...
                    excelData, ...
                    pathFile, ...
                    "Sheet", sheetName, ...
                    "WriteRowNames", options.WriteRowNames, ...
                    "WriteVariableNames", options.WriteVariableNames, ...
                    "PreserveFormat", true);
            catch ME
                isSuccess = false;
                msg = string(ME.message);
            end

        end % writeTable

    end % methods

    methods (Static, Access = private)

        function assertVariables(variableNames, refVariableNames)

            if ~isequal(variableNames, refVariableNames)
                error( ...
                    "OpenMebius2:ExcelFileStore:VariableMismatch", ...
                    "The variable names [%s] are not matched with the correct variable names [%s].", ...
                    strjoin(variableNames, ", "), ...
                    strjoin(refVariableNames, ", "));
            end

        end % assertVariables

    end % methods

end % classdef
