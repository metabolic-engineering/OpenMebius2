classdef IOResult < IO

    events

        GeneralMsg
        ResultDataLoad

    end % events

    properties (SetAccess = public)

        % Result data
        IDs (1, :) string = ""
        dataMask (1, :) logical = false(1, 0)

    end % properties

    properties (SetAccess = private)

        directoryResult (1, 1) string

    end % properties

    methods

        function obj = IOResult(resultInput)
            % Constructor for IOResult class

            resultLocation = IOResult.resolveResultLocation(resultInput);

            obj@IO(resultLocation.Directory);

            if obj.isError
                obj.directoryResult = "";
            else
                obj.directoryResult = resultLocation.Directory;
            end

        end % constructor

    end % methods

    methods (Static, Access = private)

        function resultLocation = resolveResultLocation(resultInput)

            if isa(resultInput, 'openmebius.domain.result.ResultLocation')
                resultLocation = resultInput;
                return
            end

            resultLocation = ...
                openmebius.domain.result.ResultLocation.fromDirectory( ...
                string(resultInput));

        end % resolveResultLocation

    end % methods (Static, Access = private)

    methods (Access = public)

        %% Public get functions
        function tableRtn = getFluxOverView(obj, id, options)
            % GETFLUXOVERVIEW Get the flux overview from the result file.
            %
            % Parameters:
            %   obj: IOResult
            %       The IOResult object.
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
                obj (1, 1) IOResult
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
            %   obj: IOResult
            %       The IOResult object.
            %   batchID: string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) IOResult
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

            headerNames = ["Fragment", "M+i"];
            headerTypes = ["string", "string"];
            repeatNames = ["Measured", "Estimated", "Chi^2"];
            repeatTypes = ["double", "double", "double"];

            % Add the repeatNames to the headerNames
            for i = 1:numLabeling
                headerNames = [headerNames, repeatNames];
                headerTypes = [headerTypes, repeatTypes];
            end % for i

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
            %   obj: IOResult
            %       The IOResult object.
            %   batchIDs: string
            %       The batch ID to load the result files.
            %   names: string
            %       The batch names to load the result files.

            arguments
                obj (1, 1) IOResult
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

            [data, tempDataMask] = loadResultFiles(obj, batchIDs);

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
                    iFluxID = iData.model.modelID;
                    iFluxID = [iFluxID; "biomass"];
                    % Reaction names
                    iFluxName = iData.model.modelReaction;
                    iFluxName = [iFluxName; ""];

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
            %   obj: IOResult
            %       The IOResult object.
            %   batchID: string
            %       The batch ID to load the result files.
            %   RxnID: string
            %       The reaction ID to get the confidence interval data.

            arguments
                obj (1, 1) IOResult
                batchID (1, 1) string
                RxnID (1, 1) string
            end % arguments

            % Load the result file
            filename = batchID + ".h5";
            filePath = fullfile(obj.directoryResult, filename);

            if ~isfile(filePath)
                notifyGeneralMessage(obj, "error", "Result file does not exist.");
                return;
            end

            % Load the result data
            % Load the status
            data = struct;
            status = h5read(filePath, '/status');

            if ~(status(1) && status(2) && status(3))
                return;
            end % if

            data.status = status;

            % Set initial data
            data.RxnID = RxnID;

            % Load the model data
            data.model.modelID = h5read(filePath, '/model/modelID');
            data.model.modelReaction = h5read(filePath, '/model/modelReaction');

            % Result of FVA
            data.fluxVariability.fluxUBFwd = ...
                h5read(filePath, '/fluxVariability/fluxUBFwd');
            data.fluxVariability.fluxLBFwd = ...
                h5read(filePath, '/fluxVariability/fluxLBFwd');

            % Flux distribution
            data.RSSIdx = ...
                h5read(filePath, "/RSSIndex");
            iterName = string(sprintf("%04d", data.RSSIdx(1)));
            addressName = "/fluxResult/" + iterName;
            data.fluxFwd = ...
                h5read(filePath, addressName + "/fluxFwd");

            % Confidence interval data
            data.fluxLB = ...
                h5read(filePath, "/fluxLB");
            data.fluxUB = ...
                h5read(filePath, "/fluxUB");
            data.CI.algorithm = ...
                h5read(filePath, "/CI/algorithm");

            % Switch data
            switch data.CI.algorithm
                case "Monte Carlo"
                    data.CI.flux = h5read(filePath, "/CI/fluxes");
                    data.CI.fluxLB = h5read(filePath, "/CI/fluxLB");
                    data.CI.fluxUB = h5read(filePath, "/CI/fluxUB");

                    % Extract the reaction flux

                otherwise
                    notifyGeneralMessage(obj, "error", "Unknown confidence interval algorithm: " + data.CI.algorithm);
                    return;
            end % switch

        end % getCIReaction

        function [isExist, data] = getNextLabelSuggestion(obj, batchID)
            % GETNEXTLABELSUGGESTION Get the next label suggestion from the result file.
            %
            % Parameters:
            %   obj: IOResult
            %       The IOResult object.
            %   batchID: string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) IOResult
                batchID (1, 1) string
            end % arguments

            % Load the result file
            isExist = true;
            data = struct;
            filename = batchID + ".h5";
            filePath = fullfile(obj.directoryResult, filename);

            if ~isfile(filePath)
                isExist = false;
                return;
            end

            % Load the suggestion data
            try
                data.ID = h5read(filePath, '/model/modelID');
                data.ID = [data.ID; "biomass"];
                data.rxn = h5read(filePath, '/model/modelReaction');
                data.rxn = [data.rxn; "biomass"];
                data.colName = h5read(filePath, '/nextLabelPattern/suggestionTable/colName');
                data.data = h5read(filePath, '/nextLabelPattern/suggestionTable/data');
                data.fluxLB = h5read(filePath, '/fluxLB');
                data.fluxUB = h5read(filePath, '/fluxUB');
            catch
                isExist = false;
                return;
            end % try-catch

            try
                RSSIdx = h5read(filePath, '/RSSIndex');
                data.bestfit = h5read(filePath, "/fluxResult/" + string(sprintf("%04d", RSSIdx(1))) + "/fluxFwd");
                data.FVALB = h5read(filePath, '/fluxVariability/fluxLBFwd');
                data.FVAUB = h5read(filePath, '/fluxVariability/fluxUBFwd');
            catch
                isExist = false;
                return;
            end

            try
                numData = size(data.data, 1);
                data.patternLabel = strings(numData, 1);

                for i = 1:numData

                    pattern = data.data(i, :);
                    patternStr = strjoin(pattern, '_');
                    patternStr = matlab.lang.makeValidName(patternStr);
                    data.patternLabel(i) = patternStr;

                    data.(patternStr).fluxLB = ...
                        h5read(filePath, '/nextLabelPattern/' + patternStr + '/fluxLB');
                    data.(patternStr).fluxUB = ...
                        h5read(filePath, '/nextLabelPattern/' + patternStr + '/fluxUB');

                end % for i

            catch

            end

        end % getNextLabelSuggestion

        function RSS = getRSS(~, data)
            % GETRSS Get the RSS from the result file.
            %
            % Parameters:
            %   obj: IOResult
            %       The IOResult object.
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
            %   obj: IOResult
            %       The IOResult object.
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
            %   obj: IOResult
            %       The IOResult object.
            %   ids: string array
            %       The batch IDs to load the result files.

            arguments
                obj (1, 1) IOResult
                % Batch IDs
                ids (1, :) string
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            % Define the mask
            dataMask = false(1, 0);
            data = cell(1, 0);

            obj.IDs = ids;
            obj.dataMask = dataMask;

            if ~isfolder(obj.directoryResult)
                obj.isError = true;
                notifyGeneralMessage(obj, "error", "Result directory does not exist.");
                return;
            end

            % Get all files in the directory
            files = dir(fullfile(obj.directoryResult, '*.h5'));

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
            %   obj: IOResult
            %       The IOResult object.
            %   id: string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) IOResult
                % Batch ID
                id (1, 1) string
                % Read status
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            data = struct;

            if ~isfolder(obj.directoryResult)
                obj.isError = true;
                notifyGeneralMessage(obj, "error", "Result directory does not exist.");
                return;
            end

            % Get all files in the directory
            files = dir(fullfile(obj.directoryResult, '*.h5'));

            if isempty(files)
                return;
            end

            % Remove the extension
            iFilename = string(char(files.name));
            idx = find(contains(iFilename, obj.IDs), 1);

            if isempty(idx)
                return;
            end

            % Load the result file
            data = getResultData(obj, id, readstatus = options.readstatus);

            if isempty(data)
                notifyGeneralMessage(obj, "error", "Failed to load the result file.");
                return;
            end

            reset(obj);

        end % loadResultFile

        %% Public draw functions
        function drawCIReaction(obj, UIaxes, data)
            % DRAWCIREACTION Draw the confidence interval reaction results.
            %
            % Parameters:
            %   obj: IOResult
            %       The IOResult object.
            %   UIaxes: Axes
            %       The axes to draw the results.
            %   data: struct

            arguments
                obj (1, 1) IOResult
                UIaxes (1, 1) matlab.graphics.axis.Axes
                data (1, 1) struct
            end % arguments

            % Get status
            status = data.status;

            if ~status(1) && ~status(2) && ~status(3)
                % Disable the axes
                UIaxes.Visible = 'off';
                return;
            end

            % Get the algorithm
            algorithm = data.CI.algorithm;

            switch algorithm
                case "Monte Carlo"

                    % Get the reaction index
                    modelID = data.model.modelID;
                    RxnID = data.RxnID;
                    RxnIdx = find(contains(modelID, RxnID), 1);

                    if isempty(RxnIdx)
                        notifyGeneralMessage(obj, "error", "Reaction ID not found: " + RxnID);
                        return;
                    end % if isempty(RxnIdx)

                    ReactionName = data.model.modelReaction{RxnIdx};

                    % Get the flux data
                    flux = data.CI.flux(RxnIdx, :);
                    fluxLB = data.CI.fluxLB(RxnIdx, :);
                    fluxUB = data.CI.fluxUB(RxnIdx, :);
                    bestfit = data.fluxFwd(RxnIdx);
                    FVALB = data.fluxVariability.fluxLBFwd(RxnIdx);
                    FVAUB = data.fluxVariability.fluxUBFwd(RxnIdx);

                    % Draw the Monte Carlo stochastic results
                    drawMonteCarloStocastic( ...
                        obj, UIaxes, flux, fluxLB, fluxUB, bestfit, ...
                        showFVA = true, ...
                        FVA = [FVALB, FVAUB], ...
                        title = ReactionName ...
                    );

                otherwise
                    notifyGeneralMessage(obj, "error", "Unknown confidence interval algorithm: " + algorithm);
            end % switch

        end % drawCIReaction

        function drawMonteCarloStocastic(~, UIaxes, flux, fluxLB, fluxUB, bestfit, options)
            % DRAWMONTECARLOSTOCASTIC Draw the Monte Carlo stochastic results.
            %
            % Parameters:
            %   obj: IOResult
            %       The IOResult object.
            %   UIaxes: Axes
            %       The axes to draw the results.

            arguments
                ~
                UIaxes (1, 1) matlab.graphics.axis.Axes
                flux (1, :) double
                fluxLB (1, :) double
                fluxUB (1, :) double
                bestfit (1, 1) double
                options.showFVA (1, 1) logical = true
                options.FVA (1, 2) double = [nan, nan]
                options.title (1, 1) string = "Reaction Index"
            end % arguments

            yMax = max(fluxUB);
            yMin = min(fluxLB);
            yRange = yMax - yMin;
            yMargin = max(0.1 * yRange, 0.1);
            yMin = yMin - yMargin;
            yMax = yMax + yMargin;
            x = 1:length(flux);

            % Font size
            UIaxes.FontSize = 16;
            UIaxes.FontName = 'Arial';

            % Create the axes
            UIaxes.Visible = 'on';
            UIaxes.XLim = [0, length(flux) + 1];
            UIaxes.YLim = [yMin, yMax];

            UIaxes.XLabel.String = "Iteration";
            UIaxes.YLabel.String = "Flux";
            UIaxes.Title.String = options.title;

            % X軸の目盛りを設定
            % メモリは0から始まり，100ごとに表示
            UIaxes.XTick = 0:100:length(flux);
            UIaxes.XTickLabel = string(UIaxes.XTick);
            UIaxes.XTickLabelRotation = 0;

            % Plot the flux data
            hold(UIaxes, 'on');

            % Flux =  #E69F00
            plot(UIaxes, x, repmat(bestfit, size(x)), '-', 'Color', "#E69F00", 'LineWidth', 3, 'DisplayName', 'Best Fit');
            % Flux LB = #56B4E9
            plot(UIaxes, x, fluxLB, '-', 'Color', "#56B4E9", 'LineWidth', 3, 'DisplayName', 'Flux LB');
            % Flux UB = #009E73
            plot(UIaxes, x, fluxUB, '-', 'Color', "#009E73", 'LineWidth', 3, 'DisplayName', 'Flux UB');

            % Add legend
            legend(UIaxes, 'show', 'Location', 'best');

            hold(UIaxes, 'off');

        end % drawMonteCarloStocastic

        %% Public save functions
        function saveResult(obj, batchID, names, directoryPath, options)
            % SAVERESULT Save the result data to the selected directory.
            %
            % Parameters:
            % -----------
            %   obj: IOResult
            %       The IOResult object.
            %   batchID: (1, :) string
            %       The batch IDs to save the result files.
            %   names: (1, :) string
            %       The names of the batch IDs.
            %   directoryPath: (1, 1) string
            %       The directory path to save the result files.
            %   options: struct
            %       The options for saving the result files.
            %       options.addDatetime: (1, 1) logical
            %           Whether to add the current date and time to the directory name.
            %
            % See also: saveResultData

            arguments
                obj (1, 1) IOResult
                batchID (:, 1) string
                names (:, 1) string
                directoryPath (1, 1) string
                options.addDatetime (1, 1) logical = true
            end % arguments

            if length(batchID) ~= length(names) || length(batchID) ~= unique(length(batchID))
                notifyGeneralMessage(obj, "error", "Batch ID and names must have the same length.");
                return;
            end % if

            for iBatch = 1:length(batchID)

                % Get the batch ID and name
                iBatchID = batchID(iBatch);
                iName = names(iBatch);

                % Create the file name
                if options.addDatetime
                    datetimeStr = string(datetime('now', 'Format', 'yyyyMMdd-HHmmss'));
                    directoryName = iName + "_" + iBatchID + "_" + datetimeStr;
                else
                    directoryName = iName + "_" + iBatchID;
                end % if

                try
                    % Create the directory if it does not exist
                    iDirectoryPath = fullfile(directoryPath, directoryName);

                    if isfolder(iDirectoryPath)
                        msg = "Directory already exists: " + iDirectoryPath;
                        notifyGeneralMessage(obj, "error", msg);
                        continue;
                    end % if isfolder(directoryPath)

                    mkdir(iDirectoryPath);

                catch ME

                    notifyGeneralMessage(obj, "error", "Failed to create the directory: " + ME.message);
                    continue;

                end % try-catch

                msg = "Saving result to: " + iDirectoryPath;
                notifyGeneralMessage(obj, "info", msg);

                % Save the result data
                saveResultData(obj, iBatchID, iName, iDirectoryPath, "xlsx");

            end % for iBatch

        end % function saveResult

        function saveResultData(obj, batchID, name, directoryPath, fmt)
            % SAVERESULTDATA Save the result data to the selected directory.
            %
            % Parameters:
            %   obj: IOResult
            %       The IOResult object.
            %   batchID: (1, 1) string
            %       The batch IDs to save the result files.
            %   name: (1, 1) string
            %       The names of the batch IDs.
            %   directoryPath: (1, 1) string
            %       The directory path to save the result files.
            %   fmt: (1, 1) string
            %       The format to save the result files.

            arguments
                obj (1, 1) IOResult
                batchID (1, 1) string
                name (1, 1) string
                directoryPath (1, 1) string
                fmt (1, 1) string {mustBeMember(fmt, ["xlsx", "csv"]) ...
                                       mustBeNonempty(fmt)} = "xlsx"
            end % arguments

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

            % Create the file name
            switch fmt
                case "xlsx"
                    fileName = "result_" + name + "_" + batchID + ".xlsx";
            end % switch

            filePath = fullfile(directoryPath, fileName);

            % Create flux row header
            overview = obj.getFluxOverView(batchID);
            [isSuccess, msg] = obj.exportExcelFile(filePath, overview, "Overview");

            if ~isSuccess
                notifyGeneralMessage(app, "error", "Failed to save the overview data: " + msg);
                return;
            end % if ~isSuccess

            detailed = obj.getFluxDetailed(batchID);
            [isSuccess, msg] = obj.exportExcelFile(filePath, detailed, "Detailed", WriteRowNames = false);

            if ~isSuccess
                notifyGeneralMessage(app, "error", "Failed to save the detailed data: " + msg);
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
            %   obj: IOResult
            %       The IOResult object.
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
            %   obj: IOResult
            %       The IOResult object.
            %   id: (1, 1) string
            %       The batch ID to load the result files.

            arguments
                obj (1, 1) IOResult
                id (1, 1) string
                options.readstatus (1, 4) logical = [true, true, true, true]
            end % arguments

            % Load the result file
            filePath = fullfile(obj.directoryResult, id + ".h5");

            if ~isfile(filePath)
                notifyGeneralMessage(obj, "error", "Result file does not exist.");
                return;
            end

            % Load the status
            data = struct;
            data.ID = h5read(filePath, '/ID');
            status = h5read(filePath, '/status');
            data.status = status;

            status = and(status, options.readstatus);

            if status(1)

                % Load the model data
                data.model.modelID = h5read(filePath, '/model/modelID');
                data.model.modelReaction = h5read(filePath, '/model/modelReaction');

                % Load MDV data
                data.MDVExp = h5read(filePath, '/MDVExp');
                data.MDVExpName = h5read(filePath, '/MDVFragList');
                data.MDVFragMask = h5read(filePath, '/MDVFragMask');

                % Result of FVA
                data.fluxVariability.fluxUBFwd = ...
                    h5read(filePath, '/fluxVariability/fluxUBFwd');
                data.fluxVariability.fluxLBFwd = ...
                    h5read(filePath, '/fluxVariability/fluxLBFwd');
                data.fluxVariability.time = ...
                    h5read(filePath, '/fluxVariability/time');

            end

            if status(1)

                % Result of InitialFlux
                data.initialFlux.fluxFwd = ...
                    h5read(filePath, '/initialFlux/fluxFwd');
                data.initialFlux.RSS = ...
                    h5read(filePath, '/initialFlux/RSS');
                data.initialFlux.time = ...
                    h5read(filePath, '/initialFlux/time');

            end % if status(1)

            if status(2)

                % Result of FVA
                data.RSS = ...
                    h5read(filePath, "/RSS");
                data.RSSIdx = ...
                    h5read(filePath, "/RSSIndex");
                data.threshold = ...
                    h5read(filePath, "/threshold");

                for i = 1:length(data.RSSIdx)

                    iterName = string(sprintf("%04d", data.RSSIdx(i)));
                    fieldName = "fluxResult" + iterName;
                    addressName = "/fluxResult/" + iterName;
                    data.(fieldName).fluxFwd = ...
                        h5read(filePath, addressName + "/fluxFwd");
                    data.(fieldName).RSS = ...
                        h5read(filePath, addressName + "/RSS");
                    data.(fieldName).MDV = ...
                        h5read(filePath, addressName + "/MDV");
                    data.(fieldName).exitflag = ...
                        h5read(filePath, addressName + "/exitflag");
                    data.(fieldName).time = ...
                        h5read(filePath, addressName + "/time");

                end % for i

            end % if status(2)

            if status(3)

                % Result of FVA
                data.fluxLB = ...
                    h5read(filePath, "/fluxLB");
                data.fluxUB = ...
                    h5read(filePath, "/fluxUB");

            end % if status(3)

        end % getResultData

        function notifyGeneralMessage(obj, status, msg)
            % NOTIFYINITIALFLUXEVENT Notify the initial flux event.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) IOResult
                status (1, 1) string {mustBeMember(status, ["info", "warning", "error"])}
                msg (1, 1) string
            end % arguments

            % Event data
            type = "GeneralMsg";
            ed = struct;
            ed.status = status;
            ed.msg = msg;

            notify(obj, 'GeneralMsg', BatchProgressEventData(type, ed));
            % obj.status.updateMsg(msg, "Info", "Info");

        end % notifyInitialFluxEvent

    end % methods (Access = protected)

    methods (Access = private)

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

end % class IOResult
