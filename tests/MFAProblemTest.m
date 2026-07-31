classdef MFAProblemTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAProblemTest.sourcePath());

        end

    end

    methods (Test)

        function composesRightHandSideAndSolvesFlux(testCase)

            problem = MFAProblemTest.createProblem();

            rightHandSide = problem.composeRightHandSide(0.25);
            flux = problem.solveFlux(0.25);

            testCase.verifyEqual(rightHandSide, [5; 0.25]);
            testCase.verifyEqual(flux, rightHandSide);
            testCase.verifyEqual(problem.IndependentIndices, 2);

        end

        function extractsIndependentValuesFromMultiplePoints(testCase)

            problem = MFAProblemTest.createProblem();

            values = problem.extractIndependentValues([5, 5; 0.1, 0.2]);

            testCase.verifyEqual(values, [0.1, 0.2]);

        end

        function createsEquivalentNonnegativeFluxConstraints(testCase)

            problem = MFAProblemTest.createProblem();
            [matrix, rightHandSide] = ...
                problem.nonnegativeFluxInequalities();
            independentValue = 0.25;
            flux = problem.solveFlux(independentValue);

            testCase.verifyEqual( ...
                matrix * independentValue - rightHandSide, ...
                -flux, ...
                'AbsTol', 1e-12);

        end

        function createsFixedFluxEquality(testCase)

            problem = MFAProblemTest.createProblem();
            [matrix, rightHandSide] = ...
                problem.fixedFluxEqualities([0; 1], 0.25);

            testCase.verifyEqual(matrix, 1, 'AbsTol', 1e-12);
            testCase.verifyEqual( ...
                rightHandSide, 0.25, 'AbsTol', 1e-12);
            testCase.verifyEqual( ...
                matrix * 0.25, rightHandSide, ...
                'AbsTol', 1e-12);

        end

        function rejectsMismatchedIndependentMapping(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.MFAProblem( ...
                Stoichiometry = eye(2), ...
                RightHandSide = zeros(2, 1), ...
                LowerBounds = zeros(2, 1), ...
                UpperBounds = ones(2, 1), ...
                IndependentMask = [false; true], ...
                BoundaryReactionMask = [true; true]), ...
            "OpenMebius2:MFAProblem:IndependentMappingMismatch");

        end

        function rejectsInvalidBounds(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.MFAProblem( ...
                Stoichiometry = eye(2), ...
                RightHandSide = zeros(2, 1), ...
                LowerBounds = [0; 2], ...
                UpperBounds = ones(2, 1), ...
                IndependentMask = [false; true], ...
                BoundaryReactionMask = [false; true]), ...
            "OpenMebius2:MFAProblem:InvalidBounds");

        end

    end

    methods (Static, Access = private)

        function problem = createProblem()

            problem = openmebius.mfa.MFAProblem( ...
                Stoichiometry = eye(2), ...
                RightHandSide = [5; 0], ...
                LowerBounds = zeros(2, 1), ...
                UpperBounds = 10 * ones(2, 1), ...
                IndependentMask = [false; true], ...
                BoundaryReactionMask = [false; true]);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
            'src');

        end

    end

end
