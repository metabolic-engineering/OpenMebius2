classdef AnalysisMessageObserverStub < handle

    properties (SetAccess = private)
        Levels (:, 1) string = strings(0, 1)
        Messages (:, 1) string = strings(0, 1)
    end

    methods

        function report(obj, level, message)

            obj.Levels(end + 1, 1) = string(level);
            obj.Messages(end + 1, 1) = string(message);

        end

    end

end
