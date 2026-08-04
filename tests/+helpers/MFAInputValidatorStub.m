classdef MFAInputValidatorStub < handle

    properties
        EffluxResult
        MDVResult
    end

    properties (SetAccess = private)
        EffluxCallCount (1, 1) double = 0
        MDVCallCount (1, 1) double = 0
        LastEffluxSettings = []
    end

    methods

        function obj = MFAInputValidatorStub(effluxResult, mdvResult)

            obj.EffluxResult = effluxResult;
            obj.MDVResult = mdvResult;

        end

        function result = validateEfflux(obj, ~, ~, ~, settings)

            obj.EffluxCallCount = obj.EffluxCallCount + 1;
            obj.LastEffluxSettings = settings;
            result = obj.EffluxResult;

        end

        function result = validateMDV(obj, ~, ~, ~)

            obj.MDVCallCount = obj.MDVCallCount + 1;
            result = obj.MDVResult;

        end

    end

end
