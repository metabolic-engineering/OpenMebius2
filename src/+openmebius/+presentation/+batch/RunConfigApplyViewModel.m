classdef RunConfigApplyViewModel
    % RUNCONFIGAPPLYVIEWMODEL Presentation result for an Apply command.

    properties (SetAccess = private)
        IsSuccessful (1, 1) logical
        Notifications (1, :) cell
    end

    methods

        function obj = RunConfigApplyViewModel(options)

            arguments
                options.IsSuccessful (1, 1) logical = false
                options.Notifications (1, :) cell = {}
            end

            obj.IsSuccessful = options.IsSuccessful;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
