classdef ExperimentComparisonSelection
    % EXPERIMENTCOMPARISONSELECTION Selected comparison tables.

    properties (SetAccess = private)
        ExperimentNames (1, :) string
        DataNames (1, :) string
        Tables (:, 1) cell
    end

    methods

        function obj = ExperimentComparisonSelection(options)

            arguments
                options.ExperimentNames (1, :) string = strings(1, 0)
                options.DataNames (1, :) string = strings(1, 0)
                options.Tables (:, 1) cell = cell(0, 1)
            end

            if numel(options.DataNames) ~= numel(options.Tables)
                error( ...
                    "OpenMebius2:ExperimentComparison:TableCountMismatch", ...
                    "One comparison table is required for each data item.");
            end

            obj.ExperimentNames = options.ExperimentNames;
            obj.DataNames = options.DataNames;
            obj.Tables = options.Tables;

        end % constructor

    end % methods

end % classdef
