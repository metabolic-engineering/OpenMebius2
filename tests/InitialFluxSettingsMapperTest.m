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
