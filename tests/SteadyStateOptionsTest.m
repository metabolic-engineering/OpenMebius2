classdef SteadyStateOptionsTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(SteadyStateOptionsTest.sourcePath());

        end

    end

    methods (Test)

        function suppliesTypedDefaults(testCase)

            options = openmebius.mfa.SteadyStateOptions();

            testCase.verifyEqual(options.Algorithm, "sqp");
            testCase.verifyEqual(options.MaxFunctionEvaluations, 1000000);
            testCase.verifyEqual(options.FiniteDifferenceType, "central");

        end

        function selectsStableFiniteDifferenceSteps(testCase)

            options = openmebius.mfa.SteadyStateOptions( ...
                FiniteDifferenceStepSize = 1e-5, ...
                IncludeConfiguredStep = true, ...
                MaxStepSizeCandidates = 3, ...
                StepSizeCandidates = [1e-4; 1e-5; 1e-6]);

            testCase.verifyEqual( ...
                options.finiteDifferenceStepSizes(), [1e-5; 1e-4; 1e-6]);

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
