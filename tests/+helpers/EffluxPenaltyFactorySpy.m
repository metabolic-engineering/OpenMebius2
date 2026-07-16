classdef EffluxPenaltyFactorySpy < handle

    properties (SetAccess = private)
        Penalty = openmebius.mfa.EffluxPenalty()
        CallCount (1, 1) double = 0
        LastModel = []
        LastSubstrateList = []
        LastValues = []
        LastStandardDeviations = []
        LastFreeMask = []
    end

    methods

        function penalty = create( ...
                obj, model, substrateList, values, ...
                standardDeviations, freeMask)

            obj.CallCount = obj.CallCount + 1;
            obj.LastModel = model;
            obj.LastSubstrateList = substrateList;
            obj.LastValues = values;
            obj.LastStandardDeviations = standardDeviations;
            obj.LastFreeMask = freeMask;
            penalty = obj.Penalty;

        end

    end

end
