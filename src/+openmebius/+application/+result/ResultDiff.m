classdef ResultDiff
    % RESULTDIFF Analysis-setting differences between two saved results.

    properties (SetAccess = private)
        BatchIDs (2, 1) string
        BatchNames (2, 1) string
        Differences (:, 1) string
    end

    methods

        function obj = ResultDiff(options)

            arguments
                options.BatchIDs (2, 1) string
                options.BatchNames (2, 1) string
                options.Differences (:, 1) string = strings(0, 1)
            end

            obj.BatchIDs = options.BatchIDs;
            obj.BatchNames = options.BatchNames;
            obj.Differences = options.Differences;

        end % constructor

    end % methods

end % classdef
