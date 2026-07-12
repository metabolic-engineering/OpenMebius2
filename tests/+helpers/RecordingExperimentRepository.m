classdef RecordingExperimentRepository < handle

    properties
        Experiments = struct("Name", "experiments")
        LoadCount (1, 1) double = 0
        LoadedLocation
        LoadedModel
    end

    methods

        function experiments = load(obj, experimentLocation, model)

            obj.LoadCount = obj.LoadCount + 1;
            obj.LoadedLocation = experimentLocation;
            obj.LoadedModel = model;
            experiments = obj.Experiments;

        end

    end

end
