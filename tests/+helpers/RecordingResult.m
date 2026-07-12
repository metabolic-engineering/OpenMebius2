classdef RecordingResult < handle

    properties
        WasCalled (1, 1) logical = false
        BatchIDs (:, 1) string = strings(0, 1)
        BatchNames (:, 1) string = strings(0, 1)
        OutputLocation openmebius.domain.result.ResultLocation
        AddDatetime (1, 1) logical = true
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

            obj.WasCalled = true;
            obj.BatchIDs = batchIDs;
            obj.BatchNames = batchNames;
            obj.OutputLocation = outputLocation;
            obj.AddDatetime = options.addDatetime;

        end

    end

end
