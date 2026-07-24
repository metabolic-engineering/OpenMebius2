classdef ConfidenceIntervalSettingsMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ConfidenceIntervalSettingsMapperTest.sourcePath());

        end

    end

    methods (Test)

        function mapsCanonicalBatchConfiguration(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.isCalcCI = true;
            settings = openmebius.application.analysis ...
                .ConfidenceIntervalSettingsMapper.fromBatchConfig(config);

            testCase.verifyTrue(settings.Enabled);
            testCase.verifyEqual( ...
                settings.Method, ...
                openmebius.mfa.ConfidenceIntervalMethod.MonteCarlo);
            testCase.verifyEqual( ...
                settings.MonteCarloSettings.Procedure, ...
                openmebius.mfa ...
                .MonteCarloOptimizationProcedure.MultipleRun);
            testCase.verifyEqual( ...
                settings.MonteCarloSettings.IterationCount, 500);
            testCase.verifyEqual( ...
                settings.MonteCarloSettings.TrialCount, 50);
            testCase.verifyEqual( ...
                settings.GridSearchSettings.Threshold, "chi-sq");
            testCase.verifyEqual( ...
                settings.GridSearchSettings.IntervalMode, ...
                openmebius.mfa.GridSearchIntervalMode.Automatic);
            testCase.verifyEqual( ...
                settings.GridSearchSettings.ExecutionMode, ...
                openmebius.mfa.GridSearchExecutionMode.Parallel);

        end

        function fillsMissingNestedValuesFromDomainDefaults(testCase)

            settings = openmebius.application.analysis ...
                .ConfidenceIntervalSettingsMapper.fromBatchConfig( ...
                struct(CIConf = struct(MC = struct)));

            testCase.verifyFalse(settings.Enabled);
            testCase.verifyEqual( ...
                settings.MonteCarloSettings.IterationCount, 500);
            testCase.verifyEqual( ...
                settings.GridSearchSettings.PointCount, 10);

        end

        function mapsLegacyProcedureAndGridAliases(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.algorithm = "Grid search";
            config.CIConf.MC = rmfield( ...
                config.CIConf.MC, 'optimizationProcedure');
            config.CIConf.MC.procedure = "Single run";
            config.CIConf.grid.threshold = "F distribution";
            settings = openmebius.application.analysis ...
                .ConfidenceIntervalSettingsMapper.fromBatchConfig(config);

            testCase.verifyEqual( ...
                settings.Method, ...
                openmebius.mfa.ConfidenceIntervalMethod.GridSearch);
            testCase.verifyEqual( ...
                settings.MonteCarloSettings.Procedure, ...
                openmebius.mfa ...
                .MonteCarloOptimizationProcedure.SingleRun);
            testCase.verifyEqual( ...
                settings.GridSearchSettings.Threshold, ...
            "f-distribution");

        end

        function mapsCanonicalGridModes(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid.intervalMode = "fixed-delta";
            config.CIConf.grid.executionMode = "serial";

            settings = openmebius.application.analysis ...
                .ConfidenceIntervalSettingsMapper.fromBatchConfig(config);

            testCase.verifyEqual( ...
                settings.GridSearchSettings.IntervalMode, ...
                openmebius.mfa.GridSearchIntervalMode.FixedDelta);
            testCase.verifyEqual( ...
                settings.GridSearchSettings.ExecutionMode, ...
                openmebius.mfa.GridSearchExecutionMode.Serial);

        end

        function mapsLegacyGridModeAsIntervalMode(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid = rmfield( ...
                config.CIConf.grid, ...
                {'intervalMode', 'executionMode'});
            config.CIConf.grid.isParallel = false;

            settings = openmebius.application.analysis ...
                .ConfidenceIntervalSettingsMapper.fromBatchConfig(config);

            testCase.verifyEqual( ...
                settings.GridSearchSettings.IntervalMode, ...
                openmebius.mfa.GridSearchIntervalMode.FixedDelta);
            testCase.verifyEqual( ...
                settings.GridSearchSettings.ExecutionMode, ...
                openmebius.mfa.GridSearchExecutionMode.Parallel);

        end

        function canonicalProcedureTakesPrecedence(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.MC.optimizationProcedure = "multiple";
            config.CIConf.MC.procedure = "Single run";
            settings = openmebius.application.analysis ...
                .ConfidenceIntervalSettingsMapper.fromBatchConfig(config);

            testCase.verifyEqual( ...
                settings.MonteCarloSettings.Procedure, ...
                openmebius.mfa ...
                .MonteCarloOptimizationProcedure.MultipleRun);

        end

        function rejectsUnknownProcedureAtMappingBoundary(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.MC.optimizationProcedure = "unsupported";

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .ConfidenceIntervalSettingsMapper ...
                .fromBatchConfig(config), ...
                "OpenMebius2:ConfidenceIntervalSettingsMapper:" + ...
            "UnknownProcedure");

        end

        function runSettingsAlwaysUseSteadyStateIterations(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.isINSTMFA = true;
            settings = openmebius.application.analysis ...
                .MFAConfidenceIntervalRunSettingsMapper ...
                .fromBatchConfig(config);

            testCase.verifyEqual( ...
                settings.IterationSettings.AnalysisMode, ...
                openmebius.mfa.MFAAnalysisMode.SteadyState);

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
