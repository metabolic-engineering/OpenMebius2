classdef BatchJsonMapper
    % BATCHJSONMAPPER
    % Converts between batch JSON data and the internal batch table.

    methods (Static)

        function batchTable = toTable(batchJsonData, variableNames)

            if nargin < 2 || isempty(variableNames)
                variableNames = openmebius.infrastructure.batch.BatchJsonMapper.defaultVariableNames();
            end

            variableNames = cellstr(variableNames);

            document = ...
                openmebius.infrastructure.batch.BatchJsonMigration.toCurrentDocument( ...
                batchJsonData);
            batchData = document.batches;

            if isempty(batchData)
                batchTable = openmebius.infrastructure.batch.BatchJsonMapper.emptyTable(variableNames);
                return
            end

            batchData = batchData(:);
            numBatches = numel(batchData);

            ids = strings(numBatches, 1);
            names = strings(numBatches, 1);
            expValues = cell(numBatches, 1);
            descriptions = strings(numBatches, 1);
            configValues = cell(numBatches, 1);
            contentHashes = strings(numBatches, 1);

            for i = 1:numBatches
                ids(i) = string(batchData(i).id);
                names(i) = string(batchData(i).name);
                expValues{i} = batchData(i).exp;
                descriptions(i) = string(batchData(i).description);
                configValues{i} = ...
                    openmebius.domain.batch.BatchConfig.normalize( ...
                    batchData(i).config);
                contentHashes(i) = string(batchData(i).contentHash);
            end

            batchTable = table( ...
                ids, ...
                names, ...
                expValues, ...
                descriptions, ...
                configValues, ...
                contentHashes, ...
                'VariableNames', variableNames ...
                );

            batchTable.config = arrayfun(@(x) x{:}, batchTable.config);

        end % toTable

        function batchJsonData = toJsonData(batchTable)

            arguments
                batchTable table
            end

            batchData = ...
                openmebius.infrastructure.batch.BatchJsonMapper.toBatchData( ...
                batchTable);
            batchJsonData = ...
                openmebius.infrastructure.batch.BatchJsonMigration.createCurrentDocument( ...
                batchData);

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

            variableNames = ...
                {'id', 'name', 'exp', 'description', 'config', 'contentHash'};

        end % defaultVariableNames

        function variableTypes = defaultVariableTypes()

            variableTypes = ...
                {'string', 'string', 'cell', 'string', 'struct', 'string'};

        end % defaultVariableTypes

    end % methods

    methods (Static, Access = private)

        function batchData = toBatchData(batchTable)

            batchData = struct( ...
                'id', {}, ...
                'name', {}, ...
                'exp', {}, ...
                'description', {}, ...
                'config', {}, ...
                'contentHash', {});

            for i = 1:height(batchTable)
                batchData(i, 1).id = batchTable.id(i);
                batchData(i, 1).name = batchTable.name(i);
                batchData(i, 1).exp = batchTable.exp{i};
                batchData(i, 1).description = batchTable.description(i);
                batchData(i, 1).config = batchTable.config(i);
                batchData(i, 1).contentHash = batchTable.contentHash(i);
            end

        end % toBatchData

    end % methods

end % classdef
