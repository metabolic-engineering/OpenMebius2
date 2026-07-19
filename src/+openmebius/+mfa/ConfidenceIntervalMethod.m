classdef ConfidenceIntervalMethod
    % CONFIDENCEINTERVALMETHOD Supported confidence-interval methods.

    enumeration
        MonteCarlo
        GridSearch
    end

    methods

        function value = isMonteCarlo(obj)

            value = obj == ...
                openmebius.mfa.ConfidenceIntervalMethod.MonteCarlo;

        end

        function value = displayName(obj)

            if obj.isMonteCarlo()
                value = "Monte Carlo";
            else
                value = "Grid search";
            end

        end

    end

end
