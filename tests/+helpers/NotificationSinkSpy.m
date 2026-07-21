classdef NotificationSinkSpy < handle

    properties
        Name (1, 1) string
        Messages (1, :) cell = {}
        ThrowOnWrite (1, 1) logical = false
    end

    methods

        function obj = NotificationSinkSpy(name, options)

            arguments
                name (1, 1) string
                options.ThrowOnWrite (1, 1) logical = false
            end

            obj.Name = name;
            obj.ThrowOnWrite = options.ThrowOnWrite;

        end

        function write(obj, message)

            if obj.ThrowOnWrite
                error("OpenMebius2:Test:SinkFailure", "sink failed");
            end

            obj.Messages{end + 1} = message;

        end

        function value = count(obj)

            value = numel(obj.Messages);

        end

    end

end
