classdef RawMSDataRepository < handle
    % RAWMSDATAREPOSITORY
    % Filesystem-backed repository for raw MS text imports.

    methods

        function report = importShimadzuASCII(~, rawInput, experimentInput, fragmentNames)

            arguments
                ~
                rawInput
                experimentInput
                fragmentNames string
            end

            rawLocation = ...
                openmebius.domain.raw.RawDataLocation.fromInput(rawInput);
            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation ...
                .fromInput(experimentInput);

            if ~isfolder(rawLocation.Directory)
                error( ...
                    "OpenMebius2:RawMSDataRepository:RawDirectoryNotFound", ...
                    "Raw MS data directory does not exist: %s", ...
                    rawLocation.Directory);
            end

            if ~isfolder(experimentLocation.Directory)
                error( ...
                    "OpenMebius2:RawMSDataRepository:ExperimentDirectoryNotFound", ...
                    "Experiment directory does not exist: %s", ...
                    experimentLocation.Directory);
            end

            textFiles = rawLocation.textFiles();

            if isempty(textFiles)
                error( ...
                    "OpenMebius2:RawMSDataRepository:NoTextFiles", ...
                    "No raw MS text files were found in: %s", ...
                    rawLocation.Directory);
            end

            fragmentNames = string(fragmentNames(:));
            fragmentNames = fragmentNames(strlength(fragmentNames) > 0);

            if isempty(fragmentNames)
                error( ...
                    "OpenMebius2:RawMSDataRepository:NoFragments", ...
                    "No MS fragment names were provided for raw MS import.");
            end

            io = IORawFile(rawLocation);
            [isError, output] = io.readMSDataFromShimadzuASCII( ...
                experimentLocation, ...
                cellstr(fragmentNames));

            if isError
                error( ...
                    "OpenMebius2:RawMSDataRepository:ImportFailed", ...
                    "%s", ...
                    openmebius.infrastructure.experiment.RawMSDataRepository ...
                    .outputMessage(output));
            end

            report = ...
                openmebius.infrastructure.experiment.RawMSDataRepository ...
                .reportFromRawOutput(output);

            missingFiles = strings(0, 1);

            for i = 1:numel(report.ImportedFiles)
                workbookName = report.ImportedFiles(i);
                workbookPath = experimentLocation.workbookFile(workbookName);

                if ~isfile(workbookPath)
                    missingFiles(end + 1, 1) = workbookName; %#ok<AGROW>
                end
            end

            if ~isempty(missingFiles)
                error( ...
                    "OpenMebius2:RawMSDataRepository:MissingOutputWorkbook", ...
                    "Raw MS import did not create workbook(s): %s", ...
                    strjoin(missingFiles, ", "));
            end

        end % importShimadzuASCII

    end % methods

    methods (Static, Access = private)

        function report = reportFromRawOutput(output)

            report = struct( ...
                'ImportedFiles', strings(0, 1), ...
                'SkippedFiles', strings(0, 1), ...
                'Messages', strings(0, 1));

            if ~isstruct(output)
                return
            end

            if isfield(output, 'ImportedFiles')
                report.ImportedFiles = string(output.ImportedFiles(:));
            end

            if isfield(output, 'Messages')
                report.Messages = string(output.Messages(:));
            end

        end % reportFromRawOutput

        function message = outputMessage(output)

            message = "Raw MS data import failed.";

            if isstruct(output) && isfield(output, 'message')
                message = string(output.message);
                return
            end

            if isstring(output) || ischar(output)
                output = string(output);

                if strlength(output) > 0
                    message = output;
                end
            end

        end % outputMessage

    end % methods (Static, Access = private)

end % classdef
