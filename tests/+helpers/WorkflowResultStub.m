classdef WorkflowResultStub < handle

    properties (SetAccess = private)
        Result
        CallCount (1, 1) double = 0
        LastArguments (1, :) cell = cell(1, 0)
    end

    methods

        function obj = WorkflowResultStub(result)

            obj.Result = result;

        end

        function result = run(obj, varargin)

            obj.CallCount = obj.CallCount + 1;
            obj.LastArguments = varargin;
            result = obj.Result;

        end

        function invokeCallback(obj, name, varargin)

            for index = 1:numel(obj.LastArguments) - 1
                candidate = obj.LastArguments{index};

                if (ischar(candidate) || isstring(candidate)) && ...
                        isscalar(string(candidate)) && ...
                        string(candidate) == string(name)
                    obj.LastArguments{index + 1}(varargin{:});
                    return
                end

            end

            error("Callback '%s' was not supplied.", string(name));

        end

    end

end
