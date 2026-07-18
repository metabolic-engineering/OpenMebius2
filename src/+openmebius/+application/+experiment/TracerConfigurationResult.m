classdef TracerConfigurationResult
    % TRACERCONFIGURATIONRESULT Values returned by tracer editor commands.

    properties (SetAccess = private)
        Position (1, 2) double
        EditorTable table
        Pattern (1, 1) string
        Messages (:, 1) string
    end

    methods

        function obj = TracerConfigurationResult(options)

            arguments
                options.Position (1, 2) double
                options.EditorTable table = table()
                options.Pattern (1, 1) string = ""
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Position = options.Position;
            obj.EditorTable = options.EditorTable;
            obj.Pattern = options.Pattern;
            obj.Messages = options.Messages;

        end % constructor

    end % methods

end % classdef
