classdef MFAIterationSettingsTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAIterationSettingsTest.sourcePath());

        end

    end

    methods (Test)

        function mapsBatchConfigToTypedSettings(testCase)

            config = struct;
            config.isINSTMFA = true;
            config.optimizationMethod = "hybrid";
            config.algorithm = "IPMs";
            config.fmincon.maxIterations = 321;

            settings = openmebius.mfa.MFAIterationSettings ...
                .fromBatchConfig(config);

            testCase.verifyTrue(settings.UseInstationaryMFA);
            testCase.verifyEqual( ...
                settings.OptimizationMethod, "hybrid-ga-gradient");
            testCase.verifyTrue(settings.requestsHybridOptimization());
            testCase.verifyTrue(settings.hasKnownOptimizationMethod());
            testCase.verifyEqual( ...
                settings.SolverOptions.Algorithm, "interior-point");
            testCase.verifyEqual( ...
                settings.SolverOptions.MaxIterations, 321);
            testCase.verifyEmpty(settings.OptionWarnings);

        end

        function normalizesLocalOptimizationAliases(testCase)

            for method = ["gradient-only", "fmincon", "local"]
                settings = openmebius.mfa.MFAIterationSettings ...
                    .fromBatchConfig(struct( ...
                    isINSTMFA = false, ...
                    optimizationMethod = method));

                testCase.verifyEqual( ...
                    settings.OptimizationMethod, "gradient-only");
                testCase.verifyTrue( ...
                    settings.hasKnownOptimizationMethod());
            end

        end

        function retainsUnknownMethodAndSolverWarning(testCase)

            settings = openmebius.mfa.MFAIterationSettings ...
                .fromBatchConfig(struct( ...
                isINSTMFA = false, ...
                optimizationMethod = "custom", ...
                algorithm = "not-an-algorithm"));

            testCase.verifyEqual( ...
                settings.OptimizationMethod, "custom");
            testCase.verifyFalse( ...
                settings.hasKnownOptimizationMethod());
            testCase.verifyEqual( ...
                settings.OptionWarnings, ...
                "Unknown FMINCON algorithm 'not-an-algorithm'. " + ...
                "Using sqp.");

        end

        function requiresExplicitAnalysisMode(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.MFAIterationSettings ...
                .fromBatchConfig(struct), ...
                "OpenMebius2:MFAIterationSettings:" + ...
                "InvalidAnalysisMode");

        end

        function rejectsNonlogicalNumericAnalysisMode(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.MFAIterationSettings ...
                .fromBatchConfig(struct(isINSTMFA = 2)), ...
                "OpenMebius2:MFAIterationSettings:" + ...
                "InvalidAnalysisMode");

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
