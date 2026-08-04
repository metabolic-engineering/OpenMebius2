classdef MSViewEventRecorder < handle

    properties
        ComparisonRequested (1, 1) logical = false
        Closed (1, 1) logical = false
    end

    methods

        function recordComparisonRequested(obj, ~, ~)

            obj.ComparisonRequested = true;

        end

        function recordClosed(obj, ~, ~)

            obj.Closed = true;

        end

    end

end
