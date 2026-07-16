classdef MFAAnalysisMode
    % MFAANALYSISMODE Supported nonlinear MFA analysis modes.

    enumeration
        SteadyState
        Instationary
    end

    methods

        function value = isInstationary(obj)

            value = obj == ...
                openmebius.mfa.MFAAnalysisMode.Instationary;

        end % isInstationary

    end % methods

end % classdef
