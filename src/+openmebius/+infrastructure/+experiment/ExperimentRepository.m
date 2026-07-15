classdef ExperimentRepository < handle
    % EXPERIMENTREPOSITORY
    % Filesystem-backed repository for experiment workbook files.

    properties (Access = private)
        DerivedDataRestorer
    end

    methods

        function obj = ExperimentRepository(options)

            arguments
                options.DerivedDataRestorer = openmebius.domain.experiment ...
                    .ExperimentDerivedDataRestorer()
            end

            obj.DerivedDataRestorer = options.DerivedDataRestorer;

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

        function result = restoreDerivedData(obj, workbook, model)

            arguments
                obj
                workbook
                model
            end

            modelMSTable = table();
            targetMetabolites = strings(0, 1);

            if ~isempty(workbook.tableMDVBiomass)
                modelMSTable = model.getMSTable();
                targetMetabolites = model.getTargetMetaboliteList();
            end

            result = obj.DerivedDataRestorer.restore( ...
                MSNormalized = workbook.tableMSNormalized, ...
                MDV = workbook.tableMDV, ...
                MDVBiomass = workbook.tableMDVBiomass, ...
                Enrichment = workbook.tableEnrichment, ...
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

        function data = readWorkbookSheet(~, pathFile, sheetName, options)

            arguments
                ~
                pathFile (1, 1) string
                sheetName (1, 1) string
                options.ReadRowNames (1, 1) logical = true
                options.ReadVariableNames (1, 1) logical = true
                options.CheckVariable (1, 1) logical = true
                options.RefTypes (1, :) string = []
                options.RefVariableNames (1, :) string = []
            end

            try
                data = openmebius.infrastructure.filesystem.ExcelFileStore ...
                    .readTable( ...
                    pathFile, ...
                    sheetName, ...
                    ReadRowNames = options.ReadRowNames, ...
                    ReadVariableNames = options.ReadVariableNames, ...
                    CheckVariable = options.CheckVariable, ...
                    RefTypes = options.RefTypes, ...
                    RefVariableNames = options.RefVariableNames);
            catch ME
                openmebius.infrastructure.experiment.ExperimentRepository ...
                    .throwWorkbookReadError(pathFile, ME);
            end

        end % readWorkbookSheet

        function data = readOptionalWorkbookSheet(obj, pathFile, preferredSheetName, aliases, options)

            arguments
                obj
                pathFile (1, 1) string
                preferredSheetName (1, 1) string
                aliases (1, :) string = preferredSheetName
                options.ReadRowNames (1, 1) logical = true
                options.ReadVariableNames (1, 1) logical = true
            end

            sheetName = obj.resolveWorkbookSheetName( ...
                pathFile, ...
                preferredSheetName, ...
                aliases);

            try
                data = openmebius.infrastructure.filesystem.ExcelFileStore ...
                    .readTable( ...
                    pathFile, ...
                    sheetName, ...
                    ReadRowNames = options.ReadRowNames, ...
                    ReadVariableNames = options.ReadVariableNames, ...
                    CheckVariable = false);
            catch
                data = table();
            end

        end % readOptionalWorkbookSheet

        function [isSuccess, msg] = writeWorkbookSheet(~, pathFile, data, sheetName, options)

            arguments
                ~
                pathFile (1, 1) string
                data
                sheetName (1, 1) string
                options.WriteRowNames (1, 1) logical = true
                options.WriteVariableNames (1, 1) logical = true
            end

            [isSuccess, msg] = openmebius.infrastructure.filesystem.ExcelFileStore ...
                .writeTable( ...
                pathFile, ...
                data, ...
                sheetName, ...
                WriteRowNames = options.WriteRowNames, ...
                WriteVariableNames = options.WriteVariableNames);

        end % writeWorkbookSheet

        function sheetNames = listWorkbookSheets(~, pathFile)

            arguments
                ~
                pathFile (1, 1) string
            end

            try
                sheetNames = string(sheetnames(pathFile));
                sheetNames = sheetNames(:);
                return
            catch
            end

            try
                [~, sheets] = xlsfinfo(pathFile);
                sheetNames = string(sheets);
                sheetNames = sheetNames(:);
            catch
                sheetNames = strings(0, 1);
            end

        end % listWorkbookSheets

        function sheetName = resolveWorkbookSheetName(obj, pathFile, preferredSheetName, aliases)

            arguments
                obj
                pathFile (1, 1) string
                preferredSheetName (1, 1) string
                aliases (1, :) string = preferredSheetName
            end

            sheetName = preferredSheetName;
            workbookSheets = obj.listWorkbookSheets(pathFile);

            if isempty(workbookSheets)
                return
            end

            normalizedWorkbookSheets = ...
                openmebius.infrastructure.experiment.ExperimentRepository ...
                .normalizeSheetName(workbookSheets);
            aliases = unique([preferredSheetName aliases], "stable");

            for iAlias = 1:length(aliases)

                normalizedAlias = ...
                    openmebius.infrastructure.experiment.ExperimentRepository ...
                    .normalizeSheetName(aliases(iAlias));
                idx = find(normalizedWorkbookSheets == normalizedAlias, 1);

                if ~isempty(idx)
                    sheetName = workbookSheets(idx);
                    return
                end

            end

        end % resolveWorkbookSheetName

    end % methods

    methods (Static, Access = private)

        function throwWorkbookReadError(pathFile, cause)

            switch string(cause.identifier)
                case "OpenMebius2:ExcelFileStore:FileNotFound"
                    error( ...
                        "OpenMebius2:ExperimentRepository:WorkbookNotFound", ...
                        "The file %s does not exist.", ...
                        pathFile);
                case "OpenMebius2:ExcelFileStore:VariableMismatch"
                    error( ...
                        "OpenMebius2:ExperimentRepository:WorkbookVariableMismatch", ...
                        "%s", string(cause.message));
                otherwise
                    error( ...
                        "OpenMebius2:ExperimentRepository:InvalidWorkbook", ...
                        "The file %s is not a valid Excel file.", ...
                        pathFile);
            end

        end % throwWorkbookReadError

        function normalized = normalizeSheetName(sheetNames)

            normalized = lower(string(sheetNames));
            normalized = regexprep(normalized, "[\s_\-\(\)]", "");

        end % normalizeSheetName

    end % methods

end % classdef
