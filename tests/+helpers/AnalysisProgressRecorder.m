classdef AnalysisProgressRecorder < handle

    properties
        Completed (:, 1) double = zeros(0, 1)
        Total (:, 1) double = zeros(0, 1)
    end

    methods

        function record(obj, completed, total)

            obj.Completed(end + 1, 1) = completed;
            obj.Total(end + 1, 1) = total;

        end

    end

end
