classdef TracerConfigurationLaunchDecision
    % TRACERCONFIGURATIONLAUNCHDECISION Tracer editor launch decision.

    properties (SetAccess = private)
        IsAllowed (1, 1) logical
        Position (1, 2) double
        EditorTable table
        Message (1, 1) string
    end

    methods

        function obj = TracerConfigurationLaunchDecision(options)

            arguments
                options.IsAllowed (1, 1) logical = false
                options.Position (1, 2) double
                options.EditorTable table = table()
                options.Message (1, 1) string = ""
            end

            obj.IsAllowed = options.IsAllowed;
            obj.Position = options.Position;
            obj.EditorTable = options.EditorTable;
            obj.Message = options.Message;

        end % constructor

    end % methods

end % classdef
