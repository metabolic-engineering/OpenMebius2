classdef RunConfigLaunchViewModel
    % RUNCONFIGLAUNCHVIEWMODEL Values required to display RunConfig.

    properties (SetAccess = private)
        IsAvailable (1, 1) logical
        Session
        Editor
        Notifications (1, :) cell
    end

    methods

        function obj = RunConfigLaunchViewModel(options)

            arguments
                options.IsAvailable (1, 1) logical = false
                options.Session = []
                options.Editor = []
                options.Notifications (1, :) cell = {}
            end

            obj.IsAvailable = options.IsAvailable;
            obj.Session = options.Session;
            obj.Editor = options.Editor;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
