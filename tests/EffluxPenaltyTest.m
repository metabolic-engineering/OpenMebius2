classdef EffluxPenaltyTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(EffluxPenaltyTest.sourcePath());

        end

    end

    methods (Test)

        function evaluatesMultipleFluxColumns(testCase)

            penalty = openmebius.mfa.EffluxPenalty( ...
                ReactionIndices = [1; 3], ...
                ExperimentalValues = [1; 4], ...
                StandardDeviations = [0.5; 2]);
            flux = [2, 1; 7, 7; 2, 6];

            testCase.verifyEqual(penalty.evaluate(flux), [5, 1]);

        end

        function emptyPenaltyReturnsZeroForEveryFlux(testCase)

            penalty = openmebius.mfa.EffluxPenalty();

            testCase.verifyEqual( ...
                penalty.evaluate(zeros(3, 2)), zeros(1, 2));

        end

        function evaluatesUsingIndependentProfile(testCase)

            profile = openmebius.mfa.EffluxPerturbationProfile( ...
                ReactionIndices = 2, ...
                ExperimentalValues = 4, ...
                StandardDeviations = 2);
            penalty = openmebius.mfa.EffluxPenalty( ...
                Profile = profile);

            testCase.verifyEqual(penalty.evaluate([0; 6]), 1);
            testCase.verifyEqual(penalty.Profile, profile);
            testCase.verifyEqual(penalty.ReactionIndices, 2);

        end

        function evaluatesReversibleExchangeAsNetFlux(testCase)

            profile = openmebius.mfa.EffluxPerturbationProfile( ...
                ReactionIndices = 1, ...
                CounterReactionIndices = 2, ...
                ExperimentalValues = 5, ...
                StandardDeviations = 0.5);
            penalty = openmebius.mfa.EffluxPenalty( ...
                Profile = profile);

            testCase.verifyEqual(penalty.evaluate([7; 2]), 0);
            testCase.verifyEqual(penalty.evaluate([7; 1]), 4);

        end

        function rejectsNonpositiveStandardDeviation(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.EffluxPenalty( ...
                ReactionIndices = 1, ...
                ExperimentalValues = 1, ...
                StandardDeviations = 0), ...
                "OpenMebius2:EffluxPenalty:InvalidStandardDeviation");

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
