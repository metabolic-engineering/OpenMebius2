classdef RunConfigMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end % addSourcePath

    end % methods

    methods (Test)

        function mapsAlgorithmLabels(testCase)

            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.algorithmToView('interior-point'), ...
                'IPMs');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.algorithmToView('sqp'), ...
                'SQP');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.algorithmToConfig('IPMs'), ...
                'interior-point');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.algorithmToConfig('SQP'), ...
                'sqp');

        end % mapsAlgorithmLabels

        function mapsMonteCarloLabels(testCase)

            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.mcOptimizationProcedureToView('single'), ...
                'Single run');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.mcOptimizationProcedureToConfig('Multiple run'), ...
                'multiple');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.mcCalculationMethodToView('discarding'), ...
                'Discarding');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.mcCalculationMethodToConfig('Mean-varianced'), ...
                'mean-varianced');

        end % mapsMonteCarloLabels

        function mapsCIAndGridLabels(testCase)

            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.ciAlgorithmToView('grid search'), ...
                'Grid search');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.ciAlgorithmToConfig('Monte Carlo'), ...
                'Monte Carlo');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.gridThresholdToView('chi-sq'), ...
                'Chi-squared');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.gridThresholdToView('F-dist'), ...
                'F-distribution');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.gridThresholdToConfig('Chi-squared'), ...
                'chi-sq');
            testCase.verifyEqual( ...
                openmebius.presentation.batch.RunConfigMapper.gridThresholdToConfig('F-distribution'), ...
                'f-distribution');

        end % mapsCIAndGridLabels

        function mapsConfigToAndFromViewModel(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.algorithm = 'interior-point';
            config.CIConf.algorithm = 'Grid search';
            config.CIConf.grid.threshold = 'chi-sq';
            config.CIConf.MC.optimizationProcedure = 'multiple';
            config.CIConf.MC.calculationMethod = 'discarding';

            viewModel = ...
                openmebius.presentation.batch.RunConfigMapper.toViewModel( ...
                config);

            testCase.verifyClass( ...
                viewModel, ...
                'openmebius.presentation.batch.RunConfigViewModel');
            testCase.verifyEqual(viewModel.Algorithm, "IPMs");
            testCase.verifyEqual(viewModel.CIAlgorithm, "Grid search");
            testCase.verifyEqual(viewModel.GridThreshold, "Chi-squared");
            testCase.verifyEqual( ...
                viewModel.MCOptimizationProcedure, ...
                "Multiple run");
            testCase.verifyEqual(viewModel.MCCalculationMethod, "Discarding");

            viewModel.Algorithm = "SQP";
            viewModel.CIAlgorithm = "Monte Carlo";
            viewModel.GridThreshold = "F-distribution";
            viewModel.MCOptimizationProcedure = "Single run";
            viewModel.MCCalculationMethod = "Mean-varianced";

            updatedConfig = ...
                openmebius.presentation.batch.RunConfigMapper.fromViewModel( ...
                viewModel, ...
                config);

            testCase.verifyEqual(updatedConfig.algorithm, 'sqp');
            testCase.verifyEqual(updatedConfig.CIConf.algorithm, 'Monte Carlo');
            testCase.verifyEqual( ...
                updatedConfig.CIConf.grid.threshold, ...
                'f-distribution');
            testCase.verifyEqual( ...
                updatedConfig.CIConf.MC.optimizationProcedure, ...
                'single');
            testCase.verifyEqual( ...
                updatedConfig.CIConf.MC.calculationMethod, ...
                'mean-varianced');
            openmebius.domain.batch.BatchConfig.validate(updatedConfig);

        end % mapsConfigToAndFromViewModel

        function mapsAllEditableValuesRoundTrip(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.iteration = 47;
            config.algorithm = 'interior-point';
            config.largeScale = true;
            config.suggestNextFlux = true;
            config.perturbateEfflux = true;
            config.efflux.selection = [true; false];
            config.efflux.substrate = ["A"; "B"];
            config.efflux.substrateSD = [0.1; 0.2];
            config.isCalcCI = true;
            config.CIConf.algorithm = 'Grid search';
            config.CIConf.MC.iteration = 321;
            config.CIConf.MC.fixMID = false;
            config.CIConf.MC.MIDSD = 0.07;
            config.CIConf.MC.optimizationProcedure = 'single';
            config.CIConf.MC.terminationTolerance = 0.02;
            config.CIConf.MC.proximityThreshold = 0.03;
            config.CIConf.MC.certainThreshold = 8;
            config.CIConf.MC.theNumberOfRuns = 19;
            config.CIConf.MC.calculationMethod = 'mean-varianced';
            config.CIConf.grid.isParallel = false;
            config.CIConf.grid.points = 23;
            config.CIConf.grid.delta = 0.5;
            config.CIConf.grid.iteration = 71;
            config.CIConf.grid.threshold = 'f-distribution';
            config.deleteResultFile = false;
            config.isINSTMFA = true;
            config.INSTMFA.poolMetabolite = ["M1"; "M2"];
            config.INSTMFA.poolSize = [1.5; 2.5];
            config.INSTMFA.timePointsExpName = ["E1"; "E2"];
            config.INSTMFA.timePoints = [0; 5];

            viewModel = openmebius.presentation.batch ...
                .RunConfigMapper.toViewModel(config);
            actual = openmebius.presentation.batch ...
                .RunConfigMapper.fromViewModel(viewModel, config);

            testCase.verifyEqual(actual.iteration, config.iteration);
            testCase.verifyEqual(actual.algorithm, config.algorithm);
            testCase.verifyEqual(actual.largeScale, config.largeScale);
            testCase.verifyEqual( ...
                actual.suggestNextFlux, config.suggestNextFlux);
            testCase.verifyEqual(actual.efflux, config.efflux);
            testCase.verifyEqual(actual.isCalcCI, config.isCalcCI);
            testCase.verifyEqual(actual.CIConf, config.CIConf);
            testCase.verifyEqual( ...
                actual.deleteResultFile, config.deleteResultFile);
            testCase.verifyEqual(actual.isINSTMFA, config.isINSTMFA);
            testCase.verifyEqual(actual.INSTMFA, config.INSTMFA);

        end % mapsAllEditableValuesRoundTrip

        function preservesDisabledTableSettings(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.efflux.selection = true;
            config.efflux.substrate = "A";
            config.efflux.substrateSD = 0.4;
            config.INSTMFA.poolMetabolite = "M";
            config.INSTMFA.poolSize = 2;
            config.INSTMFA.timePointsExpName = "E";
            config.INSTMFA.timePoints = 4;
            viewModel = openmebius.presentation.batch ...
                .RunConfigMapper.toViewModel(config);
            viewModel.PerturbateEfflux = false;
            viewModel.IsINSTMFA = false;

            actual = openmebius.presentation.batch ...
                .RunConfigMapper.fromViewModel(viewModel, config);

            testCase.verifyEqual(actual.efflux, config.efflux);
            testCase.verifyEqual(actual.INSTMFA, config.INSTMFA);

        end % preservesDisabledTableSettings

        function rejectsUnknownValue(testCase)

            testCase.verifyError( ...
                @() openmebius.presentation.batch.RunConfigMapper.algorithmToConfig('unknown'), ...
                'OpenMebius2:RunConfigMapper:UnsupportedValue');

        end % rejectsUnknownValue

    end % methods

end % classdef
