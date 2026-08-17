classdef PathwayLabelModelStub < handle

    properties
        ReactionID (1, 1) string = ""
        Position (1, 2) double = [nan nan]
        Called (1, 1) logical = false
        ModelTable table = table( ...
            0, 0, ...
            'VariableNames', {'x', 'y'}, ...
            'RowNames', {'R1'})
        PathwayData openmebius.application.model.ModelPathwayData = ...
            openmebius.application.model.ModelPathwayData( ...
            Image = ones(2), ...
            ReactionIDs = "R1", ...
            X = 0, ...
            Y = 0)
    end

    methods

        function updatePathwayLabelPosition( ...
                obj, reactionID, position)

            obj.Called = true;
            obj.ReactionID = reactionID;
            obj.Position = position;
            obj.ModelTable{1, ["x", "y"]} = position;
            obj.PathwayData = openmebius.application.model ...
                .ModelPathwayData( ...
                Image = ones(2), ...
                ReactionIDs = "R1", ...
                X = position(1), ...
                Y = position(2));

        end

        function value = getModelTableGUI(obj)

            value = obj.ModelTable;

        end

        function value = getPathwayData(obj)

            value = obj.PathwayData;

        end

    end

end
