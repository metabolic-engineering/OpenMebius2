classdef IORawFile

    properties

        RawDataLocation openmebius.domain.raw.RawDataLocation

    end % properties

    properties (Dependent)

        fileDirectory

    end % properties

    methods

        %% Constructor
        function obj = IORawFile(rawInput)

            obj.RawDataLocation = ...
                openmebius.domain.raw.RawDataLocation.fromInput(rawInput);

        end % function

        function fileDirectory = get.fileDirectory(obj)

            if isempty(obj.RawDataLocation)
                fileDirectory = "";
                return;
            end

            fileDirectory = obj.RawDataLocation.Directory;

        end % get.fileDirectory

        function obj = set.fileDirectory(obj, fileDirectory)

            obj.RawDataLocation = ...
                openmebius.domain.raw.RawDataLocation.fromInput(fileDirectory);

        end % set.fileDirectory

        %% Public utilization method
        function [isError, output] = readMSDataFromShimadzuASCII(obj, toSavePath, fragmentList)

            output = IORawFile.emptyImportReport();
            targetLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromInput( ...
                toSavePath);

            if ~obj.validateFileDirectory()
                isError = true;
                output = IORawFile.appendFailure( ...
                    output, ...
                    obj.fileDirectory, ...
                    'Invalid file directory.');
                return;
            end

            textList = obj.RawDataLocation.textFiles();
            numFile = length(textList);

            if numFile == 0
                isError = true;
                output = IORawFile.appendFailure( ...
                    output, ...
                    obj.RawDataLocation.Directory, ...
                    'No raw MS text files were found.');
                return;
            end

            for i = 1:numFile

                sourceFile = obj.RawDataLocation.textFile(textList(i));
                [data, fileIsError, fileOutput] = obj.readTextData(sourceFile);

                if fileIsError
                    message = sprintf( ...
                        'Error reading file: %s. %s', ...
                        sourceFile, ...
                        fileOutput.message);
                    output = IORawFile.appendFailure( ...
                        output, ...
                        textList(i), ...
                        message);
                    continue;
                end

                [~, name, ~] = fileparts(textList(i));
                workbookName = string(name) + ".xlsx";
                workbookFile = targetLocation.workbookFile(workbookName);

                try
                    data = data(:, {'Name', 'Area'});
                catch ME
                    message = sprintf( ...
                        'Error preparing raw MS table for file: %s. %s', ...
                        sourceFile, ...
                        ME.message);
                    output = IORawFile.appendFailure( ...
                        output, ...
                        textList(i), ...
                        message);
                    continue;
                end

                [fileIsError, fileOutput] = obj.exportToExcel( ...
                    data, ...
                    workbookFile, ...
                    fragmentList);

                if fileIsError
                    message = sprintf( ...
                        'Error exporting to Excel for file: %s. %s', ...
                        workbookFile, ...
                        fileOutput.message);
                    output = IORawFile.appendFailure( ...
                        output, ...
                        textList(i), ...
                        message);
                    continue;
                end

                output = IORawFile.appendSuccess( ...
                    output, ...
                    workbookName, ...
                    "Raw MS data imported successfully: " + workbookName);

            end % for

            isError = ~isempty(output.FailedFiles);

            if isError
                output.message = strjoin(output.FailureMessages, newline);
            else
                output.message = sprintf( ...
                    'Imported %d raw MS data file(s).', ...
                    numel(output.ImportedFiles));
            end

        end % function

    end % methods

    methods (Access = private)

        %% Private utility methods
        function [data, isError, output] = readTextData(~, filename)

            isError = false;
            output = '';
            data = table();

            fileID = fopen(filename, 'r');

            if fileID == -1
                isError = true;
                output.message = sprintf('Failed to open file: %s', filename);
                return;
            end

            % Tag
            tag = '[MS Quantitative Results]';
            rowDataLine = -1;
            lineCount = 0;
            lineEnd = -1;

            while ~feof(fileID)

                line = fgetl(fileID);
                lineCount = lineCount + 1;

                if contains(line, tag)
                    rowDataLine = lineCount + 2; % Data starts two lines after the tag
                    break;
                end

            end % while

            while ~feof(fileID)

                line = fgetl(fileID);
                lineCount = lineCount + 1;

                if strcmp(line, '')
                    lineEnd = lineCount - 1; % End of data
                    break;
                end

            end % while

            fclose(fileID);

            if rowDataLine == -1 || lineEnd == -1
                isError = true;
                output.message = sprintf('Tag not found or data end not found in file: %s', filename);
                return;
            end

            try
                data = readtable( ...
                    filename, ...
                    'Delimiter', '\t', ...
                    'NumHeaderLines', rowDataLine - 1, ...
                    'VariableNamingRule', 'preserve' ...
                );
            catch ME
                isError = true;
                output.message = sprintf('Error reading table from file: %s. %s', filename, ME.message);
                return;
            end

            data = data(1:(lineEnd - rowDataLine), :);
            idx = ismissing(data(:, {'Area', 'Height'}));
            data{:, {'Area', 'Height'}}(idx) = 0;

        end % function

        function [isError, output] = exportToExcel(obj, data, filename, fragment)

            isError = false;
            output = '';
            MSTable = table();

            for i = 1:length(fragment)

                idx = obj.matchFragmentRows(data.Name, fragment{i});
                selectedData = data(idx, 'Area');
                numRows = max(100, height(selectedData));
                selectedNaN = nan(numRows - height(selectedData), 1);
                selectedDataNaN = table(selectedNaN, 'VariableNames', {'Area'});
                selectedData = [selectedData; selectedDataNaN]; %#ok<AGROW>

                if sum(selectedData{:, :}, 'omitnan') > 0

                    selectedData.Properties.VariableNames('Area') = {fragment{i}}; %#ok<CCAT1>
                    MSTable = [MSTable, selectedData]; %#ok<AGROW>

                end % for

            end % for

            if isempty(MSTable) || width(MSTable) == 0
                isError = true;
                output.message = 'No matching MS fragment data was found in the raw text file.';
                return;
            end

            MSTable = MSTable(~all(isnan(MSTable.Variables), 2), :);

            if isempty(MSTable)
                isError = true;
                output.message = 'No non-zero MS fragment data was found in the raw text file.';
                return;
            end

            rowNames = arrayfun( ...
                @(x) sprintf('M+%d', x), ...
                0:(height(MSTable) - 1), ...
                'UniformOutput', false);
            MSTable.Properties.RowNames = rowNames;

            try
                writetable(MSTable, filename, 'WriteRowNames', true, 'Sheet', 'MS');
            catch ME
                isError = true;
                output.message = sprintf('Error writing to Excel file: %s. %s', filename, ME.message);
                return;
            end

        end % function

        %% Private validation method
        function isValid = validateFileDirectory(obj)

            isValid = isfolder(obj.RawDataLocation.Directory);

        end % function

        function idx = matchFragmentRows(~, names, fragment)

            normalizedNames = IORawFile.normalizeFragmentLabels(names);
            normalizedFragment = IORawFile.normalizeFragmentLabels(fragment);

            idx = startsWith(normalizedNames, normalizedFragment);

            if ~any(idx)
                idx = contains(normalizedNames, normalizedFragment);
            end

        end % matchFragmentRows

    end % methods (Private)

    methods (Static, Access = private)

        function report = emptyImportReport()

            report = struct( ...
                'ImportedFiles', strings(0, 1), ...
                'FailedFiles', strings(0, 1), ...
                'Messages', strings(0, 1), ...
                'FailureMessages', strings(0, 1), ...
                'message', "");

        end % emptyImportReport

        function report = appendSuccess(report, fileName, message)

            report.ImportedFiles(end + 1, 1) = string(fileName);
            report.Messages(end + 1, 1) = string(message);

        end % appendSuccess

        function report = appendFailure(report, fileName, message)

            message = string(message);

            report.FailedFiles(end + 1, 1) = string(fileName);
            report.FailureMessages(end + 1, 1) = message;
            report.Messages(end + 1, 1) = message;
            report.message = strjoin(report.FailureMessages, newline);

        end % appendFailure

        function labels = normalizeFragmentLabels(labels)

            labels = lower(string(labels));
            labels = regexprep(labels, '\[m[-_ ]*(\d+)\]', '$1');
            labels = regexprep(labels, '(^|[^a-z0-9])m[-_ ]*(\d+)(?=$|[^a-z0-9])', '$1$2');
            labels = regexprep(labels, '[^a-z0-9]', '');

        end % normalizeFragmentLabels

    end % methods (Static, Access = private)

end % classdef
