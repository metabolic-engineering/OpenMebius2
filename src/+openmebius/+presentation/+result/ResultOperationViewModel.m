classdef ResultOperationViewModel
    % RESULTOPERATIONVIEWMODEL UI values for result-area commands.

    properties (SetAccess = private)
        Report = []
        Notifications (:, 1) cell
    end

    methods

        function obj = ResultOperationViewModel(options)

            arguments
                options.Report = []
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.Report = options.Report;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
