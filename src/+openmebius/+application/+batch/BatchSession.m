classdef BatchSession < handle

    events

        CancelRequested % Cancel requested event

    end % events

    properties (Access = private)

        % Experiment object
        model
        exp

        % Batch table
        tableBatch table

        % Batch configuration
        filename = 'batch.json'
        BatchJsonRepository
        BatchPreparationService
        BatchExecutionCoordinator
        NotificationEmitter openmebius.application.notification ...
            .NotificationEmitter
        batchColumnNamesforGUI = ["ID", "Name", "Experiment", "Description"];
        batchColumnEditableforGUI = [false, true, false, true];

    end % properties

    properties (Dependent)

        tableBatchForGUI

    end % properties (Dependent)

    methods

        % Constructor
        function obj = BatchSession(exp, options)

            arguments
                exp
                options.AnalysisProvenanceBuilder = ...
                    openmebius.application.analysis ...
                    .AnalysisProvenanceBuilder()
                options.BatchRunService = ...
                    openmebius.application.batch.BatchRunService()
                options.BatchPreparationService = []
                options.BatchExecutionCoordinator = []
                options.NotificationEmitter (1, 1) ...
                    openmebius.application.notification ...
                    .NotificationEmitter = ...
                    openmebius.application.notification ...
                    .NotificationEmitter(Source = "BatchSession")
            end

            % Set properties
            obj.exp = exp;
            obj.model = exp.getModel();
            obj.BatchJsonRepository = ...
                openmebius.infrastructure.batch.BatchJsonRepository();

            if isempty(options.BatchPreparationService)
                obj.BatchPreparationService = ...
                    openmebius.application.batch.BatchPreparationService( ...
                    ProvenanceBuilder = ...
                    options.AnalysisProvenanceBuilder);
            else
                obj.BatchPreparationService = ...
                    options.BatchPreparationService;
            end

            if isempty(options.BatchExecutionCoordinator)
                obj.BatchExecutionCoordinator = ...
                    openmebius.application.batch ...
                    .BatchExecutionCoordinator( ...
                    RunService = options.BatchRunService);
            else
                obj.BatchExecutionCoordinator = ...
                    options.BatchExecutionCoordinator;
            end

            obj.NotificationEmitter = options.NotificationEmitter;
            % Initialize table
            initTableBatch(obj);
            loadBatchFile(obj);

        end % constructor

        %% Public getter methods
        function tableBatchForGUI = get.tableBatchForGUI(obj)

            % Get batch for GUI
            batch = obj.tableBatch(:, {'id', 'name', 'exp', 'description'});

            expStr = strings(height(batch), 1);

            for i = 1:height(batch)
                val = batch.exp{i};

                if isstring(val)
                    expStr(i) = strjoin(val, "; ");
                elseif ischar(val)
                    expStr(i) = string(val);
                elseif iscellstr(val)
                    expStr(i) = strjoin(string(val), "; ");
                else
                    expStr(i) = "";
                end

            end

            batch.exp = expStr;

            batch.Properties.VariableNames = obj.batchColumnNamesforGUI;

            tableBatchForGUI = batch;

        end % set.tableBatchForGUI

        function batch = getBatch(obj)

            % Get batch
            batch = obj.tableBatch;

        end % getBatch

        function [batch, columnEditable] = getBatchForGUI(obj)

            batch = obj.tableBatchForGUI;
            columnEditable = obj.batchColumnEditableforGUI;

        end % getBatchForGUI

        function ids = getBatchIDsFinished(obj)
            % GETBATCHIDSFINISHED Get batch IDs that are finished
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            %
            % Return
            % ------
            % ids: string array
            %     Batch IDs

            ids = obj.batchCollection().finishedIds();

        end % getBatchIDsFinished

        function config = getBatchConfig(obj, id)
            % GETBATCHCONFIG Get batch configuration
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % id: string
            %     Batch ID
            %
            % Return
            % ------
            % config: struct
            %     Batch configuration

            arguments
                obj
                id (1, 1) string
            end

            config = obj.batchCollection().configFor(id);

        end % getBatchConfig

        function isCustomFragment = getBatchIsCustomFragment(obj, ids)
            % GETBATCHISCUSTOMFRAGMENT Get batch custom fragment flag
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            %
            % Return
            % ------
            % isCustomFragment (1, 1) logical
            %     Custom fragment flag

            arguments
                obj
                ids (1, :) string
            end

            isCustomFragment = false(1, length(ids));
            collection = obj.batchCollection();

            for i = 1:length(ids)
                config = collection.configFor(ids(i));

                % Field check
                if ~isfield(config, 'isSelectMSFragment')
                    error("Field 'isSelectMSFragment' not found in batch configuration: %s", ids(i));
                end

                isCustomFragment(i) = config.isSelectMSFragment && strcmp(config.MS.fragment, 'custom');

            end % for i

        end % getBatchIsCustomFragment

        function tableRtn = getBatchCustomFragment(obj, ids)
            % GETBATCHCUSTOMFRAGMENT Get batch custom fragment
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            %
            % Return
            % ------
            % tableRtn: table
            %     Custom fragment table
            %     RowNames: Fragment name
            %     VariableNames: experiment name
            %     Data: boolean
            %         true: fragment is selected
            %         false: fragment is not selected
            %     Example:
            %         |           | exp1 | exp2 | exp3 |
            %         |-----------|------|------|------|
            %         | fragment1 | true | false| true |
            %         | fragment2 | false| true | false|
            %         | fragment3 | true | true | false|
            %         | ...       | ...  | ...  | ...  |
            %         | fragmentN | true | false| true |

            arguments
                obj
                ids (1, :) string
            end

            expDefault = obj.model.getMSTable();
            expDefaultMask = expDefault.Used;
            tableRtn = table.empty(0, 0);
            collection = obj.batchCollection();

            for i = 1:length(ids)

                % Get batch configuration
                config = collection.configFor(ids(i));
                expListFromBatch = getBatchExpList(obj, ids(i));

                % Get custom fragment table
                customFrag = config.MS.customFragment;
                expList = config.MS.expList;
                fragmentList = config.MS.fragmentList;

                if ~config.isSelectMSFragment

                    tableRtn = [tableRtn, ...
                                    array2table( ...
                                    repmat(expDefaultMask, 1, length(expListFromBatch)), ...
                                    'VariableNames', expListFromBatch, ...
                                    'RowNames', expDefault.Properties.RowNames) ...
                                ]; %#ok<AGROW>
                    continue

                end

                % Create table
                tableRtn = [ ...
                                tableRtn, ...
                                array2table( ...
                                customFrag, ...
                                'VariableNames', string(expList), ...
                                'RowNames', fragmentList) ...
                            ]; %#ok<AGROW>

            end % for i

        end % getBatchCustomFragment

        function selections = getBatchMSFragmentSelections(obj, ids)
            % GETBATCHMSFRAGMENTSELECTIONS Get domain MS fragment selections
            % for the selected batches.

            arguments
                obj
                ids (1, :) string
            end

            expDefault = obj.model.getMSTable();
            defaultFragmentNames = string(expDefault.Properties.RowNames(:));
            expDefaultMask = logical(expDefault.Used(:));
            collection = obj.batchCollection();

            selections = repmat( ...
                struct( ...
                'BatchID', "", ...
                'ExperimentNames', strings(1, 0), ...
                'FragmentNames', strings(0, 1), ...
                'Selection', false(0, 0) ...
            ), ...
                1, ...
                numel(ids));

            for i = 1:numel(ids)
                config = collection.configFor(ids(i));
                expListFromBatch = string(obj.getBatchExpList(ids(i))).';

                selections(i).BatchID = ids(i);

                if ~config.isSelectMSFragment || isempty(config.MS.customFragment)
                    selections(i).ExperimentNames = expListFromBatch;
                    selections(i).FragmentNames = defaultFragmentNames;
                    selections(i).Selection = repmat(expDefaultMask, 1, numel(expListFromBatch));
                    continue
                end

                selections(i).ExperimentNames = string(config.MS.expList(:)).';
                selections(i).FragmentNames = string(config.MS.fragmentList(:));
                selections(i).Selection = logical(config.MS.customFragment);
            end

        end % getBatchMSFragmentSelections

        function tableRtn = getBatchGridReactionTable(obj, ids)
            % GETBATCHGRIDREACTIONTABLE Build grid-search reaction rows.
            %

            arguments
                obj
                ids (1, :) string
            end

            modelTable = obj.model.getModelTable();
            reactionIDs = string(modelTable.Properties.RowNames(:));

            if numel(reactionIDs) ~= height(modelTable) || ...
                    any(strlength(reactionIDs) == 0) || ...
                    ~ismember("Reaction", string( ...
                    modelTable.Properties.VariableNames))
                error( ...
                    "OpenMebius2:BatchSession:" + ...
                    "InvalidGridReactionModel", ...
                    "The model must provide row IDs and a Reaction " + ...
                "column for grid-search configuration.");
            end

            reactions = string(modelTable.Reaction(:));
            selection = true(height(modelTable), 1);

            if ~isempty(ids)
                config = obj.batchCollection().configFor(ids(1));
                stored = config.CIConf.grid.reactions;
                storedIDs = string(stored.id(:));
                storedSelection = logical(stored.select(:));
                [isStored, storedIndex] = ismember( ...
                    reactionIDs, storedIDs);

                if any(isStored)
                    selection(isStored) = ...
                        storedSelection(storedIndex(isStored));
                end

            end

            tableRtn = table( ...
                selection, reactionIDs, reactions, ...
                'VariableNames', {'Select', 'ID', 'Reaction'});

        end % getBatchGridReactionTable

        function [tableRtn, columnEditable] = getBatchEffluxSDTable(obj, ids)
            % GETBATCHEFFLUXSDTABLE Get batch efflux standard deviation table
            %
            % tableRtn = getBatchEffluxSDTable(obj, ids)
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            %
            % Return
            % ------
            % tableRtn: table
            %     Efflux standard deviation table
            %     ColumnNames: Selection, SD
            %     RowNames: Substrate
            %     VariableTypes: logical, double

            arguments
                obj
                ids (1, :) string
            end

            tableRtn = table( ...
                'Size', [0, 2], ...
                'VariableNames', {'Selection', 'SD'}, ...
                'VariableTypes', {'logical', 'double'}, ...
                'RowNames', string([]) ...
            );
            columnEditable = [true, true];

            if length(ids) ~= 1
                obj.reportDiagnosticWarning( ...
                    "Only one batch ID can be specified for efflux " + ...
                "standard deviation table.");
                return
            end

            collection = obj.batchCollection();

            if collection.statusesFor(ids(1)) == "unknown"
                obj.reportDiagnosticWarning( ...
                    "Batch ID not found: " + ids(1));
                return
            end

            config = collection.configFor(ids(1));

            currentSelection = logical(config.efflux.selection(:));
            currentSubstrate = string(config.efflux.substrate(:));
            currentSubstrateSD = double(config.efflux.substrateSD(:));

            nConfig = min([length(currentSubstrate), length(currentSelection), length(currentSubstrateSD)]);

            if nConfig < length(currentSubstrate) || nConfig < length(currentSelection) || nConfig < length(currentSubstrateSD)
                obj.reportDiagnosticWarning( ...
                    "Length of substrates, selection, and substrateSD " + ...
                "are not the same. Extra entries are ignored.");
                currentSubstrate = currentSubstrate(1:nConfig);
                currentSelection = currentSelection(1:nConfig);
                currentSubstrateSD = currentSubstrateSD(1:nConfig);
            end

            substratesModel = string(obj.model.getMetaboliteTableSubstrate());

            % Rebuild the UI table on the current model substrate list while
            % preserving values already stored in the batch configuration.
            % The previous implementation reset the whole table to false/NaN
            % whenever a model substrate was missing from config.efflux, which
            % made saved Selection/SD values appear to be ignored.
            substrates = sort(substratesModel(:));
            selectionUpdated = false(length(substrates), 1);
            substrateSDUpdated = nan(length(substrates), 1);

            [tfConfig, idxConfig] = ismember(substrates, currentSubstrate);

            if any(tfConfig)
                selectionUpdated(tfConfig) = currentSelection(idxConfig(tfConfig));
                substrateSDUpdated(tfConfig) = currentSubstrateSD(idxConfig(tfConfig));
            end

            tableRtn = table( ...
                selectionUpdated, ...
                substrateSDUpdated, ...
                'VariableNames', {'Selection', 'SD'}, ...
                'RowNames', substrates ...
            );
            tableRtn.Properties.VariableTypes = {'logical', 'double'};

        end % getBatchEffluxSDTable

        function tableRtn = getBatchSuggestionTable(obj, ids)
            % GETBATCHSUGGESTIONTABLE Get batch suggestion table
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            %
            % Return
            % ------
            % tableRtn: table
            %     Suggestion table
            %
            % Example
            % -------
            %     |                 | substrate1 | substrate2 | ... |
            %     | label pattern 1 | 13C1~1     | [1]Glc~1   | ... |
            %     | label pattern 2 | 13C2~1     | [2]Glc~1   | ... |
            %     | ...             | ...        | ...        | ... |

            arguments
                obj
                ids (1, :) string
            end

            % If exists, return the suggestion table of the first ID
            collection = obj.batchCollection();

            for i = 1:length(ids)
                config = collection.configFor(ids(i));

                if isfield(config, 'suggestionTable') && ~isempty(config.suggestionTable)
                    suggestionValues = string(config.suggestionTable);
                    suggestionVariableNames = ...
                        string(config.suggestionTableVarNames(:)).';

                    if size(suggestionValues, 2) ~= ...
                            numel(suggestionVariableNames)
                        error( ...
                            "OpenMebius2:Batch:InvalidSuggestionTable", ...
                            "Suggestion table columns do not match its " + ...
                        "variable names.");
                    end

                    tableRtn = array2table( ...
                        suggestionValues, ...
                        'VariableNames', ...
                        cellstr(suggestionVariableNames));
                    suggestionRowNames = ...
                        string(config.suggestionTableRowNames(:));

                    if numel(suggestionRowNames) == height(tableRtn) && ...
                            all(strlength(suggestionRowNames) > 0)
                        tableRtn.Properties.RowNames = ...
                            cellstr(suggestionRowNames);
                    end

                    % Filter columns
                    tracerTable = obj.exp.tableTracersInfo;
                    tracerPattern = tracerTable.Properties.VariableNames;
                    tableRtn = tableRtn(:, intersect(tracerPattern, tableRtn.Properties.VariableNames, 'stable'));

                    % Add missing columns
                    for j = 1:length(tracerPattern)

                        if ~ismember(tracerPattern{j}, tableRtn.Properties.VariableNames)

                            tableRtn.(tracerPattern{j}) = ...
                                strings(height(tableRtn), 1);

                        end

                    end

                    % Sort
                    tableRtn = tableRtn(:, tracerPattern);

                    return

                end

            end % for i

            tracerTable = obj.exp.tableTracersInfo;
            tracerPattern = tracerTable.Properties.VariableNames;

            tableRtn = table( ...
                'Size', [0, length(tracerPattern)], ...
                'VariableNames', tracerPattern, ...
                'RowNames', string([]), ...
                'VariableTypes', repmat({'string'}, 1, length(tracerPattern)) ...
            );

        end % getBatchSuggestionTable

        function tableRtn = getBatchINSTMFAPoolTable(obj, ids)
            % GETBATCHINSTMFAPOOLTABLE Get batch INST-MFA pool size table
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string array
            %     Batch IDs
            %
            % Return
            % ------
            % tableRtn: table
            %     INST-MFA pool size table
            %     ColumnNames: Metabolite, PoolSize

            arguments
                obj
                ids (1, :) string
            end

            if length(ids) ~= 1
                obj.reportDiagnosticWarning( ...
                    "Only one batch ID can be specified for INST-MFA " + ...
                "pool size table.");
                tableRtn = table();
                return
            end

            collection = obj.batchCollection();

            if collection.statusesFor(ids(1)) == "unknown"
                obj.reportDiagnosticWarning( ...
                    "Batch ID not found: " + ids(1));
                tableRtn = table();
                return
            end

            config = collection.configFor(ids(1));

            poolSize = config.INSTMFA.poolSize;
            metabolites = config.INSTMFA.poolMetabolite;

            metabolitesModel = obj.model.getMetaboliteTable();
            metabolitesModel = metabolitesModel(metabolitesModel.Type == "metabolite", :);
            metabolitesModel = metabolitesModel.Metabolite;
            metabolitesModelString = string(metabolitesModel);
            % metabolitesとmetaboliteModelの要素を突き合わせて、metabolitesModelに合わせる．
            poolSizeAligned = nan(length(metabolitesModelString), 1);

            for i = 1:length(metabolites)

                idxMet = strcmp(metabolitesModelString, metabolites{i});

                if ~isempty(idxMet)
                    poolSizeAligned(idxMet) = poolSize(i);
                end

            end

            tableRtn = table( ...
                metabolitesModelString, ...
                poolSizeAligned, ...
                'VariableNames', {'Metabolite', 'PoolSize'} ...
            );

        end % getBatchINSTMFAPoolTable

        function [tableRtn, columnEditable] = getBatchINSTMFATimePoints(obj, ids)
            % GETBATCHINSTMFATIMEPOINTS Get batch INST-MFA time points
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string array
            %     Batch IDs
            %
            % Return
            % ------
            % tableRtn: table
            %     INST-MFA time points table
            %     ColumnNames: Experiment, TimePoint

            arguments
                obj
                ids (1, :) string
            end

            columnEditable = [false, true];

            if length(ids) ~= 1
                obj.reportDiagnosticWarning( ...
                    "Only one batch ID can be specified for INST-MFA " + ...
                "time points.");
                tableRtn = table();
                return
            end

            collection = obj.batchCollection();

            if collection.statusesFor(ids(1)) == "unknown"
                obj.reportDiagnosticWarning( ...
                    "Batch ID not found: " + ids(1));
                tableRtn = table();
                return
            end

            config = collection.configFor(ids(1));

            if ~config.isINSTMFA
                obj.reportDiagnosticWarning( ...
                    "INST-MFA is not enabled for batch ID: " + ids(1));
                tableRtn = table();
                return
            end

            expNames = config.INSTMFA.timePointsExpName(:);
            timePoints = config.INSTMFA.timePoints(:);

            tableRtn = table( ...
                expNames, ...
                timePoints, ...
                'VariableNames', {'TimePointExpName', 'TimePoint'} ...
            );

        end % getBatchINSTMFATimePoints

        function expList = getBatchExpList(obj, ids)
            % GETBATCHEXPLIST Get batch experiment list
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string array
            %     Batch IDs
            %
            % Return
            % ------
            % expList: string array
            %     Experiment list

            arguments
                obj
                ids (1, :) string
            end

            expList = obj.batchCollection().experimentsFor(ids);

        end % getBatchExpList

        function status = getBatchStatus(obj, ids)
            % GETBATCHSTATUS Get batch status
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string array
            %     Batch IDs
            %
            % Return
            % ------
            % status: string array
            %     Batch status

            arguments
                obj
                ids (:, 1) string
            end

            status = obj.batchCollection().statusesFor(ids);

        end % getBatchStatus

        function config = getDefaultConfig(~)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();

        end

        %% Public update methods
        function updateBatchFromGUI(obj, batch)

            % Update batch from GUI
            batchNow = batch(:, {'ID', 'Name', 'Experiment', 'Description'});

            % Convert experiment column to cell
            batchNow.Experiment = cellfun(@(x) strsplit(x, "; "), batchNow.Experiment, 'UniformOutput', false);

            obj.tableBatch(:, {'id', 'name', 'exp', 'description'}) = batchNow;

            updateContentHash(obj, batch.ID);

        end % updateBatchFromGUI

        function updateBatchConfig(obj, ids, config)
            % UPDATEBATCHCONFIG Update batch configuration
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            % config: struct
            %     Batch configuration

            arguments
                obj
                ids (:, 1) string
                config struct
            end

            collection = obj.batchCollection();
            collection.replaceConfigs(ids, config);
            obj.tableBatch = collection.toTable();

            updateContentHash(obj, ids);

        end % updateBatchConfig

        function updateBatchMSFragmentSelections(obj, selections)
            % UPDATEBATCHMSFRAGMENTSELECTIONS Update custom fragments from
            % domain MS fragment selection structs.

            arguments
                obj
                selections (1, :) struct
            end

            expDefaultTable = obj.model.getMSTable();
            defaultFragmentNames = string(expDefaultTable.Properties.RowNames(:));
            expDefaultMask = logical(expDefaultTable.Used(:));
            [editor, collection] = obj.batchConfigEditor();
            ids = editor.applyMSFragmentSelections( ...
                selections, ...
                defaultFragmentNames, ...
                expDefaultMask);
            obj.tableBatch = collection.toTable();

            updateContentHash(obj, ids);

        end % updateBatchMSFragmentSelections

        function updateBatchConfigFragment(obj, ids, expFrag)
            % UPDATEBATCHCONFIGFRAGMENT Update batch configuration for custom fragments
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            % expFrag: table
            %     Experiment fragment table
            %     RowNames: Fragment name
            %     VariableNames: experiment name
            %     Data: boolean
            %         true: fragment is selected
            %         false: fragment is not selected
            %     Example:
            %         |           | exp1 | exp2 | exp3 |
            %         |-----------|------|------|------|
            %         | fragment1 | true | false| true |
            %         | fragment2 | false| true | false|
            %         | fragment3 | true | true | false|
            %         | ...       | ...  | ...  | ...  |
            %         | fragmentN | true | false| true |
            %
            % defaultFrag: table
            %     Default fragment table
            %     RowNames: Fragment name
            %     VariableNames: Used
            %     Data: boolean
            %         true: fragment is used
            %         false: fragment is not used
            %     Example:
            %         |           | Used |
            %         |-----------|------|
            %         | fragment1 | true |
            %         | fragment2 | false|
            %         | fragment3 | true |
            %         | ...       | ...  |
            %         | fragmentN | false|
            %
            % Description
            % -----------
            % - If the fragment pattern is same as the default fragment,
            % the isSelectMSFragment field is set to false.

            arguments
                obj
                ids (1, :) string
                expFrag table
            end

            selections = repmat( ...
                struct( ...
                'BatchID', "", ...
                'ExperimentNames', strings(1, 0), ...
                'FragmentNames', strings(0, 1), ...
                'Selection', false(0, 0) ...
            ), ...
                1, ...
                numel(ids));

            for i = 1:length(ids)
                expList = string(obj.getBatchExpList(ids(i))).';
                expFragTable = expFrag(:, cellstr(expList));

                selections(i).BatchID = ids(i);
                selections(i).ExperimentNames = expList;
                selections(i).FragmentNames = string(expFrag.Properties.RowNames(:));
                selections(i).Selection = logical(table2array(expFragTable));
            end

            obj.updateBatchMSFragmentSelections(selections);

        end % updateBatchConfigFragment

        function updateBatchConfigEffluxSD(obj, ids, tableEffluxSD)
            % UPDATEBATCHCONFIGEFFLUXSD Update batch configuration efflux standard deviation
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            % tableEffluxSD: table
            %     Efflux standard deviation table
            %     ColumnNames: Substrate, SD
            %     VariableTypes: string, double

            arguments
                obj
                ids (1, :) string
                tableEffluxSD table
            end

            newSelection = logical(tableEffluxSD.Selection(:));
            newSubstrate = string(tableEffluxSD.Properties.RowNames);
            newSubstrateSD = double(tableEffluxSD.SD(:));
            [editor, collection] = obj.batchConfigEditor();
            editor.applyEfflux( ...
                ids, newSelection, newSubstrate, newSubstrateSD);
            obj.tableBatch = collection.toTable();

            updateContentHash(obj, ids);

        end % updateBatchConfigEffluxSD

        function updateBatchConfigSuggestionTable(obj, ids, suggestionTable)
            % UPDATEBATCHCONFIGSUGGESTIONTABLE Update batch configuration suggestion table
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            % suggestionTable: table
            %     Suggestion table
            %
            % Example
            % -------
            %     |                 | substrate1 | substrate2 | ... |
            %     | label pattern 1 | 13C1~1     | [1]Glc~1   | ... |
            %     | label pattern 2 | 13C2~1     | [2]Glc~1   | ... |
            %     | ...             | ...        | ...        | ... |

            arguments
                obj
                ids (1, :) string
                suggestionTable table
            end

            % Table to strings
            suggestionTableCell = table2cell(suggestionTable);
            isEmpty = cellfun(@(x) isempty(x), suggestionTableCell);
            suggestionTableCell(isEmpty) = {""};

            % Delete rows with has empty cells.
            rowMask = all(~isEmpty, 2);
            suggestionTableCell = suggestionTableCell(rowMask, :);
            suggestionTable = suggestionTable(rowMask, :);

            suggestionTableCell = string(suggestionTableCell);
            [editor, collection] = obj.batchConfigEditor();
            editor.applySuggestion( ...
                ids, ...
                suggestionTableCell, ...
                string(suggestionTable.Properties.RowNames(:)), ...
                string(suggestionTable.Properties.VariableNames));
            obj.tableBatch = collection.toTable();

            updateContentHash(obj, ids);

        end % updateBatchConfigSuggestionTable

        function updateBatchConfigStatus(obj, ids, status)
            % UPDATEBATCHCONFIGSTATUS Update batch configuration status
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % ids: string
            %     Batch ID
            % status: string
            %     Batch configuration status

            arguments
                obj
                ids (1, :) string
                status (1, 1) string
            end

            collection = obj.batchCollection();
            collection.setStatus(ids, status);
            obj.tableBatch = collection.toTable();

        end % updateBatchConfigStatus

        function updateExperimentalData(obj, expObject)
            % UPDATEEXPERIMENTALDATA Update experimental data
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % expObject: Experiment
            %     Experiment object

            arguments
                obj
                expObject
            end

            if isempty(expObject) || ...
                    (isa(expObject, 'handle') && ~isvalid(expObject))
                error( ...
                    "OpenMebius2:Batch:InvalidExperimentObject", ...
                "Experiment object is not valid.");
            end

            if ~ismethod(expObject, 'getModel')
                error( ...
                    "OpenMebius2:Batch:InvalidExperimentObject", ...
                "Experiment object must provide getModel.");
            end

            obj.exp = expObject;
            obj.model = expObject.getModel();

        end % method updateBatchConfigStatus

        %% Public operation methods
        function addBatch(obj, name, exp, description, config)

            arguments
                obj
                name (1, 1) string
                exp (1, 1) cell
                description (1, 1) string
                config struct
            end

            collection = obj.batchCollection();
            id = collection.add(name, exp, description, config);
            obj.tableBatch = collection.toTable();

            updateContentHash(obj, id);

        end % addBatch

        function editBatch(obj, id, name, exp, description, config)
            % EDITBATCH Edit batch
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % id: (1, 1) string
            %     Batch ID
            % name: (1, 1) string
            %     Batch name
            % exp: (1, 1) cell
            %     Experiment name list
            % description: (1, 1) string
            %     Batch description
            % config: struct
            %     Batch configuration

            arguments
                obj
                id (1, 1) string
                name (1, 1) string
                exp (1, 1) cell
                description (1, 1) string
                config struct
            end

            % Fill missing fields with current config
            collection = obj.batchCollection();
            currentConfig = collection.configFor(id);
            config = openmebius.domain.batch.BatchConfig.fillMissingFields( ...
                config, ...
                currentConfig);
            config = obj.updateINSTMFATable( ...
                config, ...
                exp{:}', ...
                nan(length(exp{:}'), 1) ...
            );

            collection.edit(id, name, exp, description, config);
            obj.tableBatch = collection.toTable();

            updateContentHash(obj, id);

        end % editBatch

        function removeBatch(obj, id)
            % REMOVEBATCH Remove batch by ID
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % id: (1, 1) string
            %     Batch ID
            %     If the batch is finished, it cannot be removed

            arguments
                obj
                id (1, 1) string
            end

            collection = obj.batchCollection();
            [removed, reason] = collection.remove(id);

            if reason == "finished"

                displayId = extractBefore(string(id), ...
                    min(strlength(string(id)) + 1, 11));
                error( ...
                    "OpenMebius2:Batch:FinishedBatchRemoval", ...
                    "Batch ID %s is finished. Cannot remove.", ...
                    displayId);

            end

            if removed
                obj.tableBatch = collection.toTable();
            end

        end % removeBatch

        function clearBatch(obj)

            collection = obj.batchCollection();
            collection.clearUnfinished();
            obj.tableBatch = collection.toTable();

        end % clearBatch

        function autoFillBatch(obj)

            obj.clearBatch();

            expList = obj.exp.getExpList();
            numExp = length(expList);
            description = "Auto-generated batch";

            % Add batch
            for i = 1:numExp

                % Get experiment
                iExp = expList(i);

                % Add batch
                obj.addBatch( ...
                    iExp, ...
                    {iExp}, ...
                    description, ...
                    obj.getDefaultConfig() ...
                );

            end % for i

        end % autoFillBatch

        function saveBatchFile(obj, fileDirectory)
            % SAVEBATCHFILE Save batch file in JSON format
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % fileDirectory: string
            %     File directory name

            if nargin < 2
                experimentLocation = obj.getExperimentLocation();
            else
                experimentLocation = ...
                    openmebius.domain.experiment.ExperimentLocation.fromInput( ...
                    fileDirectory);
            end

            obj.BatchJsonRepository.save( ...
                experimentLocation, ...
                string(obj.filename), ...
                obj.tableBatch);

        end % saveBatchFile

        function [isError, msg] = loadBatchFile(obj, fileDirectory)
            % LOADBATCHFILE Load batch file in JSON format
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch
            % fileDirectory: string
            %     File directory name
            %
            % Return
            % ------
            % isError (1, 1) logical
            %     Error flag if the import process failed
            % msg (1, 1) string
            %     Message

            if nargin < 2
                experimentLocation = obj.getExperimentLocation();
            else
                experimentLocation = ...
                    openmebius.domain.experiment.ExperimentLocation.fromInput( ...
                    fileDirectory);
            end

            isError = false;

            [batchLoaded, isImportError, msg] = obj.BatchJsonRepository.load( ...
                experimentLocation, ...
                string(obj.filename), ...
                obj.tableBatch.Properties.VariableNames);

            if isImportError
                isError = true;
                return
            end % if isImportError

            obj.tableBatch = batchLoaded;
            updateContentHash(obj, obj.tableBatch.id);

        end % loadBatchFile

        function result = runBatch(obj, fileDirectory, options)
            % RUNBATCH Run batch
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch

            arguments
                obj
                fileDirectory
                options.ProgressReporter (1, 1) function_handle = @(~) []
                options.NotificationReporter (1, 1) function_handle = @(~) []
                options.ResultReporter (1, 1) function_handle = @(~) []
            end

            resultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                fileDirectory);

            if ~obj.exp.hasCalculatedMDV()
                result = openmebius.application.batch ...
                    .BatchExecutionResult( ...
                    false, ...
                    ErrorMessage = ...
                "MDV data has not been calculated.");

                publishGeneralMessage( ...
                    obj, ...
                    "error", ...
                    "MDV data has not been calculated. Press the " + ...
                    "Calculate MDV button before running batch jobs.", ...
                    options.NotificationReporter);
                return
            end

            [obj.tableBatch, contentChanged, provenances] = ...
                obj.BatchPreparationService.prepare( ...
                obj.tableBatch, ...
                obj.tableBatch.id, ...
                obj.model, ...
                obj.exp);

            if any(contentChanged)
                saveBatchFile(obj);
            end

            [updatedTable, result] = obj.BatchExecutionCoordinator.run( ...
                obj.tableBatch, ...
                obj.model, ...
                obj.exp, ...
                resultLocation, ...
                provenances, ...
                Controller = obj, ...
                ProgressReporter = options.ProgressReporter, ...
                CheckpointWriter = @(batchTable) ...
                checkpointBatch(obj, batchTable), ...
                MessageReporter = options.NotificationReporter, ...
                ResultReporter = options.ResultReporter);
            obj.tableBatch = updatedTable;

        end % runBatch

        function cancelBatch(obj)

            notify(obj, 'CancelRequested');

        end

    end % methods

    methods (Access = private)

        function initTableBatch(obj)

            obj.tableBatch = ...
                openmebius.infrastructure.batch.BatchJsonMapper.emptyTable();

        end % initTableBatch

        function collection = batchCollection(obj)

            collection = openmebius.domain.batch.BatchCollection( ...
                obj.tableBatch);

        end % batchCollection

        function [editor, collection] = batchConfigEditor(obj)

            collection = obj.batchCollection();
            editor = openmebius.domain.batch.BatchConfigEditor(collection);

        end % batchConfigEditor

        function changed = updateContentHash(obj, ids)

            arguments
                obj
                ids string
            end

            [obj.tableBatch, changed] = ...
                obj.BatchPreparationService.prepare( ...
                obj.tableBatch, ...
                ids, ...
                obj.model, ...
                obj.exp);

        end % updateContentHash

        function checkpointBatch(obj, batchTable)

            obj.tableBatch = batchTable;
            saveBatchFile(obj);

        end % checkpointBatch

        function publishGeneralMessage(obj, level, message, reporter)

            if nargin < 4
                reporter = @(~) [];
            end

            emitter = openmebius.application.notification ...
                .NotificationEmitter( ...
                Publisher = reporter, ...
                Source = "BatchSession");
            emitter.report( ...
                level, ...
                message, ...
                Code = "batch.operation");

        end % method publishGeneralMessage

        function reportDiagnosticWarning(obj, message)

            obj.NotificationEmitter.report( ...
                "warning", ...
                string(message), ...
                Code = "batch.validation", ...
                Audience = "developer", ...
                Kind = "diagnostic");

        end % reportDiagnosticWarning

        function experimentLocation = getExperimentLocation(obj)

            if ismethod(obj.exp, 'getExperimentLocation')
                experimentLocation = obj.exp.getExperimentLocation();
                return;
            end

            error("Batch:MissingExperimentLocation", ...
            "The experiment object does not expose getExperimentLocation().");

        end % method getExperimentLocation

    end % methods (Access = private)

    methods (Static, Access = private)

        function updatedConfig = updateINSTMFATable(currentConfig, newTimeCourse, newTimePoints)
            % UPDATEINSTMFATABLE Update INST-MFA table
            %
            % Parameters
            % ----------
            % currentConfig: struct
            %     Current batch configuration
            % currentTimeCourse: string array
            %     Current time course experiment names
            % currentTimePoints: double array
            %     Current time points
            %
            % Return
            % ------
            % updatedConfig: struct
            %     Updated batch configuration

            arguments
                currentConfig struct
                newTimeCourse (:, 1) string
                newTimePoints (:, 1) double
            end

            updatedConfig = currentConfig;

            if currentConfig.isINSTMFA

                currentTimeCourse = string(currentConfig.INSTMFA.timePointsExpName(:));
                currentTimePoints = double(currentConfig.INSTMFA.timePoints(:));

                % Find duplicated and added experiments
                [duplicatedExp, idxCurrentTimeCourse, ~] = ...
                    intersect(currentTimeCourse, newTimeCourse);
                addedExpMask = ~ismember(newTimeCourse, currentTimeCourse);
                numDuplicated = length(duplicatedExp);

                % Initialize updated time course and time points
                updatedTimeCourse = strings(length(newTimeCourse), 1);
                updatedTimePoints = nan(length(newTimePoints), 1);

                % Fill updated time course and time points
                updatedTimeCourse(1:numDuplicated) = duplicatedExp;
                updatedTimePoints(1:numDuplicated) = currentTimePoints(idxCurrentTimeCourse);
                updatedTimeCourse(numDuplicated + 1:end) = newTimeCourse(addedExpMask);
                updatedTimePoints(numDuplicated + 1:end) = newTimePoints(addedExpMask);

                % Sort by time course
                updatedTimeCourse = sort(updatedTimeCourse);
                [~, sortIdx] = ismember(updatedTimeCourse, newTimeCourse);
                updatedTimePoints = updatedTimePoints(sortIdx);

                % Update configuration
                updatedConfig.INSTMFA.timePointsExpName = string(updatedTimeCourse(:));
                updatedConfig.INSTMFA.timePoints = double(updatedTimePoints(:));

            else

                return

            end

        end % updateINSTMFATable

    end % methods (Static, Access = private)

end % classdef
