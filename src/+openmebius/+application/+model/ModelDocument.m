classdef ModelDocument < handle

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
        ModelRepository
        ReactionParser
        Validator
        NotificationEmitter openmebius.application.notification ...
            .NotificationEmitter
        ValidationErrors (:, 1) string = strings(0, 1)
        ValidationWarnings (:, 1) string = strings(0, 1)

        errorColumnsModel (1, :) double = [];
        errorColumnsMS (1, :) double = [];
        errorColumnsAtom (1, :) double = [];

    end

    properties (Access = protected)
        logLevel (1, 1) string = "Info"
    end

    properties (Dependent)

        % The file name
        pathModel (1, 1) string;
        pathLabel (1, 1) string;
        pathPathway (1, 1) string;

        % Dependent table for GUI
        tableModelGUI table;

    end

    %% General methods
    methods

        function obj = ModelDocument(modelInput, options)

            arguments
                modelInput
                options.ModelRepository = ...
                    openmebius.infrastructure.model.ModelRepository()
                options.ReactionParser = openmebius.application.model ...
                    .ModelReactionParser()
                options.Validator = openmebius.application.model ...
                    .ModelWorkspaceValidator()
                options.NotificationEmitter (1, 1) ...
                    openmebius.application.notification ...
                    .NotificationEmitter = ...
                    openmebius.application.notification ...
                    .NotificationEmitter(Source = "ModelDocument")
            end

            modelLocation = ...
                openmebius.domain.model.ModelLocation.fromInput( ...
                modelInput);

            obj.ModelLocation = modelLocation;

            obj.ModelRepository = options.ModelRepository;
            obj.ReactionParser = options.ReactionParser;
            obj.Validator = options.Validator;
            obj.NotificationEmitter = options.NotificationEmitter;

            obj.ModelRepository.assertModelDirectory(modelLocation);

            updateMsg(obj, ...
                "The directory " + modelLocation.Directory + " exists.", ...
                "Info", ...
                obj.logLevel);

            setupTableInfo(obj);

            loadModel(obj);
            loadPathway(obj);

            parseModels(obj);
            throwIfConstructionFailed( ...
                obj, ...
                "OpenMebius2:ModelRepository:ModelParseFailed", ...
            "Failed to parse the metabolic model.");

            parseMS(obj);
            throwIfConstructionFailed( ...
                obj, ...
                "OpenMebius2:ModelRepository:MSParseFailed", ...
            "Failed to parse the mass spectrometry model.");

            listUpMetaboliteAll(obj);
            throwIfConstructionFailed( ...
                obj, ...
                "OpenMebius2:ModelRepository:MetaboliteBuildFailed", ...
            "Failed to build the metabolite list.");

            loadLabel(obj);
            createLabelView(obj);

        end % ModelDocument

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

        function tableModelGUI = get.tableModelGUI(obj)

            try
                % tableModelとtableXYを結合（列名で結合）
                tableModelGUI = join(obj.tableModel, obj.tableXY, 'Keys', 'RowNames');
            catch
                updateMsg(obj, "The tableModel and tableXY could not be joined.", "Error", obj.logLevel);
                tableModelGUI = table();
            end

        end % get.tableModelGUI

        function data = getPathwayData(obj)

            data = openmebius.application.model.ModelPathwayData();

            if ~obj.isPathwayLoaded || isempty(obj.imagePathway)
                return
            end

            modelTable = obj.tableModelGUI;

            if isempty(modelTable) || ...
                    ~all(ismember( ...
                    ["x", "y"], ...
                    string(modelTable.Properties.VariableNames))) || ...
                    isempty(modelTable.Properties.RowNames)
                data = openmebius.application.model.ModelPathwayData( ...
                    Image = obj.imagePathway);
                return
            end

            data = openmebius.application.model.ModelPathwayData( ...
                Image = obj.imagePathway, ...
                ReactionIDs = string(modelTable.Properties.RowNames), ...
                X = double(modelTable.x), ...
                Y = double(modelTable.y));

        end % getPathwayData

        function aggregate = snapshot(obj)
            aggregate = openmebius.domain.model.ModelAggregate( ...
                ModelTable = obj.getModelTableGUI(), ...
                MassSpectrometryTable = obj.getMSTable(), ...
                AtomTable = obj.getAtomTable(), ...
                BiomassTable = obj.getBiomassTable(), ...
                LabelTable = obj.getTableLabelView(), ...
                LabelConfiguration = obj.getLabelStructView(), ...
                Pathway = obj.getPathwayData(), ...
                InvalidModelRows = obj.getInvalidModelRowIdx(), ...
                InvalidMassSpectrometryRows = ...
                obj.getInvalidMSRowIdx(), ...
                InvalidAtomRows = obj.getInvalidAtomRowIdx());
        end

        function updatePathwayLabelPosition( ...
                obj, reactionID, position)

            arguments
                obj
                reactionID (1, 1) string
                position (1, 2) double
            end

            if strlength(strtrim(reactionID)) == 0
                error( ...
                    "OpenMebius2:PathwayLabel:ReactionRequired", ...
                "Please select a reaction.");
            end

            isRemoval = all(isnan(position));

            if ~isRemoval && any(~isfinite(position))
                error( ...
                    "OpenMebius2:PathwayLabel:InvalidPosition", ...
                "Pathway label coordinates must be finite values.");
            end

            reactionIDs = string(obj.tableXY.Properties.RowNames);
            row = find(reactionIDs == reactionID, 1);

            if isempty(row)
                error( ...
                    "OpenMebius2:PathwayLabel:ReactionNotFound", ...
                    "Reaction '%s' is not available in pathway positions.", ...
                    reactionID);
            end

            obj.tableXY{row, ["x", "y"]} = position;

        end % updatePathwayLabelPosition

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

        function loadLabel(obj)

            obj.structLabel = obj.ModelRepository.readLabel( ...
                obj.ModelLocation, ...
                obj.fileLabel, ...
                obj.fileTypeLabel);

            reset(obj);
            updateMsg(obj, ...
                obj.pathLabel + " is successfully imported.", ...
                "Info", ...
                obj.logLevel);

        end % loadLabel

        function exportLabel(obj)

            if ~isValidLabelStruct(obj)
                return;
            end

            convertLabelViewToStruct(obj);

            obj.ModelRepository.writeLabel( ...
                obj.ModelLocation, ...
                obj.fileLabel, ...
                obj.fileTypeLabel, ...
                obj.structLabel);

            reset(obj);
            updateMsg(obj, ...
                "The data is successfully exported to " + obj.pathLabel + ".", ...
                "Info", ...
                obj.logLevel);

        end % exportLabel

        function updateLabelConfiguration( ...
                obj, tableLabelView, structLabelView)

            arguments
                obj
                tableLabelView table
                structLabelView struct
            end

            obj.validateLabelConfiguration( ...
                tableLabelView, structLabelView);
            obj.tableLabelView = tableLabelView;
            obj.structLabelView = structLabelView;
            obj.exportLabel();

        end % updateLabelConfiguration

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
                error("OpenMebius2:ModelDocument:InvalidSplitFluxSize", ...
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

        function modelLocation = getModelLocation(obj)

            modelLocation = obj.ModelLocation;

        end % function getModelLocation

        function tableOut = getInfoTable(obj)

            tableOut = obj.tableInfo;

        end % function getInfoTable

        function tableOut = getModelTable(obj)

            tableOut = obj.tableModel;

        end % function getModelTable

        function tableOut = getParsedReactionTable(obj)

            tableOut = obj.modelRxn;

        end % function getParsedReactionTable

        function tableOut = getParsedTransitionTable(obj)

            tableOut = obj.modelTrans;

        end % function getParsedTransitionTable

        function [fileName, fileType] = getModelFileDescriptor(obj)

            fileName = obj.fileModel;
            fileType = obj.fileTypeModel;

        end % function getModelFileDescriptor

        function path = getModelFilePath(obj)

            path = obj.pathModel;

        end % function getModelFilePath

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

            if hasValidationErrors(obj)
                return;
            end

            parseMS(obj);

            if hasValidationErrors(obj)
                return;
            end

            listUpMetaboliteAll(obj);

        end % function reconstructModel

        function report = updateModelTableGUI(obj, tableIn)

            reset(obj);
            obj.errorColumnsModel = [];

            try
                tableModelIn = tableIn(:, ["Reaction", "Transition", "Independent"]);
                tableXYIn = tableIn(:, ["x", "y"]);
            catch
                recordValidationError( ...
                    obj, ...
                "The table is not in the correct format.");
                report = createValidationReport( ...
                    obj, ...
                    "", ...
                    obj.errorColumnsModel);
                return;
            end

            obj.tableModel = tableModelIn;
            obj.tableXY = tableXYIn;

            reconstructModel(obj);

            report = createValidationReport( ...
                obj, ...
                "The model table has been updated successfully.", ...
                obj.errorColumnsModel);

            if report.IsValid
                saveModel(obj);
            end

        end % function updateModelTable

        function setReactionIndependent(obj, reactionID, independent)

            arguments
                obj
                reactionID (1, 1) string
                independent (1, 1) logical
            end

            rowNames = string(obj.modelRxn.Properties.RowNames);
            index = find(rowNames == reactionID, 1);

            if isempty(index)
                error("Reaction ID was not found: %s.", reactionID);
            end

            obj.modelRxn.Independent(index) = independent;
            obj.tableModel.Independent(index) = independent;

        end % function setReactionIndependent

        function report = updateMSTable(obj, tableIn)

            reset(obj);
            obj.errorColumnsMS = [];

            try
                tableMSIn = tableIn(:, ["Reaction", "Transition"]);
            catch
                recordValidationError( ...
                    obj, ...
                "The table is not in the correct format.");
                report = createValidationReport( ...
                    obj, ...
                    "", ...
                    obj.errorColumnsMS);
                return;
            end

            if any(strcmp(tableIn.Properties.VariableNames, "Used"))
                tableMSIn.Used = normalizeMSUsedColumn(obj, tableIn.Used, height(tableMSIn));
            else
                tableMSIn.Used = true(height(tableMSIn), 1);
                recordValidationWarning( ...
                    obj, ...
                    "The MS table does not contain the 'Used' column. " + ...
                "A default 'Used=true' column has been added.");
            end

            obj.tableMS = tableMSIn;
            reconstructModel(obj);

            report = createValidationReport( ...
                obj, ...
                "The MS table has been updated successfully.", ...
                obj.errorColumnsMS);

            if report.IsValid
                saveModel(obj);
            end

        end % method updateMSTable

        function report = updateAtomTable(obj, tableIn)

            reset(obj);
            obj.errorColumnsAtom = [];

            try
                obj.tableAtom = tableIn;
            catch
                recordValidationError( ...
                    obj, ...
                "The table is not in the correct format.");
                report = createValidationReport( ...
                    obj, ...
                    "", ...
                    obj.errorColumnsAtom);
                return;
            end

            [tf, errcols] = isValidAtomTable(obj, obj.tableAtom);

            if ~tf
                obj.errorColumnsAtom = errcols;
                recordValidationError( ...
                    obj, ...
                "The Atom table contains invalid values.");
                report = createValidationReport( ...
                    obj, ...
                    "", ...
                    obj.errorColumnsAtom);
                return;
            end

            reconstructModel(obj);

            report = createValidationReport( ...
                obj, ...
                "The atom table has been updated successfully.", ...
                obj.errorColumnsAtom);

            if report.IsValid
                saveModel(obj);
            end

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
            if obj.fileTypeModel ~= "xlsx"
                error( ...
                    "OpenMebius2:ModelRepository:" + ...
                    "UnsupportedModelFileType", ...
                    "The file type %s is not supported.", ...
                    obj.fileTypeModel);
            end

            for i = 1:length(obj.tableList)

                obj.(obj.tableList(i)) = ...
                    obj.ModelRepository.readModelSheet( ...
                    obj.ModelLocation, ...
                    obj.fileModel, ...
                    obj.fileTypeModel, ...
                    obj.tableSheetNames(i), ...
                    ReadRowNames = obj.tableReadRowName(i), ...
                    RefVariableNames = ...
                    obj.tableVariableNames.(obj.tableLabelNames(i)), ...
                    RefTypes = obj.tableTypes.(obj.tableLabelNames(i)));

                reset(obj);
                updateMsg(obj, ...
                    obj.pathModel + "/" + obj.tableSheetNames(i) + ...
                    " is successfully imported.", ...
                    "Info", ...
                    obj.logLevel);

            end % for

        end % loadModel

        function loadPathway(obj)

            try
                obj.imagePathway = obj.ModelRepository.readPathwayImage( ...
                    obj.ModelLocation, ...
                    obj.filePathway, ...
                    obj.fileTypePathway);
                obj.isPathwayLoaded = true;
            catch ME
                updateMsg(obj, string(ME.message), "Error", obj.logLevel);
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

            convertedLabel = struct();

            for i = 1:numLabel

                labelFieldName = labelFieldNames{i};
                ratioFieldName = ratioFieldNames{i};

                convertedLabel.(labelFieldName).name = label.Name{i};
                convertedLabel.(labelFieldName).num = label.Num{i};
                convertedLabel.(labelFieldName).label = ...
                    ratio.(ratioFieldName).Label;
                convertedLabel.(labelFieldName).ratio = ...
                    ratio.(ratioFieldName).Ratio;

            end % for

            app.structLabel = convertedLabel;

        end % convertLabelViewToStruct

        function validateLabelConfiguration(obj, labelTable, ratioTables)
            obj.Validator.validateLabelConfiguration(labelTable, ratioTables);
        end % validateLabelConfiguration

        function label = makeStructLabel(~, input)

            label = matlab.lang.makeValidName(input);
            label = matlab.lang.makeUniqueStrings(label);

        end % makeStructLabel

        function [tf, errcols] = isValidAtomTable(obj, tableAtom)
            [tf, errcols] = obj.Validator.validateAtomTable(tableAtom);
        end % isValidAtomTable

        % TODO: Implement the function
        function tf = isValidLabelStruct(~)

            tf = true;

        end % isValidLabelStruct

        % TODO: Implement the function
        function tf = isValidLabelDigits(~, ~, ~)

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

            if hasValidationErrors(obj)
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

            if hasValidationErrors(obj)
                return;
            end

            updateMsg(obj, "The mass spectrometry models have been parsed successfully.", "Info", obj.logLevel);

        end % parseMS

        function [react, product, rev, err] = parseReaction(obj, rxnCol)

            arguments
                obj;
                rxnCol cell;
            end

            result = obj.ReactionParser.parse(rxnCol);
            react = result.Reactants;
            product = result.Products;
            rev = result.Reversible;
            err = result.ErrorRows;

            for message = result.Errors.'
                recordValidationError(obj, message);
            end

            if ~isempty(result.Errors)
                return
            end

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
                        recordValidationError( ...
                            obj, ...
                            "The metabolite in the reaction " + ...
                            iRxn + " is empty.");
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
                            msg = "The carbon transition of " + reaction{iRxn}{iMetabolite} + " is not defined.";
                            recordValidationError(obj, msg);
                            err = [err, iRxn]; %#ok<AGROW>
                            iNumC = 0;
                        end

                        if numCarbon ~= iNumC
                            msg = "The number of carbon in " + reaction{iRxn}{iMetabolite} + " is not consistent.";
                            recordValidationError(obj, msg);
                            err = [err, iRxn]; %#ok<AGROW>
                        end

                    elseif sum(ismember(reaction{iRxn}{iMetabolite}, metabolite(:, 1))) == 0

                        try
                            iNumC = numel(transition{iRxn}{iMetabolite});
                        catch
                            msg = "The carbon transition of " + reaction{iRxn}{iMetabolite} + " is not defined.";
                            recordValidationError(obj, msg);
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
                recordValidationWarning( ...
                    obj, ...
                    "The MS table 'Used' column could not be converted " + ...
                "to logical values. All fragments are selected.");
            end

        end % method normalizeMSUsedColumn

        %% Save functions
        function saveModel(obj)

            tables = cell(1, numel(obj.tableList));

            for tableIndex = 1:numel(obj.tableList)
                tables{tableIndex} = obj.(obj.tableList(tableIndex));
            end

            obj.ModelRepository.writeModelSheets( ...
                obj.ModelLocation, ...
                obj.fileModel, ...
                obj.fileTypeModel, ...
                obj.tableSheetNames, ...
                tables, ...
                obj.tableReadRowName);

            updateMsg( ...
                obj, ...
                "The data is successfully exported to " + ...
                obj.pathModel + ".", ...
                "Info", ...
                obj.logLevel);

        end % saveModel

    end % methods (private)

    methods (Access = protected)

        function updateMsg(obj, text, level, ~)

            obj.NotificationEmitter.report( ...
                lower(string(level)), ...
                string(text), ...
                Code = "model.document", ...
                Audience = "developer", ...
                Kind = "diagnostic");

        end % updateMsg

        function reset(obj)

            obj.ValidationErrors = strings(0, 1);
            obj.ValidationWarnings = strings(0, 1);

        end % reset

        function recordValidationError(obj, message)

            message = string(message);
            obj.ValidationErrors(end + 1, 1) = message;
            updateMsg(obj, message, "Error", obj.logLevel);

        end % recordValidationError

        function recordValidationWarning(obj, message)

            message = string(message);
            obj.ValidationWarnings(end + 1, 1) = message;
            updateMsg(obj, message, "Warning", obj.logLevel);

        end % recordValidationWarning

        function tf = hasValidationErrors(obj)

            tf = ~isempty(obj.ValidationErrors);

        end % hasValidationErrors

        function report = createValidationReport( ...
                obj, successMessage, invalidRows)

            arguments
                obj
                successMessage (1, 1) string
                invalidRows double = zeros(0, 1)
            end

            warnings = unique(obj.ValidationWarnings, "stable");

            if hasValidationErrors(obj)
                errorMessage = join( ...
                    unique(obj.ValidationErrors, "stable"), ...
                    newline);
                report = openmebius.domain.model ...
                    .ModelValidationReport.failure( ...
                    errorMessage, ...
                    Warnings = warnings, ...
                    InvalidRows = invalidRows(:));
                return
            end

            if successMessage ~= ""
                updateMsg(obj, successMessage, "Info", obj.logLevel);
            end

            report = openmebius.domain.model ...
                .ModelValidationReport.success( ...
                successMessage, ...
                Warnings = warnings, ...
                InvalidRows = invalidRows(:));

        end % createValidationReport

        function throwIfConstructionFailed(obj, identifier, fallbackMessage)

            arguments
                obj
                identifier (1, 1) string
                fallbackMessage (1, 1) string
            end

            if ~hasValidationErrors(obj)
                return
            end

            message = join( ...
                unique(obj.ValidationErrors, "stable"), ...
                newline);

            if message == ""
                message = fallbackMessage;
            end

            error(identifier, "%s", message);

        end % throwIfConstructionFailed

    end % methods (Access = protected)

end % classdef
