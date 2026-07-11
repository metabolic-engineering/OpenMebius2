classdef ExperimentRepository < handle
    % EXPERIMENTREPOSITORY
    % Filesystem-backed repository for legacy IOExps experiment data.

    methods

        function report = importFiles(~, experimentLocation, files)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                files (:, 1) string
            end

            if ~isfolder(experimentLocation.Directory)
                error( ...
                    "OpenMebius2:ExperimentRepository:DirectoryNotFound", ...
                    "Experiment directory does not exist: %s", ...
                    experimentLocation.Directory);
            end

            report = struct( ...
                'ImportedFiles', strings(0, 1), ...
                'SkippedFiles', strings(0, 1), ...
                'Messages', strings(0, 1));

            for i = 1:numel(files)
                sourceFile = string(files(i));

                if ismissing(sourceFile) || strlength(sourceFile) == 0
                    continue
                end

                if ~isfile(sourceFile)
                    error( ...
                        "OpenMebius2:ExperimentRepository:SourceFileNotFound", ...
                        "Experiment file does not exist: %s", ...
                        sourceFile);
                end

                [~, fileBaseName, fileExtension] = fileparts(sourceFile);
                fileName = string(fileBaseName) + string(fileExtension);
                destinationFile = experimentLocation.workbookFile(fileName);

                if isfile(destinationFile)
                    report.SkippedFiles(end + 1, 1) = fileName;
                    report.Messages(end + 1, 1) = ...
                        "File already exists in the experiment directory: " + fileName;
                    continue
                end

                [isCopied, copyMessage] = copyfile(sourceFile, destinationFile, 'f');

                if ~isCopied
                    error( ...
                        "OpenMebius2:ExperimentRepository:CopyFailed", ...
                        "Failed to import experiment file %s: %s", ...
                        sourceFile, ...
                        string(copyMessage));
                end

                report.ImportedFiles(end + 1, 1) = fileName;
                report.Messages(end + 1, 1) = ...
                    "File imported successfully: " + fileName;
            end

        end % importFiles

        function experiments = load(~, experimentLocation, model)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                model
            end

            if ~isfolder(experimentLocation.Directory)
                error( ...
                    "OpenMebius2:ExperimentRepository:DirectoryNotFound", ...
                    "Experiment directory does not exist: %s", ...
                    experimentLocation.Directory);
            end

            experiments = IOExps(experimentLocation, model);

            if isempty(experiments) || ~isvalid(experiments)
                error( ...
                    "OpenMebius2:ExperimentRepository:InvalidExperimentObject", ...
                    "Failed to create IOExps.");
            end

            if experiments.isError
                error( ...
                    "OpenMebius2:ExperimentRepository:LoadFailed", ...
                    "%s", string(experiments.statusMsg));
            end

        end % load

    end % methods

end % classdef
