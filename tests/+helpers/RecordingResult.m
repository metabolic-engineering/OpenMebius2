classdef RecordingResult < handle

    properties
        SaveResultWasCalled (1, 1) logical = false
        SaveResultDataWasCalled (1, 1) logical = false
        BatchIDs (:, 1) string = strings(0, 1)
        BatchNames (:, 1) string = strings(0, 1)
        OutputLocation openmebius.domain.result.ResultLocation
        AddDatetime (1, 1) logical = true
        ResultDataBatchIDs (:, 1) string = strings(0, 1)
        ResultDataNames (:, 1) string = strings(0, 1)
        ResultDataLocations cell = cell(0, 1)
        ResultDataFormats (:, 1) string = strings(0, 1)
    end

    methods

        function saveResult( ...
                obj, ...
                batchIDs, ...
                batchNames, ...
                outputLocation, ...
                options)

            arguments
                obj
                batchIDs (:, 1) string
                batchNames (:, 1) string
                outputLocation openmebius.domain.result.ResultLocation
                options.addDatetime (1, 1) logical = true
            end

            obj.SaveResultWasCalled = true;
            obj.BatchIDs = batchIDs;
            obj.BatchNames = batchNames;
            obj.OutputLocation = outputLocation;
            obj.AddDatetime = options.addDatetime;

        end

        function saveResultData( ...
                obj, ...
                batchID, ...
                name, ...
                directoryPath, ...
                fmt)

            arguments
                obj
                batchID (1, 1) string
                name (1, 1) string
                directoryPath
                fmt (1, 1) string = "xlsx"
            end

            obj.SaveResultDataWasCalled = true;
            obj.ResultDataBatchIDs(end + 1, 1) = batchID;
            obj.ResultDataNames(end + 1, 1) = name;
            obj.ResultDataLocations{end + 1, 1} = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                directoryPath);
            obj.ResultDataFormats(end + 1, 1) = fmt;

        end

    end

end
