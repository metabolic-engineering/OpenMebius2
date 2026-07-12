classdef RecordingBatchRepository < handle

    properties
        Batch = struct("Name", "batch")
        LoadCount (1, 1) double = 0
        LoadedLocation
        LoadedExperiments
    end

    methods

        function batch = load(obj, experimentLocation, experiments)

            obj.LoadCount = obj.LoadCount + 1;
            obj.LoadedLocation = experimentLocation;
            obj.LoadedExperiments = experiments;
            batch = obj.Batch;

        end

    end

end
