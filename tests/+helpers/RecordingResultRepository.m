classdef RecordingResultRepository < handle

    properties
        Result = struct("Name", "result")
        OpenCount (1, 1) double = 0
        OpenedLocation
    end

    methods

        function result = open(obj, resultLocation)

            obj.OpenCount = obj.OpenCount + 1;
            obj.OpenedLocation = resultLocation;
            result = obj.Result;

        end

    end

end
