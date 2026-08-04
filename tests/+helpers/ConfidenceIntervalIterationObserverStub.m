classdef ConfidenceIntervalIterationObserverStub < handle

    properties (SetAccess = private)
        RightHandSide double = []
    end

    methods

        function result = run(obj, mdv, rightHandSide)

            obj.RightHandSide = rightHandSide;
            result = openmebius.mfa.MFAIterationResult( ...
                IndependentValues = rightHandSide(2), ...
                Flux = rightHandSide, ...
                MDV = mdv, ...
                ObjectiveValue = 0, ...
                ExitFlag = 1);

        end

    end

end
