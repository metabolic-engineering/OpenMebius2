classdef PathwayPlotViewModel
    % PATHWAYPLOTVIEWMODEL Pathway image and labels prepared for rendering.

    properties (SetAccess = private)
        Image
        X (:, 1) double
        Y (:, 1) double
        Labels (:, 1) string
        Highlight (:, 1) logical
        IsDarkTheme (1, 1) logical
        Notification = []
    end

    methods

        function obj = PathwayPlotViewModel(options)

            arguments
                options.Image = []
                options.X (:, 1) double = zeros(0, 1)
                options.Y (:, 1) double = zeros(0, 1)
                options.Labels (:, 1) string = strings(0, 1)
                options.Highlight (:, 1) logical = false(0, 1)
                options.IsDarkTheme (1, 1) logical = false
                options.Notification = []
            end

            numberOfLabels = numel(options.Labels);

            if numel(options.X) ~= numberOfLabels || ...
                    numel(options.Y) ~= numberOfLabels || ...
                    numel(options.Highlight) ~= numberOfLabels
                error( ...
                    "OpenMebius2:PathwayPlot:SizeMismatch", ...
                    "Pathway labels, positions, and highlights must match.");
            end

            obj.Image = options.Image;
            obj.X = options.X;
            obj.Y = options.Y;
            obj.Labels = options.Labels;
            obj.Highlight = options.Highlight;
            obj.IsDarkTheme = options.IsDarkTheme;
            obj.Notification = options.Notification;

        end % constructor

    end % methods

end % classdef
