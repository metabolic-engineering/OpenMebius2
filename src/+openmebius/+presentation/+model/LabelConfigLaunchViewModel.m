classdef LabelConfigLaunchViewModel
    % LABELCONFIGLAUNCHVIEWMODEL Values required to display LabelConfig.

    properties (SetAccess = private)
        IsAvailable (1, 1) logical
        LabelTable table
        RatioTables struct
        Notifications (1, :) cell
    end

    methods

        function obj = LabelConfigLaunchViewModel(options)

            arguments
                options.IsAvailable (1, 1) logical = false
                options.LabelTable table = table()
                options.RatioTables struct = struct()
                options.Notifications (1, :) cell = {}
            end

            obj.IsAvailable = options.IsAvailable;
            obj.LabelTable = options.LabelTable;
            obj.RatioTables = options.RatioTables;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
