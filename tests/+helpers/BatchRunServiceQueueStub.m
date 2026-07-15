classdef BatchRunServiceQueueStub < handle

    properties
        Statuses (:, 1) string
        CallCount (1, 1) double = 0
        BatchIds (:, 1) string = strings(0, 1)
        CreateArguments cell = {}
        EmitCallbacks (1, 1) logical = false
    end

    methods

        function obj = BatchRunServiceQueueStub(statuses, options)

            arguments
                statuses string
                options.EmitCallbacks (1, 1) logical = false
            end

            obj.Statuses = string(statuses(:));
            obj.EmitCallbacks = options.EmitCallbacks;

        end

        function status = run(obj, varargin)

            obj.CallCount = obj.CallCount + 1;
            obj.BatchIds(end + 1, 1) = string(varargin{6});
            obj.CreateArguments = varargin;
            status = obj.Statuses(obj.CallCount);

            if obj.EmitCallbacks
                obj.invokeCallback(varargin, "MessageReporter", "message");
                obj.invokeCallback(varargin, "ResultReporter", "result");
            end

        end

    end

    methods (Static, Access = private)

        function invokeCallback(arguments, name, payload)

            index = [];

            for i = 1:numel(arguments)
                value = arguments{i};

                if (ischar(value) || isstring(value)) && ...
                        isscalar(string(value)) && string(value) == name
                    index = i;
                    break
                end
            end

            if ~isempty(index)
                arguments{index + 1}(payload);
            end

        end

    end

end
