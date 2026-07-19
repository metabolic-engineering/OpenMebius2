classdef TemplateModelLoadServiceStub < handle

    properties
        Result
        Exception = []
        Called (1, 1) logical = false
        ModelLocation
    end

    methods

        function result = load(obj, modelLocation)

            obj.Called = true;
            obj.ModelLocation = modelLocation;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
