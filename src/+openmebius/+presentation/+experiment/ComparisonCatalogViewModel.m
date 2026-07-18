classdef ComparisonCatalogViewModel
    % COMPARISONCATALOGVIEWMODEL Selectable comparison values.

    properties (SetAccess = private)
        IsAvailable (1, 1) logical
        ExperimentItems (1, :) string
        DataItems (1, :) string
        Notifications (:, 1) cell
    end

    methods

        function obj = ComparisonCatalogViewModel(options)

            arguments
                options.IsAvailable (1, 1) logical = false
                options.ExperimentItems (1, :) string = strings(1, 0)
                options.DataItems (1, :) string = strings(1, 0)
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.IsAvailable = options.IsAvailable;
            obj.ExperimentItems = options.ExperimentItems;
            obj.DataItems = options.DataItems;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
