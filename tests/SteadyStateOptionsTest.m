classdef SteadyStateOptionsTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(SteadyStateOptionsTest.sourcePath());

        end

    end

    methods (Test)

        function suppliesLegacyDefaults(testCase)

            [options, warnings] = ...
                openmebius.mfa.SteadyStateOptions.fromBatchConfig(struct);

            testCase.verifyEqual(options.Algorithm, "sqp");
            testCase.verifyEqual(options.MaxFunctionEvaluations, 1000000);
            testCase.verifyEqual(options.FiniteDifferenceType, "central");
            testCase.verifyEqual( ...
                options.finiteDifferenceStepSizes(), ...
                [1e-6; 1e-3; 1e-4; 1e-5; 1e-7]);
            testCase.verifyEmpty(warnings);

        end

        function mapsAlgorithmAliasAndSearchConfiguration(testCase)

            config = struct;
            config.algorithm = 'IPMs';
            config.fmincon.finiteDifferenceStepSize = 1e-5;
            config.fmincon.stepSizeSearch.enabled = true;
            config.fmincon.stepSizeSearch.includeConfiguredStep = false;
            config.fmincon.stepSizeSearch.maxCandidates = 2;
            config.fmincon.stepSizeSearch.candidates = '1e-4, 1e-6, 1e-8';

            [options, warnings] = ...
                openmebius.mfa.SteadyStateOptions.fromBatchConfig(config);

            testCase.verifyEqual(options.Algorithm, "interior-point");
            testCase.verifyEqual( ...
                options.finiteDifferenceStepSizes(), [1e-4; 1e-6]);
            testCase.verifyEmpty(warnings);

        end

        function mapsCurrentBatchDefaults(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();

            [options, warnings] = ...
                openmebius.mfa.SteadyStateOptions.fromBatchConfig(config);

            testCase.verifyEqual( ...
                options.finiteDifferenceStepSizes(), ...
                [1e-6; 1e-5; 1e-7; 1e-8; 1e-9]);
            testCase.verifyTrue(options.RejectWorseThanInitial);
            testCase.verifyEmpty(warnings);

        end

        function reportsUnknownAlgorithm(testCase)

            config.algorithm = 'not-an-algorithm';

            [options, warnings] = ...
                openmebius.mfa.SteadyStateOptions.fromBatchConfig(config);

            testCase.verifyEqual(options.Algorithm, "sqp");
            testCase.verifyEqual( ...
                warnings, ...
                "Unknown FMINCON algorithm 'not-an-algorithm'. Using sqp.");

        end

        function buildsFminconOptions(testCase)

            options = openmebius.mfa.SteadyStateOptions( ...
                StepSizeSearchEnabled = false);

            fminconOptions = options.buildFminconOptions([0; 2], 1e-5);

            testCase.verifyEqual( ...
                string(fminconOptions.Algorithm), "sqp");
            testCase.verifyEqual( ...
                fminconOptions.FiniteDifferenceStepSize, 1e-5);
            testCase.verifyEqual(fminconOptions.TypicalX, [1; 2]);

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
