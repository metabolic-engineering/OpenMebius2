classdef MFAAnalysisSettingsMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAAnalysisSettingsMapperTest.sourcePath());

        end

    end

    methods (Test)

        function mapsSteadyStateAnalysisSettings(testCase)

            mapping = openmebius.application.analysis ...
                .MFAAnalysisSettingsMapper.tryFromBatchConfig( ...
                struct(iteration = 3, isINSTMFA = false));

            testCase.verifyTrue(mapping.IsValid);
            testCase.verifyClass( ...
                mapping.Settings, ...
                'openmebius.application.analysis.MFAAnalysisSettings');
            testCase.verifyEqual( ...
                mapping.Settings.InitialFluxSettings.IterationCount, 3);
            testCase.verifyEqual( ...
                mapping.Settings.IterationSettings.AnalysisMode, ...
                openmebius.mfa.MFAAnalysisMode.SteadyState);
            testCase.verifyEmpty( ...
                mapping.Settings.InstationaryInputSpecification);

        end

        function mapsInstationarySpecification(testCase)

            config = struct(iteration = 2, isINSTMFA = true);
            config.INSTMFA = struct( ...
                poolMetabolite = ["A"; "B"], ...
                poolSize = [2; 4], ...
                timePoints = [0; 1]);

            mapping = openmebius.application.analysis ...
                .MFAAnalysisSettingsMapper.tryFromBatchConfig(config);

            testCase.verifyTrue(mapping.IsValid);
            testCase.verifyClass( ...
                mapping.Settings.InstationaryInputSpecification, ...
                'openmebius.mfa.InstationaryInputSpecification');

        end

        function classifiesInitialFluxMappingFailure(testCase)

            mapping = openmebius.application.analysis ...
                .MFAAnalysisSettingsMapper.tryFromBatchConfig( ...
                struct(iteration = 0, isINSTMFA = false));

            testCase.verifyFalse(mapping.IsValid);
            testCase.verifyEqual(mapping.FailureStage, "initial");
            testCase.verifyTrue(contains( ...
                mapping.ErrorMessage, ...
                "initial-flux iteration count"));

        end

        function classifiesIterationMappingFailure(testCase)

            mapping = openmebius.application.analysis ...
                .MFAAnalysisSettingsMapper.tryFromBatchConfig( ...
                struct(iteration = 1));

            testCase.verifyFalse(mapping.IsValid);
            testCase.verifyEqual(mapping.FailureStage, "input");
            testCase.verifyTrue(contains( ...
                mapping.ErrorMessage, "isINSTMFA"));

        end

        function classifiesInstationaryMappingFailure(testCase)

            mapping = openmebius.application.analysis ...
                .MFAAnalysisSettingsMapper.tryFromBatchConfig( ...
                struct(iteration = 1, isINSTMFA = true));

            testCase.verifyFalse(mapping.IsValid);
            testCase.verifyEqual( ...
                mapping.FailureStage, "instationary");
            testCase.verifyTrue(contains( ...
                mapping.ErrorMessage, "INST-MFA configuration"));

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
