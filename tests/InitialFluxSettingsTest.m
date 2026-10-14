classdef InitialFluxSettingsTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(InitialFluxSettingsTest.sourcePath());

        end

    end

    methods (Test)

        function storesPositiveIterationCount(testCase)

            settings = openmebius.mfa.InitialFluxSettings( ...
                IterationCount = 30, ...
                RestrictFreeEffluxSeeds = false, ...
                FreeEffluxSeedSigmaMultiplier = 5);

            testCase.verifyEqual(settings.IterationCount, 30);
            testCase.verifyFalse(settings.RestrictFreeEffluxSeeds);
            testCase.verifyEqual( ...
                settings.FreeEffluxSeedSigmaMultiplier, 5);

        end

        function suppliesCurrentBatchDefault(testCase)

            settings = openmebius.mfa.InitialFluxSettings();

            testCase.verifyEqual(settings.IterationCount, 30);
            testCase.verifyTrue(settings.RestrictFreeEffluxSeeds);
            testCase.verifyEqual(settings.MaxTime, 600);
            testCase.verifyEqual( ...
                settings.FreeEffluxSeedSigmaMultiplier, 3);

        end

        function rejectsInvalidFreeEffluxSeedSigmaMultiplier(testCase)

            errorID = "OpenMebius2:InitialFluxSettings:" + ...
                "InvalidFreeEffluxSeedSigmaMultiplier";

            for value = [0, -1, Inf, NaN]
                testCase.verifyError( ...
                    @() openmebius.mfa.InitialFluxSettings( ...
                    FreeEffluxSeedSigmaMultiplier = value), ...
                    errorID);
            end

        end

        function rejectsInvalidTimeout(testCase)

            for value = [0, -1, Inf, NaN, 1 + 2i]
                testCase.verifyError( ...
                    @() openmebius.mfa.InitialFluxSettings(MaxTime = value), ...
                    "OpenMebius2:InitialFluxSettings:InvalidMaxTime");
            end

        end

        function rejectsInvalidIterationCount(testCase)

            errorID = "OpenMebius2:InitialFluxSettings:" + ...
                "InvalidIterationCount";

            for value = [0, -1, 1.5, Inf, NaN]
                testCase.verifyError( ...
                    @() openmebius.mfa.InitialFluxSettings( ...
                    IterationCount = value), ...
                    errorID);
            end

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
