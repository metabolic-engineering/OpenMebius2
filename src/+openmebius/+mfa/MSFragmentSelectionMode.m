classdef MSFragmentSelectionMode
    % MSFRAGMENTSELECTIONMODE Supported MS fragment selection modes.

    enumeration
        ModelSelection
        CustomSelection
    end

    methods

        function value = usesModelSelection(obj)

            value = obj == openmebius.mfa ...
                .MSFragmentSelectionMode.ModelSelection;

        end

    end

end
