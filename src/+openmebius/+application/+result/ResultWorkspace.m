classdef ResultWorkspace < handle

    properties (SetAccess = public)

        % Result data
        IDs (1, :) string = ""
        dataMask (1, :) logical = false(1, 0)

    end % properties

    properties (SetAccess = private)

        ResultLocation openmebius.domain.result.ResultLocation
        ResultRepository
        Hdf5ResultRepository

    end % properties

    properties (Access = private)
        MessagePublisher
        NotificationReporter (1, 1) function_handle = @(~) []
    end

    methods

        function obj = ResultWorkspace(resultInput, options)
            % Constructor for ResultWorkspace class

            arguments
                resultInput
                options.ResultRepository = ...
                    openmebius.infrastructure.result.ResultRepository()
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result ...
                    .Hdf5ResultRepository()
                options.NotificationReporter (1, 1) function_handle = @(~) []
            end

            resultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                resultInput);

            obj.ResultLocation = resultLocation;
            obj.ResultRepository = options.ResultRepository;
            obj.Hdf5ResultRepository = ...
                options.Hdf5ResultRepository;
            obj.MessagePublisher = openmebius.presentation ...
                .notification.GeneralMessagePublisher();
            obj.NotificationReporter = options.NotificationReporter;

            obj.ResultRepository.assertResultDirectory(resultLocation);

            obj.MessagePublisher.write( ...
                "info", ...
                "The directory " + resultLocation.Directory + ...
                " exists.");

        end % constructor

    end % methods

    methods (Access = public)

        function setNotificationReporter(obj, reporter)

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                reporter (1, 1) function_handle
            end

            obj.NotificationReporter = reporter;

        end % setNotificationReporter

        %% Public get functions
        function resultLocation = getResultLocation(obj)

            resultLocation = obj.ResultLocation;

        end % getResultLocation

        function tableRtn = getFluxOverView(obj, id, options)
            % GETFLUXOVERVIEW Get the flux overview from the result file.
            %
            % Parameters:
            %   obj: ResultWorkspace
            %       The result workspace object.
            %   id: string
            %       The batch ID to load the result files.
            %
            % Returns:
            %   tableRtn: table
            %       The flux overview table.
            %       ID: (n, 1) string
            %       Reaction: (n, 1) string
            %       Flux: (n, 1) double
            %       UB: (n, 1) double
            %       LB: (n, 1) double

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                id (1, 1) string
                options.relative (1, 1) logical = false
                options.relativeTo (1, 1) string = ""
            end % arguments

            % Initialize the table
            tableRtn = table( ...
                'Size', [0, 6], ...
                'VariableNames', ["Reaction", "Flux", "UB", "LB", "UB (FVA)", "LB (FVA)"], ...
                'VariableTypes', ["string", "double", "double", "double", "double", "double"] ...
            );

            % Load the result file
            data = loadResultFile(obj, id);

            if isempty(data)
                notifyGeneralMessage(obj, "error", "Failed to load the result file.");
                return;
            end

            % Get the status
            status = data.status;

            if status(1)
                % Get the flux variability analysis data
                fluxVariability = data.fluxVariability;
                fluxUBFwd = fluxVariability.fluxUBFwd;
                fluxLBFwd = fluxVariability.fluxLBFwd;
                reactionID = data.model.modelID;
                reactionID = [reactionID; "biomass"];
                reactionNames = data.model.modelReaction;
                reactionNames = [reactionNames; ""];

                numFlux = size(fluxUBFwd, 1);

                % Generate a empty table: nan
                tableRtn = table( ...
                    'Size', [numFlux, 6], ...
                    'VariableNames', ["Reaction", "Flux", "LB", "UB", "LB (FVA)", "UB (FVA)"], ...
                    'VariableTypes', ["string", "double", "double", "double", "double", "double"] ...
                );

                % Set as nan
                tableRtn.Flux = nan(numFlux, 1);
                tableRtn.LB = nan(numFlux, 1);
                tableRtn.UB = nan(numFlux, 1);
                tableRtn.("LB (FVA)") = nan(numFlux, 1);
                tableRtn.("UB (FVA)") = nan(numFlux, 1);

                % Get reaction names
                tableRtn.Properties.RowNames = reactionID;
                tableRtn.Reaction = reactionNames;
                tableRtn.("UB (FVA)") = fluxUBFwd;
                tableRtn.("LB (FVA)") = fluxLBFwd;

            end % if status(1)

            if status(2)

                % Get the flux data
                fieldNames = "fluxResult" + string(sprintf("%04d", data.RSSIdx(1)));
                fluxResult = data.(fieldNames);
                flux = fluxResult.fluxFwd;

                tableRtn.Flux = flux;

            end % if status(2)

            % Get the confidence intervals
            if status(3)

                LB = data.fluxLB;
                UB = data.fluxUB;

                if ~isempty(LB) && ~isempty(UB)
                    tableRtn.LB = LB;
                    tableRtn.UB = UB;
                end

            end % if status(3)

            % Relative flux
            if options.relative && status(2)

                % Get the relative flux
                RxnIDs = tableRtn.Properties.RowNames;
                RxnIdx = find(contains(RxnIDs, options.relativeTo), 1);

                if isempty(RxnIdx)
                    relativeTo = 0.01;
                else
                    relativeTo = tableRtn.Flux(RxnIdx) / 100;
                end % if isempty(RxnIdx)

                if isnan(relativeTo) || relativeTo == 0
                    notifyGeneralMessage(obj, "error", "Relative flux cannot be calculated. The reference flux is zero or NaN.");
                    return;
                end % if isNaN(relativeTo) || relativeTo == 0

                tableRtn.Flux = tableRtn.Flux ./ relativeTo;
                tableRtn.LB = tableRtn.LB ./ relativeTo;
                tableRtn.UB = tableRtn.UB ./ relativeTo;
                tableRtn.("LB (FVA)") = tableRtn.("LB (FVA)") ./ relativeTo;
                tableRtn.("UB (FVA)") = tableRtn.("UB (FVA)") ./ relativeTo;

            end % if options.relative

        end % getFluxOverView

        function tableRtn = getFluxDetailed(obj, batchID)
            % GETFLUXDETAILED Get the flux detailed data from the result file.
            %
            % Parameters:
            %   obj: ResultWorkspace
            %       The result workspace object.
            %   batchID: string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                batchID (1, 1) string
            end % arguments

            % Initialize the table
            tableRtn = table( ...
                'Size', [0, 5], ...
                'VariableNames', ["Fragment", "M+i", "Measured", "Estimated", "Chi^2"], ...
                'VariableTypes', ["string", "string", "double", "double", "double"] ...
            );

            % Load the result file
            data = loadResultFile(obj, batchID);

            if isempty(data)
                notifyGeneralMessage(obj, "error", "Failed to load the result file.");
                return;
            end

            if ~isfield(data, 'RSSIdx') || isempty(data.RSSIdx)
                notifyGeneralMessage(obj, "error", "No flux data found in the result file.");
                return;
            end % if ~isfield(data,'RSSIdx') || isempty(data.RSSIdx)

            % Initialize the columns
            RSSIdxMin = data.RSSIdx(1);
            iterName = string(sprintf("%04d", RSSIdxMin(1)));
            fieldName = "fluxResult" + iterName;
            MDVExp = data.MDVExp;
            MDVExpName = data.MDVExpName;
            MDVFragMask = data.MDVFragMask;

            MDV = data.(fieldName).MDV;
            numLabeling = size(MDV, 2);

            baseHeaderNames = ["Fragment", "M+i"];
            baseHeaderTypes = ["string", "string"];
            repeatNames = ["Measured", "Estimated", "Chi^2"];
            repeatTypes = ["double", "double", "double"];
            headerNames = [ ...
                baseHeaderNames, ...
                repmat(repeatNames, 1, numLabeling)];
            headerTypes = [ ...
                baseHeaderTypes, ...
                repmat(repeatTypes, 1, numLabeling)];

            % Empty table
            tableString = strings(size(MDV, 1), 2);
            tableValue = nan(size(MDV, 1), numLabeling * 3);

            sizeTable = [size(MDV, 1), length(headerNames)];

            tableRtn = table( ...
                'Size', sizeTable, ...
                'VariableNames', headerNames, ...
                'VariableTypes', headerTypes ...
            );

            % Assign the table
            tableRtn{:, 1:2} = tableString;
            tableRtn{:, 3:end} = tableValue;

            % Fill the table
            FragNameRtn = cell(0, 1);
            FragCountRtn = cell(0, 1);

            for i = 1:numLabeling

                % Get the MDV data
                iMDV = MDV(:, i);
                iMDVExp = MDVExp(:, i);
                iMDVFragMask = MDVFragMask(:, i);

                tableRtn{:, (i * 3)} = iMDVExp;
                tableRtn{:, (i * 3) + 1} = iMDV;

                isotopeCounter = 0;

                for j = 1:size(iMDV, 1)

                    % Get the measured and estimated data
                    iMeasured = iMDV(j);
                    iEstimated = iMDVExp(j);
                    iChi2 = (iMeasured - iEstimated) / 0.01;
                    iChi2 = iChi2 ^ 2;

                    if iMDVFragMask(j)
                        tableRtn{j, (i * 3) + 2} = iChi2;
                    end

                    % Set the fragment isotope name
                    if j == 1
                        FragNameRtn{j} = MDVExpName(j);
                        FragCountRtn{j} = "M + " + string(int8(isotopeCounter));
                        isotopeCounter = isotopeCounter + 1;
                        continue;
                    else

                        previousName = MDVExpName{j - 1};

                        if strcmp(previousName, MDVExpName(j))
                            FragNameRtn{j} = "";
                            FragCountRtn{j} = "M + " + string(int8(isotopeCounter));
                            isotopeCounter = isotopeCounter + 1;
                        else
                            FragNameRtn{j} = MDVExpName(j);
                            isotopeCounter = 0;
                            FragCountRtn{j} = "M + " + string(int8(isotopeCounter));
                            isotopeCounter = isotopeCounter + 1;
                        end % if strcmp

                    end % if j == 0

                end % for j = 1:size(iMDV, 1)

            end % for i = 1:numLabeling

            FragNameRtn = string(FragNameRtn)';
            FragCountRtn = string(FragCountRtn)';
            tableRtn{:, 1} = FragNameRtn;
            tableRtn{:, 2} = FragCountRtn;

        end % getFluxDetailed

        function tableRtn = getFluxComparison(obj, batchIDs, names, options)
            % GETFLUXCOMPARISON Get the flux comparison data from the result file.
            %
            % Parameters:
            %   obj: ResultWorkspace
            %       The result workspace object.
            %   batchIDs: string
            %       The batch ID to load the result files.
            %   names: string
            %       The batch names to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                batchIDs (1, :) string
                names (1, :) string
                options.relative (1, 1) logical = false
                options.relativeTo (1, 1) string = ""
            end % arguments

            tableRtn = table();

            if length(batchIDs) ~= length(unique(batchIDs))
                notifyGeneralMessage(obj, "error", "Batch IDs must be unique.");
                return;
            end % if

            numData = length(batchIDs);
            % numData分のstringを作成
            variableTypes = repmat("double", 1, numData);
            variableTypesReaction = ["string", variableTypes];

            names = string(names);

            if length(unique(names)) ~= length(names)

                for i = 1:numData

                    if sum(names == names(i)) > 1
                        names(i) = names(i) + "_" + string(i);
                    end % if sum(names == names(i)) > 1

                end % for i = 1:numData

            end % if length(unique(names)) ~= length(names)

            % Initialize the table
            tableRtn = table( ...
                'Size', [0, numData], ...
                'VariableNames', names, ...
                'VariableTypes', variableTypes ...
            );

            readstatus = false(1, 4);
            readstatus(1) = true;
            readstatus(2) = true;

            [data, tempDataMask] = loadResultFiles( ...
                obj, ...
                batchIDs, ...
                readstatus = readstatus);

            data = data(tempDataMask);

            if numData ~= length(data)
                notifyGeneralMessage(obj, "error", "Failed to load the result files.");
                return;
            end

            for i = 1:numData

                iData = data{i};

                if ~isfield(iData, 'RSSIdx') || isempty(iData.RSSIdx)
                    continue;
                end % if ~isfield(iData,'RSSIdx') || isempty(iData.RSSIdx)

                iFieldName = "fluxResult" + string(sprintf("%04d", iData.RSSIdx(1)));
                iFluxResult = iData.(iFieldName);
                iFlux = iFluxResult.fluxFwd;

                if i == 1

                    numFlux = size(iFlux, 1);

                    % RxnIDs
                    iFluxID = [iData.model.modelID; "biomass"];
                    % Reaction names
                    iFluxName = [iData.model.modelReaction; ""];

                    % Generate a empty table: nan
                    tableRtn = table( ...
                        'Size', [numFlux, numData + 1], ...
                        'VariableNames', ["Reaction", names], ...
                        'VariableTypes', variableTypesReaction, ...
                        'RowNames', iFluxID ...
                    );

                    tableRtn.Reaction = iFluxName;
                    tableRtn.(names(1)) = iFlux;

                else
                    tableRtn.(names(i)) = iFlux;
                end

            end % for i

            % Relative flux
            if options.relative && numData > 1

                % Get the relative flux
                RxnIDs = tableRtn.Properties.RowNames;
                RxnIdx = find(contains(RxnIDs, options.relativeTo), 1);

                for i = 1:numData

                    if isempty(RxnIdx)
                        relativeTo = 0.01;
                    else
                        relativeTo = tableRtn.(names(i))(RxnIdx) / 100;
                    end % if isempty(RxnIdx)

                    tableRtn.(names(i)) = tableRtn.(names(i)) ./ relativeTo;
                end % for i

            end % if options.relative

        end % getFluxComparison

        function data = getCIReaction(obj, batchID, RxnID)
            % GETCIREACTION Get the confidence interval reaction data from the result file.
            %
            % Parameters:
            %   obj: ResultWorkspace
            %       The result workspace object.
            %   batchID: string
            %       The batch ID to load the result files.
            %   RxnID: string
            %       The reaction ID to get the confidence interval data.

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                batchID (1, 1) string
                RxnID (1, 1) string
            end % arguments

            if ~obj.ResultLocation.hasResultFile(batchID)
                notifyGeneralMessage(obj, "error", "Result file does not exist.");
                data = [];
                return;
            end

            data = obj.Hdf5ResultRepository.readConfidenceInterval( ...
                obj.ResultLocation, ...
                batchID, ...
                RxnID);

        end % getCIReaction

        function [isExist, data] = getNextLabelSuggestion(obj, batchID)
            % GETNEXTLABELSUGGESTION Get the next label suggestion from the result file.
            %
            % Parameters:
            %   obj: ResultWorkspace
            %       The result workspace object.
            %   batchID: string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                batchID (1, 1) string
            end % arguments

            [isExist, data] = obj.Hdf5ResultRepository ...
                .readNextLabelSuggestion( ...
                obj.ResultLocation, ...
                batchID);

        end % getNextLabelSuggestion

        function RSS = getRSS(~, data)
            % GETRSS Get the RSS from the result file.
            %
            % Parameters:
            %   obj: ResultWorkspace
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
            %   obj: ResultWorkspace
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
            %   obj: ResultWorkspace
            %       The result workspace object.
            %   ids: string array
            %       The batch IDs to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                % Batch IDs
                ids (1, :) string
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            % Define the mask
            dataMask = false(1, 0);
            data = cell(1, 0);

            obj.IDs = ids;
            obj.dataMask = dataMask;

            if ~obj.ensureResultDirectory()
                return;
            end

            % Get all files in the directory
            files = obj.ResultLocation.resultFiles();

            if isempty(files)
                return;
            end

            numFile = size(files, 1);

            numID = size(ids, 2);

            % Define the mask
            dataMask = false(1, numID);
            data = cell(1, numID);

            for i = 1:numFile

                % Find a result file with the given ID
                iFilename = files(i).name;
                % Remove the extension
                [~, iFilename] = fileparts(iFilename);
                idx = find(contains(ids, iFilename), 1);

                if isempty(idx)
                    continue;
                end

                % Load the result file
                dataTmp = loadResultFile(obj, ids(idx), readstatus = options.readstatus);

                % Store the data
                data{idx} = dataTmp;
                dataMask(idx) = true;

            end % for i

            obj.IDs = ids;
            obj.dataMask = dataMask;

        end % loadResultFiles

        function data = loadResultFile(obj, id, options)
            % LOADRESULTFILE Load the result files from the directory.
            %
            % Parameters:
            %   obj: ResultWorkspace
            %       The result workspace object.
            %   id: string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                % Batch ID
                id (1, 1) string
                % Read status
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            data = struct;

            if ~obj.ensureResultDirectory()
                return;
            end

            if ~obj.ResultLocation.hasResultFile(id)
                return;
            end

            % Load the result file
            data = getResultData(obj, id, readstatus = options.readstatus);

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
            %   obj: ResultWorkspace
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
                obj (1, 1) openmebius.application.result.ResultWorkspace
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
            %   obj: ResultWorkspace
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
                obj (1, 1) openmebius.application.result.ResultWorkspace
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
            %   obj: ResultWorkspace
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
            %   obj: ResultWorkspace
            %       The result workspace object.
            %   id: (1, 1) string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                id (1, 1) string
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            if ~obj.ResultLocation.hasResultFile(id)
                notifyGeneralMessage(obj, "error", "Result file does not exist.");
                data = [];
                return;
            end

            data = obj.Hdf5ResultRepository.readResultData( ...
                obj.ResultLocation, ...
                id, ...
                ReadStatus = options.readstatus);

        end % getResultData

        function notifyGeneralMessage(obj, status, msg)
            % NOTIFYINITIALFLUXEVENT Notify the initial flux event.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) openmebius.application.result.ResultWorkspace
                status (1, 1) string {mustBeMember(status, ["info", "warning", "error"])}
                msg (1, 1) string
            end % arguments

            notification = obj.MessagePublisher.write(status, msg);
            obj.NotificationReporter(notification);

        end % notifyGeneralMessage

    end % methods (Access = protected)

    methods (Access = private)

        function tf = ensureResultDirectory(obj)

            tf = true;

            try
                obj.ResultRepository.assertResultDirectory( ...
                    obj.ResultLocation);
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

end % class ResultWorkspace
