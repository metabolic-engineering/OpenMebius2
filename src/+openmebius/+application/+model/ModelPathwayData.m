classdef ModelPathwayData
    % MODELPATHWAYDATA UI-independent pathway image and label positions.

    properties (SetAccess = private)
        Image
        ReactionIDs (:, 1) string
        X (:, 1) double
        Y (:, 1) double
    end

    methods

        function obj = ModelPathwayData(options)

            arguments
                options.Image = []
                options.ReactionIDs (:, 1) string = strings(0, 1)
                options.X (:, 1) double = zeros(0, 1)
                options.Y (:, 1) double = zeros(0, 1)
            end

            numberOfReactions = numel(options.ReactionIDs);

            if numel(options.X) ~= numberOfReactions || ...
                    numel(options.Y) ~= numberOfReactions
                error( ...
                    "OpenMebius2:ModelPathway:PositionMismatch", ...
                    "Pathway reaction IDs and label positions must match.");
            end

            obj.Image = options.Image;
            obj.ReactionIDs = options.ReactionIDs;
            obj.X = options.X;
            obj.Y = options.Y;

        end % constructor

    end % methods

end % classdef
