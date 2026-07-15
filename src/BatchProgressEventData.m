classdef BatchProgressEventData < event.EventData

    properties
        data
    end % properties

    methods

        function data = BatchProgressEventData(type, progress)

            arguments
                type (1, 1) string
                progress
            end

            if type ~= "BatchIteration"
                error( ...
                    "OpenMebius2:BatchProgressEventData:" + ...
                    "UnsupportedType", ...
                    "Batch progress event type must be BatchIteration.");
            end

            data.data = progress;

        end % BatchProgressEventData

    end % methods

end % classdef
