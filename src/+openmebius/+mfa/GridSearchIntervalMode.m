classdef GridSearchIntervalMode
    % GRIDSEARCHINTERVALMODE Grid-point spacing strategies.

    enumeration
        Automatic
        FixedDelta
    end

    methods

        function value = isAutomatic(obj)

            value = obj == ...
                openmebius.mfa.GridSearchIntervalMode.Automatic;

        end

        function value = configValue(obj)

            if obj.isAutomatic()
                value = "automatic";
            else
                value = "fixed-delta";
            end

        end

    end

end
