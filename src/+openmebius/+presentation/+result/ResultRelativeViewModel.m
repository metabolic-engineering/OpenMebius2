classdef ResultRelativeViewModel
    % RESULTRELATIVEVIEWMODEL Relative-flux display request.

    properties (SetAccess = private)
        RelativeTo (1, 1) string
        Notifications (:, 1) cell
    end

    methods

        function obj = ResultRelativeViewModel(options)

            arguments
                options.RelativeTo (1, 1) string = ""
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.RelativeTo = options.RelativeTo;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
