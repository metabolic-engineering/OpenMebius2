classdef LabelConfigurationAppliedEventData < event.EventData
    % LABELCONFIGURATIONAPPLIEDEVENTDATA Carries edited label settings.

    properties (SetAccess = private)
        LabelTable table
        RatioTables struct
    end

    methods

        function obj = LabelConfigurationAppliedEventData( ...
                labelTable, ratioTables)

            arguments
                labelTable table
                ratioTables struct
            end

            obj.LabelTable = labelTable;
            obj.RatioTables = ratioTables;

        end % constructor

    end % methods

end % classdef
