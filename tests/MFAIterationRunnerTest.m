classdef MFAIterationRunnerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAIterationRunnerTest.sourcePath());

        end

    end

    methods (Test)

        function runsObjectiveAndAssemblesResult(testCase)

            runner = openmebius.mfa.MFAIterationRunner();
            target = [0.25; 0.75];

            result = runner.run( ...
                MFAIterationRunnerTest.createProblem(), ...
                zeros(2, 1), ...
                helpers.MFAObjectiveStub(target), ...
                openmebius.mfa.SteadyStateOptions( ...
                MaxIterations = 100, ...
                StepSizeSearchEnabled = false));

            testCase.verifyFalse(result.IsError, result.ErrorMessage);
            testCase.verifyEqual(result.Flux, target, 'AbsTol', 1e-5);
            testCase.verifyEqual( ...
                result.IndependentValues, target, 'AbsTol', 1e-5);
            testCase.verifyEqual(result.MDV, 2 * target, 'AbsTol', 1e-5);
            testCase.verifyLessThan(result.ObjectiveValue, 1e-8);

        end

        function rejectsObjectiveWithoutRequiredContract(testCase)

            runner = openmebius.mfa.MFAIterationRunner();

            testCase.verifyError( ...
                @() runner.run( ...
                MFAIterationRunnerTest.createProblem(), ...
                zeros(2, 1), ...
                struct, ...
                openmebius.mfa.SteadyStateOptions()), ...
                "OpenMebius2:MFAIterationRunner:InvalidObjective");

        end

    end

    methods (Static, Access = private)

        function problem = createProblem()

            problem = openmebius.mfa.MFAProblem( ...
                Stoichiometry = eye(2), ...
                RightHandSide = zeros(2, 1), ...
                LowerBounds = zeros(2, 1), ...
                UpperBounds = ones(2, 1), ...
                IndependentMask = true(2, 1), ...
                BoundaryReactionMask = true(2, 1));

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
