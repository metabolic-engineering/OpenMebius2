classdef ResultCatalog < handle

    properties (SetAccess = public)

        % Result data
        IDs (1, :) string = ""
        dataMask (1, :) logical = false(1, 0)

    end % properties

    properties (SetAccess = private)

        ResultLocation openmebius.domain.result.ResultLocation
        ResultRepository
        QueryService
        TableBuilder

    end % properties

    properties (Access = private)
        NotificationEmitter openmebius.application.notification ...
            .NotificationEmitter
    end

    methods

        function obj = ResultCatalog(resultInput, options)
            % Constructor for ResultCatalog class

            arguments
                resultInput
                options.ResultRepository = ...
                    openmebius.infrastructure.result.ResultRepository()
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result ...
                    .Hdf5ResultRepository()
                options.NotificationReporter (1, 1) function_handle = @(~) []
                options.QueryService = []
                options.TableBuilder = ...
                    openmebius.application.result.ResultTableBuilder()
            end

            resultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                resultInput);

            obj.ResultLocation = resultLocation;
            obj.ResultRepository = options.ResultRepository;

            if isempty(options.QueryService)
                obj.QueryService = openmebius.application.result ...
                    .ResultQueryService( ...
                    resultLocation, ...
                    ResultRepository = obj.ResultRepository, ...
                    Hdf5ResultRepository = ...
                    options.Hdf5ResultRepository);
            else
                obj.QueryService = options.QueryService;
            end

            obj.TableBuilder = options.TableBuilder;
            obj.NotificationEmitter = openmebius.application.notification ...
                .NotificationEmitter( ...
                Publisher = options.NotificationReporter, ...
                Source = "ResultCatalog");

            obj.ResultRepository.assertResultDirectory(resultLocation);

            obj.NotificationEmitter.report( ...
                "info", ...
                "The directory " + resultLocation.Directory + ...
                " exists.", ...
                Code = "result.directory.available", ...
                Audience = "developer", ...
                Kind = "diagnostic");

        end % constructor

    end % methods

    methods (Access = public)

        function setNotificationReporter(obj, reporter)

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                reporter (1, 1) function_handle
            end

            obj.NotificationEmitter = openmebius.application.notification ...
                .NotificationEmitter( ...
                Publisher = reporter, ...
                Source = "ResultCatalog");

        end % setNotificationReporter

        %% Public get functions
        function resultLocation = getResultLocation(obj)

            resultLocation = obj.ResultLocation;

        end % getResultLocation

        function ids = getResultIDs(obj)

            ids = obj.ResultLocation.resultIds();

        end % getResultIDs

        function snapshots = getBatchSnapshots(obj, ids)

            arguments
                obj
                ids string
            end

            snapshots = obj.QueryService.readBatchSnapshots(ids);

        end % getBatchSnapshots

        function tableRtn = getFluxOverView(obj, id, options)

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                id (1, 1) string
                options.relative (1, 1) logical = false
                options.relativeTo (1, 1) string = ""
            end

            data = obj.loadResultFile(id);

            if isempty(data)
                tableRtn = table();
                obj.notifyGeneralMessage( ...
                    "error", "Failed to load the result file.");
                return
            end

            [tableRtn, message] = obj.TableBuilder.fluxOverview( ...
                data, ...
                Relative = options.relative, ...
                RelativeTo = options.relativeTo);

            if message ~= ""
                obj.notifyGeneralMessage("error", message);
            end

        end % getFluxOverView

        function tableRtn = getFluxDetailed(obj, batchID)

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchID (1, 1) string
            end

            data = obj.loadResultFile(batchID);

            if isempty(data)
                tableRtn = table();
                obj.notifyGeneralMessage( ...
                    "error", "Failed to load the result file.");
                return
            end

            [tableRtn, message] = obj.TableBuilder.fluxDetailed(data);

            if message ~= ""
                obj.notifyGeneralMessage("error", message);
            end

        end % getFluxDetailed

        function tableRtn = getMDV(obj, batchID)

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchID (1, 1) string
            end

            tableRtn = obj.getFluxDetailed(batchID);

        end % getMDV

        function tableRtn = getMDVSummary(obj, batchID)

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchID (1, 1) string
            end

            data = obj.loadResultFile(batchID);

            if isempty(data)
                tableRtn = table();
                obj.notifyGeneralMessage( ...
                    "error", "Failed to load the result file.");
                return
            end

            [tableRtn, message] = obj.TableBuilder.mdvSummary(data);

            if message ~= ""
                obj.notifyGeneralMessage("error", message);
            end

        end % getMDVSummary

        function tableRtn = getFluxComparison(obj, batchIDs, names, options)

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchIDs (1, :) string
                names (1, :) string
                options.relative (1, 1) logical = false
                options.relativeTo (1, 1) string = ""
            end

            if numel(batchIDs) ~= numel(unique(batchIDs))
                tableRtn = table();
                obj.notifyGeneralMessage("error", "Batch IDs must be unique.");
                return
            end

            [data, mask] = obj.loadResultFiles( ...
                batchIDs, readstatus = [true, true, false, false]);
            data = data(mask);
            [tableRtn, message] = obj.TableBuilder.fluxComparison( ...
                data, ...
                string(names), ...
                Relative = options.relative, ...
                RelativeTo = options.relativeTo);

            if message ~= ""
                obj.notifyGeneralMessage("error", message);
            end

        end % getFluxComparison

        function data = getCIReaction(obj, batchID, RxnID)
            % GETCIREACTION Get the confidence interval reaction data from the result file.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   batchID: string
            %       The batch ID to load the result files.
            %   RxnID: string
            %       The reaction ID to get the confidence interval data.

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchID (1, 1) string
                RxnID (1, 1) string
            end % arguments

            if ~obj.ResultLocation.hasResultFile(batchID)
                notifyGeneralMessage(obj, "error", "Result file does not exist.");
                data = [];
                return;
            end

            data = obj.QueryService.readConfidenceInterval( ...
                batchID, RxnID);

        end % getCIReaction

        function data = getOptimizationState(obj, batchID)
            % GETOPTIMIZATIONSTATE Get RSS trials and their threshold.

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchID (1, 1) string
            end

            if ~obj.ResultLocation.hasResultFile(batchID)
                notifyGeneralMessage(obj, "error", "Result file does not exist.");
                data = [];
                return
            end

            data = obj.QueryService.readOptimizationState(batchID);

        end % getOptimizationState

        function [isExist, data] = getNextLabelSuggestion(obj, batchID)
            % GETNEXTLABELSUGGESTION Get the next label suggestion from the result file.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   batchID: string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchID (1, 1) string
            end % arguments

            [isExist, data] = obj.QueryService ...
                .readNextLabelSuggestion(batchID);

        end % getNextLabelSuggestion

        function RSS = getRSS(~, data)
            % GETRSS Get the RSS from the result file.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   data: cell
            %       The result data.
            %
            % Returns:
            %   RSS: (:,1) double
            %       The RSS data.

            numData = length(data);
            RSS = nan(numData, 1);

            for i = 1:numData

                % Get the RSS data
                iData = data{i};

                if ~isfield(iData, 'RSS')
                    RSS(i) = nan;
                    continue;
                end % if ~isfield(iData,'RSS')

                RSS(i) = min(iData.RSS);

            end % for i

        end % getRSS

        function isPassed = getIsPassedChi2Test(obj, data)
            % GETISPASSEDCHI2TEST Get the isPassedChi2Test from the result file.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   data: cell
            %       The result data.
            %
            % Returns:
            %   isPassed: (:,1) logical
            %       The isPassedChi2Test data.

            RSS = getRSS(obj, data);

            threshold = getX(obj, data, "threshold");

            isPassed = RSS < threshold;

        end % getIsPassedChi2Test

        %% Public load functions
        function [data, dataMask] = loadResultFiles(obj, ids, options)
            % LOADRESULTFILES Load the result files from the directory.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   ids: string array
            %       The batch IDs to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                % Batch IDs
                ids (1, :) string
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            obj.IDs = ids;

            try
                [data, dataMask] = obj.QueryService.readMany( ...
                    ids, ReadStatus = options.readstatus);
            catch exception
                notifyGeneralMessage(obj, "error", string(exception.message));
                data = cell(1, numel(ids));
                dataMask = false(1, numel(ids));
            end

            obj.dataMask = dataMask;

        end % loadResultFiles

        function data = loadResultFile(obj, id, options)
            % LOADRESULTFILE Load the result files from the directory.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   id: string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                % Batch ID
                id (1, 1) string
                % Read status
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            try
                data = obj.QueryService.read( ...
                    id, ReadStatus = options.readstatus);
            catch exception
                notifyGeneralMessage( ...
                    obj, "error", string(exception.message));
                data = [];
                return
            end

            if isempty(data)
                notifyGeneralMessage(obj, "error", "Failed to load the result file.");
                return;
            end

        end % loadResultFile

        %% Public save functions
        function saveResult(obj, batchID, names, directoryPath, options)
            % SAVERESULT Save the result data to the selected directory.
            %
            % Parameters:
            % -----------
            %   obj: ResultCatalog
            %       The result workspace object.
            %   batchID: (1, :) string
            %       The batch IDs to save the result files.
            %   names: (1, :) string
            %       The names of the batch IDs.
            %   directoryPath: string or ResultLocation
            %       The directory or location to save the result files.
            %   options: struct
            %       The options for saving the result files.
            %       options.addDatetime: (1, 1) logical
            %           Whether to add the current date and time to the directory name.
            %
            % See also: saveResultData

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchID (:, 1) string
                names (:, 1) string
                directoryPath
                options.addDatetime (1, 1) logical = true
            end % arguments

            outputLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                directoryPath);

            if length(batchID) ~= length(names)
                notifyGeneralMessage(obj, "error", "Batch ID and names must have the same length.");
                return;
            end % if

            exportPlan = openmebius.application.result.ResultExportPlan.build( ...
                batchID, ...
                names, ...
                outputLocation, ...
                AddDatetime = options.addDatetime);

            for iBatch = 1:exportPlan.count()

                exportItem = exportPlan.exportItem(iBatch);

                try
                    % Create the directory if it does not exist
                    iLocation = exportItem.ExportLocation;

                    if iLocation.directoryExists()
                        msg = "Directory already exists: " + iLocation.Directory;
                        notifyGeneralMessage(obj, "error", msg);
                        continue;
                    end % if iLocation.directoryExists()

                    mkdir(iLocation.Directory);

                catch ME

                    notifyGeneralMessage(obj, "error", "Failed to create the directory: " + ME.message);
                    continue;

                end % try-catch

                msg = "Saving result to: " + iLocation.Directory;
                notifyGeneralMessage(obj, "info", msg);

                % Save the result data
                saveResultData( ...
                    obj, ...
                    exportItem.BatchID, ...
                    exportItem.BatchName, ...
                    iLocation, ...
                    "xlsx");

            end % for iBatch

        end % function saveResult

        function saveResultData(obj, batchID, name, directoryPath, fmt)
            % SAVERESULTDATA Save the result data to the selected directory.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   batchID: (1, 1) string
            %       The batch IDs to save the result files.
            %   name: (1, 1) string
            %       The names of the batch IDs.
            %   directoryPath: string or ResultLocation
            %       The directory or location to save the result files.
            %   fmt: (1, 1) string
            %       The format to save the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                batchID (1, 1) string
                name (1, 1) string
                directoryPath
                fmt (1, 1) string {mustBeMember(fmt, ["xlsx", "csv"]) ...
                    mustBeNonempty(fmt)} = "xlsx"
            end % arguments

            outputLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                directoryPath);

            data = obj.getResultData(batchID);

            if isempty(data)
                obj.notifyGeneralMessage("error", "Failed to load the result data.");
                return;
            end % if isempty(data)

            status = data.status;

            if ~status(1) && ~status(2) && ~status(3)
                obj.notifyGeneralMessage("error", "No result data to save.");
                return;
            end % if

            baseName = "result_" + name + "_" + batchID;

            % Create flux row header
            overview = obj.getFluxOverView(batchID);

            if fmt == "csv"
                obj.saveResultDataAsCsv( ...
                    baseName, ...
                    outputLocation, ...
                    overview, ...
                    data, ...
                    status, ...
                    batchID);
                return
            end

            filePath = outputLocation.artifactFile(baseName + ".xlsx");

            [isSuccess, msg] = obj.exportExcelFile(filePath, overview, "Overview");

            if ~isSuccess
                notifyGeneralMessage(obj, "error", "Failed to save the overview data: " + msg);
                return;
            end % if ~isSuccess

            detailed = obj.getFluxDetailed(batchID);
            [isSuccess, msg] = obj.exportExcelFile(filePath, detailed, "Detailed", WriteRowNames = false);

            if ~isSuccess
                notifyGeneralMessage(obj, "error", "Failed to save the detailed data: " + msg);
                return;
            end % if ~isSuccess

            info = obj.getInformationTable(data);
            [isSuccess, msg] = obj.exportExcelFile(filePath, info, "info", WriteRowNames = false);

            if ~isSuccess
                notifyGeneralMessage(obj, "error", "Failed to save the information data: " + msg);
                return;
            end % if ~isSuccess

            [gridSearch, gridSearchMessage] = ...
                obj.TableBuilder.gridSearch(data);

            if gridSearchMessage ~= ""
                notifyGeneralMessage( ...
                    obj, "error", gridSearchMessage);
                return;
            end

            if ~isempty(gridSearch)
                [isSuccess, msg] = obj.exportExcelFile( ...
                    filePath, ...
                    gridSearch, ...
                    "GridSearch", ...
                    WriteRowNames = false);

                if ~isSuccess
                    notifyGeneralMessage( ...
                        obj, ...
                        "error", ...
                        "Failed to save the grid-search data: " + msg);
                    return;
                end

                profiles = obj.TableBuilder ...
                    .gridSearchProfiles(gridSearch);
                profileFilePath = outputLocation.artifactFile( ...
                    baseName + "_grid_search_profiles.xlsx");

                for profileIndex = 1:numel(profiles)
                    sheetName = obj.gridSearchProfileSheetName( ...
                        profiles(profileIndex).ReactionID, ...
                        profileIndex);
                    [isSuccess, msg] = obj.exportExcelFile( ...
                        profileFilePath, ...
                        profiles(profileIndex).Data, ...
                        sheetName, ...
                        WriteRowNames = false);

                    if ~isSuccess
                        notifyGeneralMessage( ...
                            obj, ...
                            "error", ...
                            "Failed to save grid-search profile " + ...
                            profiles(profileIndex).ReactionID + ...
                            ": " + msg);
                        return;
                    end

                end

            end

            if ~status(2)
                return;
            end

            FluxAll = obj.getFluxAll(data);
            [isSuccess, msg] = obj.exportExcelFile(filePath, FluxAll, "all", WriteRowNames = true);

            if ~isSuccess
                notifyGeneralMessage(obj, "error", "Failed to save the all flux data: " + msg);
                return;
            end % if ~isSuccess

        end % function saveResultData

    end % methods

    methods (Access = protected)

        %% Protected get functions
        function x = getX(~, data, address)
            % GETX Get the X data from the result file.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   data: cell
            %       The result data.
            %   address: string
            %
            % Returns:
            %   data: (:,1) double
            %       The X data.

            numData = length(data);
            x = nan(numData, 1);

            for i = 1:numData

                % Get the X data
                iData = data{i};

                if ~isfield(iData, address)
                    x(i) = nan;
                    continue;
                end % if ~isfield(iData, address)

                x(i) = iData.(address);

            end % for i

        end % getX

        function data = getResultData(obj, id, options)
            % GETRESULTDATA Get the result data from the file.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The result workspace object.
            %   id: (1, 1) string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                id (1, 1) string
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            try
                data = obj.QueryService.read( ...
                    id, ReadStatus = options.readstatus);
            catch exception
                notifyGeneralMessage( ...
                    obj, "error", string(exception.message));
                data = [];
                return
            end

            if isempty(data)
                notifyGeneralMessage(obj, "error", "Result file does not exist.");
            end

        end % getResultData

        function notifyGeneralMessage(obj, status, msg)
            % NOTIFYINITIALFLUXEVENT Notify the initial flux event.
            %
            % Parameters:
            %   obj: ResultCatalog
            %       The current result catalog.

            arguments
                obj (1, 1) openmebius.application.result.ResultCatalog
                status (1, 1) string {mustBeMember(status, ["info", "warning", "error"])}
                msg (1, 1) string
            end % arguments

            obj.NotificationEmitter.report( ...
                status, ...
                msg, ...
                Code = "result.operation");

        end % notifyGeneralMessage

    end % methods (Access = protected)

    methods (Access = private)

        function tf = ensureResultDirectory(obj)

            tf = true;

            try
                obj.QueryService.assertAvailable();
            catch ME
                tf = false;
                notifyGeneralMessage(obj, "error", string(ME.message));
            end

        end % ensureResultDirectory

        function [isSuccess, msg] = exportExcelFile(obj, pathFile, excelData, sheetName, options)

            arguments
                obj
                pathFile (1, 1) string
                excelData
                sheetName (1, 1) string = ""
                options.WriteRowNames (1, 1) logical = true
                options.WriteVariableNames (1, 1) logical = true
            end

            [isSuccess, msg] = obj.ResultRepository.writeExcelTable( ...
                pathFile, ...
                excelData, ...
                sheetName, ...
                WriteRowNames = options.WriteRowNames, ...
                WriteVariableNames = options.WriteVariableNames);

        end % exportExcelFile

        function saveResultDataAsCsv(obj, baseName, outputLocation, overview, data, status, batchID)

            [isSuccess, msg] = obj.exportCsvTable( ...
                outputLocation.artifactFile(baseName + "_overview.csv"), ...
                overview);

            if ~isSuccess
                notifyGeneralMessage(obj, "error", "Failed to save the overview data: " + msg);
                return;
            end

            detailed = obj.getFluxDetailed(batchID);
            [isSuccess, msg] = obj.exportCsvTable( ...
                outputLocation.artifactFile(baseName + "_detailed.csv"), ...
                detailed, ...
                WriteRowNames = false);

            if ~isSuccess
                notifyGeneralMessage(obj, "error", "Failed to save the detailed data: " + msg);
                return;
            end

            info = obj.getInformationTable(data);
            [isSuccess, msg] = obj.exportCsvTable( ...
                outputLocation.artifactFile(baseName + "_info.csv"), ...
                info, ...
                WriteRowNames = false);

            if ~isSuccess
                notifyGeneralMessage(obj, "error", "Failed to save the information data: " + msg);
                return;
            end

            [gridSearch, gridSearchMessage] = ...
                obj.TableBuilder.gridSearch(data);

            if gridSearchMessage ~= ""
                notifyGeneralMessage( ...
                    obj, "error", gridSearchMessage);
                return;
            end

            if ~isempty(gridSearch)
                [isSuccess, msg] = obj.exportCsvTable( ...
                    outputLocation.artifactFile( ...
                    baseName + "_grid_search.csv"), ...
                    gridSearch, ...
                    WriteRowNames = false);

                if ~isSuccess
                    notifyGeneralMessage( ...
                        obj, ...
                        "error", ...
                        "Failed to save the grid-search data: " + msg);
                    return;
                end

            end

            if ~status(2)
                return;
            end

            fluxAll = obj.getFluxAll(data);
            [isSuccess, msg] = obj.exportCsvTable( ...
                outputLocation.artifactFile(baseName + "_all.csv"), ...
                fluxAll);

            if ~isSuccess
                notifyGeneralMessage(obj, "error", "Failed to save the all flux data: " + msg);
            end

        end % saveResultDataAsCsv

        function [isSuccess, msg] = exportCsvTable(obj, pathFile, tableData, options)

            arguments
                obj
                pathFile (1, 1) string
                tableData table
                options.WriteRowNames (1, 1) logical = true
                options.WriteVariableNames (1, 1) logical = true
            end

            [isSuccess, msg] = obj.ResultRepository.writeCsvTable( ...
                pathFile, ...
                tableData, ...
                WriteRowNames = options.WriteRowNames, ...
                WriteVariableNames = options.WriteVariableNames);

        end % exportCsvTable

        function sheetName = gridSearchProfileSheetName( ...
                ~, reactionID, profileIndex)

            safeReactionID = strip(string(reactionID));
            invalidCharacters = [ ...
                "<", ">", ":", string(char(34)), ...
                string(char(92)), "/", "|", "?", "*", ...
                "[", "]", "'"];

            for characterIndex = 1:numel(invalidCharacters)
                safeReactionID = replace( ...
                    safeReactionID, ...
                    invalidCharacters(characterIndex), ...
                    "_");
            end

            if ismissing(safeReactionID) || safeReactionID == ""
                safeReactionID = "Flux";
            end

            prefix = "GS_" + compose("%03d", profileIndex) + "_";
            maximumIDLength = 31 - strlength(prefix);

            if strlength(safeReactionID) > maximumIDLength
                safeReactionID = extractBetween( ...
                    safeReactionID, 1, maximumIDLength);
            end

            sheetName = prefix + safeReactionID;

        end % gridSearchProfileSheetName

        function tableRtn = getInformationTable(~, data)
            % GETINFORMATIONTABLE Get the information table from the result file.
            %
            % Parameters:
            %   data: struct

            tableRtn = table( ...
                'Size', [0, 2], ...
                'VariableNames', ["Property", "Value"], ...
                'VariableTypes', ["string", "string"] ...
                );

            id = ["Batch ID", string(data.ID)];
            tableRtn = [tableRtn; cell2table(cellstr(id), 'VariableNames', tableRtn.Properties.VariableNames)];
            threshold = ["Chi2 Test Threshold", string(data.threshold)];
            tableRtn = [tableRtn; cell2table(cellstr(threshold), 'VariableNames', tableRtn.Properties.VariableNames)];

        end % getInformationTable

        function tableRtn = getFluxAll(~, data)
            % GETFLUXALL Get all flux data from the result file.
            %
            % Parameters:
            %   data: struct

            numFlux = length(data.RSS);
            numRxn = length(data.model.modelID) + 1 + 3; % +1 for biomass
            names = strings(1, length(data.RSS));
            variableTypes = repmat("double", 1, length(data.RSS));
            variableTypesReaction = repmat("string", 1, 1);

            dataTable = nan(numRxn, numFlux);

            for i = 1:numFlux

                iterName = string(sprintf("%04d", data.RSSIdx(i)));
                fieldName = "fluxResult" + iterName;
                iFluxResult = data.(fieldName);

                names(i) = "N" + iterName;

                dataTable(1, i) = iFluxResult.RSS;
                dataTable(2, i) = iFluxResult.exitflag;
                dataTable(3, i) = iFluxResult.time;
                dataTable(4:end, i) = iFluxResult.fluxFwd;

            end % for i

            id = data.model.modelID;
            id = ["RSS"; "ExitFlag"; "UnixTime"; id; "biomass"];
            rxnName = data.model.modelReaction;
            rxnName = [""; ""; ""; rxnName; ""];

            tableRtn = table( ...
                'Size', [numRxn, numFlux + 1], ...
                'VariableNames', ["Reaction", names], ...
                'VariableTypes', [variableTypesReaction, variableTypes], ...
                'RowNames', id ...
                );
            tableRtn.Reaction = rxnName;
            tableRtn{:, 2:end} = dataTable;

        end % getFluxAll

    end % methods (Access = private)

end % class ResultCatalog
