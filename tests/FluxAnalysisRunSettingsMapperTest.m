classdef FluxAnalysisRunSettingsMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(FluxAnalysisRunSettingsMapperTest.sourcePath());

        end

    end

    methods (Test)

        function mapsAllAnalysisSections(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.suggestionTable = "A";
            config.suggestionTableRowNames = "candidate";
            config.suggestionTableVarNames = "Tracer";
            settings = openmebius.application.analysis ...
                .FluxAnalysisRunSettingsMapper.fromBatchConfig(config);

            testCase.verifyTrue(settings.canRunDistribution());
            testCase.verifyTrue( ...
                settings.canCalculateConfidenceInterval());
            testCase.verifyTrue(settings.canSuggestNextExperiment());
            testCase.verifyClass( ...
                settings.DistributionSettings, ...
                'openmebius.application.analysis.MFAAnalysisSettings');
            testCase.verifyEqual( ...
                settings.NextExperimentRunSettings ...
                .NextLabelSettings.Patterns, ...
                "A");

        end

        function isolatesDistributionMappingFailure(testCase)

            config = struct(iteration = 0, isINSTMFA = false);
            settings = openmebius.application.analysis ...
                .FluxAnalysisRunSettingsMapper.fromBatchConfig(config);

            testCase.verifyFalse(settings.canRunDistribution());
            testCase.verifyEqual( ...
                settings.DistributionFailureStage, "initial");
            testCase.verifySubstring( ...
                settings.DistributionErrorMessage, ...
                "initial-flux iteration count");
            testCase.verifyTrue( ...
                settings.canCalculateConfidenceInterval());
            testCase.verifyTrue(settings.canSuggestNextExperiment());

        end

        function isolatesConfidenceMappingFailure(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.algorithm = "unsupported";
            settings = openmebius.application.analysis ...
                .FluxAnalysisRunSettingsMapper.fromBatchConfig(config);

            testCase.verifyTrue(settings.canRunDistribution());
            testCase.verifyFalse( ...
                settings.canCalculateConfidenceInterval());
            testCase.verifySubstring( ...
                settings.ConfidenceIntervalErrorMessage, ...
                "Unknown confidence-interval method");
            testCase.verifyFalse(settings.canSuggestNextExperiment());

        end

        function isolatesNextExperimentMappingFailure(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.suggestionTable = ["A", "B"];
            config.suggestionTableVarNames = "Tracer";
            settings = openmebius.application.analysis ...
                .FluxAnalysisRunSettingsMapper.fromBatchConfig(config);

            testCase.verifyTrue(settings.canRunDistribution());
            testCase.verifyTrue( ...
                settings.canCalculateConfidenceInterval());
            testCase.verifyFalse(settings.canSuggestNextExperiment());
            testCase.verifySubstring( ...
                settings.NextExperimentErrorMessage, ...
                "Candidate pattern columns must match tracer names");

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
