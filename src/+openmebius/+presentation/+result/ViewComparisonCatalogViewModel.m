classdef ViewComparisonCatalogViewModel
    % VIEWCOMPARISONCATALOGVIEWMODEL Batch rows shown by ViewComparison.

    properties (SetAccess = private)
        IsAvailable (1, 1) logical
        BatchIDs (:, 1) string
        BatchNames (:, 1) string
        ExperimentNames (:, 1) string
        Contents (:, 1) string
        Notifications (:, 1) cell
    end

    methods

        function obj = ViewComparisonCatalogViewModel(options)

            arguments
                options.IsAvailable (1, 1) logical = false
                options.BatchIDs (:, 1) string = strings(0, 1)
                options.BatchNames (:, 1) string = strings(0, 1)
                options.ExperimentNames (:, 1) string = strings(0, 1)
                options.Contents (:, 1) string = strings(0, 1)
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.IsAvailable = options.IsAvailable;
            obj.BatchIDs = options.BatchIDs;
            obj.BatchNames = options.BatchNames;
            obj.ExperimentNames = options.ExperimentNames;
            obj.Contents = options.Contents;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
