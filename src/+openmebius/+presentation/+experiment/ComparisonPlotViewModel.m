classdef ComparisonPlotViewModel
    % COMPARISONPLOTVIEWMODEL Plot-ready comparison series.

    properties (SetAccess = private)
        IsAvailable (1, 1) logical
        ExperimentNames (1, :) string
        DataNames (1, :) string
        Values (:, 1) cell
        StackLabels (:, 1) cell
        Notifications (:, 1) cell
    end

    methods

        function obj = ComparisonPlotViewModel(options)

            arguments
                options.IsAvailable (1, 1) logical = false
                options.ExperimentNames (1, :) string = strings(1, 0)
                options.DataNames (1, :) string = strings(1, 0)
                options.Values (:, 1) cell = cell(0, 1)
                options.StackLabels (:, 1) cell = cell(0, 1)
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.IsAvailable = options.IsAvailable;
            obj.ExperimentNames = options.ExperimentNames;
            obj.DataNames = options.DataNames;
            obj.Values = options.Values;
            obj.StackLabels = options.StackLabels;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
