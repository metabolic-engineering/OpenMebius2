classdef NotificationSinkSpy < handle

    properties
        Name (1, 1) string
        Messages (1, :) cell = {}
        ThrowOnWrite (1, 1) logical = false
        WriteAttempts (1, 1) double = 0
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

            obj.WriteAttempts = obj.WriteAttempts + 1;

            if obj.ThrowOnWrite
                error("OpenMebius2:Test:SinkFailure", "sink failed");
            end

            obj.Messages{end + 1} = message;

        end

        function value = count(obj)

            value = numel(obj.Messages);

        end

        function value = attemptCount(obj)

            value = obj.WriteAttempts;

        end

    end

end
