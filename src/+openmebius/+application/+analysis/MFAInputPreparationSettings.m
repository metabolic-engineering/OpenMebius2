classdef MFAInputPreparationSettings
    % MFAINPUTPREPARATIONSETTINGS Typed settings for MFA input assembly.

    properties (SetAccess = private)
        EffluxPerturbation (1, 1) openmebius.mfa ...
            .EffluxPerturbationSettings
        FragmentSelection (1, 1) openmebius.mfa.MSFragmentSelection
    end

    methods

        function obj = MFAInputPreparationSettings(options)

            arguments
                options.EffluxPerturbation (1, 1) openmebius.mfa ...
                    .EffluxPerturbationSettings = openmebius.mfa ...
                    .EffluxPerturbationSettings()
                options.FragmentSelection (1, 1) openmebius.mfa ...
                    .MSFragmentSelection = openmebius.mfa ...
                    .MSFragmentSelection()
            end

            obj.EffluxPerturbation = options.EffluxPerturbation;
            obj.FragmentSelection = options.FragmentSelection;

        end

    end

end
