classdef IOModel < Status

    properties

        % The file type to load
        fileTypeModel (1, 1) string {mustBeMember(fileTypeModel, ["xlsx", "csv"])} = "xlsx";
        fileTypeLabel (1, 1) string {mustBeMember(fileTypeLabel, "json")} = "json";
        fileTypePathway (1, 1) string {mustBeMember(fileTypePathway, "tiff")} = "tiff";
        fileModel (1, 1) string = "metabolic_network";
        fileLabel (1, 1) string = "label";
        filePathway (1, 1) string = "metabolic_pathway";

        % Tables
        tableInfo table;
        tableModel table;
        tableMS table;
        tableBiomass table;
        tableXY table;
        tableAtom table;

        % Label
        tableLabelView table;
        structLabelView struct = struct();
        ratioTableVariableNames = ["Label", "Ratio"];

        % Structure
        structLabel = struct;

        % Table model
        modelRxn table;
        modelTrans table;
        MSRxn table;
        MSTrans table;
        modelMetabolite table;
        MSMetabolite table;

        % Pathway map image
        imagePathway;

        isPathwayLoaded (1, 1) logical = false;
        isLabelLoaded (1, 1) logical = false;

    end

    properties (Access = private)

        % TableSheetNames
        tableList string = ["tableInfo", "tableModel", "tableMS", "tableBiomass", "tableXY", "tableAtom"];
        tableSheetNames string = ["info", "model", "MS", "biomass", "position", "atom"];
        tableReadRowName logical = [false, true, true, false, true, true];
        tableLabelNames string = ["tableInfo", "tableModel", "tableMS", "tableBiomass", "tableXY", "tableAtom"];
        tableVariableNames struct = struct;
        tableTypes struct = struct;
        modelMetaboliteReactant table;
        modelMetaboliteProduct table;
        MSMetaboliteReactant table;
        MSMetaboliteProduct table;
        ModelLocation openmebius.domain.model.ModelLocation

        errorColumnsModel (1, :) double = [];
        errorColumnsMS (1, :) double = [];
        errorColumnsAtom (1, :) double = [];

        % Error control
        IOstatus (1, 1) string {mustBeMember(IOstatus, [ ...
                                                            "fileLoad", ...
                                                            "modelParse" ...
                                                            "MSParse" ...
                                                            "metabolite" ...
                                                            "completed" ...
                                                        ])} = "fileLoad";

    end

    properties (Dependent)

        % The file name
        pathModel (1, 1) string;
        pathLabel (1, 1) string;
        pathPathway (1, 1) string;
        pathHash (1, 1) string;
        pathCache (1, 1) string;

        % Dependent table for GUI
        tableModelGUI table;

        % Model modification
        isUpdatedModel (1, 1) logical;

    end

    %% General methods
    methods

        function obj = IOModel(modelInput)

            modelLocation = ...
                openmebius.domain.model.ModelLocation.fromInput( ...
                modelInput);

            obj.ModelLocation = modelLocation;
            openmebius.infrastructure.legacy.LegacyFileAccess ...
                .initializeDirectory(obj, modelLocation.Directory);

            if obj.isError
                return;
            end

            setupTableInfo(obj);

            loadModel(obj);
            loadPathway(obj);

            if obj.isError
                return;
            end

            obj.IOstatus = "modelParse";

            parseModels(obj);

            if obj.isError
                return;
            end

            obj.IOstatus = "MSParse";

            parseMS(obj);

            if obj.isError
                return;
            end

            obj.IOstatus = "metabolite";

            listUpMetaboliteAll(obj);

            if obj.isError
                return;
            end

            obj.IOstatus = "completed";

            loadLabel(obj);
            createLabelView(obj);

        end % IOModel

        % Dependent properties
        % Get the file name
        function pathModel = get.pathModel(obj)
            pathModel = obj.ModelLocation.modelFile( ...
                obj.fileModel, ...
                obj.fileTypeModel);
        end % get.pathModel

        % Get the file name
        function pathPathway = get.pathPathway(obj)
            pathPathway = obj.ModelLocation.pathwayFile( ...
                obj.filePathway, ...
                obj.fileTypePathway);
        end % get.pathPathway

        % Get the file name
        function pathLabel = get.pathLabel(obj)
            pathLabel = obj.ModelLocation.labelFile( ...
                obj.fileLabel, ...
                obj.fileTypeLabel);
        end % get.pathLabel

        % Get the hash file
        function pathHash = get.pathHash(obj)
            pathHash = obj.ModelLocation.hashFile(obj.fileModel);
        end % get.pathHash

        function pathCache = get.pathCache(obj)
            pathCache = obj.ModelLocation.cacheFile(obj.fileModel);
        end % get.pathCache

        function tableModelGUI = get.tableModelGUI(obj)

            try
                % tableModelとtableXYを結合（列名で結合）
                tableModelGUI = join(obj.tableModel, obj.tableXY, 'Keys', 'RowNames');
            catch
                updateMsg(obj, "The tableModel and tableXY could not be joined.", "Error", obj.logLevel);
                tableModelGUI = table();
            end

        end % get.tableModelGUI

        function isUpdatedModel = get.isUpdatedModel(obj)
            % Check if the model is updated
            %
            % Returns
            % -------
            % isUpdatedModel logical
            %     True if the model is updated
            %     If any error occurs, the function returns true (enforce the model reconstructions)

            isUpdatedModel = false;

            % Load the hash file
            try
                fid = fopen(obj.pathHash, 'r');
                hash = fscanf(fid, '%s');
                fclose(fid);
            catch
                isUpdatedModel = true;
                return;
            end

            % Generate hash
            hashCurrentModel = obj.getHashFromFile(obj.pathModel);

            % Compare the hash
            if ~strcmp(hash, hashCurrentModel)
                isUpdatedModel = true;
            end

        end % get.isUpdatedModel

        %% Public setup methods
        function setupTableInfo(obj)

            obj.tableSheetNames = ["info", "model", "MS", "biomass", "position", "atom"];

            obj.tableVariableNames.tableInfo = ["Information", "Value"];
            obj.tableVariableNames.tableModel = ["Reaction", "Transition", "Independent"];
            obj.tableVariableNames.tableMS = ["Reaction", "Transition", "Used"];
            obj.tableVariableNames.tableBiomass = ["Precursor", "Biomass"];
            obj.tableVariableNames.tableXY = ["x", "y"];
            obj.tableVariableNames.tableAtom = ["C", "H", "O", "N", "S", "Si"];

            obj.tableTypes.tableInfo = ["cell", "cell"];
            obj.tableTypes.tableModel = ["cell", "cell", "logical"];
            obj.tableTypes.tableMS = ["cell", "cell", "logical"];
            obj.tableTypes.tableBiomass = ["cell", "double"];
            obj.tableTypes.tableXY = ["double", "double"];
            obj.tableTypes.tableAtom = ["int8", "int8", "int8", "int8", "int8", "int8"];

        end % setupSheetNames

        %% Public drawing methods
        function drawPathway(obj, UIaxes, contextMenu, options)
            % DRAWPATWAY: Draw the metabolic pathway on the given UIAxes
            %
            % INPUT:
            %   UIaxes matlab.ui.control.UIAxes
            %     The UIAxes object where the pathway image will be displayed.
            %   contextMenu matlab.ui.container.ContextMenu
            %     The context menu to be associated with the UIAxes.

            arguments
                obj;
                UIaxes matlab.ui.control.UIAxes;
                contextMenu matlab.ui.container.ContextMenu;
                options.darkmode (1, 1) logical = false;
            end

            if ~obj.isPathwayLoaded
                updateMsg(obj, "The pathway image could not be loaded.", "Error", obj.logLevel);
                return;
            end

            img = obj.imagePathway;

            if options.darkmode
                img = convertImageForDarkTheme(obj, img);
            end

            hImage = image(UIaxes, img, 'HitTest', 'off');
            imRatio = size(img, 1) / size(img, 2);
            UIaxes.DataAspectRatio = [1, imRatio, 1];

            UIaxes.Visible = 'off';
            axis(UIaxes, 'image');
            % Title
            title(UIaxes, 'Metabolic Pathway');
            % Hide XY label
            xlabel(UIaxes, '');
            ylabel(UIaxes, '');

            % Ensure the UIAxes and image are interactive
            UIaxes.HitTest = 'on';
            UIaxes.PickableParts = 'all';

            % Re-associate the context menu with the UIAxes and the image
            UIaxes.ContextMenu = contextMenu;
            hImage.ContextMenu = contextMenu;

            drawFluxLabel(obj, UIaxes, [], darkmode = options.darkmode);

        end % drawPathway

        function drawFluxLabel(obj, UIaxes, flux, options)
            % DRAWFLUXLABEL: Draw the flux labels on the given UIAxes
            %
            % INPUT:
            %   UIaxes matlab.ui.control.UIAxes
            %     The UIAxes object where the flux labels will be displayed.
            %   flux cell
            %     The cell array of flux labels to be displayed.
            %   options struct
            %     The options for drawing the flux labels.

            arguments
                obj;
                UIaxes matlab.ui.control.UIAxes;
                flux cell = [];
                options.highlight (:, 1) logical = [];
                options.darkmode (1, 1) logical = false;
            end

            % Clear existing flux labels
            delete(findobj(UIaxes, 'Type', 'text'));

            if isempty(options.highlight)
                highlight = false(height(obj.tableModelGUI), 1);
            else
                highlight = options.highlight;
            end

            mtableModelGUI = obj.tableModelGUI;

            if isempty(flux)
                flux = mtableModelGUI.Properties.RowNames;
            end

            % Set the color based on the dark mode option
            if options.darkmode
                fluxColor = '#FFFFFF'; % White for dark mode
            else
                fluxColor = '#000000'; % Black for light mode
            end

            for i = 1:height(mtableModelGUI)

                x = mtableModelGUI.x(i);
                y = mtableModelGUI.y(i);
                fluxLabel = flux{i};

                if highlight(i)
                    text(UIaxes, x, y, fluxLabel, ...
                        'Color', '#009E73', 'FontSize', 14, 'FontWeight', 'bold');
                else
                    text(UIaxes, x, y, fluxLabel, ...
                        'Color', fluxColor, 'FontSize', 14, 'FontWeight', 'normal');
                end % if

            end

        end % drawFluxLabel

        function imgOut = convertImageForDarkTheme(~, img)
            % CONVERTIMAGEFORDARKTHEME: Convert an image to a dark theme compatible format
            %
            % Parameters:
            % -----------
            % img (2D or 3D array)
            %     The input image to be converted. It can be a grayscale (2D) or RGB (3D) image.
            %
            % Returns:
            % --------
            % imgOut (2D or 3D array)
            %     The output image with the dark theme compatible format.

            % Normalize the image to double precision if it is uint8
            if isa(img, 'uint8')
                img = im2double(img);
            end

            % Switch based on the number of channels in the image
            if size(img, 3) == 1
                % Grayscale image to inverted grayscale
                imgOut = 1 - img;

            elseif size(img, 3) == 3
                % Assuming RGB image
                hsv = rgb2hsv(img);
                % Adjust the hue and saturation
                hsv(:, :, 3) = 0.9 - hsv(:, :, 3);
                % Clip the value channel to ensure it is within a reasonable range
                hsv(:, :, 3) = max(0.2, min(hsv(:, :, 3), 0.95));
                % Reconvert to RGB
                imgOut = hsv2rgb(hsv);

            else
                error('Unsupported image format');
            end

        end % function convertImageForDarkTheme

        function loadLabel(obj)

            obj.structLabel = openmebius.infrastructure.legacy.LegacyFileAccess ...
                .importJSONFile(obj, obj.pathLabel);

        end % loadLabel

        function exportLabel(obj)

            if ~isValidLabelStruct(obj)
                return;
            end

            convertLabelViewToStruct(obj);

            openmebius.infrastructure.legacy.LegacyFileAccess ...
                .exportJSONFile(obj, obj.pathLabel, obj.structLabel);

        end % exportLabel

        function hash = getHashFromFile(~, pathFile, options)

            arguments
                ~
                pathFile (1, 1) string
                options.Algorithm (1, 1) string = "SHA256"
            end

            hash = openmebius.infrastructure.legacy.LegacyFileAccess ...
                .getHashFromFile(pathFile, Algorithm = options.Algorithm);

        end % getHashFromFile

        function saveHashFile(~, pathFile)

            arguments
                ~
                pathFile (1, 1) string
            end

            openmebius.infrastructure.legacy.LegacyFileAccess.saveHashFile(pathFile);

        end % saveHashFile

        function tableLabel = convertLabelCellToTable(obj, cellLabel)

            ratioVariableNames = obj.ratioTableVariableNames;

            % テーブルであるか判定
            if istable(cellLabel)

                tableLabel = cellLabel;

            else

                tableLabel = cell2table(cellLabel, 'VariableNames', ratioVariableNames);

            end

            disp(tableLabel);

        end % convertLabelCellToTable

        %% Public judge methods
        function tf = isSymmetricMetabolite(obj, metaboliteName)

            metaboliteList = getMetaboliteTable(obj);
            tf = metaboliteList.Symmetric{ ...
                                              strcmp(metaboliteList.Metabolite, metaboliteName) ...
                                          };

        end % method isSymmetricMetabolite

        %% Public get methods
        function subSorted = getSubstrateTable(obj)

            type = "substrate";
            subs = obj.modelMetabolite(obj.modelMetabolite.Type == type, :);
            subSorted = sortrows(subs, "Metabolite", 'ascend');

        end % getSubstrateTable

        function totalFlux = getSplittedFlux(obj, netFlux)
            % GETSPLITTEDFLUX Get the splitted flux from the net flux
            %
            % Parameters
            % ----------
            % netFlux (n, 1) double
            %     The net flux (n reactions), ordered as obj.modelRxn の行順
            %
            % Returns
            % -------
            % totalFlux (m, 1) double
            %     The splitted flux (m reactions)
            %
            %   netFlux(i) = v_fwd(i) - v_rev(i)
            %   v_fwd(i) >= 0, v_rev(i) >= 0

            arguments
                obj;
                netFlux (:, 1) double {mustBeNumeric};
            end

            % 反応数チェック
            numRxn = height(obj.modelRxn);

            if numel(netFlux) ~= numRxn
                error("IOModel:getSplittedFlux:InvalidSize", ...
                    "The length of netFlux (%d) does not match the number of reactions (%d).", ...
                    numel(netFlux), numRxn);
            end

            % Flag for reversible reactions
            revMask = obj.modelRxn.Reversible;

            if ~islogical(revMask)
                revMask = logical(revMask);
            end

            numRev = nnz(revMask);
            numIrrev = numRxn - numRev;

            % The total length of splitted flux
            % Irreversible reactions: 1 flux each
            % Reversible reactions: 2 fluxes each (forward and reverse)
            totalLen = numIrrev + 2 * numRev;
            totalFlux = zeros(totalLen, 1);

            idx = 0;

            for i = 1:numRxn

                v = netFlux(i);

                if ~revMask(i)
                    idx = idx + 1;
                    totalFlux(idx) = v;

                else

                    idx = idx + 1; % forward

                    if v >= 0
                        totalFlux(idx) = v;
                    else
                        totalFlux(idx) = 0;
                    end

                    idx = idx + 1; % reverse

                    if v >= 0
                        totalFlux(idx) = 0;
                    else
                        totalFlux(idx) = -v;
                    end

                end

            end

        end % getSplittedFlux

    end % methods (public)

    % Get methods
    methods (Access = public)

        function status = getIOStatus(obj)

            status = obj.IOstatus;

        end % function getIOStatus

        function modelLocation = getModelLocation(obj)

            modelLocation = obj.ModelLocation;

        end % function getModelLocation

        function tableOut = getModelTable(obj)

            tableOut = obj.tableModel;

        end % function getModelTable

        function tableOut = getModelTableGUI(obj)

            tableOut = obj.tableModelGUI;

        end % function getModelGUITable

        function tableOut = getMSTable(obj)

            tableOut = obj.tableMS;

        end % function getMSTable

        function tableRxn = getMSRxnTable(obj)
            % GETMSRXNTABLE Get the mass spectrometry reaction table
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % tableRxn table
            %     The mass spectrometry reaction table

            tableRxn = obj.MSRxn;

        end % function getMSRxnTable

        function tableMSTrans = getMSTransTable(obj)
            % GETMSTRANSTABLE Get the mass spectrometry transition table
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % tableMSTrans table
            %     The mass spectrometry transition table

            tableMSTrans = obj.MSTrans;

        end % function getMSTransTable

        function tableOut = getAtomTable(obj)

            tableOut = obj.tableAtom;

        end % function getAtomTable

        function tableOut = getBiomassTable(obj)

            tableOut = obj.tableBiomass;

        end % function getBiomassTable

        function tableOut = getMetaboliteTable(obj)

            tableOut = obj.modelMetabolite;

        end % function getMetaboliteTable

        function metabolite = getMetaboliteTableMetabolite(obj)

            tableMetabolite = obj.modelMetabolite;
            metabolite = tableMetabolite.Metabolite;
            isMetabolite = tableMetabolite.Type == "metabolite";
            metabolite = metabolite(isMetabolite);
            metabolite = string(sort(metabolite));
            metabolite = metabolite(:);

        end % function getMetaboliteTableMetabolite

        function substrate = getMetaboliteTableSubstrate(obj)

            tableMetabolite = obj.modelMetabolite;
            substrate = tableMetabolite.Metabolite;
            isSubstrate = tableMetabolite.Type == "substrate";
            substrate = substrate(isSubstrate);
            substrate = string(sort(substrate));
            substrate = substrate(:);

        end % function getMetaboliteTableSubstrate

        function tableOut = getMSMetaboliteTable(obj)

            try
                tableOut = obj.MSMetabolite;
            catch
                updateMsg(obj, "The MS metabolite table could not be loaded.", "Error", obj.logLevel);
                tableOut = table();
            end

        end % function getMSMetaboliteTable

        function idx = getInvalidModelRowIdx(obj)

            idx = obj.errorColumnsModel;

        end % function getInvalidModelRowIdx

        function idx = getInvalidMSRowIdx(obj)

            idx = obj.errorColumnsMS;

        end % function getInvalidMSRowIdx

        function idx = getInvalidAtomRowIdx(obj)

            idx = obj.errorColumnsAtom;

        end % function getInvalidAtomRowIdx

        function tableOut = getTableLabelView(obj)

            tableOut = obj.tableLabelView;

        end % function getTableLabelView

        function struct = getLabelStruct(obj)

            struct = obj.structLabel;

        end % function getLabelStruct

        function struct = getLabelStructView(obj)

            struct = obj.structLabelView;

        end % function getLabelStructView

        function stringRtn = getTemplateMSTable(obj)

            MS = getMSTable(obj);
            MSList = MS.Properties.RowNames;
            IndexName = "Row";
            Index = arrayfun(@(x) "M+" + x, 0:100);

            stringRtn = strings(length(Index) + 1, length(MSList) + 1);
            stringRtn(1, 2:end) = MSList';
            stringRtn(2:end, 1) = Index';
            stringRtn(1, 1) = IndexName;

        end % method getTemplateMSTable

        % Reconstruct function
        function reconstructModel(obj)

            parseModels(obj);

            if obj.isError
                return;
            end

            parseMS(obj);

            if obj.isError
                return;
            end

            listUpMetaboliteAll(obj);

            if obj.isError
                return;
            end

        end % function reconstructModel

        function updateModelTableGUI(obj, tableIn)

            reset(obj);

            try
                tableModelIn = tableIn(:, ["Reaction", "Transition", "Independent"]);
                tableXYIn = tableIn(:, ["x", "y"]);
            catch
                updateMsg(obj, "The table is not in the correct format.", "Error", obj.logLevel);
                obj.isError = true;
                return;
            end

            updateMsg(obj, "The table has been updated successfully.", "Info", obj.logLevel);

            obj.tableModel = tableModelIn;
            obj.tableXY = tableXYIn;

            obj.errorColumnsModel = [];

            reconstructModel(obj);

        end % function updateModelTable

        function updateMSTable(obj, tableIn)

            reset(obj);

            try
                tableMSIn = tableIn(:, ["Reaction", "Transition"]);
            catch
                updateMsg(obj, "The table is not in the correct format.", "Error", obj.logLevel);
                obj.isError = true;
                return;
            end

            if any(strcmp(tableIn.Properties.VariableNames, "Used"))
                tableMSIn.Used = normalizeMSUsedColumn(obj, tableIn.Used, height(tableMSIn));
            else
                tableMSIn.Used = true(height(tableMSIn), 1);
                updateMsg(obj, "The MS table does not contain the 'Used' column. A default 'Used=true' column has been added.", "Warning", obj.logLevel);
            end

            obj.tableMS = tableMSIn;
            obj.errorColumnsMS = [];

            updateMsg(obj, "The table has been updated successfully.", "Info", obj.logLevel);

            reconstructModel(obj);

        end % method updateMSTable

        function updateAtomTable(obj, tableIn)

            reset(obj);

            try
                obj.tableAtom = tableIn;
            catch
                updateMsg(obj, "The table is not in the correct format.", "Error", obj.logLevel);
                obj.isError = true;
                return;
            end

            obj.errorColumnsAtom = [];

            [tf, errcols] = isValidAtomTable(obj, obj.tableAtom);

            if ~tf
                updateMsg(obj, "The Atom table contains invalid values.", "Error", obj.logLevel);
                obj.isError = true;
                obj.errorColumnsAtom = errcols;
                return;
            end

            updateMsg(obj, "The table has been updated successfully.", "Info", obj.logLevel);

            reconstructModel(obj);

        end % function updateAtomTable

        function updateStructLabel(obj, structLabelIn)
            % UPDATESTRUCTLABEL Update the label structure
            %
            % Parameters
            % ----------
            % structLabelIn struct
            %     The label structure to be updated

            obj.structLabel = structLabelIn;

            updateMsg(obj, "The label structure has been updated successfully.", "Info", obj.logLevel);

            obj.isLabelLoaded = true;

        end % function updateStructLabel

    end % methods (public)

    methods (Access = private)

        % Load metabolic model
        function loadModel(obj)

            % Load the model
            if ~(obj.fileTypeModel == "xlsx")

                obj.isError = true;
                updateMsg(obj, "The file type " + obj.fileTypeModel + " is not supported.", "Error", obj.logLevel);
                return

            end % if

            for i = 1:length(obj.tableList)

                obj.(obj.tableList(i)) = ...
                    openmebius.infrastructure.legacy.LegacyFileAccess.importExcelFile( ...
                    obj, obj.pathModel, obj.tableSheetNames(i), ...
                    "refVariableNames", obj.tableVariableNames.(obj.tableLabelNames(i)), ...
                    "readRowName", obj.tableReadRowName(i), ...
                    "refTypes", obj.tableTypes.(obj.tableLabelNames(i)));

                if obj.isError
                    return;
                end

            end % for

        end % loadModel

        function loadPathway(obj)

            try
                obj.imagePathway = imread(obj.pathPathway);
                obj.isPathwayLoaded = true;
            catch
                updateMsg(obj, "The pathway image could not be loaded.", "Error", obj.logLevel);
                obj.isPathwayLoaded = false;
            end

        end % loadPathway

        function createLabelView(app)

            fieldNames = fieldnames(app.structLabel);
            numField = numel(fieldNames);

            tempLabelView = cell(numField, 2);

            for i = 1:numel(fieldNames)

                tempLabelView{i, 1} = app.structLabel.(fieldNames{i}).name;
                tempLabelView{i, 2} = app.structLabel.(fieldNames{i}).num;

                % if isempty(fieldnames(app.structLabelView))
                %     app.structLabelView = struct();
                % end

                ratioVariableNames = app.ratioTableVariableNames;

                app.structLabelView.(fieldNames{i}) = cell2table( ...
                    [app.structLabel.(fieldNames{i}).label, num2cell(app.structLabel.(fieldNames{i}).ratio)], ...
                    'VariableNames', ratioVariableNames ...
                );

            end

            app.tableLabelView = table( ...
                tempLabelView(:, 1), ...
                tempLabelView(:, 2), ...
                'VariableNames', ["Name", "Num"] ...
            );

        end % createLabelView

        function convertLabelViewToStruct(app)

            label = app.tableLabelView;
            ratio = app.structLabelView;
            numLabel = height(label);
            labelFieldNames = makeStructLabel(app, label.Name);
            ratioFieldNames = fieldnames(ratio);

            for i = 1:numLabel

                labelFieldName = labelFieldNames{i};
                ratioFieldName = ratioFieldNames{i};

                if ~isfield(app.structLabel, labelFieldName)
                    app.structLabel.(labelFieldName) = struct();
                end

                app.structLabel.(labelFieldName).name = label.Name{i};
                app.structLabel.(labelFieldName).num = label.Num{i};
                app.structLabel.(labelFieldName).label = ratio.(ratioFieldName).Label;
                app.structLabel.(labelFieldName).ratio = ratio.(ratioFieldName).Ratio;

            end % for

        end % convertLabelViewToStruct

        function label = makeStructLabel(~, input)

            label = matlab.lang.makeValidName(input);
            label = matlab.lang.makeUniqueStrings(label);

        end % makeStructLabel

        function [tf, errcols] = isValidAtomTable(~, tableAtom)

            numMolecule = height(tableAtom);
            numElement = width(tableAtom);
            err = false(numMolecule, numElement);
            tf = true;

            for i = 1:numMolecule

                for j = 1:numElement

                    isNumeric = isnumeric(tableAtom{i, j});

                    if ~isNumeric
                        err(i, j) = true;
                        continue
                    end

                    isInteger = isinteger(tableAtom{i, j});

                    if ~isInteger
                        err(i, j) = true;
                        continue
                    end

                    isPositive = tableAtom{i, j} >= 0;

                    if ~isPositive
                        err(i, j) = true;
                        continue
                    end

                end

            end

            errcols = any(err, 2);
            errcols = find(errcols);

            if any(err, 'all')
                tf = false;
            end

        end % isValidAtomTable

        % TODO: Implement the function
        function tf = isValidLabelStruct(obj)

            tf = true;

        end % isValidLabelStruct

        % TODO: Implement the function
        function tf = isValidLabelDigits(~, labelPattern, numC)

            tf = true;

        end % isValidLabelDigits

        function parseModels(obj)

            [react, product, rev, err] = parseReaction(obj, obj.tableModel.Reaction);

            obj.modelRxn = table( ...
                react, ...
                product, ...
                rev, ...
                obj.tableModel.Independent, ...
                'RowNames', obj.tableModel.Properties.RowNames, ...
                'VariableNames', ["Reactants", "Products", "Reversible", "Independent"] ...
            );

            obj.errorColumnsModel = [obj.errorColumnsModel, err];

            [react, product, rev, err] = parseReaction(obj, obj.tableModel.Transition);

            obj.modelTrans = table( ...
                react, ...
                product, ...
                rev, ...
                'RowNames', obj.tableModel.Properties.RowNames, ...
                'VariableNames', ["Reactants", "Products", "Reversible"] ...
            );

            obj.errorColumnsModel = [obj.errorColumnsModel, err];

            if obj.isError
                return;
            end

            updateMsg(obj, "The models have been parsed successfully.", "Info", obj.logLevel);

        end % parseModels

        function parseMS(obj)

            [react, product, rev, err] = parseReaction(obj, obj.tableMS.Reaction);

            obj.MSRxn = table( ...
                react, ...
                product, ...
                rev, ...
                'RowNames', obj.tableMS.Properties.RowNames, ...
                'VariableNames', ["Reactants", "Products", "Reversible"] ...
            );

            obj.errorColumnsMS = [obj.errorColumnsMS, err];

            [react, product, rev, err] = parseReaction(obj, obj.tableMS.Transition);

            obj.MSTrans = table( ...
                react, ...
                product, ...
                rev, ...
                'RowNames', obj.tableMS.Properties.RowNames, ...
                'VariableNames', ["Reactants", "Products", "Reversible"] ...
            );

            obj.errorColumnsMS = [obj.errorColumnsMS, err];

            if obj.isError
                return;
            end

            updateMsg(obj, "The mass spectrometry models have been parsed successfully.", "Info", obj.logLevel);

        end % parseMS

        function [react, product, rev, err] = parseReaction(obj, rxnCol)

            arguments
                obj;
                rxnCol cell;
            end

            % Parse the reaction
            numRxn = size(rxnCol, 1);
            react = cell(numRxn, 1);
            product = cell(numRxn, 1);
            rev = false(numRxn, 1);
            err = [];

            % Split reaction into reactants and products with delimiters <=> and -->
            for iRxn = 1:numRxn

                if isempty(rxnCol(iRxn))
                    continue
                end

                if sum(ismissing(rxnCol(iRxn))) > 0
                    continue
                end

                iSplitFwd = strsplit(rxnCol{iRxn}, '-->');

                if numel(iSplitFwd) == 2
                    react{iRxn} = strsplit(iSplitFwd{1}, '+');
                    product{iRxn} = strsplit(iSplitFwd{2}, '+');
                    continue
                end

                iSplitRev = strsplit(rxnCol{iRxn}, '<=>');

                if numel(iSplitRev) == 2
                    react{iRxn} = strsplit(iSplitRev{1}, '+');
                    product{iRxn} = strsplit(iSplitRev{2}, '+');
                    rev(iRxn) = true;
                    continue
                end

                if isscalar(iSplitFwd) && isscalar(iSplitRev)
                    obj.isError = true;
                    updateMsg(obj, "The reaction " + rxnCol{iRxn} + " does not contain an arrow.", "Error", obj.logLevel);
                    err = [err, iRxn]; %#ok<AGROW>
                    continue
                end

                if numel(iSplitFwd) > 2 || numel(iSplitRev) > 2
                    obj.isError = true;
                    updateMsg(obj, "The reaction " + rxnCol{iRxn} + " contains more than one arrow.", "Error", obj.logLevel);
                    err = [err, iRxn]; %#ok<AGROW>
                    continue
                end

            end

            if obj.isError
                react = cell(numRxn, 1);
                product = cell(numRxn, 1);
                rev = false(numRxn, 1);
                return;
            end

            react = strtrim(react);
            product = strtrim(product);

            updateMsg(obj, "The reactions have been parsed successfully.", "Debug", obj.logLevel);

        end % parseReaction

        function [metType, isSymmetric, arrangedMetabolite] = typeMetabolite(~, metabolite)

            metType = 'metabolite';
            arrangedMetabolite = metabolite;
            isSymmetric = false;

            % Substrate or Product
            expression = "^Subs_";

            if ~isempty(regexp(metabolite, expression, 'once'))
                metType = 'substrate';
                arrangedMetabolite = regexprep(metabolite, expression, '');

            end

            expression = "^Sym_";

            if ~isempty(regexp(arrangedMetabolite, expression, 'once'))
                isSymmetric = true;
            end

        end % typeMetabolite

        function listUpMetaboliteAll(obj)
            % List up all metabolites in the model
            % obj.modelMetabolite table (4 columns)
            % | Metabolite | Carbon | Type | Symmetric |

            [obj.modelMetaboliteReactant, err] = listUpMetabolite(obj, obj.modelRxn.Reactants, obj.modelTrans.Reactants);
            obj.errorColumnsModel = [obj.errorColumnsModel, err];

            [obj.modelMetaboliteProduct, err] = listUpMetabolite(obj, obj.modelRxn.Products, obj.modelTrans.Products);
            obj.errorColumnsModel = [obj.errorColumnsModel, err];

            [obj.MSMetaboliteReactant, err] = listUpMetabolite(obj, obj.MSRxn.Reactants, obj.MSTrans.Reactants);
            obj.errorColumnsMS = [obj.errorColumnsMS, err];

            [obj.MSMetaboliteProduct, err] = listUpMetabolite(obj, obj.MSRxn.Products, obj.MSTrans.Products);
            obj.errorColumnsMS = [obj.errorColumnsMS, err];

            % reactant tableとproduct tableのmetaboliteを統合し，重複を削除，並び替え
            obj.modelMetabolite = [obj.modelMetaboliteReactant; obj.modelMetaboliteProduct];
            obj.MSMetabolite = [obj.MSMetaboliteReactant; obj.MSMetaboliteProduct];

            % sortrow
            obj.modelMetabolite = uniqueTable(obj, obj.modelMetabolite, "Metabolite");
            obj.modelMetabolite = sortrows(obj.modelMetabolite, ["Type", "Metabolite"], 'ascend');
            obj.MSMetabolite = uniqueTable(obj, obj.MSMetabolite, "Metabolite");
            obj.MSMetabolite = sortrows(obj.MSMetabolite, ["Type", "Metabolite"], 'ascend');

        end % listUpMetaboliteAll

        function outTable = uniqueTable(~, inTable, key)

            inCell = table2cell(inTable);
            keyIdx = strcmp(inTable.Properties.VariableNames, key);

            [~, idx] = unique(inCell(:, keyIdx));

            outTable = inTable(idx, :);

        end % uniqueTable

        function [metabolite, err] = listUpMetabolite(obj, reaction, transition)

            metabolite = cell(0, 4);
            err = [];

            numRxn = size(reaction, 1);

            % for each reaction
            for iRxn = 1:numRxn

                numMetabolite = numel(reaction{iRxn});

                % for each metabolite
                for iMetabolite = 1:numMetabolite

                    [metType, isSymmetric, arrangedMetabolite] = typeMetabolite(obj, reaction{iRxn}{iMetabolite});

                    if strcmp(arrangedMetabolite, '')
                        obj.isError = true;
                        updateMsg(obj, "The metabolite in the reaction " + iRxn + " is empty.", "Error", obj.logLevel);
                        err = [err, iRxn]; %#ok<AGROW>
                        continue
                    end

                    reaction{iRxn}{iMetabolite} = arrangedMetabolite;

                    if strcmp(metType, 'substrate')
                        reaction{iRxn}{iMetabolite} = ['Subs_' reaction{iRxn}{iMetabolite}];
                    end

                    % Error handling
                    % If the metabolite is already listed up in the metabolite table
                    if sum(ismember(reaction{iRxn}{iMetabolite}, metabolite(:, 1))) == 1

                        idxRow = strcmp(reaction{iRxn}{iMetabolite}, metabolite(:, 1));
                        numCarbon = metabolite{idxRow, 2};

                        try
                            iNumC = numel(transition{iRxn}{iMetabolite});
                        catch
                            obj.isError = true;
                            msg = "The carbon transition of " + reaction{iRxn}{iMetabolite} + " is not defined.";
                            updateMsg(obj, msg, "Error", obj.logLevel);
                            err = [err, iRxn]; %#ok<AGROW>
                            iNumC = 0;
                        end

                        if numCarbon ~= iNumC
                            obj.isError = true;
                            msg = "The number of carbon in " + reaction{iRxn}{iMetabolite} + " is not consistent.";
                            updateMsg(obj, msg, "Error", obj.logLevel);
                            err = [err, iRxn]; %#ok<AGROW>
                        end

                    elseif sum(ismember(reaction{iRxn}{iMetabolite}, metabolite(:, 1))) == 0

                        try
                            iNumC = numel(transition{iRxn}{iMetabolite});
                        catch
                            obj.isError = true;
                            msg = "The carbon transition of " + reaction{iRxn}{iMetabolite} + " is not defined.";
                            updateMsg(obj, msg, "Error", obj.logLevel);
                            err = [err, iRxn]; %#ok<AGROW>
                            iNumC = 0;
                        end

                        metabolite{end + 1, 1} = reaction{iRxn}{iMetabolite}; %#ok<AGROW>
                        metabolite{end, 2} = iNumC;
                        metabolite{end, 3} = metType;
                        metabolite{end, 4} = isSymmetric;

                    end

                end

            end

            VariableNames = ["Metabolite", "Carbon", "Type", "Symmetric"];
            metabolite = array2table(metabolite, 'VariableNames', VariableNames);

            updateMsg(obj, "The metabolites have been listed up successfully.", "Debug", obj.logLevel);

        end % listUpMetabolite

        function used = normalizeMSUsedColumn(obj, usedIn, numRows)
            % NORMALIZEMSUSEDCOLUMN Convert MS Used column to a logical column vector.
            % used = normalizeMSUsedColumn(obj, usedIn, numRows)
            %
            % Inputs:
            %   usedIn (various types): The input value for the MS Used column. It can be logical, numeric, cell array, or string.
            %   numRows (integer): The number of rows in the MS table.
            %
            % Outputs:
            %   used (logical array): A logical column vector indicating whether each row is used (true) or not (false).

            try

                if islogical(usedIn)
                    used = usedIn;

                elseif isnumeric(usedIn)
                    used = usedIn ~= 0;
                    used(isnan(usedIn)) = false;

                elseif iscell(usedIn)
                    used = false(numRows, 1);

                    for i = 1:numRows
                        iValue = usedIn{i};

                        if isempty(iValue)
                            used(i) = false;

                        elseif islogical(iValue)
                            used(i) = iValue(1);

                        elseif isnumeric(iValue)
                            iValue = iValue(1);
                            used(i) = ~isnan(iValue) && iValue ~= 0;

                        elseif ischar(iValue) || isstring(iValue)
                            used(i) = any(lower(strtrim(string(iValue))) == ["true", "1", "yes", "y", "on"]);

                        else
                            used(i) = logical(iValue);
                        end

                    end

                elseif ischar(usedIn) || isstring(usedIn)
                    used = ismember(lower(strtrim(string(usedIn))), ["true", "1", "yes", "y", "on"]);

                else
                    used = logical(usedIn);
                end

                used = used(:);

                if numel(used) ~= numRows
                    error("OpenMebius2:InvalidMSUsedColumn", ...
                    "The Used column has an invalid number of rows.");
                end

            catch
                used = true(numRows, 1);
                updateMsg(obj, "The MS table 'Used' column could not be converted to logical values. All fragments are selected.", "Warning", obj.logLevel);
            end

        end % method normalizeMSUsedColumn

        %% Save functions
        function saveModel(obj)

        end % saveModel

    end % methods (private)

end % classdef
