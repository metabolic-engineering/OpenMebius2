classdef ExperimentTableAssembler
    % EXPERIMENTTABLEASSEMBLER Builds aggregate experiment tables.

    methods

        function result = assemble(obj, collection)

            arguments
                obj
                collection openmebius.domain.experiment ...
                    .ExperimentCollection
            end

            info = obj.assembleInfo(collection);
            [tracer, tracerFull] = obj.assembleSubstrate( ...
                collection, "Label");
            [uptake, uptakeFull] = obj.assembleSubstrate( ...
                collection, "Uptake");

            result = openmebius.domain.experiment ...
                .ExperimentAggregateTables( ...
                Info = info, ...
                Tracer = tracer, ...
                TracerFull = tracerFull, ...
                Uptake = uptake, ...
                UptakeFull = uptakeFull);

        end % assemble

    end % methods

    methods (Access = private)

        function result = assembleInfo(~, collection)

            if collection.Count == 0
                result = table();
                return
            end

            infoTables = cell(collection.Count, 1);

            for iExperiment = 1:collection.Count
                fieldName = collection.FieldNames(iExperiment);
                experimentInfo = collection.Data.(fieldName).tableInfo;
                experimentInfo.Properties.RowNames = ...
                    collection.FileBaseNames(iExperiment);
                infoTables{iExperiment} = experimentInfo;
            end

            result = vertcat(infoTables{:});

        end % assembleInfo

        function [result, fullResult] = assembleSubstrate( ...
                obj, collection, type)

            arguments
                obj
                collection openmebius.domain.experiment ...
                    .ExperimentCollection
                type (1, 1) string {mustBeMember(type, ["Label", "Uptake"])}
            end

            fullResult = table();
            rowNames = collection.FileBaseNames;

            for iExperiment = 1:collection.Count
                fieldName = collection.FieldNames(iExperiment);
                substrate = collection.Data.(fieldName).tableSubstrate;
                experimentTable = obj.arrangeExperimentTable( ...
                    substrate, type, rowNames(iExperiment));

                if isempty(fullResult)
                    fullResult = experimentTable;
                else
                    fullResult = obj.joinTableByRow( ...
                        fullResult, experimentTable);
                end
            end

            substrates = collection.Model.getSubstrateTable();
            metabolites = string(substrates.Metabolite(:))';
            result = obj.extractVariables(fullResult, metabolites, type);
            missingSamples = setdiff( ...
                rowNames, string(result.Properties.RowNames));

            if ~isempty(missingSamples)
                [missingTable, missingFullTable] = ...
                    obj.createMissingSampleTables( ...
                    missingSamples, metabolites, result, fullResult, type);
                result = [result; missingTable];
                fullResult = [fullResult; missingFullTable];
            end

            sortedRowNames = sortrows( ...
                result.Properties.RowNames, 'ascend');
            result = result(sortedRowNames, :);
            fullResult = fullResult(sortedRowNames, :);

        end % assembleSubstrate

        function result = arrangeExperimentTable( ...
                ~, data, column, rowName)

            filtered = data(:, column);

            if isempty(filtered.Properties.RowNames)
                result = table();
                return
            end

            transposed = rows2vars(filtered);
            transposed.Properties.RowNames = rowName;
            result = removevars(transposed, "OriginalVariableNames");

        end % arrangeExperimentTable

        function result = joinTableByRow(~, table1, table2)

            table1.Rownames = table1.Properties.RowNames;
            table2.Rownames = table2.Properties.RowNames;
            commonVariables = intersect( ...
                table1.Properties.VariableNames, ...
                table2.Properties.VariableNames);
            result = outerjoin( ...
                table1, ...
                table2, ...
                'Keys', commonVariables, ...
                'MergeKeys', true);
            result.Properties.RowNames = result.Rownames;
            result = removevars(result, 'Rownames');

        end % joinTableByRow

        function result = extractVariables(~, data, variables, type)

            missingVariables = setdiff( ...
                variables, data.Properties.VariableNames);
            missingColumn = nan(height(data), 1);

            if type == "Label"
                missingColumn = repmat("", height(data), 1);
            end

            for iVariable = 1:numel(missingVariables)
                data.(missingVariables{iVariable}) = missingColumn;
            end

            result = data(:, variables);

        end % extractVariables

        function [missingTable, missingFullTable] = ...
                createMissingSampleTables( ...
                ~, missingSamples, metabolites, tableData, fullData, type)

            fullMetabolites = fullData.Properties.VariableNames;

            switch type
                case "Uptake"
                    missingTable = table( ...
                        'Size', [numel(missingSamples) numel(metabolites)], ...
                        'VariableTypes', repmat( ...
                        "double", 1, numel(metabolites)), ...
                        'VariableNames', tableData.Properties.VariableNames, ...
                        'RowNames', missingSamples);
                    missingTable{:, :} = nan;
                    missingFullTable = table( ...
                        'Size', [numel(missingSamples) numel(fullMetabolites)], ...
                        'VariableTypes', repmat( ...
                        "double", 1, numel(fullMetabolites)), ...
                        'VariableNames', fullMetabolites, ...
                        'RowNames', missingSamples);
                    missingFullTable{:, :} = nan;
                case "Label"
                    missingTable = table( ...
                        'Size', [numel(missingSamples) numel(metabolites)], ...
                        'VariableTypes', repmat( ...
                        "string", 1, numel(metabolites)), ...
                        'VariableNames', tableData.Properties.VariableNames, ...
                        'RowNames', missingSamples);
                    missingTable{:, :} = {""};
                    missingFullTable = table( ...
                        'Size', [numel(missingSamples) numel(fullMetabolites)], ...
                        'VariableTypes', repmat( ...
                        "string", 1, numel(fullMetabolites)), ...
                        'VariableNames', fullMetabolites, ...
                        'RowNames', missingSamples);
                    missingFullTable{:, :} = {""};
            end

        end % createMissingSampleTables

    end % methods (Access = private)

end % classdef
