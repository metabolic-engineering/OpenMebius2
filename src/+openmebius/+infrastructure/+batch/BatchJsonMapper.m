classdef BatchJsonMapper
    % BATCHJSONMAPPER
    % Converts between legacy batch JSON data and the internal batch table.

    methods (Static)

        function batchTable = toTable(batchData, variableNames)

            if nargin < 2 || isempty(variableNames)
                variableNames = openmebius.infrastructure.batch.BatchJsonMapper.defaultVariableNames();
            end

            variableNames = cellstr(variableNames);

            if isempty(batchData)
                batchTable = openmebius.infrastructure.batch.BatchJsonMapper.emptyTable(variableNames);
                return
            end

            batchData = batchData(:);

            for i = 1:numel(batchData)
                batchData(i).config = ...
                    openmebius.domain.batch.BatchConfig.normalize( ...
                    batchData(i).config);
            end

            batchTable = table( ...
                string({batchData.id})', ...
                string({batchData.name})', ...
                {batchData.exp}', ...
                string({batchData.description})', ...
                {batchData.config}', ...
                'VariableNames', variableNames ...
            );

            batchTable.config = arrayfun(@(x) x{:}, batchTable.config);

        end % toTable

        function batchJsonData = toJsonData(batchTable)

            arguments
                batchTable table
            end

            % Preserve the current legacy jsonencode(table) format.
            batchJsonData = batchTable;

        end % toJsonData

        function batchTable = emptyTable(variableNames)

            if nargin < 1 || isempty(variableNames)
                variableNames = openmebius.infrastructure.batch.BatchJsonMapper.defaultVariableNames();
            end

            variableNames = cellstr(variableNames);
            variableTypes = openmebius.infrastructure.batch.BatchJsonMapper.defaultVariableTypes();

            if numel(variableNames) ~= numel(variableTypes)
                error( ...
                    "OpenMebius2:BatchJsonMapper:InvalidSchema", ...
                    "Batch table schema must contain %d variables.", ...
                    numel(variableTypes));
            end

            batchTable = table( ...
                'Size', [0, numel(variableNames)], ...
                'VariableNames', variableNames, ...
                'VariableTypes', variableTypes ...
            );

        end % emptyTable

        function variableNames = defaultVariableNames()

            variableNames = {'id', 'name', 'exp', 'description', 'config'};

        end % defaultVariableNames

        function variableTypes = defaultVariableTypes()

            variableTypes = {'string', 'string', 'cell', 'string', 'struct'};

        end % defaultVariableTypes

    end % methods

end % classdef
