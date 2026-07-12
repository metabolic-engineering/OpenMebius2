classdef RecordingResultExporter < handle

    properties
        WasCalled (1, 1) logical = false
        Result
        BatchIDs (:, 1) string = strings(0, 1)
        BatchNames (:, 1) string = strings(0, 1)
        OutputLocation openmebius.domain.result.ResultLocation
        AddDatetime (1, 1) logical = true
    end

    methods

        function saveResult( ...
                obj, ...
                result, ...
                batchIDs, ...
                batchNames, ...
                outputLocation, ...
                options)

            arguments
                obj
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
                outputLocation openmebius.domain.result.ResultLocation
                options.AddDatetime (1, 1) logical = true
            end

            obj.WasCalled = true;
            obj.Result = result;
            obj.BatchIDs = batchIDs;
            obj.BatchNames = batchNames;
            obj.OutputLocation = outputLocation;
            obj.AddDatetime = options.AddDatetime;

        end

    end

end
