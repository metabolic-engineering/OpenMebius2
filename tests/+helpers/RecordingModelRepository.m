classdef RecordingModelRepository < handle

    properties
        Model = struct("Name", "model")
        LoadCount (1, 1) double = 0
        LoadedLocation
    end

    methods

        function model = load(obj, modelLocation)

            obj.LoadCount = obj.LoadCount + 1;
            obj.LoadedLocation = modelLocation;
            model = obj.Model;

        end

    end

end
