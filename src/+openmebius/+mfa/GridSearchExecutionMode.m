classdef GridSearchExecutionMode
    % GRIDSEARCHEXECUTIONMODE Grid-search scheduling strategies.

    enumeration
        Serial
        Parallel
    end

    methods

        function value = isParallel(obj)

            value = obj == ...
                openmebius.mfa.GridSearchExecutionMode.Parallel;

        end

        function value = configValue(obj)

            if obj.isParallel()
                value = "parallel";
            else
                value = "serial";
            end

        end

    end

end
