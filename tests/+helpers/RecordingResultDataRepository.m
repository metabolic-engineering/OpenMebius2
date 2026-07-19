classdef RecordingResultDataRepository < handle

    properties
        ResultData = struct( ...
            'ID', "recorded", ...
            'status', false(1, 4))
        ReadCount (1, 1) double = 0
        ResultLocation
        ResultId (1, 1) string = ""
        ReadStatus (1, 4) logical = false(1, 4)
    end

    methods

        function data = readResultData(obj, resultLocation, id, options)

            arguments
                obj
                resultLocation
                id (1, 1) string
                options.ReadStatus (1, 4) logical = ...
                    [true, true, true, true]
            end

            obj.ReadCount = obj.ReadCount + 1;
            obj.ResultLocation = resultLocation;
            obj.ResultId = id;
            obj.ReadStatus = options.ReadStatus;
            data = obj.ResultData;

        end

    end

end
