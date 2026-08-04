classdef ExperimentEditMapper
    % EXPERIMENTEDITMAPPER Maps aggregate edits back to experiment records.

    methods

        function result = map(~, collection, aggregateTable, target)

            arguments
                ~
                collection openmebius.domain.experiment ...
                    .ExperimentCollection
                aggregateTable table
                target (1, 1) string {mustBeMember( ...
                    target, ["Tracer", "Uptake"])}
            end

            switch target
                case "Tracer"
                    fullTable = collection.TracerTableFull;
                    substrateVariable = "Label";
                case "Uptake"
                    fullTable = collection.UptakeTableFull;
                    substrateVariable = "Uptake";
            end

            fullTable = openmebius.domain.experiment ...
                .ExperimentEditMapper.mergeAggregateTable( ...
                fullTable, aggregateTable, target);
            data = collection.Data;
            sampleNames = string(fullTable.Properties.RowNames);

            for sampleIndex = 1:numel(sampleNames)
                [isKnown, collectionIndex] = ismember( ...
                    sampleNames(sampleIndex), collection.FileBaseNames);

                if ~isKnown
                    error( ...
                        "OpenMebius2:ExperimentEditMapper:UnknownSample", ...
                        "The experiment '%s' is not loaded.", ...
                        sampleNames(sampleIndex));
                end

                fieldName = collection.FieldNames(collectionIndex);
                substrateTable = data.(fieldName).tableSubstrate;
                data.(fieldName).tableSubstrate = ...
                    openmebius.domain.experiment.ExperimentEditMapper ...
                    .applyAggregateRow( ...
                    fullTable(sampleIndex, :), ...
                    substrateTable, ...
                    substrateVariable);
            end

            result = openmebius.domain.experiment ...
                .ExperimentEditMappingResult( ...
                data, aggregateTable, fullTable, target);

        end % map

        function data = normalizeUITableInput(~, data, target)

            arguments
                ~
                data table
                target (1, 1) string {mustBeMember( ...
                    target, ["Tracer", "Uptake"])}
            end

            variables = data.Properties.VariableNames;

            for variableIndex = 1:numel(variables)
                variable = variables{variableIndex};
                values = data.(variable);

                switch target
                    case "Tracer"
                        if iscell(values)
                            values = cellfun( ...
                                @(value) openmebius.domain.experiment ...
                                .ExperimentEditMapper.toStringScalar(value), ...
                                values, ...
                                UniformOutput = true);
                        else
                            values = string(values);
                            values(ismissing(values)) = "";
                        end

                        data.(variable) = string(values);

                    case "Uptake"
                        if iscell(values)
                            values = cellfun( ...
                                @(value) openmebius.domain.experiment ...
                                .ExperimentEditMapper.toDouble(value), ...
                                values);
                        else
                            values = double(values);
                        end

                        data.(variable) = values;
                end

            end

        end % normalizeUITableInput

    end % methods

    methods (Static, Access = private)

        function fullTable = mergeAggregateTable( ...
                fullTable, aggregateTable, target)

            inputRows = string(aggregateTable.Properties.RowNames);
            fullRows = string(fullTable.Properties.RowNames);

            if ~isequal(sort(inputRows(:)), sort(fullRows(:)))
                error( ...
                    "OpenMebius2:ExperimentEditMapper:SampleMismatch", ...
                    "The aggregate and full tables must contain the same experiments.");
            end

            inputVariables = aggregateTable.Properties.VariableNames;
            fullVariables = fullTable.Properties.VariableNames;
            missingVariables = setdiff( ...
                inputVariables, fullVariables, "stable");

            for variableIndex = 1:numel(missingVariables)
                variable = missingVariables{variableIndex};

                switch target
                    case "Tracer"
                        fullTable.(variable) = strings(height(fullTable), 1);
                    case "Uptake"
                        fullTable.(variable) = nan(height(fullTable), 1);
                end

            end

            if ~isempty(missingVariables)
                fullTable = fullTable(:, ...
                    sort(fullTable.Properties.VariableNames));
            end

            [~, inputIndex] = ismember(fullRows, inputRows);

            for variableIndex = 1:numel(inputVariables)
                variable = inputVariables{variableIndex};
                values = fullTable.(variable);
                inputValues = aggregateTable.(variable);
                values(:, :) = inputValues(inputIndex, :);
                fullTable.(variable) = values;
            end

        end % mergeAggregateTable

        function substrateTable = applyAggregateRow( ...
                aggregateRow, substrateTable, substrateVariable)

            variables = aggregateRow.Properties.VariableNames;
            substrateRows = string(substrateTable.Properties.RowNames);
            missingRows = setdiff(variables, cellstr(substrateRows), "stable");

            if ~isempty(missingRows)
                missingTable = openmebius.domain.experiment ...
                    .ExperimentEditMapper.createMissingRows( ...
                    substrateTable, string(missingRows));
                substrateTable = [substrateTable; missingTable];
                substrateRows = string(substrateTable.Properties.RowNames);
            end

            for variableIndex = 1:numel(variables)
                variable = variables{variableIndex};
                rowIndex = find(substrateRows == string(variable), 1);
                values = substrateTable.(substrateVariable);
                values(rowIndex, :) = aggregateRow.(variable);
                substrateTable.(substrateVariable) = values;
            end

        end % applyAggregateRow

        function missingTable = createMissingRows(template, rowNames)

            variables = template.Properties.VariableNames;
            missingTable = table();
            rowCount = numel(rowNames);

            for variableIndex = 1:numel(variables)
                variable = variables{variableIndex};
                templateValues = template.(variable);
                valueSize = size(templateValues);
                valueSize(1) = rowCount;

                if isstring(templateValues)
                    values = strings(valueSize);
                elseif isfloat(templateValues)
                    values = nan(valueSize, "like", templateValues);
                elseif isnumeric(templateValues)
                    values = zeros(valueSize, "like", templateValues);
                elseif islogical(templateValues)
                    values = false(valueSize);
                elseif iscell(templateValues)
                    values = cell(valueSize);
                elseif ischar(templateValues)
                    values = repmat(' ', valueSize);
                elseif isdatetime(templateValues)
                    values = NaT(valueSize);
                elseif isduration(templateValues)
                    values = seconds(nan(valueSize));
                else
                    error( ...
                        "OpenMebius2:ExperimentEditMapper:" + ...
                        "UnsupportedSubstrateVariable", ...
                        "Cannot create missing values for variable '%s'.", ...
                        variable);
                end

                missingTable.(variable) = values;
            end

            missingTable.Properties.RowNames = cellstr(rowNames);

        end % createMissingRows

        function value = toStringScalar(value)

            if isempty(value)
                value = "";
                return
            end

            if iscell(value)
                value = openmebius.domain.experiment ...
                    .ExperimentEditMapper.toStringScalar(value{1});
                return
            end

            value = string(value);

            if isempty(value) || ismissing(value(1))
                value = "";
                return
            end

            value = value(1);

        end % toStringScalar

        function value = toDouble(value)

            if isempty(value)
                value = NaN;
                return
            end

            if iscell(value)
                value = openmebius.domain.experiment ...
                    .ExperimentEditMapper.toDouble(value{1});
                return
            end

            if isstring(value) || ischar(value)
                value = str2double(string(value));
            else
                value = double(value);
            end

            if isempty(value) || ~isfinite(value(1))
                value = NaN;
            else
                value = value(1);
            end

        end % toDouble

    end % methods (Static, Access = private)

end % classdef
