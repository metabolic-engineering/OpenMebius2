classdef InstationaryInputFactorySpy < handle

    properties (SetAccess = private)
        CallCount (1, 1) double = 0
        LastSpecification = []
    end

    methods

        function input = create(obj, ~, specification)

            obj.CallCount = obj.CallCount + 1;
            obj.LastSpecification = specification;
            input = openmebius.mfa.InstationaryInput( ...
                PoolSizes = specification.PoolSizes, ...
                TimePoints = specification.TimePoints);

        end

    end

end
