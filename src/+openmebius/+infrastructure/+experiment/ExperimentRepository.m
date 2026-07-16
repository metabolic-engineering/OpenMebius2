classdef ExperimentRepository < handle
    % EXPERIMENTREPOSITORY
    % Filesystem-backed repository for experiment workbook files.

    properties (Access = private)
        DerivedDataRestorer
        WorkbookStore
    end

    methods

        function obj = ExperimentRepository(options)

            arguments
                options.DerivedDataRestorer = openmebius.domain.experiment ...
                    .ExperimentDerivedDataRestorer()
                options.WorkbookStore = openmebius.infrastructure.experiment ...
                    .ExperimentWorkbookStore()
            end

            obj.DerivedDataRestorer = options.DerivedDataRestorer;
            obj.WorkbookStore = options.WorkbookStore;

        end % constructor

        function experiments = load(obj, experimentLocation, model)

            arguments
                obj
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                model
            end

            experiments = IOExps( ...
                experimentLocation, ...
                model, ...
                ExperimentRepository = obj);

            if isempty(experiments) || ~isvalid(experiments)
                error( ...
                    "OpenMebius2:ExperimentRepository:InvalidExperimentObject", ...
                    "Failed to create IOExps.");
            end

        end % load

        function experiments = initialize(obj, experimentLocation, model)

            arguments
                obj
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                model
            end

            experiments = IOExps( ...
                experimentLocation, ...
                model, ...
                ExperimentRepository = obj, ...
                AllowEmpty = true);

            if isempty(experiments) || ~isvalid(experiments)
                error( ...
                    "OpenMebius2:ExperimentRepository:" + ...
                    "InvalidExperimentObject", ...
                    "Failed to initialize IOExps.");
            end

        end % initialize

        function workbook = loadWorkbook(obj, pathFile)

            arguments
                obj
                pathFile (1, 1) string
            end

            workbook = obj.WorkbookStore.load(pathFile);

        end % loadWorkbook

        function saveWorkbook(obj, pathFile, workbook)

            arguments
                obj
                pathFile (1, 1) string
                workbook openmebius.infrastructure.experiment ...
                    .ExperimentWorkbookData
            end

            obj.WorkbookStore.save(pathFile, workbook);

        end % saveWorkbook

        function result = restoreDerivedData(obj, workbook, model)

            arguments
                obj
                workbook openmebius.infrastructure.experiment ...
                    .ExperimentWorkbookData
                model
            end

            modelMSTable = table();
            targetMetabolites = strings(0, 1);

            if ~isempty(workbook.MDVBiomass)
                modelMSTable = model.getMSTable();
                targetMetabolites = model.getTargetMetaboliteList();
            end

            result = obj.DerivedDataRestorer.restore( ...
                MSNormalized = workbook.MSNormalized, ...
                MDV = workbook.MDV, ...
                MDVBiomass = workbook.MDVBiomass, ...
                Enrichment = workbook.Enrichment, ...
                ModelMSTable = modelMSTable, ...
                TargetMetabolites = targetMetabolites);

        end % restoreDerivedData

        function assertExperimentDirectory(~, experimentLocation)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
            end

            if ~isfolder(experimentLocation.Directory)
                error( ...
                    "OpenMebius2:ExperimentRepository:DirectoryNotFound", ...
                    "Experiment directory does not exist: %s", ...
                    experimentLocation.Directory);
            end

        end % assertExperimentDirectory

        function files = listWorkbooks(~, experimentLocation, fileType)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                fileType (1, 1) string = "xlsx"
            end

            files = experimentLocation.filesByType(fileType);

        end % listWorkbooks

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

    end % methods

end % classdef
