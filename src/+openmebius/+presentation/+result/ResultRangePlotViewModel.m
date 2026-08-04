classdef ResultRangePlotViewModel
    % RESULTRANGEPLOTVIEWMODEL Data and notifications for a range plot.

    properties (SetAccess = private)
        UpperBounds table
        LowerBounds table
        BestFits table
        ReactionNames (:, 1) string
        Notifications (:, 1) cell
    end

    methods

        function obj = ResultRangePlotViewModel(options)

            arguments
                options.UpperBounds table = table()
                options.LowerBounds table = table()
                options.BestFits table = table()
                options.ReactionNames (:, 1) string = strings(0, 1)
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.UpperBounds = options.UpperBounds;
            obj.LowerBounds = options.LowerBounds;
            obj.BestFits = options.BestFits;
            obj.ReactionNames = options.ReactionNames;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
