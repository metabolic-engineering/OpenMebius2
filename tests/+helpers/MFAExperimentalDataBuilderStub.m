classdef MFAExperimentalDataBuilderStub < handle

    properties
        Result
        ErrorIdentifier (1, 1) string = ""
    end

    properties (SetAccess = private)
        CallCount (1, 1) double = 0
    end

    methods

        function obj = MFAExperimentalDataBuilderStub(result)

            obj.Result = result;

        end

        function result = build(obj, ~, ~, ~, ~)

            obj.CallCount = obj.CallCount + 1;

            if strlength(obj.ErrorIdentifier) > 0
                error( ...
                    obj.ErrorIdentifier, ...
                    "Experimental data construction failed.");
            end

            result = obj.Result;

        end

    end

end
