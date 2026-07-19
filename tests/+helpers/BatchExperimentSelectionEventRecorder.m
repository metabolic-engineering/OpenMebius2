classdef BatchExperimentSelectionEventRecorder < handle

    properties
        Applied (1, 1) logical = false
        Closed (1, 1) logical = false
        Selection = []
    end

    methods

        function recordApplied(obj, ~, event)

            obj.Applied = true;
            obj.Selection = event.Selection;

        end

        function recordClosed(obj, ~, ~)

            obj.Closed = true;

        end

    end

end % classdef
