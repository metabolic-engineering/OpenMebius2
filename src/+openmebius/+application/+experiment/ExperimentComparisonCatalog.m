classdef ExperimentComparisonCatalog
    % EXPERIMENTCOMPARISONCATALOG Available comparison selections.

    properties (SetAccess = private)
        ExperimentNames (1, :) string
        DataNames (1, :) string
    end

    methods

        function obj = ExperimentComparisonCatalog(options)

            arguments
                options.ExperimentNames (1, :) string = strings(1, 0)
                options.DataNames (1, :) string = strings(1, 0)
            end

            obj.ExperimentNames = options.ExperimentNames;
            obj.DataNames = options.DataNames;

        end % constructor

    end % methods

end % classdef
