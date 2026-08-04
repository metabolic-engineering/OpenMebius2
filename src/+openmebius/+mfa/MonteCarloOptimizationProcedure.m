classdef MonteCarloOptimizationProcedure
    % MONTECARLOOPTIMIZATIONPROCEDURE Sampling optimization procedures.

    enumeration
        SingleRun
        MultipleRun
    end

    methods

        function value = isMultipleRun(obj)

            value = obj == openmebius.mfa ...
                .MonteCarloOptimizationProcedure.MultipleRun;

        end

        function value = displayName(obj)

            if obj.isMultipleRun()
                value = "Multiple run";
            else
                value = "Single run";
            end

        end

        function value = configValue(obj)

            if obj.isMultipleRun()
                value = "multiple";
            else
                value = "single";
            end

        end

    end

end
