classdef Batch < handle

    events

        GeneralMsg % General message event
        ProgressUpdate % Progress update event
        CancelRequested % Cancel requested event
        FluxResult % Flux result event

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
        AnalysisProvenanceBuilder
        BatchExecutionCoordinator
        MessagePublisher
        batchColumnNamesforGUI = ["ID", "Name", "Experiment", "Description"];
        batchColumnEditableforGUI = [false, true, false, true];

    end % properties

    properties (Dependent)

        tableBatchForGUI

    end % properties (Dependent)

    methods

        % Constructor
        function obj = Batch(exp, options)

            arguments
                exp
                options.AnalysisProvenanceBuilder = ...
                    openmebius.application.analysis ...
                    .AnalysisProvenanceBuilder()
                options.BatchRunService = ...
                    openmebius.application.batch.BatchRunService()
                options.BatchExecutionCoordinator = []
            end

            % Set properties
            obj.exp = exp;
            obj.model = exp.getModel();
            obj.BatchJsonRepository = ...
                openmebius.infrastructure.batch.BatchJsonRepository();
            obj.AnalysisProvenanceBuilder = ...
                options.AnalysisProvenanceBuilder;
            if isempty(options.BatchExecutionCoordinator)
                obj.BatchExecutionCoordinator = ...
                    openmebius.application.batch ...
                    .BatchExecutionCoordinator( ...
                    RunService = options.BatchRunService, ...
                    ProvenanceBuilder = ...
                    obj.AnalysisProvenanceBuilder);
            else
                obj.BatchExecutionCoordinator = ...
                    options.BatchExecutionCoordinator;
            end
            obj.MessagePublisher = openmebius.presentation ...
                .notification.GeneralMessagePublisher();

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

            tempBatch = obj.tableBatch;

            mask = false(height(tempBatch), 1);

            for i = 1:height(tempBatch)

                % Check if the batch is finished
                if strcmp(tempBatch.config(i).status, 'finished')
                    mask(i) = true;
                end

            end % for i

            ids = obj.tableBatch.id(mask);

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

            % Get batch configuration
            idx = find(obj.tableBatch.id == id, 1);

            if isempty(idx)
                error("Batch ID not found: %s", id);
            end

            config = obj.tableBatch.config(idx);

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

            for i = 1:length(ids)

                idx = find(obj.tableBatch.id == ids(i), 1);

                if isempty(idx)
                    error("Batch ID not found: %s", ids(i));
                end

                config = obj.tableBatch.config(idx);

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

            idx = arrayfun(@(x) find(obj.tableBatch.id == x, 1), ids, 'UniformOutput', false);
            idx = cell2mat(idx);

            tableRtn = table.empty(0, 0);

            for i = 1:length(ids)

                % Get batch configuration
                config = obj.tableBatch.config(idx(i));
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

            idx = arrayfun(@(x) find(obj.tableBatch.id == x, 1), ids, 'UniformOutput', false);
            idx = cell2mat(idx);

            if numel(idx) ~= numel(ids)
                error("Batch ID not found: %s", ids);
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

            for i = 1:numel(ids)
                config = obj.tableBatch.config(idx(i));
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
                warning("Only one batch ID can be specified for efflux standard deviation table.");
                return
            end

            idx = find(obj.tableBatch.id == ids(1), 1);

            if isempty(idx)
                warning("Batch ID not found: %s", ids(1));
                return
            end

            config = obj.tableBatch.config(idx);

            currentSelection = logical(config.efflux.selection(:));
            currentSubstrate = string(config.efflux.substrate(:));
            currentSubstrateSD = double(config.efflux.substrateSD(:));

            nConfig = min([length(currentSubstrate), length(currentSelection), length(currentSubstrateSD)]);

            if nConfig < length(currentSubstrate) || nConfig < length(currentSelection) || nConfig < length(currentSubstrateSD)
                warning("Length of substrates, selection, and substrateSD are not the same. Extra entries are ignored.");
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
            for i = 1:length(ids)

                idx = find(obj.tableBatch.id == ids(i), 1);

                if isempty(idx)
                    error("Batch ID not found: %s", ids(i));
                end

                config = obj.tableBatch.config(idx);

                if isfield(config, 'suggestionTable') && ~isempty(config.suggestionTable)
                    suggestionTableCell = config.suggestionTable;
                    suggestionTableVarNames = config.suggestionTableVarNames;
                    numSuggestions = length(suggestionTableCell);

                    tableRtn = table( ...
                        'Size', [numSuggestions, length(suggestionTableVarNames)], ...
                        'VariableNames', suggestionTableVarNames, ...
                        'VariableTypes', repmat({'string'}, 1, length(suggestionTableVarNames)) ...
                    );

                    for iSuggestion = 1:numSuggestions

                        iData = suggestionTableCell{iSuggestion}';
                        tableRtn{iSuggestion, :} = iData;

                    end

                    % Filter columns
                    tracerTable = obj.exp.tableTracersInfo;
                    tracerPattern = tracerTable.Properties.VariableNames;
                    tableRtn = tableRtn(:, intersect(tracerPattern, tableRtn.Properties.VariableNames, 'stable'));

                    % Add missing columns
                    for j = 1:length(tracerPattern)

                        if ~ismember(tracerPattern{j}, tableRtn.Properties.VariableNames)

                            tableRtn.(tracerPattern{j}) = repmat({""}, height(tableRtn), 1);

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
                'VariableTypes', repmat({'cell'}, 1, length(tracerPattern)) ...
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
                warning("Only one batch ID can be specified for INST-MFA pool size table.");
                tableRtn = table();
                return
            end

            idx = find(obj.tableBatch.id == ids(1), 1);

            if isempty(idx)
                warning("Batch ID not found: %s", ids(1));
                tableRtn = table();
                return
            end

            config = obj.tableBatch.config(idx);

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
                warning("Only one batch ID can be specified for INST-MFA time points.");
                tableRtn = table();
                return
            end

            idx = find(obj.tableBatch.id == ids(1), 1);

            if isempty(idx)
                warning("Batch ID not found: %s", ids(1));
                tableRtn = table();
                return
            end

            config = obj.tableBatch.config(idx);

            if ~config.isINSTMFA
                warning("INST-MFA is not enabled for batch ID: %s", ids(1));
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

            expList = strings(0, 1);

            for i = 1:length(ids)

                idx = find(obj.tableBatch.id == ids(i), 1);

                if isempty(idx)
                    error("Batch ID not found: %s", ids(i));
                end

                expName = obj.tableBatch.exp{idx};
                expList = [expList; string(expName)]; %#ok<AGROW>

            end

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

            % Initialize status
            status = strings(length(ids), 1);

            for i = 1:length(ids)

                idx = find(obj.tableBatch.id == ids(i), 1);

                if isempty(idx)
                    status(i) = "unknown";
                    continue
                end

                status(i) = obj.tableBatch.config(idx).status;

            end

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

            % Get index of ids in obj.tableBatch.id
            idx = arrayfun(@(x) find(obj.tableBatch.id == x, 1), ids);

            if length(idx) ~= length(ids)
                error("Batch ID not found: %s", ids);
            end

            for i = 1:length(ids)

                % Update batch configuration
                configFilled = ...
                    openmebius.domain.batch.BatchConfig.normalize(config);
                obj.tableBatch.config(idx(i)) = configFilled;

            end % for i

            updateContentHash(obj, ids);

        end % updateBatchConfig

        function updateBatchMSFragmentSelections(obj, selections)
            % UPDATEBATCHMSFRAGMENTSELECTIONS Update custom fragments from
            % domain MS fragment selection structs.

            arguments
                obj
                selections (1, :) struct
            end

            requiredFields = ["BatchID", "ExperimentNames", "FragmentNames", "Selection"];

            for fieldName = requiredFields
                if ~isfield(selections, fieldName)
                    error( ...
                        "OpenMebius2:Batch:InvalidMSFragmentSelection", ...
                        "MS fragment selection is missing field %s.", ...
                        fieldName);
                end
            end

            expDefaultTable = obj.model.getMSTable();
            defaultFragmentNames = string(expDefaultTable.Properties.RowNames(:));
            expDefaultMask = logical(expDefaultTable.Used(:));
            ids = strings(1, numel(selections));

            for i = 1:numel(selections)
                selection = selections(i);
                id = string(selection.BatchID);
                idx = find(obj.tableBatch.id == id, 1);

                if isempty(idx)
                    error("Batch ID not found: %s", id);
                end

                expList = string(selection.ExperimentNames(:)).';
                fragmentNames = string(selection.FragmentNames(:));
                selectionData = logical(selection.Selection);

                if size(selectionData, 1) ~= numel(fragmentNames) || ...
                        size(selectionData, 2) ~= numel(expList)
                    error( ...
                        "OpenMebius2:Batch:InvalidMSFragmentSelection", ...
                        "MS fragment selection size does not match fragments and experiments.");
                end

                defaultSelection = repmat(expDefaultMask, 1, size(selectionData, 2));
                isDefault = ...
                    isequal(fragmentNames, defaultFragmentNames) && ...
                    isequal(selectionData, defaultSelection);

                obj.tableBatch.config(idx).isSelectMSFragment = ~isDefault;

                if isDefault
                    obj.tableBatch.config(idx).MS.fragment = 'all';
                else
                    obj.tableBatch.config(idx).MS.fragment = 'custom';
                end

                obj.tableBatch.config(idx).MS.customFragment = selectionData;
                obj.tableBatch.config(idx).MS.fragmentList = fragmentNames;
                obj.tableBatch.config(idx).MS.expList = expList;
                ids(i) = id;
            end

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

            % Update batch configuration for custom fragments
            idx = arrayfun(@(x) find(obj.tableBatch.id == x, 1), ids, 'UniformOutput', false);
            idx = cell2mat(idx);

            if length(idx) ~= length(ids)
                error("Batch ID not found: %s", ids);
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

            % Update batch configuration efflux standard deviation
            idx = arrayfun(@(x) find(obj.tableBatch.id == x, 1), ids, 'UniformOutput', false);
            idx = cell2mat(idx);

            if length(idx) ~= length(ids)
                error("Batch ID not found: %s", ids);
            end

            newSelection = logical(tableEffluxSD.Selection(:));
            newSubstrate = string(tableEffluxSD.Properties.RowNames);
            newSubstrateSD = double(tableEffluxSD.SD(:));

            for i = 1:length(idx)

                currentConfig = obj.tableBatch.config(idx(i));
                currentSelection = currentConfig.efflux.selection(:);
                currentSubstrate = string(currentConfig.efflux.substrate(:));
                currentSubstrateSD = currentConfig.efflux.substrateSD(:);

                [~, iaNew, iaCurrent] = intersect(newSubstrate, currentSubstrate);

                updatedSelection = currentSelection;
                updatedSubstrateSD = currentSubstrateSD;

                updatedSelection(iaCurrent) = newSelection(iaNew);
                updatedSubstrateSD(iaCurrent) = newSubstrateSD(iaNew);

                % Add new substrates
                substrateToAdd = setdiff(newSubstrate, currentSubstrate);
                mask = ismember(newSubstrate, substrateToAdd);
                updatedSelection = [updatedSelection; newSelection(mask)];
                updatedSubstrateSD = [updatedSubstrateSD; newSubstrateSD(mask)];
                updatedSubstrate = [currentSubstrate; newSubstrate(mask)];

                % Sort by substrate name
                [updatedSubstrate, sortIdx] = sort(updatedSubstrate);
                updatedSelection = updatedSelection(sortIdx);
                updatedSubstrateSD = updatedSubstrateSD(sortIdx);

                obj.tableBatch.config(idx(i)).efflux.selection = updatedSelection;
                obj.tableBatch.config(idx(i)).efflux.substrate = updatedSubstrate;
                obj.tableBatch.config(idx(i)).efflux.substrateSD = updatedSubstrateSD;

            end % for i

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

            % Update batch configuration suggestion table
            idx = arrayfun(@(x) find(obj.tableBatch.id == x, 1), ids, 'UniformOutput', false);
            idx = cell2mat(idx);

            if length(idx) ~= length(ids)
                error("Batch ID not found: %s", ids);
            end

            % Table to strings
            suggestionTableCell = suggestionTable{:, :};
            isEmpty = cellfun(@(x) isempty(x), suggestionTableCell);
            suggestionTableCell(isEmpty) = {""};

            % Delete rows with has empty cells.
            rowMask = all(~isEmpty, 2);
            suggestionTableCell = suggestionTableCell(rowMask, :);
            suggestionTable = suggestionTable(rowMask, :);

            suggestionTableCell = string(suggestionTableCell);

            for i = 1:length(ids)

                obj.tableBatch.config(idx(i)).suggestionTable = suggestionTableCell;
                obj.tableBatch.config(idx(i)).suggestionTableRowNames = suggestionTable.Properties.RowNames;
                obj.tableBatch.config(idx(i)).suggestionTableVarNames = suggestionTable.Properties.VariableNames;

            end % for i

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

            % Update batch configuration status
            idx = find(obj.tableBatch.id == ids);

            if length(idx) ~= length(ids)
                error("Batch ID not found: %s", ids);
            end

            for i = 1:length(ids)

                switch status
                    case 'ready'
                        obj.tableBatch.config(idx(i)).status = 'ready';
                    case 'finished'
                        obj.tableBatch.config(idx(i)).status = 'finished';
                    case 'error'
                        obj.tableBatch.config(idx(i)).status = 'error';
                    case 'warning'
                        obj.tableBatch.config(idx(i)).status = 'warning';
                    case 'canceled'
                        obj.tableBatch.config(idx(i)).status = 'canceled';
                    otherwise
                        error("Unknown status: %s", status);
                end

            end % for i

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

            % Ensure config has the same fields as the default config
            config = openmebius.domain.batch.BatchConfig.normalize(config);
            id = openmebius.domain.batch.BatchIdentity.newId( ...
                obj.tableBatch.id);

            row = cell2table( ...
                {id, name, exp, description, config, ""}, ...
                'VariableNames', obj.tableBatch.Properties.VariableNames ...
            );
            row.Properties.VariableTypes = obj.tableBatch.Properties.VariableTypes;

            % Add batch
            if isempty(obj.tableBatch)
                obj.tableBatch = row;
            else
                obj.tableBatch = [obj.tableBatch; row];
            end

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

            % Edit batch
            idx = find(obj.tableBatch.id == id, 1);

            if isempty(idx)
                error("Batch ID not found: %s", id);
            end

            % Fill missing fields with current config
            currentConfig = obj.tableBatch.config(idx);
            config = openmebius.domain.batch.BatchConfig.fillMissingFields( ...
                config, ...
                currentConfig);
            config = obj.updateINSTMFATable( ...
                config, ...
                exp{:}', ...
                nan(length(exp{:}'), 1) ...
            );

            obj.tableBatch.name(idx) = name;
            obj.tableBatch.exp(idx) = exp;
            obj.tableBatch.description(idx) = description;
            obj.tableBatch.config(idx) = config;

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

            % Remove batch
            idFinished = getBatchIDsFinished(obj);

            if any(idFinished == id)

                msg = sprintf("Batch ID %s is finished. Cannot remove.", id);

                publishGeneralMessage(obj, "error", string(msg));
                return

            end

            obj.tableBatch(obj.tableBatch.id == id, :) = [];

        end % removeBatch

        function clearBatch(obj)

            % Clear batch
            tempBatch = obj.tableBatch;
            ids = getBatchIDsFinished(obj);
            initTableBatch(obj);
            tempBatch = tempBatch(ismember(tempBatch.id, ids), :);
            obj.tableBatch = tempBatch;

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

        function status = runBatch(obj, fileDirectory)
            % RUNBATCH Run batch
            %
            % Parameters
            % ----------
            % obj: Batch
            %     Batch

            resultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                fileDirectory);
            if ~obj.exp.hasCalculatedMDV()
                status = "error";

                publishGeneralMessage( ...
                    obj, ...
                    "error", ...
                    "MDV data has not been calculated. Press the " + ...
                    "Calculate MDV button before running batch jobs.");
                return
            end

            contentChanged = updateContentHash(obj, obj.tableBatch.id);

            if any(contentChanged)
                saveBatchFile(obj);
            end

            [updatedTable, status] = obj.BatchExecutionCoordinator.run( ...
                obj.tableBatch, ...
                obj.model, ...
                obj.exp, ...
                resultLocation, ...
                Controller = obj, ...
                ProgressReporter = @(progress) ...
                publishBatchProgress(obj, progress), ...
                CheckpointWriter = @(batchTable) ...
                checkpointBatch(obj, batchTable), ...
                MessageReporter = @(eventData) ...
                notify(obj, 'GeneralMsg', eventData), ...
                ResultReporter = @(eventData) ...
                notify(obj, 'FluxResult', eventData));
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

        function changed = updateContentHash(obj, ids)

            arguments
                obj
                ids string
            end

            ids = string(ids(:));
            changed = false(size(ids));

            for i = 1:numel(ids)
                idx = find(obj.tableBatch.id == ids(i), 1);

                if isempty(idx)
                    error("Batch ID not found: %s", ids(i));
                end

                provenance = buildAnalysisProvenance(obj, idx);
                previousHash = obj.tableBatch.contentHash(idx);
                currentHash = provenance.contentHash;
                changed(i) = previousHash ~= currentHash;
                obj.tableBatch.contentHash(idx) = currentHash;

                % Empty hashes belong to migrated legacy data. Initialize them
                % without invalidating an otherwise usable legacy result.
                if changed(i) && strlength(previousHash) > 0 && ...
                        strcmp(obj.tableBatch.config(idx).status, 'finished')
                    obj.tableBatch.config(idx).status = 'ready';
                end
            end

        end % updateContentHash

        function provenance = buildAnalysisProvenance(obj, idx)

            config = obj.tableBatch.config(idx);
            experimentNames = string(obj.tableBatch.exp{idx});
            provenance = obj.AnalysisProvenanceBuilder.build( ...
                config, ...
                obj.tableBatch.id(idx), ...
                obj.model, ...
                obj.exp, ...
                experimentNames);

        end % buildAnalysisProvenance

        function publishBatchProgress(obj, progress)

            notify( ...
                obj, ...
                'ProgressUpdate', ...
                BatchProgressEventData("BatchIteration", progress));

        end % publishBatchProgress

        function checkpointBatch(obj, batchTable)

            obj.tableBatch = batchTable;
            saveBatchFile(obj);

        end % checkpointBatch

        function publishGeneralMessage(obj, level, message)

            obj.MessagePublisher.report( ...
                level, ...
                message, ...
                @(eventData) notify(obj, 'GeneralMsg', eventData));

        end % method publishGeneralMessage

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
