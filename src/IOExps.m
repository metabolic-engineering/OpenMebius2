classdef IOExps < handle

    properties (Access = private)

        Collection openmebius.domain.experiment.ExperimentCollection
        ComparisonBuilder
        EditMapper
        EditValidator
        ExperimentRepository
        TableAssembler
        MessagePublisher
        ValidationErrors (:, 1) string = strings(0, 1)
        ValidationWarnings (:, 1) string = strings(0, 1)

    end % properties

    properties (Access = protected)
        logLevel (1, 1) string = "Info"
    end

    properties (Dependent, SetAccess = private)

        fileExpList (1, :) string
        dataExp (1, :)
        fieldNames (1, :) string
        pathModel (1, 1) string
        ExperimentLocation openmebius.domain.experiment.ExperimentLocation
        tableExpsInfo table
        tableTracersInfoFull table
        tableTracersInfo table
        tableUptakesInfoFull table
        tableUptakesInfo table
        tableAtom table
        objModel
        defaultVariableNamesListSubstrate (1, :) string
        defaultVariableTypesListSubstrate (1, :) string
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
                options.ComparisonBuilder = openmebius.domain.experiment ...
                    .ExperimentComparisonBuilder()
                options.EditMapper = openmebius.domain.experiment ...
                    .ExperimentEditMapper()
                options.EditValidator = openmebius.domain.experiment ...
                    .ExperimentEditValidator()
                options.TableAssembler = openmebius.domain.experiment ...
                    .ExperimentTableAssembler()
                options.AllowEmpty (1, 1) logical = false
            end

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromInput( ...
                experimentInput);

            obj.Collection = openmebius.domain.experiment ...
                .ExperimentCollection(experimentLocation);
            obj.ComparisonBuilder = options.ComparisonBuilder;
            obj.EditMapper = options.EditMapper;
            obj.EditValidator = options.EditValidator;
            obj.ExperimentRepository = options.ExperimentRepository;
            obj.TableAssembler = options.TableAssembler;
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

        function value = get.fileExpList(obj)

            value = obj.Collection.FileNames;

        end % get.fileExpList

        function value = get.dataExp(obj)

            value = obj.Collection.Data;

        end % get.dataExp

        function set.dataExp(obj, value)

            obj.Collection.replaceData(value);

        end % set.dataExp

        function value = get.fieldNames(obj)

            value = obj.Collection.FieldNames;

        end % get.fieldNames

        function value = get.pathModel(obj)

            value = obj.Collection.ModelPath;

        end % get.pathModel

        function value = get.ExperimentLocation(obj)

            value = obj.Collection.Location;

        end % get.ExperimentLocation

        function value = get.tableExpsInfo(obj)

            value = obj.Collection.InfoTable;

        end % get.tableExpsInfo

        function set.tableExpsInfo(obj, value)

            obj.Collection.replaceInfoTable(value);

        end % set.tableExpsInfo

        function value = get.tableTracersInfoFull(obj)

            value = obj.Collection.TracerTableFull;

        end % get.tableTracersInfoFull

        function set.tableTracersInfoFull(obj, value)

            obj.Collection.replaceTracerTables( ...
                obj.Collection.TracerTable, value);

        end % set.tableTracersInfoFull

        function value = get.tableTracersInfo(obj)

            value = obj.Collection.TracerTable;

        end % get.tableTracersInfo

        function set.tableTracersInfo(obj, value)

            obj.Collection.replaceTracerTables(value);

        end % set.tableTracersInfo

        function value = get.tableUptakesInfoFull(obj)

            value = obj.Collection.UptakeTableFull;

        end % get.tableUptakesInfoFull

        function set.tableUptakesInfoFull(obj, value)

            obj.Collection.replaceUptakeTables( ...
                obj.Collection.UptakeTable, value);

        end % set.tableUptakesInfoFull

        function value = get.tableUptakesInfo(obj)

            value = obj.Collection.UptakeTable;

        end % get.tableUptakesInfo

        function set.tableUptakesInfo(obj, value)

            obj.Collection.replaceUptakeTables(value);

        end % set.tableUptakesInfo

        function value = get.tableAtom(obj)

            value = obj.Collection.AtomTable;

        end % get.tableAtom

        function value = get.objModel(obj)

            value = obj.Collection.Model;

        end % get.objModel

        function value = get.defaultVariableNamesListSubstrate(obj)

            value = obj.Collection.DefaultSubstrateVariableNames;

        end % get.defaultVariableNamesListSubstrate

        function value = get.defaultVariableTypesListSubstrate(obj)

            value = obj.Collection.DefaultSubstrateVariableTypes;

        end % get.defaultVariableTypesListSubstrate

        function numFile = get.numFile(obj)

            numFile = obj.Collection.Count;

        end % get.numFile

        function fileListWOExt = get.fileListWOExt(obj)

            fileListWOExt = obj.Collection.FileBaseNames;

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

            obj.Collection.replaceFiles( ...
                obj.ExperimentRepository.listWorkbooks( ...
                obj.ExperimentLocation, ...
                "xlsx"));

            if isempty(obj.fileExpList)
                if options.AllowEmpty
                    [model, modelPath] = obj.resolveModelInput(modelInput);
                    obj.Collection.replaceModel(model, modelPath);
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

            [model, modelPath] = obj.resolveModelInput(modelInput);
            obj.Collection.replaceModel(model, modelPath);

            loadExpFiles(obj);

            aggregateTables = obj.TableAssembler.assemble(obj.Collection);
            obj.Collection.replaceAggregateTables(aggregateTables);

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

            switch type
                case "Info"
                    % Update the info table
                    status = updateTableExpInfo(obj, data);
                case "Tracer"
                    data = obj.EditMapper.normalizeUITableInput( ...
                        data, type);
                    status = updateTableExpSubstrate(obj, data);
                case "Uptake"
                    data = obj.EditMapper.normalizeUITableInput( ...
                        data, type);
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

            obj.Collection.replaceFiles( ...
                obj.ExperimentRepository.listWorkbooks( ...
                sourceLocation, ...
                options.type));

            for i = 1:length(obj.fileExpList)

                fileExp = obj.fileExpList(i);
                fieldName = obj.fieldNames(i);

                pathFile = sourceLocation.workbookFile(fileExp);
                structName = fieldName;

                workbook = obj.ExperimentRepository.loadWorkbook(pathFile);
                applyWorkbookData(obj, workbook, structName);

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
                    workbook = createWorkbookData(obj, fieldName);
                    obj.ExperimentRepository.saveWorkbook( ...
                        obj.ExperimentLocation.workbookFile( ...
                        obj.fileExpList(i)), ...
                        workbook);
                    updateMsg( ...
                        obj, name + " is saved.", "Info", obj.logLevel);
                catch ME
                    recordValidationError( ...
                        obj, ...
                        name + " is not saved. " + string(ME.message));
                end

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

        function collection = getCollection(obj)

            collection = obj.Collection;

        end % getCollection

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

            result = obj.ComparisonBuilder.buildMSNormalized( ...
                obj.Collection, fragName);

            if ~result.IsAvailable
                updateMsg(obj, result.Message, "Error", obj.logLevel);
            end

            tableRtn = result.Data;

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

            result = obj.ComparisonBuilder.buildMDVBiomass( ...
                obj.Collection, fragName);

            if ~result.IsAvailable
                updateMsg(obj, result.Message, "Error", obj.logLevel);
            end

            tableRtn = result.Data;

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

            result = obj.ComparisonBuilder.buildEnrichment(obj.Collection);

            if ~result.IsAvailable
                updateMsg(obj, result.Message, "Error", obj.logLevel);
            end

            tableRtn = result.Data;
            tableRtnErr = result.ErrorMask;

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

            result = obj.ComparisonBuilder.buildSelection(obj.Collection);

            if ~result.IsAvailable
                updateMsg(obj, result.Message, "Error", obj.logLevel);
            end

            tableRtnSelect = result.Selected;
            tableRtnAvailable = result.Available;
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

            obj.Collection.replaceModel(model);

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

            availableTracer = getTableLabelView(obj.objModel);
            validation = obj.EditValidator.validateTracer( ...
                tableSubstrate, ...
                obj.tableTracersInfo.Properties.VariableNames, ...
                obj.fileListWOExt, ...
                availableTracer.Name);

            if ~validation.IsValid
                recordValidationError(obj, validation.ErrorMessage);
                status = true;
                return;
            end

            editResult = obj.EditMapper.map( ...
                obj.Collection, tableSubstrate, "Tracer");
            obj.Collection.applyEdit(editResult);

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

            validation = obj.EditValidator.validateUptake( ...
                tableUptake, ...
                obj.tableUptakesInfo.Properties.VariableNames, ...
                obj.fileListWOExt);

            if ~validation.IsValid
                recordValidationError(obj, validation.ErrorMessage);
                status = true;
                return;
            end

            editResult = obj.EditMapper.map( ...
                obj.Collection, tableUptake, "Uptake");
            obj.Collection.applyEdit(editResult);

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

        function workbook = createWorkbookData(obj, fieldName)

            arguments
                obj IOExps
                fieldName (1, 1) string
            end

            workbook = openmebius.infrastructure.experiment ...
                .ExperimentWorkbookData( ...
                Info = obj.dataExp.(fieldName).tableInfo, ...
                Substrate = obj.dataExp.(fieldName).tableSubstrate, ...
                MS = obj.dataExp.(fieldName).tableMS, ...
                MSNormalized = getStoredTableOrEmpty( ...
                obj, fieldName, "tableMSNormalized"), ...
                MDV = getStoredTableOrEmpty( ...
                obj, fieldName, "tableMDV"), ...
                MDVBiomass = getStoredTableOrEmpty( ...
                obj, fieldName, "tableMDVBiomass"), ...
                Enrichment = getStoredTableOrEmpty( ...
                obj, fieldName, "tableEnrichment"), ...
                DefaultSubstrateVariableNames = ...
                obj.defaultVariableNamesListSubstrate, ...
                DefaultSubstrateVariableTypes = ...
                obj.defaultVariableTypesListSubstrate);

        end % createWorkbookData

        function applyWorkbookData(obj, workbook, structName, options)

            arguments
                obj IOExps
                workbook openmebius.infrastructure.experiment ...
                    .ExperimentWorkbookData
                structName (1, 1) string
                options.UpdateDefaults (1, 1) logical = false
                options.CreateSubstrateTemplate (1, 1) logical = false
            end

            if options.UpdateDefaults
                obj.Collection.replaceDefaultSubstrateMetadata( ...
                    workbook.DefaultSubstrateVariableNames, ...
                    workbook.DefaultSubstrateVariableTypes);
            end

            obj.dataExp.(structName).tableInfo = workbook.Info;
            obj.dataExp.(structName).tableSubstrate = workbook.Substrate;
            obj.dataExp.(structName).tableMS = workbook.MS;

            % Keep stored derived sheets without triggering recalculation.
            loadStoredDerivedTables(obj, workbook, structName);

            if options.CreateSubstrateTemplate && ...
                    isempty(obj.dataExp.(structName).tableSubstrate)
                obj.dataExp.(structName).tableSubstrate = ...
                    createTemplateSubstrateTable(obj);
            end

        end % applyWorkbookData

        function loadStoredDerivedTables(obj, workbook, structName)

            arguments
                obj IOExps
                workbook openmebius.infrastructure.experiment ...
                    .ExperimentWorkbookData
                structName (1, 1) string
            end

            storedData = obj.ExperimentRepository.restoreDerivedData( ...
                workbook, ...
                obj.objModel);
            sourceNames = [ ...
                               "MSNormalized", ...
                               "MDV", ...
                               "MDVBiomass", ...
                               "Enrichment" ...
                           ];
            targetNames = [ ...
                               "tableMSNormalized", ...
                               "tableMDV", ...
                               "tableMDVBiomass", ...
                               "tableEnrichment" ...
                           ];

            for iTable = 1:numel(sourceNames)
                storedTable = storedData.(sourceNames(iTable));

                if ~isempty(storedTable)
                    obj.dataExp.(structName).(targetNames(iTable)) = ...
                        storedTable;
                end
            end

            if ~isempty(storedData.MDVBiomass)
                obj.dataExp.(structName).errMDV = storedData.MDVErrors;

                if ~isempty(storedData.Selection)
                    obj.dataExp.(structName).tableSelection = ...
                        storedData.Selection;
                end
            end

            if ~isempty(storedData.Enrichment)
                obj.dataExp.(structName).errEnrichment = ...
                    storedData.EnrichmentErrors;
            end

            for iWarning = 1:numel(storedData.Warnings)
                updateMsg( ...
                    obj, ...
                    storedData.Warnings(iWarning), ...
                    "Warning", ...
                    obj.logLevel);
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

            workbook = obj.ExperimentRepository.loadWorkbook(pathFile);
            applyWorkbookData( ...
                obj, ...
                workbook, ...
                structName, ...
                UpdateDefaults = true, ...
                CreateSubstrateTemplate = true);

        end % loadExpFile

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
