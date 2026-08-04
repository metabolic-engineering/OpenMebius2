classdef PathwayLabelEditResult
    % PATHWAYLABELEDITRESULT Updated pathway position and display data.

    properties (SetAccess = private)
        ReactionID (1, 1) string
        Position (1, 2) double
        IsRemoved (1, 1) logical
        ModelTable table
        PathwayData openmebius.application.model.ModelPathwayData
        Messages (:, 1) string
    end

    methods

        function obj = PathwayLabelEditResult(options)

            arguments
                options.ReactionID (1, 1) string
                options.Position (1, 2) double
                options.IsRemoved (1, 1) logical
                options.ModelTable table
                options.PathwayData openmebius.application.model ...
                    .ModelPathwayData
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.ReactionID = options.ReactionID;
            obj.Position = options.Position;
            obj.IsRemoved = options.IsRemoved;
            obj.ModelTable = options.ModelTable;
            obj.PathwayData = options.PathwayData;
            obj.Messages = options.Messages;

        end % constructor

    end % methods

end % classdef
