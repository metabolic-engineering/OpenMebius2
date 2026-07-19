classdef MSFragmentSelection
    % MSFRAGMENTSELECTION
    % Typed model-default or custom MS fragment selection.

    properties (SetAccess = private)
        Mode (1, 1) openmebius.mfa.MSFragmentSelectionMode
        Fragments (:, 1) string
        SelectedMask (:, 1) logical
    end

    methods

        function obj = MSFragmentSelection(options)

            arguments
                options.Mode (1, 1) openmebius.mfa ...
                    .MSFragmentSelectionMode = openmebius.mfa ...
                    .MSFragmentSelectionMode.ModelSelection
                options.Fragments (:, 1) string = strings(0, 1)
                options.SelectedMask (:, 1) logical = false(0, 1)
            end

            obj.Mode = options.Mode;
            obj.Fragments = options.Fragments;
            obj.SelectedMask = options.SelectedMask;

        end

    end

end
