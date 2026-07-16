classdef RecordingDatasetRepository < handle

    properties
        Paths (:, 1) string = strings(0, 1)
        Values (:, 1) cell = cell(0, 1)
        DataTypes (:, 1) string = strings(0, 1)
        FailAt (1, 1) double = inf
        FailureMessage (1, 1) string = "write failure"
    end

    methods

        function [isSuccess, message] = writeDataset( ...
                obj, ~, path, value, options)

            arguments
                obj
                ~
                path (1, 1) string
                value
                options.DataType (1, 1) string = "double"
            end

            callIndex = numel(obj.Paths) + 1;
            obj.Paths(callIndex, 1) = path;
            obj.Values{callIndex, 1} = value;
            obj.DataTypes(callIndex, 1) = options.DataType;
            isSuccess = callIndex ~= obj.FailAt;

            if isSuccess
                message = "";
            else
                message = obj.FailureMessage;
            end

        end

    end

end
