classdef MFAIterationReporterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAIterationReporterTest.sourcePath());

        end

    end

    methods (Test)

        function reportsOptimizationSettings(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            reporter = MFAIterationReporterTest.reporter(observer);
            settings = openmebius.mfa.MFAIterationSettings( ...
                AnalysisMode = ...
                openmebius.mfa.MFAAnalysisMode.SteadyState, ...
                OptimizationMethod = openmebius.mfa ...
                .MFAOptimizationMethod.HybridGAGradient, ...
                OptionWarnings = "solver option warning");

            reporter.reportSettings(settings);

            testCase.verifyEqual( ...
                observer.Levels, ["info"; "warning"]);
            testCase.verifyEqual( ...
                observer.Messages(1), ...
                "Hybrid GA optimization is temporarily disabled. " + ...
            "Using FMINCON only.");
            testCase.verifyEqual( ...
                observer.Messages(2), "solver option warning");

        end

        function reportsMappedConfigurationWarnings(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            reporter = MFAIterationReporterTest.reporter(observer);
            settings = openmebius.mfa.MFAIterationSettings( ...
                AnalysisMode = ...
                openmebius.mfa.MFAAnalysisMode.SteadyState, ...
                OptionWarnings = ...
                "Unknown optimizationMethod 'custom'. " + ...
            "Using FMINCON only.");

            reporter.reportSettings(settings);

            testCase.verifyEqual(observer.Levels, "warning");
            testCase.verifyEqual( ...
                observer.Messages, ...
                "Unknown optimizationMethod 'custom'. " + ...
            "Using FMINCON only.");

        end

        function reportsSuccessfulInstationaryResult(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            reporter = MFAIterationReporterTest.reporter(observer);
            result = MFAIterationReporterTest.result();

            reporter.reportResult( ...
                result, openmebius.mfa.MFAAnalysisMode.Instationary);

            testCase.verifyEqual(observer.Levels, "info");
            testCase.verifyEqual( ...
                observer.Messages, ...
                "Nonlinear optimization for instationary MFA " + ...
            "completed. RSS:     1.00.");

        end

        function formatsRSSAsFixedWidthWithElapsedTime(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            reporter = MFAIterationReporterTest.reporter(observer);
            result = MFAIterationReporterTest.result( ...
                ObjectiveValue = 12.345);

            reporter.reportResult( ...
                result, ...
                openmebius.mfa.MFAAnalysisMode.SteadyState, ...
                ElapsedSeconds = 5.35);

            testCase.verifyEqual( ...
                observer.Messages, ...
                "Nonlinear optimization completed. RSS:    12.35. " + ...
            "Elapsed: 5.35 sec.");

        end

        function padsShortRSSAndDisplaysOverflowAsInf(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            reporter = MFAIterationReporterTest.reporter(observer);

            reporter.reportResult( ...
                MFAIterationReporterTest.result( ...
                ObjectiveValue = 1.2), ...
                openmebius.mfa.MFAAnalysisMode.SteadyState);
            reporter.reportResult( ...
                MFAIterationReporterTest.result( ...
                ObjectiveValue = 99999.99), ...
                openmebius.mfa.MFAAnalysisMode.SteadyState);
            reporter.reportResult( ...
                MFAIterationReporterTest.result( ...
                ObjectiveValue = 100000), ...
                openmebius.mfa.MFAAnalysisMode.SteadyState);

            testCase.verifyEqual( ...
                observer.Messages, ...
                ["Nonlinear optimization completed. RSS:     1.20."; ...
                 "Nonlinear optimization completed. RSS: 99999.99."; ...
             "Nonlinear optimization completed. RSS:      Inf."]);

        end

        function reportsResultErrorDetails(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            reporter = MFAIterationReporterTest.reporter(observer);
            result = MFAIterationReporterTest.result( ...
                ErrorMessage = "solver failed");

            reporter.reportResult( ...
                result, openmebius.mfa.MFAAnalysisMode.SteadyState);

            testCase.verifyEqual(observer.Levels, "error");
            testCase.verifyEqual( ...
                observer.Messages, ...
            "Nonlinear optimization failed. solver failed");

        end

        function reportsNonfiniteObjectiveAsFailure(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            reporter = MFAIterationReporterTest.reporter(observer);
            result = MFAIterationReporterTest.result( ...
                ObjectiveValue = NaN);

            reporter.reportResult( ...
                result, openmebius.mfa.MFAAnalysisMode.SteadyState);

            testCase.verifyEqual(observer.Levels, "error");
            testCase.verifyEqual( ...
                observer.Messages, "Nonlinear optimization failed.");

        end

        function callbackForwardsRunnerMessages(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            callback = MFAIterationReporterTest.reporter(observer) ...
                .callback();

            callback("warning", "runner warning");

            testCase.verifyEqual(observer.Levels, "warning");
            testCase.verifyEqual(observer.Messages, "runner warning");

        end

    end

    methods (Static, Access = private)

        function reporter = reporter(observer)

            reporter = openmebius.mfa.MFAIterationReporter( ...
                MessageReporter = @(level, message) ...
                observer.report(level, message));

        end

        function value = result(options)

            arguments
                options.ObjectiveValue (1, 1) double = 1
                options.Output (1, 1) struct = struct
                options.ErrorMessage (1, 1) string = ""
            end

            value = openmebius.mfa.MFAIterationResult( ...
                IndependentValues = 0.5, ...
                Flux = [5; 0.5], ...
                MDV = 0.8, ...
                ObjectiveValue = options.ObjectiveValue, ...
                ExitFlag = 1, ...
                Output = options.Output, ...
                ErrorMessage = options.ErrorMessage);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
            'src');

        end

    end

end
