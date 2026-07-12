classdef Hdf5FileStore
    % HDF5FILESTORE
    % Writes HDF5 datasets without depending on legacy file state.

    methods (Static)

        function [isSuccess, msg] = writeDataset(pathFile, pathData, data, options)

            arguments
                pathFile (1, 1) string
                pathData (1, 1) string
                data
                options.DataType (1, 1) string ...
                    {mustBeMember(options.DataType, ...
                    ["int8", "uint8", "int16", "uint16", "int32", "uint32", "int64", "uint64", "single", "double", "string"])} ...
                    = "double"
            end

            isSuccess = true;
            msg = "";

            try
                h5read(pathFile, pathData);
            catch

                try
                    h5create(pathFile, pathData, size(data), "DataType", options.DataType);
                catch
                    isSuccess = false;
                    msg = "The dataset " + pathData + ...
                        " cannot be created in the file " + pathFile + ".";
                    return
                end

            end

            try
                h5write(pathFile, pathData, data);
            catch
                isSuccess = false;
                msg = "The data cannot be written to the dataset " + ...
                    pathData + " in the file " + pathFile + ".";
            end

        end % writeDataset

    end % methods

end % classdef
