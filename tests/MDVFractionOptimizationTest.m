classdef MDVFractionOptimizationTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MDVFractionOptimizationTest.sourcePath());

        end

    end

    methods (Test)

        function recoversExactMDVAndFraction(testCase)

            correction = MDVCorrection();
            matrix = correction.getCorrectedMatrixSkew( ...
                1, 0, 0, 0, 0, 0, ...
                numObservedMDV = 2, ...
                numTracerCarbon = 1);
            expectedMDV = [0.25; 0.75];
            expectedFraction = 0.1;
            observed = matrix * ( ...
                (1 - expectedFraction) * expectedMDV + ...
                expectedFraction * [1; 0]);

            [actualMDV, objective, actualFraction] = ...
                correction.correctWithOptimizedFraction( ...
                observed, ...
                1, 0, 0, 0, 0, 0, ...
                expectedFraction, ...
                numTracerCarbon = 1);

            testCase.verifyEqual( ...
                actualMDV', expectedMDV, AbsTol = 1e-8);
            testCase.verifyEqual( ...
                actualFraction, expectedFraction, AbsTol = 1e-8);
            testCase.verifyLessThan(objective, 1e-12);

        end

        function perturbsInconsistentMeasuredFraction(testCase)

            correction = MDVCorrection();
            matrix = correction.getCorrectedMatrixSkew( ...
                1, 0, 0, 0, 0, 0, ...
                numObservedMDV = 2, ...
                numTracerCarbon = 1);
            actualFraction = 0.05;
            measuredFraction = 0.2;
            observed = matrix * [actualFraction; 1 - actualFraction];

            [mdv, objective, optimizedFraction] = ...
                correction.correctWithOptimizedFraction( ...
                observed, ...
                1, 0, 0, 0, 0, 0, ...
                measuredFraction, ...
                numTracerCarbon = 1);

            testCase.verifyGreaterThanOrEqual(mdv, zeros(1, 2));
            testCase.verifyEqual(sum(mdv), 1, AbsTol = 1e-10);
            testCase.verifyGreaterThanOrEqual(optimizedFraction, 0);
            testCase.verifyLessThan(optimizedFraction, measuredFraction);
            testCase.verifyGreaterThan(objective, 0);

        end

        function rejectsFractionUpperBoundAtOne(testCase)

            correction = MDVCorrection();

            testCase.verifyError( ...
                @() correction.correctWithOptimizedFraction( ...
                [0.5; 0.5], ...
                1, 0, 0, 0, 0, 0, ...
                0.1, ...
                fractionBounds = [0, 1]), ...
            "MDVCorrection:InvalidFractionBounds");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename("fullpath"))), ...
            "src");

        end

    end

end % classdef
