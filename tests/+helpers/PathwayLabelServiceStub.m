classdef PathwayLabelServiceStub < handle

    properties
        SetCalled (1, 1) logical = false
        RemoveCalled (1, 1) logical = false
        Model = []
        ReactionID (1, 1) string = ""
        Position (1, 2) double = [nan nan]
        Result = []
        Exception = []
    end

    methods

        function result = setPosition( ...
                obj, model, reactionID, position)

            obj.SetCalled = true;
            obj.Model = model;
            obj.ReactionID = reactionID;
            obj.Position = position;
            result = obj.returnResult();

        end

        function result = removePosition(obj, model, reactionID)

            obj.RemoveCalled = true;
            obj.Model = model;
            obj.ReactionID = reactionID;
            result = obj.returnResult();

        end

    end

    methods (Access = private)

        function result = returnResult(obj)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
