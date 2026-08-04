classdef TracerConfigurationViewModel
    % TRACERCONFIGURATIONVIEWMODEL UI values for the tracer editor.

    properties (SetAccess = private)
        IsSuccessful (1, 1) logical
        Position (1, 2) double
        EditorTable table
        Pattern (1, 1) string
        Notifications (:, 1) cell
    end

    methods

        function obj = TracerConfigurationViewModel(options)

            arguments
                options.IsSuccessful (1, 1) logical = false
                options.Position (1, 2) double = [NaN, NaN]
                options.EditorTable table = table()
                options.Pattern (1, 1) string = ""
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.IsSuccessful = options.IsSuccessful;
            obj.Position = options.Position;
            obj.EditorTable = options.EditorTable;
            obj.Pattern = options.Pattern;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
