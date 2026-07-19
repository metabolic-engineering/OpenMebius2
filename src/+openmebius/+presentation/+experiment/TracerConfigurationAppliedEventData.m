classdef TracerConfigurationAppliedEventData < event.EventData
    % TRACERCONFIGURATIONAPPLIEDEVENTDATA Carries tracer editor values.

    properties (SetAccess = private)
        Position (1, 2) double
        EditorTable table
    end

    methods

        function obj = TracerConfigurationAppliedEventData( ...
                position, editorTable)

            arguments
                position (1, 2) double
                editorTable table
            end

            obj.Position = position;
            obj.EditorTable = editorTable;

        end % constructor

    end % methods

end % classdef
