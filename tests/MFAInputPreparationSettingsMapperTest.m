classdef MFAInputPreparationSettingsMapperTest < ...
        matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAInputPreparationSettingsMapperTest.sourcePath());

        end

    end

    methods (Test)

        function suppliesNonperturbatedModelSelectionDefaults(testCase)

            settings = openmebius.application.analysis ...
                .MFAInputPreparationSettingsMapper ...
                .fromBatchConfig(struct);

            testCase.verifyFalse(settings.EffluxPerturbation.Enabled);
            testCase.verifyTrue( ...
                settings.FragmentSelection.Mode.usesModelSelection());

        end

        function mapsEffluxPerturbation(testCase)

            config.perturbateEfflux = true;
            config.efflux = struct( ...
                substrate = ["B"; "A"], ...
                selection = [1; 0], ...
                substrateSD = [0.5; 0.1]);

            settings = openmebius.application.analysis ...
                .MFAInputPreparationSettingsMapper ...
                .fromBatchConfig(config);

            perturbation = settings.EffluxPerturbation;
            testCase.verifyTrue(perturbation.Enabled);
            testCase.verifyEqual(perturbation.Substrates, ["B"; "A"]);
            testCase.verifyEqual( ...
                perturbation.FreeSelection, [true; false]);
            testCase.verifyEqual( ...
                perturbation.StandardDeviations, [0.5; 0.1]);

        end

        function mapsGrowthRatePerturbation(testCase)

            config.perturbateEfflux = true;
            config.efflux = struct( ...
                muSelection = true, ...
                muSD = 0.03);

            settings = openmebius.application.analysis ...
                .MFAInputPreparationSettingsMapper ...
                .fromBatchConfig(config);

            perturbation = settings.EffluxPerturbation;
            testCase.verifyTrue(perturbation.Enabled);
            testCase.verifyTrue(perturbation.GrowthRateFree);
            testCase.verifyEqual( ...
                perturbation.GrowthRateStandardDeviation, 0.03);

        end

        function mapsCustomFragmentSelection(testCase)

            config.MS = struct( ...
                fragment = "custom", ...
                fragmentList = ["B"; "A"], ...
                customFragment = [true; false]);

            settings = openmebius.application.analysis ...
                .MFAInputPreparationSettingsMapper ...
                .fromBatchConfig(config);

            selection = settings.FragmentSelection;
            testCase.verifyEqual( ...
                selection.Mode, ...
                openmebius.mfa ...
                .MSFragmentSelectionMode.CustomSelection);
            testCase.verifyEqual(selection.Fragments, ["B"; "A"]);
            testCase.verifyEqual( ...
                selection.SelectedMask, [true; false]);

        end

        function rejectsUnknownFragmentSelectionMode(testCase)

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .MFAInputPreparationSettingsMapper ...
                .fromBatchConfig(struct( ...
                MS = struct(fragment = "unknown"))), ...
                "OpenMebius2:MFAInputPreparationSettingsMapper:" + ...
                "InvalidFragmentSelectionMode");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
