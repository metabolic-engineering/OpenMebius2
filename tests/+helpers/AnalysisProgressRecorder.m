classdef AnalysisProgressRecorder < handle

    properties
        Phase (:, 1) string = strings(0, 1)
        Completed (:, 1) double = zeros(0, 1)
        Total (:, 1) double = zeros(0, 1)
    end

    methods

        function record(obj, varargin)

            if nargin == 4
                phase = string(varargin{1});
                completed = varargin{2};
                total = varargin{3};
            else
                phase = "";
                completed = varargin{1};
                total = varargin{2};
            end

            obj.Phase(end + 1, 1) = phase;
            obj.Completed(end + 1, 1) = completed;
            obj.Total(end + 1, 1) = total;

        end

    end

end
