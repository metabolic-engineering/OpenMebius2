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

            ioInstance.exportJSONFile(filenameBatch, batchTable);

        end % save

        function [batchData, isError, msg] = load(~, experimentLocation, fileName)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                fileName (1, 1) string
            end

            ioInstance = IO(experimentLocation.Directory);
            filenameBatch = experimentLocation.batchFile(fileName);

            batchData = ioInstance.importJSONFile(filenameBatch);
            msg = ioInstance.statusMsg();
            isError = ioInstance.isError;

        end % load

    end % methods

end % classdef
