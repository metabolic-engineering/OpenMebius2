classdef BatchRunServiceQueueStub < handle

    properties
        Statuses (:, 1) string
        CallCount (1, 1) double = 0
        BatchIds (:, 1) string = strings(0, 1)
        Provenances cell = {}
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

        function result = run(obj, varargin)

            obj.CallCount = obj.CallCount + 1;
            obj.BatchIds(end + 1, 1) = string(varargin{6});
            obj.CreateArguments = varargin;
            status = obj.Statuses(obj.CallCount);
            result = helpers.BatchRunServiceQueueStub.toResult(status);
            provenanceIndex = obj.namedArgumentIndex( ...
                varargin, "Provenance");

            if ~isempty(provenanceIndex)
                obj.Provenances{end + 1, 1} = ...
                    varargin{provenanceIndex + 1};
            end

            if obj.EmitCallbacks
                obj.invokeCallback(varargin, "MessageReporter", "message");
                obj.invokeCallback(varargin, "ResultReporter", "result");
                obj.invokeProgressCallback(varargin, 1, 4);
            end

        end

    end

    methods (Static, Access = private)

        function result = toResult(status)

            switch lower(strtrim(string(status)))
                case "finished"
                    result = openmebius.application.batch ...
                        .BatchExecutionResult(true);
                case "canceled"
                    result = openmebius.application.batch ...
                        .BatchExecutionResult(false, Canceled = true);
                otherwise
                    result = openmebius.application.batch ...
                        .BatchExecutionResult( ...
                            false, ...
                            ErrorMessage = ...
                                "One or more batch jobs failed.");
            end

        end

        function invokeCallback(arguments, name, payload)

            index = helpers.BatchRunServiceQueueStub ...
                .namedArgumentIndex(arguments, name);

            if ~isempty(index)
                arguments{index + 1}(payload);
            end

        end

        function invokeProgressCallback(arguments, completed, total)

            index = helpers.BatchRunServiceQueueStub ...
                .namedArgumentIndex(arguments, "ProgressReporter");

            if ~isempty(index)
                arguments{index + 1}(completed, total);
            end

        end

        function index = namedArgumentIndex(arguments, name)

            index = [];

            for i = 1:numel(arguments)
                value = arguments{i};

                if (ischar(value) || isstring(value)) && ...
                        isscalar(string(value)) && string(value) == name
                    index = i;
                    break
                end
            end

        end

    end

end
