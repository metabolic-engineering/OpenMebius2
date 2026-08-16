classdef MSFragmentTableMapper
    % MSFRAGMENTTABLEMAPPER
    % Converts batch MS fragment selections to and from RunConfig table UI data.

    methods (Static)

        function viewModel = toViewModel(selections)

            selections = openmebius.presentation.batch.MSFragmentTableMapper.normalizeSelections(selections);

            if isempty(selections)
                viewTable = table.empty(0, 0);
                metadata = openmebius.presentation.batch.MSFragmentTableMapper.emptyMetadata();

                viewModel = struct( ...
                    'Data', viewTable, ...
                    'ColumnName', {{}}, ...
                    'RowName', {{}}, ...
                    'ColumnEditable', false(1, 0), ...
                    'Metadata', metadata ...
                    );
                return
            end

            fragmentNames = string(selections(1).FragmentNames(:));
            numRows = numel(fragmentNames);
            numColumns = sum(arrayfun(@(x) numel(x.ExperimentNames), selections));

            data = false(numRows, numColumns);
            batchIDs = strings(1, numColumns);
            experimentNames = strings(1, numColumns);
            displayColumnNames = strings(1, numColumns);
            rawVariableNames = strings(1, numColumns);

            columnIndex = 0;

            for i = 1:numel(selections)
                selection = selections(i);

                if ~isequal(fragmentNames, string(selection.FragmentNames(:)))
                    error( ...
                        "OpenMebius2:MSFragmentTableMapper:FragmentMismatch", ...
                        "All MS fragment selections must share the same fragment list.");
                end

                selectionData = logical(selection.Selection);
                experimentList = string(selection.ExperimentNames(:));

                if size(selectionData, 1) ~= numRows || size(selectionData, 2) ~= numel(experimentList)
                    error( ...
                        "OpenMebius2:MSFragmentTableMapper:InvalidSelectionSize", ...
                        "MS fragment selection size does not match its fragments and experiments.");
                end

                for j = 1:numel(experimentList)
                    columnIndex = columnIndex + 1;
                    data(:, columnIndex) = selectionData(:, j);
                    batchIDs(columnIndex) = string(selection.BatchID);
                    experimentNames(columnIndex) = experimentList(j);
                    displayColumnNames(columnIndex) = experimentList(j);
                    rawVariableNames(columnIndex) = sprintf("batch_%d_exp_%d", i, j);
                end
            end

            variableNames = matlab.lang.makeUniqueStrings( ...
                matlab.lang.makeValidName(cellstr(rawVariableNames)));
            variableNames = string(variableNames);

            viewTable = array2table( ...
                data, ...
                'VariableNames', cellstr(variableNames), ...
                'RowNames', cellstr(fragmentNames));

            metadata = struct( ...
                'BatchIDs', batchIDs, ...
                'ExperimentNames', experimentNames, ...
                'DisplayColumnNames', displayColumnNames, ...
                'VariableNames', variableNames ...
                );
            viewTable.Properties.UserData = metadata;

            viewModel = struct( ...
                'Data', viewTable, ...
                'ColumnName', {cellstr(displayColumnNames)}, ...
                'RowName', {cellstr(fragmentNames)}, ...
                'ColumnEditable', true(1, numColumns), ...
                'Metadata', metadata ...
                );

        end % toViewModel

        function selections = fromViewTable(viewTable, metadata)

            if nargin < 2 || isempty(metadata)
                metadata = viewTable.Properties.UserData;
            end

            openmebius.presentation.batch.MSFragmentTableMapper.validateMetadata( ...
                viewTable, ...
                metadata);

            columnBatchIDs = string(metadata.BatchIDs(:));
            columnExperimentNames = string(metadata.ExperimentNames(:));
            variableNames = string(metadata.VariableNames(:));
            fragmentNames = string(viewTable.Properties.RowNames(:));
            uniqueBatchIDs = unique(columnBatchIDs, 'stable');

            selections = repmat( ...
                openmebius.presentation.batch.MSFragmentTableMapper.emptySelection(), ...
                1, ...
                numel(uniqueBatchIDs));

            for i = 1:numel(uniqueBatchIDs)
                batchID = uniqueBatchIDs(i);
                mask = columnBatchIDs == batchID;
                batchVariableNames = cellstr(variableNames(mask));
                selectionData = logical(viewTable{:, batchVariableNames});

                selections(i).BatchID = batchID;
                selections(i).ExperimentNames = columnExperimentNames(mask).';
                selections(i).FragmentNames = fragmentNames;
                selections(i).Selection = selectionData;
            end

        end % fromViewTable

    end % methods

    methods (Static, Access = private)

        function selections = normalizeSelections(selections)

            if isempty(selections)
                selections = repmat( ...
                    openmebius.presentation.batch.MSFragmentTableMapper.emptySelection(), ...
                    1, ...
                    0);
                return
            end

            requiredFields = ["BatchID", "ExperimentNames", "FragmentNames", "Selection"];

            for fieldName = requiredFields
                if ~isfield(selections, fieldName)
                    error( ...
                        "OpenMebius2:MSFragmentTableMapper:MissingField", ...
                        "MS fragment selection is missing field %s.", ...
                        fieldName);
                end
            end

        end % normalizeSelections

        function validateMetadata(viewTable, metadata)

            requiredFields = ["BatchIDs", "ExperimentNames", "VariableNames"];

            for fieldName = requiredFields
                if ~isfield(metadata, fieldName)
                    error( ...
                        "OpenMebius2:MSFragmentTableMapper:MissingMetadata", ...
                        "MS fragment table metadata is missing field %s.", ...
                        fieldName);
                end
            end

            variableNames = string(metadata.VariableNames(:));

            if numel(variableNames) ~= width(viewTable)
                error( ...
                    "OpenMebius2:MSFragmentTableMapper:InvalidMetadata", ...
                    "MS fragment table metadata column count does not match the table width.");
            end

            if ~all(ismember(variableNames, string(viewTable.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:MSFragmentTableMapper:InvalidMetadata", ...
                    "MS fragment table metadata references unknown table variables.");
            end

        end % validateMetadata

        function metadata = emptyMetadata()

            metadata = struct( ...
                'BatchIDs', strings(1, 0), ...
                'ExperimentNames', strings(1, 0), ...
                'DisplayColumnNames', strings(1, 0), ...
                'VariableNames', strings(1, 0) ...
                );

        end % emptyMetadata

        function selection = emptySelection()

            selection = struct( ...
                'BatchID', "", ...
                'ExperimentNames', strings(1, 0), ...
                'FragmentNames', strings(0, 1), ...
                'Selection', false(0, 0) ...
                );

        end % emptySelection

    end % methods

end % classdef
