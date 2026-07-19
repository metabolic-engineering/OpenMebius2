classdef LabelConfigurationEventRecorder < handle

    properties
        Applied (1, 1) logical = false
        Closed (1, 1) logical = false
        EventData = []
    end

    methods

        function recordApplied(obj, ~, event)

            obj.Applied = true;
            obj.EventData = event;

        end

        function recordClosed(obj, ~, ~)

            obj.Closed = true;

        end

    end

end
