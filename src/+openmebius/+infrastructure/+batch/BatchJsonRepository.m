classdef BatchJsonRepository
    % BATCHJSONREPOSITORY
    % Reads and writes batch JSON files.

    properties (Access = private)
        JsonFileStore
    end

    methods

        function obj = BatchJsonRepository(options)

            arguments
                options.JsonFileStore = ...
                    openmebius.infrastructure.filesystem.JsonFileStore()
            end

            obj.JsonFileStore = options.JsonFileStore;

        end % constructor

        function save(obj, experimentLocation, fileName, batchTable)

            arguments
                obj
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                fileName (1, 1) string
                batchTable table
            end

            filenameBatch = experimentLocation.batchFile(fileName);

            batchJsonData = openmebius.infrastructure.batch.BatchJsonMapper.toJsonData(batchTable);

            obj.JsonFileStore.writeAtomically( ...
                filenameBatch, ...
                batchJsonData);

        end % save

        function [batchTable, isError, msg] = load( ...
                obj, ...
                experimentLocation, ...
                fileName, ...
                variableNames)

            if nargin < 4
                variableNames = openmebius.infrastructure.batch.BatchJsonMapper.defaultVariableNames();
            end

            filenameBatch = experimentLocation.batchFile(fileName);

            try
                batchData = obj.JsonFileStore.read(filenameBatch);
            catch ME
                batchTable = openmebius.infrastructure.batch.BatchJsonMapper.emptyTable(variableNames);
                isError = true;
                msg = string(ME.message);
                return
            end

            batchTable = openmebius.infrastructure.batch.BatchJsonMapper.toTable(batchData, variableNames);
            isError = false;
            msg = filenameBatch + " is successfully imported.";

        end % load

    end % methods

end % classdef
