classdef Hdf5ResultRepository < handle
    % HDF5RESULTREPOSITORY
    % Writes flux analysis result datasets to HDF5.

    methods

        function assertResultDirectory(~, resultLocation)

            arguments
                ~
                resultLocation openmebius.domain.result.ResultLocation
            end

            if ~resultLocation.directoryExists()
                error( ...
                    "OpenMebius2:Hdf5ResultRepository:DirectoryNotFound", ...
                    "Result directory does not exist: %s", ...
                    resultLocation.Directory);
            end

        end % assertResultDirectory

        function [isSuccess, msg] = writeDataset(~, pathFile, pathData, data, options)

            arguments
                ~
                pathFile (1, 1) string
                pathData (1, 1) string
                data
                options.DataType (1, 1) string = "double"
            end

            [isSuccess, msg] = openmebius.infrastructure.filesystem.Hdf5FileStore ...
                .writeDataset( ...
                pathFile, ...
                pathData, ...
                data, ...
                DataType = options.DataType);

        end % writeDataset

    end % methods

end % classdef
