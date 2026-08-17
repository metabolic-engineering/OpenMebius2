classdef DatasetWriteSequence
    % DATASETWRITESEQUENCE Writes an ordered sequence of HDF5 datasets.

    methods (Static)

        function [isSuccess, message] = write( ...
                repository, resultFile, paths, values, dataTypes)

            arguments
                repository
                resultFile (1, 1) string
                paths (:, 1) string
                values (:, 1) cell
                dataTypes (:, 1) string
            end

            if numel(paths) ~= numel(values) || ...
                    numel(paths) ~= numel(dataTypes)
                error( ...
                    "OpenMebius2:DatasetWriteSequence:SizeMismatch", ...
                    "Dataset paths, values, and data types must have " + ...
                    "the same number of elements.");
            end

            isSuccess = true;
            message = "";

            for i = 1:numel(paths)
                [isSuccess, message] = repository.writeDataset( ...
                    resultFile, ...
                    paths(i), ...
                    values{i}, ...
                    DataType = dataTypes(i));

                if ~isSuccess
                    message = "Failed to write " + paths(i) + ": " + ...
                        string(message);
                    return;
                end

            end

        end % write

    end % methods (Static)

end % classdef
