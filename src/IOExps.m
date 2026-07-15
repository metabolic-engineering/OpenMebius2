classdef IOExps < handle

    properties (Access = public)

        fileExpList (1, :) string = strings(1, 0);
        dataExp (1, :) = struct;
        % "tableInfo", table, ...
        % "tableSubstrate", table, ...
        % "tableMS", table ...
        % "tableMSNormalized", table, ...
        fieldNames string = strings(1, 0);
        pathModel (1, 1) string = "";
        ExperimentLocation openmebius.domain.experiment.ExperimentLocation

        tableExpsInfo table;
        tableTracersInfoFull table;
        tableTracersInfo table;
        tableUptakesInfoFull table;
        tableUptakesInfo table;
        tableAtom table;

        objModel;

        defaultVariableNamesListSubstrate string;
        defaultVariableTypesListSubstrate string;

    end % properties

    properties (Access = private)

        ExperimentRepository
        MessagePublisher
        ValidationErrors (:, 1) string = strings(0, 1)
        ValidationWarnings (:, 1) string = strings(0, 1)

    end % properties

    properties (Access = protected)
        logLevel (1, 1) string = "Info"
    end

    properties (Dependent)

        numFile (1, 1) double;

        fileListWOExt (1, :) string;

    end % properties

    methods

        function obj = IOExps(experimentInput, modelInput, options)

            arguments
                experimentInput
                modelInput = []
                options.ExperimentRepository = ...
                    openmebius.infrastructure.experiment.ExperimentRepository()
                options.AllowEmpty (1, 1) logical = false
            end

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromInput( ...
                experimentInput);

            obj.ExperimentLocation = experimentLocation;
            obj.ExperimentRepository = options.ExperimentRepository;
            obj.MessagePublisher = openmebius.presentation ...
                .notification.GeneralMessagePublisher( ...
                LogLevel = obj.logLevel);

            obj.ExperimentRepository.assertExperimentDirectory( ...
                experimentLocation);

            updateMsg(obj, ...
                "The directory " + experimentLocation.Directory + ...
                " exists.", ...
                "Info", ...
                obj.logLevel);

            loadExpData( ...
                obj, ...
                modelInput, ...
                AllowEmpty = options.AllowEmpty);

        end % constructor

        function numFile = get.numFile(obj)

            numFile = length(obj.fileExpList);

        end % get.numFile

        function fileListWOExt = get.fileListWOExt(obj)

            fileListWOExt = erase(obj.fileExpList, ".xlsx");

        end % get.fileListWOExt

        %% Public general methods
        function loadExpData(obj, modelInput, options)

            arguments
                obj IOExps
                modelInput = []
                options.AllowEmpty (1, 1) logical = false
            end

            resetValidation(obj);

            if isempty(modelInput)

                if ~isempty(obj.objModel)
                    modelInput = obj.objModel;
                else
                    modelInput = obj.pathModel;
                end

            end

            obj.fileExpList = obj.ExperimentRepository.listWorkbooks( ...
                obj.ExperimentLocation, ...
                "xlsx");
            obj.fieldNames = matlab.lang.makeValidName(obj.fileExpList);

            if isempty(obj.fileExpList)
                if options.AllowEmpty
                    [obj.objModel, obj.pathModel] = ...
                        obj.resolveModelInput(modelInput);
                    obj.tableAtom = obj.objModel.tableAtom;
                    obj.dataExp = struct;
                    obj.tableExpsInfo = table();
                    obj.tableTracersInfoFull = table();
                    obj.tableTracersInfo = table();
                    obj.tableUptakesInfoFull = table();
                    obj.tableUptakesInfo = table();
                    return
                end

                recordValidationError( ...
                    obj, ...
                    "The experiment file does not exist.");
                throwIfValidationFailed( ...
                    obj, ...
                    "OpenMebius2:IOExps:ExperimentFileNotFound", ...
                    "The experiment file does not exist.");
            end

            [obj.objModel, obj.pathModel] = obj.resolveModelInput(modelInput);

            obj.tableAtom = obj.objModel.tableAtom;

            loadExpFiles(obj);

            combineInfoData(obj);
            combineTraceData(obj);
            combineUptakeData(obj);

        end % loadExpData

        function report = updateExpData(obj, data, type)
            % UPDATEEXPDATA: Update the experimental data
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % expName: (1, 1) string
            %     The name of the experiment.
            % data: table
            %     The data to be updated.
            % type: (1, 1) string
            %     The type of the data to be updated.
            %     Options: "Info", "Tracer", "Uptake"

            arguments
                obj IOExps
                data
                type (1, 1) string {mustBeMember(type, ["Info", "Tracer", "Uptake"])}
            end % arguments

            resetValidation(obj);

            % Validate the input data
            if isempty(data) || ~istable(data)
                recordValidationError( ...
                    obj, ...
                    "The data is empty or not a table.");
                report = createValidationReport(obj, "");
                return;
            end

            status = false;

            switch type
                case "Info"
                    % Update the info table
                    status = updateTableExpInfo(obj, data);
                case "Tracer"
                    % Update the tracer table
                    data = normalizeUITableInput(obj, data, type);
                    isValid = isValidTracerData(obj, data);

                    if ~isValid
                        recordValidationError( ...
                            obj, ...
                            "The tracer data is not valid.");
                        status = true;
                    end

                    if ~status
                        status = updateTableExpSubstrate(obj, data);
                    end
                case "Uptake"
                    % Update the uptake table
                    data = normalizeUITableInput(obj, data, type);
                    status = updateTableExpUptake(obj, data);
                otherwise
                    error("Invalid type. Use 'Info', 'Tracer', or 'Uptake'.");
            end

            if status && isempty(obj.ValidationErrors)
                recordValidationError( ...
                    obj, ...
                    "The " + lower(type) + ...
                    " experiment data is not valid.");
            end

            report = createValidationReport( ...
                obj, ...
                type + " experiment data updated successfully.");

        end % updateExpData

        function importExpData(obj, fileDir, options)
            % IMPORTEXPDATA: Import experimental data from a directory
            %
            % Parameters
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % fileDir: (1, 1) string
            %     The directory containing the experimental data files.

            arguments
                obj IOExps
                fileDir (1, 1) string
                options.type (1, 1) string {mustBeMember(options.type, ["xlsx", "csv"])} = "xlsx"
                options.sheet (1, 1) string = "MS_raw"
            end % arguments

            sourceLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromInput( ...
                fileDir);
            obj.ExperimentRepository.assertExperimentDirectory( ...
                sourceLocation);

            obj.fileExpList = obj.ExperimentRepository.listWorkbooks( ...
                sourceLocation, ...
                options.type);
            obj.fieldNames = matlab.lang.makeValidName(obj.fileExpList);

            for i = 1:length(obj.fileExpList)

                fileExp = obj.fileExpList(i);
                fieldName = obj.fieldNames(i);

                pathFile = sourceLocation.workbookFile(fileExp);
                structName = fieldName;

                objExp = IOExp( ...
                    pathFile, ...
                    ExperimentRepository = obj.ExperimentRepository);

                obj.dataExp.(structName).tableInfo = objExp.tableInfo;
                obj.dataExp.(structName).tableSubstrate = objExp.tableSubstrate;
                obj.dataExp.(structName).tableMS = objExp.tableMS;

                % Keep previously calculated MDV-derived sheets from the
                % imported workbook when they exist.  Importing must not
                % trigger a recalculation.
                loadStoredDerivedTables( ...
                    obj, ...
                    objExp, ...
                    structName ...
                );

            end % for i

        end % importExpData

        function report = saveExpData(obj)

            resetValidation(obj);

            if isempty(obj.tableExpsInfo)
                recordValidationError(obj, "The data is empty.");
                report = createValidationReport(obj, "");
                return
            end

            for i = 1:length(obj.fileExpList)

                fieldName = obj.fieldNames(i);
                name = getExpName(obj, i);

                try
                    objExp = IOExp( ...
                        obj.ExperimentLocation.workbookFile( ...
                        obj.fileExpList(i)), ...
                        ExperimentRepository = obj.ExperimentRepository);

                    objExp.tableInfo = obj.dataExp.(fieldName).tableInfo;
                    objExp.tableSubstrate = ...
                        obj.dataExp.(fieldName).tableSubstrate;
                    objExp.tableMS = obj.dataExp.(fieldName).tableMS;

                    % Derived tables are persisted only when already loaded
                    % or explicitly applied by the calculation service.
                    objExp.tableMSNormalized = getStoredTableOrEmpty( ...
                        obj, fieldName, "tableMSNormalized");
                    objExp.tableMDV = getStoredTableOrEmpty( ...
                        obj, fieldName, "tableMDV");
                    objExp.tableMDVBiomass = getStoredTableOrEmpty( ...
                        obj, fieldName, "tableMDVBiomass");
                    objExp.tableEnrichment = getStoredTableOrEmpty( ...
                        obj, fieldName, "tableEnrichment");

                    objExp.saveExcelData();
                    updateMsg( ...
                        obj, name + " is saved.", "Info", obj.logLevel);
                catch ME
                    recordValidationError( ...
                        obj, ...
                        name + " is not saved. " + string(ME.message));
                end

                clear objExp;

            end

            report = createValidationReport( ...
                obj, ...
                "Save operation completed successfully.");

        end % saveExpData

        function tableTracer = createTracerTable(obj)

            tableTracer = createExperimentVsSubstrateTable(obj, "Label");

        end % createTracerTable

        function tableUptake = createUptakeTable(obj)

            tableUptake = createExperimentVsSubstrateTable(obj, "Uptake");

        end % createUptakeTable

        function tableRtn = createTableTracerConfig(obj, xy)
            % CREATETABLETRACERCONFIG: Create a table for the tracer configuration
            %
            % INPUT:
            %   xy double (1, 2)
            %     The x and y coordinates of the tracer table.
            %
            % OUTPUT:
            %   tableRtn table
            %     The table for the tracer configuration.

            % Get the tracer information
            tableTracer = obj.tableTracersInfo;

            numXY = size(tableTracer);

            if xy(2) > numXY(2)
                error("The xy coordinates are out of range.");
            end

            if xy(1) > numXY(1)
                label = tableTracer{1, xy(2)}{:};
            elseif ismissing(tableTracer{xy(1), xy(2)})
                label = '';
            else
                label = tableTracer{xy(1), xy(2)}{:};
            end

            availableTracer = createAvailableTracer(obj, xy);
            numAvailableTracer = length(availableTracer);

            vars = {'Select', 'Label', 'Ratio'};

            tableAvailableTracer = table( ...
                'Size', [numAvailableTracer 3], ...
                'VariableTypes', {'logical', 'string', 'double'}, ...
                'VariableNames', vars);

            tableAvailableTracer.Select = false(numAvailableTracer, 1);
            tableAvailableTracer.Label = availableTracer;

            if isempty(label)
                tableRtn = tableAvailableTracer;
                return;
            end

            tableRtn = parseLabelPattern(obj, label, tableAvailableTracer);

        end % tableTracerConfig

        function cellRtn = createAvailableTracer(obj, xy)

            tableTracer = obj.tableTracersInfo;
            substrates = tableTracer.Properties.VariableNames;
            substrate = substrates{xy(2)};
            tableSubstrates = obj.objModel.getSubstrateTable();

            % Metaboliteがsubstrateと一致する行をテーブルから取得
            tableSubstrate = tableSubstrates(strcmp(tableSubstrates.Metabolite, substrate), :);
            numCarbon = tableSubstrate.Carbon{:};

            % Get the tableLabelView from the model class
            tableLabelView = obj.objModel.tableLabelView;

            tableLabelViewFiltered = tableLabelView(cell2mat(tableLabelView.Num) == numCarbon, :);

            cellRtn = tableLabelViewFiltered.Name;

        end % createAvailableTracer

        function label = disparseLabelPattern(~, table)
            % DISPARSELABELPATTERN: Convert table of labels and ratios to text
            %
            % INPUT:
            %   table table
            %     The table of labels and ratios.
            %
            % OUTPUT:
            %   label string
            %     The label pattern as a text string.

            % Initialize an empty cell array to store label patterns

            tableFiltered = table(table.Select, :);

            if size(tableFiltered, 1) == 1
                tableNonZero = tableFiltered;
                tableNonZero.Ratio = 1;
            else
                tableNonZero = tableFiltered(tableFiltered.Ratio ~= 0, :);
            end

            cellLabelPattern = cell(height(tableNonZero), 1);

            % Iterate over each row of the table
            for i = 1:height(tableNonZero)
                % Extract the label and ratio
                iLabel = tableNonZero.Label{i};
                iRatio = tableNonZero.Ratio(i);

                % Combine label and ratio into a single string
                cellLabelPattern{i} = sprintf('%s~%g', iLabel, iRatio);
            end

            % Combine all label patterns into a single string separated by semicolons
            label = strjoin(cellLabelPattern, ';');

        end % disparseLabelPattern

    end % methods (Access = public)

    methods (Access = public)

        %% Public getter methods
        function expList = getExpList(obj)

            expList = obj.fileListWOExt;

        end % getExpList

        function expName = getExpName(obj, idx)

            expName = obj.fileListWOExt(idx);

        end % getExpName

        function expIdx = getExpIdx(obj, expName)

            expIdx = find(ismember(obj.fileListWOExt, expName));

        end % getExpIdx

        function model = getModel(obj)
            % GETMODEL: Get the model object
            %
            % Returns:
            % --------
            % model: IOModel
            %     The model object.
            model = obj.objModel;

        end % getModel

        function experimentLocation = getExperimentLocation(obj)

            experimentLocation = obj.ExperimentLocation;

        end % getExperimentLocation

        function tableInfo = getInfoTable(obj)
            % GETINFOTABLE: Get the information table of the experiments
            %
            % Returns:
            % --------
            % tableInfo: table
            %     The information table of the experiments.

            if isempty(obj.tableExpsInfo)
                updateMsg(obj, "The data is empty.", "Info", obj.logLevel);
                tableInfo = table;
                return;
            end

            tableInfo = obj.tableExpsInfo;

        end % getInfoTable

        function tableUptake = getUptakeTable(obj)
            % GETUPTAKETABLE: Get the uptake table of the experiments
            %
            % Returns:
            % --------
            % tableUptake: table
            %     The uptake table of the experiments.

            if isempty(obj.tableUptakesInfo)
                updateMsg(obj, "The data is empty.", "Info", obj.logLevel);
                tableUptake = table;
                return;
            end

            tableUptake = obj.tableUptakesInfo;

        end % getUptakeTable

        function tableTracer = getTracerTable(obj)
            % GETTRACERTABLE: Get the tracer table of the experiments
            %
            % Returns:
            % --------
            % tableTracer: table
            %     The tracer table of the experiments.

            if isempty(obj.tableTracersInfo)
                updateMsg(obj, "The data is empty.", "Info", obj.logLevel);
                tableTracer = table;
                return;
            end

            tableTracer = obj.tableTracersInfo;

        end % getTracerTable

        function tableMS = getMSTable(obj, expName)

            idx = getExpIdx(obj, expName);

            if isempty(idx)
                updateMsg(obj, "The experiment name is not found.", "Error", obj.logLevel);
                tableMS = table();
                return;
            end

            fieldName = obj.fieldNames(idx);
            tableMS = obj.dataExp.(fieldName).tableMS;

        end % getMSData

        function tableMSNormalized = getMSNormalizedTable(obj, expName)

            idx = getExpIdx(obj, expName);

            if isempty(idx)
                updateMsg(obj, "The experiment name is not found.", "Error", obj.logLevel);
                tableMSNormalized = table();
                return;
            end

            fieldName = obj.fieldNames(idx);

            try
                tableMSNormalized = obj.dataExp.(fieldName).tableMSNormalized;
            catch ME
                updateMsg(obj, "The MS normalized table is not found.", "Error", obj.logLevel);
                tableMSNormalized = table();
            end

        end % getMSNormalizedTable

        function tableRtn = getMSNormalizedComparison(obj, fragName)
            % GETMSNORMALIZEDCOMPARISON: Get the comparison view of MS
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % fragName: string
            %     Fragment name (Ala59, Asx302...)
            %
            % Returns:
            % --------
            % tableMSNormalized: table
            %     The MS normalized data.

            arguments
                obj IOExps
                fragName (1, 1) string
            end

            numData = length(obj.fieldNames);
            expList = obj.getExpList;
            tableRtn = table();

            for i = 1:numData

                iTableMS = getMSNormalizedTable(obj, expList(i));
                iTableMS = iTableMS(:, fragName);
                iTableMS.Properties.VariableNames = expList(i);
                iRowNames = iTableMS.Properties.RowNames;
                iTableMS.RowNamesTemp = iRowNames;

                if isempty(tableRtn)
                    tableRtn = iTableMS;
                    continue
                end % if

                tableRtn = outerjoin( ...
                    tableRtn, ...
                    iTableMS, ...
                    'Keys', "RowNamesTemp", ...
                    'MergeKeys', true ...
                );

            end % for i

            tableRtn = removevars(tableRtn, "RowNamesTemp");

            isAllNaNOrZero = all(isnan(tableRtn{:, :}) | tableRtn{:, :} == 0, 2);
            tableRtn(isAllNaNOrZero, :) = [];

        end % getMSNormalizedComparison

        function tableMDV = getMDVTable(obj, expName)

            idx = getExpIdx(obj, expName);

            if isempty(idx)
                updateMsg(obj, "The experiment name is not found.", "Error", obj.logLevel);
                tableMDV = table();
                return;
            end

            fieldName = obj.fieldNames(idx);

            try
                tableMDV = obj.dataExp.(fieldName).tableMDV;
            catch ME
                updateMsg(obj, "The MDV table is not found.", "Error", obj.logLevel);
                tableMDV = table();
            end

        end % getMDVTable

        function [tableMDVBiomass, err] = getMDVBiomassTable(obj, expName)

            idx = getExpIdx(obj, expName);

            if isempty(idx)
                updateMsg(obj, "The experiment name is not found.", "Error", obj.logLevel);
                tableMDVBiomass = table();
                err = [];
                return;
            end

            fieldName = obj.fieldNames(idx);

            try
                tableMDVBiomass = obj.dataExp.(fieldName).tableMDVBiomass;
                err = obj.dataExp.(fieldName).errMDV;
            catch ME
                updateMsg(obj, "The MDV biomass table is not found.", "Error", obj.logLevel);
                tableMDVBiomass = table();
                err = [];
            end

        end % getMDVBiomassTable

        function tableRtn = getMDVBiomassComparison(obj, fragName)
            % GETMDVBIOMASSCOMPARISON: Get the comparison view of MDV
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % fragName: string
            %     Fragment name (Ala59, Asx302...)
            %
            % Returns:
            % --------
            % tableMSNormalized: table
            %     The MS normalized data.

            arguments
                obj IOExps
                fragName (1, 1) string
            end

            numData = length(obj.fieldNames);
            expList = obj.getExpList;
            tableRtn = table();

            for i = 1:numData

                iTableMS = getMDVBiomassTable(obj, expList(i));
                iTableMS = iTableMS(:, fragName);
                iTableMS.Properties.VariableNames = expList(i);
                iRowNames = iTableMS.Properties.RowNames;
                iTableMS.RowNamesTemp = iRowNames;

                if isempty(tableRtn)
                    tableRtn = iTableMS;
                    continue
                end % if

                tableRtn = outerjoin( ...
                    tableRtn, ...
                    iTableMS, ...
                    'Keys', "RowNamesTemp", ...
                    'MergeKeys', true ...
                );

            end % for i

            tableRtn = removevars(tableRtn, "RowNamesTemp");

            isAllNaNOrZero = all(isnan(tableRtn{:, :}) | tableRtn{:, :} == 0, 2);
            tableRtn(isAllNaNOrZero, :) = [];

        end % getMDVBiomassComparison

        function [tableEnrichment, err] = getEnrichmentTable(obj, expName)
            % GETENRICHMENTTABLE: Get the enrichment table of the experiments
            %
            % Definition:
            % The 13C-enrichment of the metabolite X is a measure of the
            % fraction of the metabolite that is labeled with 13C isotopes.
            % The 13C-enrichment of the metabolite X is calculated as:
            %
            % enrichment_X = \sum_{i=0}^{n} (MDV_i * i) / n
            %
            % where MDV_i is i-th column of the mass distribution vector (MDV) of the metabolite X,
            % and n is the number of carbon atoms in the metabolite X.
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % expName: (1, 1) string
            %     The name of the experiment.
            %
            % Returns:
            % --------
            % tableEnrichment: table
            %     The enrichment table of the experiments.

            idx = getExpIdx(obj, expName);

            if isempty(idx)
                updateMsg(obj, "The experiment name is not found.", "Error", obj.logLevel);
                tableEnrichment = table();
                return;
            end

            fieldName = obj.fieldNames(idx);

            try
                tableEnrichment = obj.dataExp.(fieldName).tableEnrichment;
                err = obj.dataExp.(fieldName).errEnrichment;
            catch ME
                updateMsg(obj, "The enrichment table is not found.", "Error", obj.logLevel);
                tableEnrichment = table();
                err = [];
            end

        end % getEnrichmentTable

        function [tableRtn, tableRtnErr] = getEnrichmentComparison(obj)
            % GETENRICHMENTCOMPARISON: Get the enrichment comparison table
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            %
            % Returns:
            % --------
            % tableRtn: table
            %     The enrichment comparison table.
            % tableRtnErr: logical
            %     The error flag for the enrichment comparison table.
            %     true if there is an error, false otherwise.

            arguments
                obj IOExps
            end % arguments

            [tableRtn, tableRtnErr] = combineEnrichmentData(obj);

        end % getEnrichmentComparison

        function tableRtn = getFragmentSelection(obj, expName)
            % GETFRAGMENTSELECTION: Return the table of fragment selection
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % expName: (1, 1) string
            %     The name of the experiment.
            %
            % Returns:
            % --------
            % tableRtn: table
            %     The table of fragment selection.
            %     - Select: logical
            %         true if user selected the this fragment, false otherwise.
            %     - Available: logical
            %         true if the fragment is available in the experiment, false otherwise.
            %
            % Example:
            % --------
            % >> obj.getFragmentSelection("wt_1")
            %         | Select | Available |
            %         |--------|-----------|
            %  Ala159 |  false |   true    |
            %  Asx302 |  true  |   false   |
            %  ...    |  ...   |   ...     |

            idx = getExpIdx(obj, expName);

            if isempty(idx)
                updateMsg( ...
                    obj, ...
                    "The experiment name is not found.", ...
                    "Error", ...
                    obj.logLevel);
                tableRtn = table();
                return
            end

            fieldName = obj.fieldNames(idx);

            if ~isfield(obj.dataExp.(fieldName), "tableSelection")
                updateMsg( ...
                    obj, ...
                    "The fragment selection table is not found.", ...
                    "Error", ...
                    obj.logLevel);
                tableRtn = table();
                return
            end

            tableRtn = obj.dataExp.(fieldName).tableSelection;

        end % getFragmentSelection

        function [tableRtnSelect, tableRtnAvailable] = getSelectionComparison(obj)
            % GETSELECTIONCOMPARISON: Get the selection comparison table
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            %
            % Returns:
            % --------
            % tableRtnSelect: table
            %     The selection comparison table.
            % tableRtnAvailable: table
            %     The available selection table.

            arguments
                obj IOExps
            end % arguments

            [tableRtnSelect, tableRtnAvailable] = combineSelectionData(obj);
        end % getSelectionComparison

        %% Public update methods
        function updateModel(obj, model)
            % UPDATEMODEL: Update the model object
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % model: IOModel
            %     The model object.

            arguments
                obj IOExps
                model IOModel
            end

            obj.objModel = model;
            obj.tableAtom = model.tableAtom;

        end % updateModel

        function status = updateTableExpInfo(obj, tableInfo)
            % UPDATETABLEEXPINFO: Update the table of experimental information
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % tableInfo: table
            %     The table of experimental information.

            arguments
                obj IOExps
                tableInfo table
            end

            status = false;

            % Validate the input table
            if isempty(tableInfo) || ~istable(tableInfo)
                recordValidationError( ...
                    obj, ...
                    "The table is empty or not a table.");
                status = true;
                return;
            end

            % Check if the table has the same number of rows as the number of experiments
            variables = tableInfo.Properties.VariableNames;
            variablesCorrect = ["mu", "ODi", "ODf"];

            if ~isequal(variables, variablesCorrect)
                recordValidationError( ...
                    obj, ...
                    "The table does not have the correct variable names.");
                status = true;
                return;
            end

            obj.tableExpsInfo = tableInfo;
            substituteInfoTable(obj, tableInfo);

        end % updateTableExpInfo

        function status = updateTableExpSubstrate(obj, tableSubstrate)
            % UPDATETABLEEXPSUBSTRATE: Update the table of experimental substrates
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % tableSubstrate: table
            %     The table of experimental substrates.
            %
            % Returns:
            % --------
            % status: logical
            %     The status of the update operation.
            %     true if the update was successful, false otherwise.

            arguments
                obj IOExps
                tableSubstrate table
            end

            status = false;

            % Validate the input table
            if isempty(tableSubstrate) || ~istable(tableSubstrate)
                recordValidationError( ...
                    obj, ...
                    "The table is empty or not a table.");
                status = true;
                return;
            end

            % Check if the table has the same number of rows as the number of experiments
            variables = tableSubstrate.Properties.VariableNames;
            variablesCorrect = obj.tableTracersInfo.Properties.VariableNames;

            if ~isequal(variables, variablesCorrect)
                recordValidationError( ...
                    obj, ...
                    "The table does not have the correct variable names.");
                status = true;
                return;
            end

            % Check if the table has the same number of rows as the number of experiments
            sample = string(tableSubstrate.Properties.RowNames)';
            sampleCorrect = obj.fileListWOExt;

            if ~isequal(sort(sample(:)), sort(sampleCorrect(:)))
                recordValidationError( ...
                    obj, ...
                    "The table does not have the correct sample names.");
                status = true;
                return;
            end

            if ~isValidTracerData(obj, tableSubstrate)
                recordValidationError( ...
                    obj, ...
                    "The tracer data is not valid.");
                status = true;
                return;
            end

            % Update the table of experimental substrates
            obj.tableTracersInfo = tableSubstrate;
            err = substituteLabelUptakeTable(obj, tableSubstrate, "Label");

            if err
                recordValidationError( ...
                    obj, ...
                    "The table of experimental substrates is not valid.");
                status = true;
                return;
            end

        end % updateTableExpSubstrate

        function status = updateTableExpUptake(obj, tableUptake)
            % UPDATETABLEEXPSUBSTRATE: Update the table of experimental substrates
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % tableUptake: table
            %     The table of experimental substrates.
            %
            % Returns:
            % --------
            % status: logical
            %     The status of the update operation.
            %     true if the update was successful, false otherwise.

            arguments
                obj IOExps
                tableUptake table
            end

            status = false;

            if ~isValidUptakeData(obj, tableUptake)
                recordValidationError( ...
                    obj, ...
                    "The uptake data is not valid.");
                status = true;
                return;
            end

            obj.tableUptakesInfo = tableUptake;
            err = substituteLabelUptakeTable(obj, tableUptake, "Uptake");

            if err
                recordValidationError( ...
                    obj, ...
                    "The table of experimental substrates is not valid.");
                status = true;
                return;
            end

        end % updateTableExpUptake

        function input = getMDVCalculationInput(obj, expName)

            arguments
                obj IOExps
                expName (1, 1) string
            end

            idx = getExpIdx(obj, expName);

            if numel(idx) ~= 1
                error( ...
                    "OpenMebius2:IOExps:ExperimentNotFound", ...
                    "The experiment %s was not found.", ...
                    expName);
            end

            try
                experimentInfo = obj.tableExpsInfo(expName, :);
            catch ME
                error( ...
                    "OpenMebius2:IOExps:ExperimentInfoNotFound", ...
                    "Experiment information for %s was not found: %s", ...
                    expName, ...
                    string(ME.message));
            end

            fieldName = obj.fieldNames(idx);
            input = openmebius.domain.experiment ...
                .ExperimentMDVCalculationInput( ...
                ExperimentName = expName, ...
                RawMS = obj.dataExp.(fieldName).tableMS, ...
                ExperimentInfo = experimentInfo, ...
                AtomTable = obj.tableAtom, ...
                MSMetaboliteTable = ...
                obj.objModel.getMSMetaboliteTable(), ...
                ModelMSTable = obj.objModel.getMSTable(), ...
                TargetMetabolites = ...
                obj.objModel.getTargetMetaboliteList());

        end % getMDVCalculationInput

        function applyMDVDerivedData(obj, expName, derivedData)

            arguments
                obj IOExps
                expName (1, 1) string
                derivedData openmebius.domain.experiment ...
                    .ExperimentDerivedData
            end

            idx = getExpIdx(obj, expName);

            if numel(idx) ~= 1
                error( ...
                    "OpenMebius2:IOExps:ExperimentNotFound", ...
                    "The experiment %s was not found.", ...
                    expName);
            end

            fieldName = obj.fieldNames(idx);
            obj.dataExp.(fieldName).tableMSNormalized = ...
                derivedData.MSNormalized;
            obj.dataExp.(fieldName).tableMDV = derivedData.MDV;
            obj.dataExp.(fieldName).tableMDVBiomass = ...
                derivedData.MDVBiomass;
            obj.dataExp.(fieldName).errMDV = derivedData.MDVErrors;
            obj.dataExp.(fieldName).tableEnrichment = ...
                derivedData.Enrichment;
            obj.dataExp.(fieldName).errEnrichment = ...
                derivedData.EnrichmentErrors;
            obj.dataExp.(fieldName).tableSelection = ...
                derivedData.Selection;

        end % applyMDVDerivedData

        function tf = hasCalculatedMDV(obj)

            tf = hasBiomassCorrectedMDV(obj);

        end % hasCalculatedMDV

        function tf = hasBiomassCorrectedMDV(obj)

            tf = obj.numFile > 0;

            for i = 1:obj.numFile

                fieldName = obj.fieldNames(i);

                if ~isfield(obj.dataExp.(fieldName), "tableMDVBiomass") || ...
                        isempty(obj.dataExp.(fieldName).tableMDVBiomass)
                    tf = false;
                    return
                end

                if ~isfield(obj.dataExp.(fieldName), "tableSelection") || ...
                        isempty(obj.dataExp.(fieldName).tableSelection)
                    tf = false;
                    return
                end

            end % for i

        end % hasBiomassCorrectedMDV

    end % methods (Access = public)

    methods (Access = private)

        function [model, pathModel] = resolveModelInput(~, modelInput)

            if isa(modelInput, 'EMUModel')

                model = modelInput;

                if ~isvalid(model)
                    error( ...
                        "OpenMebius2:IOExps:InvalidModel", ...
                        "The model object is invalid.");
                end

                modelLocation = model.getModelLocation();
                pathModel = modelLocation.Directory;
                return
            end

            modelLocation = ...
                openmebius.domain.model.ModelLocation.fromInput(modelInput);
            pathModel = modelLocation.Directory;

            if pathModel == ""
                error( ...
                    "OpenMebius2:IOExps:EmptyModelDirectory", ...
                    "The model directory is empty.");
            end

            model = EMUModel(modelLocation);

        end % resolveModelInput

        function tableOut = getStoredTableOrEmpty(obj, fieldName, tableName)

            arguments
                obj IOExps
                fieldName (1, 1) string
                tableName (1, 1) string
            end

            if isfield(obj.dataExp.(fieldName), tableName)
                tableOut = obj.dataExp.(fieldName).(tableName);
            else
                tableOut = table();
            end

        end % getStoredTableOrEmpty

        function loadStoredDerivedTables(obj, objExp, structName)

            arguments
                obj IOExps
                objExp IOExp
                structName (1, 1) string
            end

            optionalTables = [ ...
                                  "tableMSNormalized", ...
                                  "tableMDV", ...
                                  "tableMDVBiomass", ...
                                  "tableEnrichment" ...
                              ];

            for iTable = 1:length(optionalTables)

                tableName = optionalTables(iTable);

                if ~isempty(objExp.(tableName))
                    obj.dataExp.(structName).(tableName) = objExp.(tableName);
                end

            end % for iTable

            if isfield(obj.dataExp.(structName), "tableMDVBiomass") && ...
                    ~isempty(obj.dataExp.(structName).tableMDVBiomass)

                try
                    calculator = openmebius.domain.experiment ...
                        .ExperimentMDVCalculator();
                    [tableMDVBiomass, errMDV] = ...
                        calculator.validateBiomassMDV( ...
                        obj.dataExp.(structName).tableMDVBiomass ...
                    );
                    obj.dataExp.(structName).tableMDVBiomass = tableMDVBiomass;
                    obj.dataExp.(structName).errMDV = errMDV;
                    obj.dataExp.(structName).tableSelection = ...
                        calculator.createFragmentSelection( ...
                        tableMDVBiomass, ...
                        errMDV, ...
                        obj.objModel.getMSTable(), ...
                        obj.objModel.getTargetMetaboliteList());
                catch ME
                    obj.dataExp.(structName).errMDV = true(1, ...
                        width(obj.dataExp.(structName).tableMDVBiomass));
                    updateMsg(obj, ...
                        "The stored biomass-corrected MDV sheet could not be validated: " + string(ME.message), ...
                        "Warning", obj.logLevel);
                end

            end

            if isfield(obj.dataExp.(structName), "tableEnrichment")
                tableEnrichment = obj.dataExp.(structName).tableEnrichment;
                obj.dataExp.(structName).errEnrichment = ...
                    any(tableEnrichment{:, :} < 0 | ...
                    tableEnrichment{:, :} > 1 | ...
                    isnan(tableEnrichment{:, :}), 2);
            end

        end % loadStoredDerivedTables

        function obj = loadExpFiles(obj)

            for i = 1:obj.numFile

                fileExp = obj.fileExpList(i);
                fieldName = obj.fieldNames(i);

                loadExpFile(obj, fileExp, fieldName);

            end

        end % loadExpFiles

        function loadExpFile(obj, fileExp, fieldName)
            % LOADEXPFILE: Load the individual experiment file
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % fileExp: string
            %     The file name of the experiment.
            % fieldName: string
            %     The field name of the experiment.

            arguments
                obj IOExps
                fileExp (1, 1) string
                fieldName (1, 1) string
            end

            pathFile = obj.ExperimentLocation.workbookFile(fileExp);
            structName = fieldName;

            objExp = IOExp( ...
                pathFile, ...
                ExperimentRepository = obj.ExperimentRepository);

            obj.defaultVariableNamesListSubstrate = ...
                objExp.getDefualtVariables("substrate");
            obj.defaultVariableTypesListSubstrate = ...
                objExp.getDefualtVariableTypes("substrate");

            obj.dataExp.(structName).tableInfo = objExp.tableInfo;
            obj.dataExp.(structName).tableSubstrate = objExp.tableSubstrate;
            obj.dataExp.(structName).tableMS = objExp.tableMS;

            loadStoredDerivedTables( ...
                obj, ...
                objExp, ...
                structName ...
            );

            if isempty(obj.dataExp.(structName).tableSubstrate)
                obj.dataExp.(structName).tableSubstrate = ...
                    createTemplateSubstrateTable(obj);
            end

            clear objExp;

        end % loadExpFile

        function combineInfoData(obj)

            % 各Infoテーブルを結合する
            % RowNameとして，ファイル名を使用する

            obj.tableExpsInfo = table;

            for i = 1:obj.numFile

                fieldName = obj.fieldNames(i);

                tableInfo = obj.dataExp.(fieldName).tableInfo;
                tableInfo.Properties.RowNames = obj.fileListWOExt(i);

                if isempty(obj.tableExpsInfo)
                    obj.tableExpsInfo = tableInfo;
                else
                    obj.tableExpsInfo = [obj.tableExpsInfo; tableInfo];
                end

            end

        end % combineInfoData

        function combineTraceData(obj)

            [tableRtn, tableFullRtn] = combineTableData(obj, "Label");

            obj.tableTracersInfo = tableRtn;
            obj.tableTracersInfoFull = tableFullRtn;

        end % combineTraceData

        function combineUptakeData(obj)

            [tableRtn, tableFullRtn] = combineTableData(obj, "Uptake");

            obj.tableUptakesInfo = tableRtn;
            obj.tableUptakesInfoFull = tableFullRtn;

        end % combineUptakeData

        function [tableRtn, tableFullRtn] = combineTableData(obj, type)

            mTableTracersInfoFull = table;
            mNumFile = obj.numFile;
            mFieldNames = obj.fieldNames;
            rowNames = obj.fileListWOExt;

            for i = 1:mNumFile

                fieldName = mFieldNames(i);
                rowName = rowNames(i);

                iTableSubstrate = obj.dataExp.(fieldName).tableSubstrate;
                iTableUptake = arrangeExperimentVsSubstrateTable(obj, iTableSubstrate, type, rowName);

                if isempty(mTableTracersInfoFull)
                    mTableTracersInfoFull = iTableUptake;
                else
                    mTableTracersInfoFull = joinTableByRow(obj, mTableTracersInfoFull, iTableUptake);
                end

            end % for i

            subs = obj.objModel.getSubstrateTable();
            metabolties = subs.Metabolite;
            metabolitesColumn = transpose(metabolties);
            mTableTracersInfo = extractNSVars(obj, mTableTracersInfoFull, metabolitesColumn, type);

            % Diff
            missingSample = setdiff(rowNames, string(mTableTracersInfo.Properties.RowNames));

            if ~isempty(missingSample)

                tableRtn = mTableTracersInfo;
                tableFullRtn = mTableTracersInfoFull;

                switch type
                    case "Uptake"

                        tableAdd = table('Size', [length(missingSample) length(metabolties)], ...
                            'VariableTypes', repmat("double", 1, length(metabolties)), ...
                            'VariableNames', mTableTracersInfo.Properties.VariableNames, ...
                            'RowNames', missingSample);
                        tableAdd{:, :} = nan;

                        fullMetabolite = mTableTracersInfoFull.Properties.VariableNames;
                        tableAddFull = table('Size', [length(missingSample) length(fullMetabolite)], ...
                            'VariableTypes', repmat("double", 1, length(fullMetabolite)), ...
                            'VariableNames', fullMetabolite, ...
                            'RowNames', missingSample);
                        tableAddFull{:, :} = nan;

                    case "Label"

                        tableAdd = table('Size', [length(missingSample) length(metabolties)], ...
                            'VariableTypes', repmat("string", 1, length(metabolties)), ...
                            'VariableNames', mTableTracersInfo.Properties.VariableNames, ...
                            'RowNames', missingSample);
                        tableAdd{:, :} = {""};

                        fullMetabolite = mTableTracersInfoFull.Properties.VariableNames;
                        tableAddFull = table('Size', [length(missingSample) length(fullMetabolite)], ...
                            'VariableTypes', repmat("string", 1, length(fullMetabolite)), ...
                            'VariableNames', fullMetabolite, ...
                            'RowNames', missingSample);
                        tableAddFull{:, :} = {""};

                end

                tableRtn = [tableRtn; tableAdd];
                tableFullRtn = [tableFullRtn; tableAddFull];

                % Sort by RowNames
                idxRtn = sortrows(tableRtn.Properties.RowNames, 'ascend');
                tableRtn = tableRtn(idxRtn, :);
                tableFullRtn = tableFullRtn(idxRtn, :);

                return

            end

            % Sort by RowNames
            idxRtn = sortrows(mTableTracersInfo.Properties.RowNames, 'ascend');
            tableRtn = mTableTracersInfo(idxRtn, :);
            tableFullRtn = mTableTracersInfoFull(idxRtn, :);

        end % combineTraceData

        function [tableRtn, err] = combineEnrichmentData(obj)
            % COMBINEENRICHMENTDATA: Create a table of enrichment data
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            %
            % Returns:
            % --------
            % tableRtn: table
            %     The table of enrichment data.
            % err: logical
            %     The error flag for the enrichment data.
            %     true if there is an error, false otherwise.
            %     Conditiions:
            %     - The table of enrichment data is empty.
            %     - The range of the table is not valid.
            %       0 <= enrichment <= 1
            %
            % Example:
            % >> obj = IOExps("path/to/your/file", "fileName");
            % >> tableRtn = combineEnrichmentData(obj)
            %     tableRtn = 3x3 table
            %     | Fragment | Sample1 | Sample2 | Sample3 |
            %     |----------|---------|---------|---------|
            %     |    Ala57 | 0.1234  | 0.5678  | 0.9101  |
            %     |    Ala85 | 0.2345  | 0.6789  | 0.0123  |
            %     |   Ala157 | 0.2345  | 0.6789  | 0.0123  |
            %
            %     err = 3x3 logical array
            %           [0 0 0; 0 0 0; 0 0 0]

            numData = obj.numFile;

            tableRtn = table();

            for i = 1:numData

                iFieldName = obj.fieldNames(i);
                iExperimentName = obj.fileListWOExt(i);

                if ~isfield(obj.dataExp.(iFieldName), "tableEnrichment") || ...
                        isempty(obj.dataExp.(iFieldName).tableEnrichment)
                    updateMsg(obj, ...
                        "The enrichment table is not available. Press Calculate MDV before viewing enrichment data.", ...
                        "Error", obj.logLevel);
                    tableRtn = table();
                    err = [];
                    return
                end

                iTableEnrichment = obj.dataExp.(iFieldName).tableEnrichment;
                iTableEnrichment.Properties.VariableNames = iExperimentName;
                iTableEnrichmentRowNames = iTableEnrichment.Properties.RowNames;
                iTableEnrichment.RowNamesTemp = iTableEnrichmentRowNames;

                if isempty(tableRtn)
                    tableRtn = iTableEnrichment;
                    continue;
                end

                tableRtn = outerjoin( ...
                    tableRtn, ...
                    iTableEnrichment, ...
                    'Keys', "RowNamesTemp", ...
                    'MergeKeys', true ...
                );

            end % for i

            % Set the row names of the table
            tableRtn.Properties.RowNames = tableRtn.RowNamesTemp;
            tableRtn = removevars(tableRtn, "RowNamesTemp");

            % Check for empty table
            if isempty(tableRtn)
                updateMsg(obj, "The enrichment table is empty.", "Error", obj.logLevel);
                err = [];
                return;
            end

            enrichmentArray = tableRtn{:, :};
            err = false(size(enrichmentArray));
            err = logical(err);

            % Check for valid range of enrichment values
            err(enrichmentArray < 0) = true;
            err(enrichmentArray > 1) = true;
            err(isnan(enrichmentArray)) = true;

        end % combineEnrichmentData

        function [tableRtnSelect, tableRtnAvailable] = combineSelectionData(obj)
            % COMBINESELECTIONDATA: Create a table of selection data
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            %
            % Returns:
            % --------
            % tableRtn: table
            %     The table of selection data.

            numData = obj.numFile;
            tableRtnSelect = table();
            tableRtnAvailable = table();

            for i = 1:numData

                iFieldName = obj.fieldNames(i);
                iExperimentName = obj.fileListWOExt(i);

                if ~isfield(obj.dataExp.(iFieldName), "tableSelection") || ...
                        isempty(obj.dataExp.(iFieldName).tableSelection)
                    updateMsg(obj, ...
                        "The fragment selection table is not available. Press Calculate MDV before configuring MDV-dependent analysis.", ...
                        "Error", obj.logLevel);
                    tableRtnSelect = table();
                    tableRtnAvailable = table();
                    return
                end

                iTableSelection = obj.dataExp.(iFieldName).tableSelection;
                iTableSelectionSelect = iTableSelection(:, "Select");
                iTableSelectionAvailable = iTableSelection(:, "Available");
                iTableSelectionSelect.Properties.VariableNames = iExperimentName;
                iTableSelectionAvailable.Properties.VariableNames = iExperimentName;
                iTableSelectionSelect.RowNamesTemp = iTableSelectionSelect.Properties.RowNames;
                iTableSelectionAvailable.RowNamesTemp = iTableSelectionAvailable.Properties.RowNames;

                if isempty(tableRtnSelect)
                    tableRtnSelect = iTableSelectionSelect;
                    tableRtnAvailable = iTableSelectionAvailable;
                    continue;
                end

                tableRtnSelect = outerjoin( ...
                    tableRtnSelect, ...
                    iTableSelectionSelect, ...
                    'Keys', "RowNamesTemp", ...
                    'MergeKeys', true ...
                );
                tableRtnAvailable = outerjoin( ...
                    tableRtnAvailable, ...
                    iTableSelectionAvailable, ...
                    'Keys', "RowNamesTemp", ...
                    'MergeKeys', true ...
                );

            end % for i

            % Set the row names of the table
            tableRtnSelect.Properties.RowNames = tableRtnSelect.RowNamesTemp;
            tableRtnSelect = removevars(tableRtnSelect, "RowNamesTemp");
            tableRtnAvailable.Properties.RowNames = tableRtnAvailable.RowNamesTemp;
            tableRtnAvailable = removevars(tableRtnAvailable, "RowNamesTemp");

        end % combineSelectionData

        function tableRtn = arrangeExperimentVsSubstrateTable(~, data, column, rowName)

            % Extract the column using variable names
            tableFiltered = data(:, column);

            if isempty(tableFiltered.Properties.RowNames)
                % If the table has only one row, transpose it
                tableRtn = table();
                return
            end

            tableTransposed = rows2vars(tableFiltered);
            tableTransposed.Properties.RowNames = rowName;
            % Delete the OriginalVariableNames
            tableRtn = removevars(tableTransposed, "OriginalVariableNames");

        end % arrangeExperimentVsSubstrateTable

        function tableRtn = createExperimentVsSubstrateTable(obj, variable)

            % Create a table with the same size as the number of experiments
            if strcmp(variable, "Uptake")
                tableData = obj.tableUptakesInfo;
            elseif strcmp(variable, "Label")
                tableData = obj.tableTracersInfo;
            else
                error("The variable is not supported.");
            end

            tableRtn = tableData;

        end % createExperimentVsSubstrateTable

        function tableRtn = createTemplateSubstrateTable(obj)
            % CREATETEMPLATESUBSTRATETABLE: Create a template for the substrate table
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            %
            % Returns:
            % --------
            % tableRtn: table
            %     The template uptake table.
            %
            % Example:
            % >> obj = IOExps("path/to/your/file", "fileName");
            % >> tableRtn = obj.createTemplateSubstrateTable()
            %     tableRtn = 3x2 table
            %                  | Uptake | Label |
            %     Subs_CO2     |    NaN | ""    |
            %     Subs_Glucose |    NaN | ""    |
            %     Subs_THF     |    NaN | ""    |

            arguments
                obj IOExps
            end

            varnames = obj.defaultVariableNamesListSubstrate;
            vartypes = obj.defaultVariableTypesListSubstrate;
            % Substrate list in the model
            subs = obj.objModel.getSubstrateTable();
            metaboltie = string(subs.Metabolite);
            metabolite = transpose(metaboltie);

            numVars = length(varnames);
            numRows = length(metabolite);

            tableRtn = table('Size', [numRows numVars], ...
                'VariableTypes', vartypes, ...
                'VariableNames', varnames, ...
                'RowNames', metabolite);

            defaultUptake = nan(numRows, 1);
            tableRtn.Uptake = defaultUptake;

        end % createTemplateSubstrateTable

        function tableRtn = joinTableByRow(~, table1, table2)

            table1Row = table1;
            table2Row = table2;

            table1Row.Rownames = table1.Properties.RowNames;
            table2Row.Rownames = table2.Properties.RowNames;

            table1Var = table1Row.Properties.VariableNames;
            table2Var = table2Row.Properties.VariableNames;

            commonRowNames = intersect(table1Var, table2Var);

            tableJoined = outerjoin(table1Row, table2Row, 'Keys', commonRowNames, 'MergeKeys', true);

            tableJoined.Properties.RowNames = tableJoined.Rownames;
            tableJoined = removevars(tableJoined, 'Rownames');

            tableRtn = tableJoined;

        end % joinTable

        function tableRtn = extractNSVars(~, tableIn, vars, type)

            VariableNames = tableIn.Properties.VariableNames;
            missingVars = setdiff(vars, VariableNames);
            numMissingVars = length(missingVars);

            tableHeight = height(tableIn);
            nanRow = nan(tableHeight, 1);

            if strcmp(type, "Label")
                nanRow = cell(tableHeight, 1);
            end

            for i = 1:numMissingVars

                tableIn.(missingVars{i}) = nanRow;

            end % for i

            tableExtracted = tableIn(:, vars);
            tableSorted = tableExtracted(:, vars);
            tableRtn = tableSorted;

        end % extractNSVars

        function tableRtn = joinFullVars(~, table1, table2)

            variableNames1 = table1.Properties.VariableNames;
            variableNames2 = table2.Properties.VariableNames;

            missingVars = setdiff(variableNames2, variableNames1);
            numMissingVars = length(missingVars);

            for i = 1:numMissingVars

                table1.(missingVars{i}) = table2.(missingVars{i});

            end % for i

            tableSorted = table1(:, variableNames2);
            tableRtn = tableSorted;

        end

        function tableRtn = substituteDataToFullTable(~, tableFull, tableIn, type)
            % SUBSTITUTEDATATOFULLTABLE: Substitute data to the full table
            %
            % Parameters:
            % -----------
            % tableFull: table
            %     The full table.
            % tableIn: table
            %     The table to be substituted.
            %
            % Returns:
            % --------
            % tableRtn: table
            %     The table with the substituted data.
            %
            % Example:
            % >> tableIn
            %     Label: {'A'; 'B'; 'C'}
            %     Ratio: [0.1; 0.2; 0.3]
            %
            % >> tableFull
            %     Label: {'A'; 'B'; 'C'; 'D'}
            %     Ratio: [0; 0; 0; 0]
            %
            % >> tableRtn = substituteDataToFullTable(tableFull, tableIn)
            %     Label: {'A'; 'B'; 'C'; 'D'}
            %     Ratio: [0.1; 0.2; 0.3; 0]

            arguments
                ~
                tableFull table
                tableIn table
                type (1, 1) string {mustBeMember(type, ["Label", "Uptake"])}
            end

            varsIn = tableIn.Properties.VariableNames;
            varsFull = tableFull.Properties.VariableNames;
            rowNamesIn = tableIn.Properties.RowNames;
            rowNamesFull = tableFull.Properties.RowNames;

            if ~all(ismember(varsIn, varsFull))
                missingVars = setdiff(varsIn, varsFull);
                warning("The variables in tableIn are not all present in tableFull: %s. Adding missing variables.", strjoin(missingVars, ", "));

                switch type
                    case "Uptake"
                        varsNan = nan(height(tableFull), numel(missingVars));
                        tableAdd = array2table(varsNan, ...
                            'VariableNames', missingVars, ...
                            'RowNames', rowNamesFull);

                    case "Label"
                        tableAdd = table('Size', [height(tableFull) numel(missingVars)], ...
                            'VariableTypes', repmat("string", 1, numel(missingVars)), ...
                            'VariableNames', missingVars, ...
                            'RowNames', rowNamesFull);

                        for k = 1:numel(missingVars)
                            tableAdd.(missingVars{k}) = repmat("", height(tableFull), 1); % string column
                        end

                end

                tableFull = [tableFull, tableAdd];
                tableFull = tableFull(:, sort(tableFull.Properties.VariableNames));

            end

            if ~all(ismember(rowNamesIn, rowNamesFull)) && height(tableIn) == height(tableFull)
                missingRows = setdiff(rowNamesIn, rowNamesFull);
                error("The rows in tableIn are not all present in tableFull: %s", strjoin(missingRows, ", "));
            end

            tableRtn = tableFull;
            numVars = length(varsIn);

            for i = 1:numVars

                iVar = varsIn{i};
                tableRtn.(iVar) = tableIn.(iVar);

            end % for i

        end % substituteDataToFullTable

        function tableRtn = substituteDataToExpData(~, tableIn, tableOut, type)
            % SUBSTITUTEDATATOEXPDATA: Substitute data to the experimental data
            %
            % Parameters:
            % -----------
            % tableIn: table
            %     The table to be substituted.
            % tableOut: table
            %     The table to be updated.
            % type: string
            %     The type of the table. It can be "Label" or "Uptake".
            %
            % Returns:
            % --------
            % tableRtn: table
            %     The table with the substituted data.
            %
            % Example:
            % >> tableIn
            %     Label: {'A'; 'B'; 'C'}
            %     Ratio: [0.1; 0.2; 0.3]
            %
            % >> tableOut
            %     RowNames | Label | Ratio |
            %     A        | 0.1   | A     |
            %     B        | 0.3   | B     |
            %     C        | 0.5   | A     |
            %
            % >> tableRtn = substituteDataToExpData(tableIn, tableOut, "Label")
            %     RowNames | Label | Ratio |
            %     A        | 0.1   | A     |
            %     B        | 0.2   | B     |
            %     C        | 0.3   | A     |

            arguments
                ~
                tableIn table
                tableOut table
                type (1, 1) string {mustBeMember(type, ["Label", "Uptake"])}
            end

            variablesIn = tableIn.Properties.VariableNames;
            rowNamesOut = tableOut.Properties.RowNames;

            if ~all(ismember(variablesIn, rowNamesOut))
                missingVars = setdiff(variablesIn, rowNamesOut);
                % Add missing variables to the tableOut
                numAddedVars = length(missingVars);
                added = nan(numAddedVars, width(tableOut));
                tableOut = [tableOut; ...
                                array2table(added, ...
                                'VariableNames', tableOut.Properties.VariableNames, ...
                                'RowNames', missingVars)];
                rowNamesOut = tableOut.Properties.RowNames;

            end

            numSample = length(variablesIn);

            % Select the output variable name
            if strcmp(type, "Label")

                varNameOut = "Label";

            elseif strcmp(type, "Uptake")

                varNameOut = "Uptake";

            end

            tableRtn = tableOut;

            for i = 1:numSample

                iVarNameIn = variablesIn{i};
                iData = tableIn.(iVarNameIn);
                iRowNameOut = find(ismember(rowNamesOut, iVarNameIn), 1);

                tableRtn.(varNameOut)(iRowNameOut) = iData;

            end % for i

        end % substituteDataToExpData

        function data = normalizeUITableInput(~, data, type)
            % NORMALIZEUITABLEINPUT: Normalize the input data from UITable
            %
            % data = normalizeUITableInput(obj, data, type)
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % data: table
            %     The input data from UITable.
            % type: string
            %     The type of the data. It can be "Tracer" or "Uptake".
            %
            % Returns:
            % --------
            % data: table
            %     The normalized data.
            %
            % Description:
            % ------------
            % This function normalizes the input data from UITable.
            % table obtained from UITable may contain cells, so the function
            % normalizes the data type.

            arguments
                ~
                data table
                type (1, 1) string {mustBeMember(type, ["Tracer", "Uptake"])}
            end

            vars = data.Properties.VariableNames;

            switch type
                case "Tracer"

                    for j = 1:numel(vars)

                        col = data.(vars{j});

                        if iscell(col)

                            % 1. Convert the empty cell or missing to ""
                            % 2. Convert char to string
                            % 3. Keep string as is
                            col = cellfun(@(x) localToStringScalar(x), col, 'UniformOutput', true);

                        else

                            col = string(col);

                        end % if iscell(col)

                        data.(vars{j}) = string(col);

                    end % for j = 1:numel(vars)

                case "Uptake"

                    for j = 1:numel(vars)

                        col = data.(vars{j});

                        if iscell(col)

                            col = cellfun(@(x) localToDouble(x), col);

                        end % if iscell(col)

                        data.(vars{j}) = double(col);

                    end % for j = 1:numel(vars)

            end % switch type

            % ---- local helpers ----
            function s = localToStringScalar(x)

                if isempty(x)
                    s = "";
                    return;
                end

                % たまに {""} のように入れ子になる場合
                if iscell(x)

                    if isempty(x)
                        s = "";
                    else
                        s = localToStringScalar(x{1});
                    end

                    return;
                end

                s = string(x);

                if ismissing(s)
                    s = "";
                end

                if numel(s) ~= 1
                    s = s(1);
                end

            end

            function d = localToDouble(x)

                if isempty(x)
                    d = NaN;
                    return;
                end

                if iscell(x)
                    d = localToDouble(x{1});
                    return;
                end

                if isstring(x) || ischar(x)

                    if strlength(string(x)) == 0
                        d = NaN;
                    else
                        d = str2double(string(x));
                    end

                    return;
                end

                d = double(x);

                if ~isfinite(d)
                    d = NaN;
                end

            end

        end % normalizeUITableInput

        function tf = isValidUptakeData(obj, data)
            % ISVALIDUPTAKEDATA: Validate the uptake data
            %
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % data: table
            %     The uptake data.

            tf = true;

            if isempty(data) || ~istable(data)
                updateMsg(obj, "The uptake data is empty or not a table.", "Error", obj.logLevel);
                tf = false;
                return;
            end

            for i = 1:height(data)

                for j = 1:width(data)

                    iData = data{i, j};

                    % iData is real value or nan
                    if ~isnan(iData) && ~isreal(iData)
                        updateMsg(obj, "The uptake data is not valid.", "Error", obj.logLevel);
                        tf = false;
                        return;
                    end

                end % for j

            end % for i

        end % isValidUptakeData

        function tf = isValidTracerData(obj, data)
            % ISVALIDTRACERDATA: Validate the tracer data
            %
            % Parameters:
            % -----------
            % data: table
            %     The tracer data.
            %
            % Returns:
            % --------
            % tf: logical
            %     true if the tracer data is valid, false otherwise.

            arguments
                obj
                data table
            end

            tf = true;

            if isempty(data) || ~istable(data)
                tf = false;
                return;
            end

            availableTracer = getTableLabelView(obj.objModel);
            availableTracerName = strip(string(availableTracer.Name));

            for i = 1:height(data)

                for j = 1:width(data)

                    iData = data{i, j};

                    % Normalize to string (and handle missing/empty) to avoid
                    % unsupported implicit conversions from <missing>.
                    iDataStr = localToStringScalar(iData);

                    if strlength(strip(iDataStr)) == 0
                        continue;
                    end

                    tracer = split(iDataStr, ';');
                    tracer = strip(tracer);
                    tracer = tracer(strlength(tracer) > 0);
                    numTracer = numel(tracer);

                    for k = 1:numTracer

                        kTracer = tracer(k);
                        kTracerSplit = split(kTracer, '~');
                        kTracerSplit = strip(kTracerSplit);

                        if numel(kTracerSplit) ~= 2
                            tf = false;
                            return;
                        end

                        kLabel = kTracerSplit(1);
                        kRatioStr = kTracerSplit(2);
                        kRatio = str2double(kRatioStr);

                        if isnan(kRatio) || kRatio < 0 || kRatio > 1
                            tf = false;
                            return;
                        end

                        if ~ismember(kLabel, availableTracerName)
                            tf = false;
                            return;
                        end

                    end % for k

                end % for j

            end % for i

            function s = localToStringScalar(v)
                % Convert table cell content into a scalar string.
                % Treat missing/empty as "".
                if iscell(v)

                    if isempty(v)
                        s = "";
                        return;
                    end

                    if isscalar(v)
                        s = localToStringScalar(v{1});
                        return;
                    end

                    s = string(v(1));
                    return;
                end

                if isstring(v)

                    if isempty(v)
                        s = "";
                        return;
                    end

                    s = v(1);

                    if ismissing(s)
                        s = "";
                    end

                    return;
                end

                if ischar(v)
                    s = string(v);
                    return;
                end

                if ismissing(v)
                    s = "";
                    return;
                end

                s = string(v);
            end

        end % validateTracerData

        function tableRtn = parseLabelPattern(~, label, availableTable)

            labelPattern = strsplit(label, ';');
            numLabelPattern = length(labelPattern);

            cellLabelPattern = cell(numLabelPattern, 2);

            for i = 1:numLabelPattern

                iLabelPattern = labelPattern{i};
                iLabelPatternSplit = strsplit(iLabelPattern, '~');

                cellLabelPattern{i, 1} = iLabelPatternSplit{1};
                cellLabelPattern{i, 2} = iLabelPatternSplit{2};

            end % for i

            % Cell配列の1列目がLabel, 2列目がRatioのCell配列が得られる．

            for i = 1:numLabelPattern

                iLabel = cellLabelPattern{i, 1};
                iRatio = cellLabelPattern{i, 2};

                if ismember(iLabel, availableTable.Label)

                    idx = find(ismember(availableTable.Label, iLabel));

                    availableTable.Select(idx) = true;
                    availableTable.Ratio(idx) = str2double(iRatio);

                end % if

            end % for i

            tableRtn = availableTable;

        end % parseLabelPattern

        function status = substituteInfoTable(obj, tableInfo)
            % SUBSTITUTETABLEINFO: Substitute the table of experimental information
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %     The IOExps object.
            % tableInfo: table
            %     The table of experimental information.

            arguments
                obj IOExps
                tableInfo table
            end

            status = false;

            if isempty(tableInfo) || ~istable(tableInfo)
                updateMsg(obj, "The table is empty or not a table.", "Error", obj.logLevel);
                status = true;
                return;
            end

            sampleName = tableInfo.Properties.RowNames;
            numData = length(sampleName);

            for i = 1:numData

                iSampleName = sampleName(i);
                idx = getExpIdx(obj, iSampleName);

                if isempty(idx)
                    updateMsg(obj, "The sample name is not found.", "Error", obj.logLevel);
                    status = true;
                    continue;
                end

                fieldName = obj.fieldNames(idx);

                obj.dataExp.(fieldName).tableInfo = tableInfo(i, :);
                obj.dataExp.(fieldName).tableInfo.Properties.RowNames = {};

            end % for i

        end % substituteInfoTable

        function status = substituteLabelUptakeTable(obj, tableIn, type)
            % SUBSTITUTETABLELABELUPTAKE: Substitute the table of label uptake
            %
            % Parameters:
            % -----------
            % obj: IOExps
            %    The IOExps object.
            % tableIn: table
            %    The table of label uptake.
            % type: string
            %    The type of the table. It can be "Label" or "Uptake".
            %
            % Returns:
            % --------
            % status: logical
            %     The status of the update operation.

            arguments
                obj IOExps
                tableIn table
                type (1, 1) string {mustBeMember(type, ["Label", "Uptake"])}
            end

            %     true if the update was successful, false otherwise.
            status = false;

            if strcmp(type, "Label")

                tableFull = obj.tableTracersInfoFull;
                tableFullSubs = substituteDataToFullTable(obj, tableFull, tableIn, type);
                obj.tableTracersInfoFull = tableFullSubs;

            elseif strcmp(type, "Uptake")

                tableFull = obj.tableUptakesInfoFull;
                tableFullSubs = substituteDataToFullTable(obj, tableFull, tableIn, type);
                obj.tableUptakesInfoFull = tableFullSubs;

            end

            numData = height(tableFullSubs);

            for i = 1:numData

                iRowName = tableFullSubs.Properties.RowNames(i);
                iRowData = tableFullSubs(i, :);

                % Check if the row name is in the table of experimental information
                if ~ismember(iRowName, obj.fileListWOExt)

                    updateMsg(obj, "The row name is not found in the table of experimental information.", "Error", obj.logLevel);
                    status = true;
                    continue;

                end % if

                % Get the index of the row name in the table of experimental information
                idx = getExpIdx(obj, iRowName);

                if isempty(idx)
                    updateMsg(obj, "The row name is not found in the table of experimental information.", "Error", obj.logLevel);
                    status = true;
                    continue;
                end

                tableSubs = obj.dataExp.(obj.fieldNames(idx)).tableSubstrate;

                if strcmp(type, "Label")

                    tableSubs = substituteDataToExpData(obj, iRowData, tableSubs, type);

                elseif strcmp(type, "Uptake")

                    tableSubs = substituteDataToExpData(obj, iRowData, tableSubs, type);

                end

                obj.dataExp.(obj.fieldNames(idx)).tableSubstrate = tableSubs;

            end % for i

        end % substituteLabelUptakeTable

    end % methods (Access = private)

    methods (Access = protected)

        function updateMsg(obj, text, level, ~)

            message = join(string(text(:)), newline);
            normalizedLevel = openmebius.infrastructure.logging.Logger ...
                .normalizeLevel(level);

            switch normalizedLevel
                case "Warning"
                    obj.ValidationWarnings(end + 1, 1) = message;
            end

            obj.MessagePublisher.write( ...
                lower(normalizedLevel), ...
                message);

        end % updateMsg

        function resetValidation(obj)

            obj.ValidationErrors = strings(0, 1);
            obj.ValidationWarnings = strings(0, 1);

        end % resetValidation

        function recordValidationError(obj, message)

            message = join(string(message(:)), newline);
            obj.ValidationErrors(end + 1, 1) = message;
            updateMsg(obj, message, "Error", obj.logLevel);

        end % recordValidationError

        function report = createValidationReport(obj, successMessage)

            arguments
                obj
                successMessage (1, 1) string
            end

            warnings = unique(obj.ValidationWarnings, "stable");

            if ~isempty(obj.ValidationErrors)
                errorMessage = join( ...
                    unique(obj.ValidationErrors, "stable"), ...
                    newline);
                report = openmebius.domain.experiment ...
                    .ExperimentValidationReport.failure( ...
                    errorMessage, ...
                    Warnings = warnings);
                return
            end

            if successMessage ~= ""
                updateMsg(obj, successMessage, "Info", obj.logLevel);
            end

            report = openmebius.domain.experiment ...
                .ExperimentValidationReport.success( ...
                successMessage, ...
                Warnings = warnings);

        end % createValidationReport

        function throwIfValidationFailed(obj, identifier, fallbackMessage)

            arguments
                obj
                identifier (1, 1) string
                fallbackMessage (1, 1) string
            end

            if isempty(obj.ValidationErrors)
                return
            end

            message = join( ...
                unique(obj.ValidationErrors, "stable"), ...
                newline);

            if message == ""
                message = fallbackMessage;
            end

            error(identifier, "%s", message);

        end % throwIfValidationFailed

    end % methods (Access = protected)

end % classdef
