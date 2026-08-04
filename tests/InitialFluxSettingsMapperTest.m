classdef InitialFluxSettingsMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(InitialFluxSettingsMapperTest.sourcePath());

        end

    end

    methods (Test)

        function mapsBatchIterationCount(testCase)

            settings = openmebius.application.analysis ...
                .InitialFluxSettingsMapper.fromBatchConfig( ...
                struct(iteration = 30));

            testCase.verifyClass( ...
                settings, 'openmebius.mfa.InitialFluxSettings');
            testCase.verifyEqual(settings.IterationCount, 30);
            testCase.verifyTrue(settings.RestrictFreeEffluxSeeds);
            testCase.verifyEqual( ...
                settings.FreeEffluxSeedSigmaMultiplier, 3);

        end

        function mapsFreeEffluxSeedSettings(testCase)

            config = struct(iteration = 30);
            config.initialFlux = struct( ...
                restrictFreeEffluxSeeds = false, ...
                freeEffluxSeedSigmaMultiplier = 5);

            settings = openmebius.application.analysis ...
                .InitialFluxSettingsMapper.fromBatchConfig(config);

            testCase.verifyFalse(settings.RestrictFreeEffluxSeeds);
            testCase.verifyEqual( ...
                settings.FreeEffluxSeedSigmaMultiplier, 5);

        end

        function rejectsInvalidFreeEffluxSeedFlag(testCase)

            config = struct(iteration = 30);
            config.initialFlux = struct( ...
                restrictFreeEffluxSeeds = 2);

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .InitialFluxSettingsMapper.fromBatchConfig(config), ...
                "OpenMebius2:InitialFluxSettingsMapper:" + ...
            "InvalidRestrictFreeEffluxSeeds");

        end

        function rejectsInvalidFreeEffluxSeedMultiplier(testCase)

            config = struct(iteration = 30);
            config.initialFlux = struct( ...
                freeEffluxSeedSigmaMultiplier = 0);

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .InitialFluxSettingsMapper.fromBatchConfig(config), ...
                "OpenMebius2:InitialFluxSettings:" + ...
            "InvalidFreeEffluxSeedSigmaMultiplier");

        end

        function requiresIterationCount(testCase)

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .InitialFluxSettingsMapper.fromBatchConfig(struct), ...
                "OpenMebius2:InitialFluxSettingsMapper:" + ...
            "MissingIterationCount");

        end

        function rejectsNonnumericIterationCount(testCase)

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .InitialFluxSettingsMapper.fromBatchConfig( ...
                struct(iteration = "30")), ...
                "OpenMebius2:InitialFluxSettingsMapper:" + ...
            "InvalidIterationCount");

        end

        function delegatesValueValidationToSettings(testCase)

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .InitialFluxSettingsMapper.fromBatchConfig( ...
                struct(iteration = 0)), ...
                "OpenMebius2:InitialFluxSettings:" + ...
            "InvalidIterationCount");

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
