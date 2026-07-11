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

            report = struct( ...
                'ImportedFiles', strings(0, 1), ...
                'SkippedFiles', strings(0, 1), ...
                'Messages', strings(0, 1));

            missingFiles = strings(0, 1);

            for i = 1:numel(textFiles)
                [~, fileBaseName] = fileparts(textFiles(i));
                workbookName = string(fileBaseName) + ".xlsx";
                workbookPath = experimentLocation.workbookFile(workbookName);

                if isfile(workbookPath)
                    report.ImportedFiles(end + 1, 1) = workbookName;
                    report.Messages(end + 1, 1) = ...
                        "Raw MS data imported successfully: " + workbookName;
                else
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
