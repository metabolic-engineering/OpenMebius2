classdef BatchJsonRepository
    % BATCHJSONREPOSITORY
    % Reads and writes legacy batch JSON files.

    methods

        function save(~, experimentLocation, fileName, batchTable)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                fileName (1, 1) string
                batchTable table
            end

            ioInstance = IO(experimentLocation.Directory);
            filenameBatch = experimentLocation.batchFile(fileName);

            batchJsonData = openmebius.infrastructure.batch.BatchJsonMapper.toJsonData(batchTable);

            ioInstance.exportJSONFile(filenameBatch, batchJsonData);

        end % save

        function [batchTable, isError, msg] = load( ...
                ~, ...
                experimentLocation, ...
                fileName, ...
                variableNames)

            if nargin < 4
                variableNames = openmebius.infrastructure.batch.BatchJsonMapper.defaultVariableNames();
            end

            ioInstance = IO(experimentLocation.Directory);
            filenameBatch = experimentLocation.batchFile(fileName);

            batchData = ioInstance.importJSONFile(filenameBatch);
            msg = ioInstance.statusMsg();
            isError = ioInstance.isError;

            if isError
                batchTable = openmebius.infrastructure.batch.BatchJsonMapper.emptyTable(variableNames);
                return
            end

            batchTable = openmebius.infrastructure.batch.BatchJsonMapper.toTable(batchData, variableNames);

        end % load

    end % methods

end % classdef
