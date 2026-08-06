classdef ViewComparisonPlotViewModel
    % VIEWCOMPARISONPLOTVIEWMODEL Aligned data drawn by ViewComparison.

    properties (SetAccess = private)
        IsAvailable (1, 1) logical
        BatchIDs (:, 1) string
        UpperBounds table
        LowerBounds table
        BestFits table
        ReactionIDs (:, 1) string
        ReactionNames (:, 1) string
        ReactionLabels (:, 1) string
        Notifications (:, 1) cell
    end

    methods

        function obj = ViewComparisonPlotViewModel(options)

            arguments
                options.IsAvailable (1, 1) logical = false
                options.BatchIDs (:, 1) string = strings(0, 1)
                options.UpperBounds table = table()
                options.LowerBounds table = table()
                options.BestFits table = table()
                options.ReactionIDs (:, 1) string = strings(0, 1)
                options.ReactionNames (:, 1) string = strings(0, 1)
                options.ReactionLabels (:, 1) string = strings(0, 1)
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.IsAvailable = options.IsAvailable;
            obj.BatchIDs = options.BatchIDs;
            obj.UpperBounds = options.UpperBounds;
            obj.LowerBounds = options.LowerBounds;
            obj.BestFits = options.BestFits;
            obj.ReactionIDs = options.ReactionIDs;
            obj.ReactionNames = options.ReactionNames;
            obj.ReactionLabels = options.ReactionLabels;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
