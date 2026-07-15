classdef FailingExperimentMDVCalculator < handle

    properties (SetAccess = private)
        CallCount (1, 1) double = 0
        LastInput = []
    end

    methods

        function result = calculate(obj, input)

            obj.CallCount = obj.CallCount + 1;
            obj.LastInput = input;
            result = []; %#ok<NASGU>

            error( ...
                "OpenMebius2:Test:InjectedMDVCalculationFailure", ...
                "Injected MDV calculation failure.");

        end

    end

end % classdef
