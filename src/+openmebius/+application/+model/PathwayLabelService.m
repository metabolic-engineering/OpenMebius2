classdef PathwayLabelService < handle
    % PATHWAYLABELSERVICE Updates pathway label positions.

    methods

        function result = setPosition( ...
                obj, model, reactionID, position)

            arguments
                obj
                model
                reactionID (1, 1) string
                position (1, 2) double
            end

            obj.validateModel(model);
            obj.validateReaction(reactionID);

            if any(~isfinite(position))
                error( ...
                    "OpenMebius2:PathwayLabel:InvalidPosition", ...
                    "Pathway label coordinates must be finite values.");
            end

            model.updatePathwayLabelPosition(reactionID, position);
            message = sprintf( ...
                "Label position added to %s at x: %.3f, y: %.3f.", ...
                reactionID, position(1), position(2));
            result = obj.createResult( ...
                model, reactionID, position, false, message);

        end % setPosition

        function result = removePosition(obj, model, reactionID)

            arguments
                obj
                model
                reactionID (1, 1) string
            end

            obj.validateModel(model);
            obj.validateReaction(reactionID);
            position = [nan nan];
            model.updatePathwayLabelPosition(reactionID, position);
            result = obj.createResult( ...
                model, ...
                reactionID, ...
                position, ...
                true, ...
                "Label position removed from " + reactionID + ".");

        end % removePosition

    end % methods

    methods (Access = private)

        function result = createResult( ...
                ~, model, reactionID, position, isRemoved, message)

            result = openmebius.application.model ...
                .PathwayLabelEditResult( ...
                    ReactionID = reactionID, ...
                    Position = position, ...
                    IsRemoved = isRemoved, ...
                    ModelTable = model.getModelTableGUI(), ...
                    PathwayData = model.getPathwayData(), ...
                    Messages = string(message));

        end % createResult

        function validateModel(~, model)

            if isempty(model) || ...
                    (isa(model, "handle") && ~isvalid(model))
                error( ...
                    "OpenMebius2:PathwayLabel:ModelUnavailable", ...
                    "Model data is not available.");
            end

        end % validateModel

        function validateReaction(~, reactionID)

            if strlength(strtrim(reactionID)) == 0
                error( ...
                    "OpenMebius2:PathwayLabel:ReactionRequired", ...
                    "Please select a reaction.");
            end

        end % validateReaction

    end % methods (Access = private)

end % classdef
