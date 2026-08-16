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
            testCase.verifyEqual(mapping.Settings.FVALowerBound, -1000);
            testCase.verifyEqual(mapping.Settings.FVAUpperBound, 1000);
            testCase.verifyTrue(mapping.Settings.UseParallel);
            testCase.verifyEqual( ...
                mapping.Settings.WorkerCount, ...
                openmebius.domain.batch.BatchConfig.defaultConfig() ...
                .CIConf.grid.workerCount);

        end

        function mapsConfiguredWorkerCount(testCase)

            config = struct(iteration = 3, isINSTMFA = false);
            config.CIConf.grid.workerCount = 7;
            mapping = openmebius.application.analysis ...
                .MFAAnalysisSettingsMapper.tryFromBatchConfig(config);

            testCase.verifyTrue(mapping.IsValid);
            testCase.verifyTrue(mapping.Settings.UseParallel);
            testCase.verifyEqual(mapping.Settings.WorkerCount, 7);

        end

        function mapsConfiguredFVABounds(testCase)

            mapping = openmebius.application.analysis ...
                .MFAAnalysisSettingsMapper.tryFromBatchConfig( ...
                struct( ...
                iteration = 3, ...
                isINSTMFA = false, ...
                fluxLB = -250, ...
                fluxUB = 450));

            testCase.verifyTrue(mapping.IsValid);
            testCase.verifyEqual(mapping.Settings.FVALowerBound, -250);
            testCase.verifyEqual(mapping.Settings.FVAUpperBound, 450);

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
