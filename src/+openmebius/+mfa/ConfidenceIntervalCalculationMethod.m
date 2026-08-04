classdef ConfidenceIntervalCalculationMethod
    % CONFIDENCEINTERVALCALCULATIONMETHOD Cumulative-bound methods.

    enumeration
        Discarding
        MeanVarianced
    end

    methods

        function value = isDiscarding(obj)

            value = obj == openmebius.mfa ...
                .ConfidenceIntervalCalculationMethod.Discarding;

        end

        function value = configValue(obj)

            if obj.isDiscarding()
                value = "discarding";
            else
                value = "mean-varianced";
            end

        end

    end

end
