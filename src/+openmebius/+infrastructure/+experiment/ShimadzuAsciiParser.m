classdef ShimadzuAsciiParser
    % SHIMADZUASCIIPARSER Parses one Shimadzu quantitative result file.

    methods

        function data = parse(~, filename)

            arguments
                ~
                filename (1, 1) string
            end

            fileID = fopen(filename, "r");

            if fileID < 0
                error( ...
                    "OpenMebius2:ShimadzuAsciiParser:FileOpenFailed", ...
                    "Failed to open file: %s", filename);
            end

            cleanup = onCleanup(@() fclose(fileID));
            dataStart = -1;
            dataEnd = -1;
            lineNumber = 0;

            while ~feof(fileID)
                line = fgetl(fileID);
                lineNumber = lineNumber + 1;

                if contains(line, "[MS Quantitative Results]")
                    dataStart = lineNumber + 2;
                    break
                end

            end

            while ~feof(fileID)
                line = fgetl(fileID);
                lineNumber = lineNumber + 1;

                if strcmp(line, "")
                    dataEnd = lineNumber - 1;
                    break
                end

            end

            if dataStart < 0 || dataEnd < dataStart
                error( ...
                    "OpenMebius2:ShimadzuAsciiParser:DataSectionNotFound", ...
                    "Tag not found or data end not found in file: %s", ...
                    filename);
            end

            try
                data = readtable( ...
                    filename, ...
                    Delimiter = "\t", ...
                    NumHeaderLines = dataStart - 1, ...
                    VariableNamingRule = "preserve");
            catch exception
                wrapped = MException( ...
                    "OpenMebius2:ShimadzuAsciiParser:TableReadFailed", ...
                    "Error reading table from file: %s.", filename);
                throw(addCause(wrapped, exception));
            end

            data = data(1:(dataEnd - dataStart), :);
            required = ["Name", "Area", "Height"];

            if ~all(ismember(required, string(data.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:ShimadzuAsciiParser:InvalidColumns", ...
                    "Shimadzu data must contain Name, Area, and Height columns.");
            end

            numericValues = data{:, ["Area", "Height"]};
            numericValues(ismissing(numericValues)) = 0;
            data{:, ["Area", "Height"]} = numericValues;

        end

    end

end
