classdef MessageReportingWorkflowStub < handle

    properties (SetAccess = private)
        Result
        Level (1, 1) string
        Message (1, 1) string
        CallCount (1, 1) double = 0
    end

    methods

        function obj = MessageReportingWorkflowStub( ...
                result, level, message)

            obj.Result = result;
            obj.Level = string(level);
            obj.Message = string(message);

        end

        function result = run(obj, varargin)

            obj.CallCount = obj.CallCount + 1;
            reporter = obj.findReporter(varargin);
            reporter(obj.Level, obj.Message);
            result = obj.Result;

        end

    end

    methods (Access = private)

        function reporter = findReporter(~, values)

            reporter = [];

            for i = 1:(numel(values) - 1)
                name = values{i};

                if (ischar(name) || isstring(name)) && ...
                        string(name) == "MessageReporter"
                    reporter = values{i + 1};
                    break
                end
            end

            if isempty(reporter)
                error( ...
                    "OpenMebius2:Test:MissingMessageReporter", ...
                    "MessageReporter was not supplied to the workflow.");
            end

        end

    end

end
