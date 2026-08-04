classdef MFAOptimizationMethod
    % MFAOPTIMIZATIONMETHOD Supported nonlinear optimization workflows.

    enumeration
        GradientOnly
        HybridGAGradient
    end

    methods

        function value = usesHybridGA(obj)

            value = obj == ...
                openmebius.mfa.MFAOptimizationMethod.HybridGAGradient;

        end % usesHybridGA

    end % methods

end % classdef
