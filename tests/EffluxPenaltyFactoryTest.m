classdef EffluxPenaltyFactoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(EffluxPenaltyFactoryTest.sourcePath());

        end

    end

    methods (Test)

        function mapsSelectedSubstratesToReactionColumns(testCase)

            model = helpers.SteadyStateModelStub();
            model.ReactionNames = ["R2", "R1"];
            factory = openmebius.mfa.EffluxPenaltyFactory();

            [penalty, profile] = factory.create( ...
                model, ...
                ["S1", "S2"], ...
                [3; 5], ...
                [0.5; 2], ...
                [true; false]);

            testCase.verifyEqual(penalty.ReactionIndices, 2);
            testCase.verifyEqual(penalty.ExperimentalValues, 3);
            testCase.verifyEqual(penalty.StandardDeviations, 0.5);
            testCase.verifyClass( ...
                penalty.Profile, ...
            'openmebius.mfa.EffluxPerturbationProfile');
            testCase.verifyEqual(profile, penalty.Profile);

        end

        function reportsMissingReaction(testCase)

            model = helpers.SteadyStateModelStub();
            model.SubstrateReactionIDs(1) = "missing";
            factory = openmebius.mfa.EffluxPenaltyFactory();

            testCase.verifyError( ...
                @() factory.create( ...
                model, "S1", 3, 0.5, true), ...
                "OpenMebius2:EffluxPerturbationProfileFactory:" + ...
            "ReactionNotFound");

        end

        function acceptsEmptyConfiguration(testCase)

            factory = openmebius.mfa.EffluxPenaltyFactory();

            penalty = factory.create( ...
                helpers.SteadyStateModelStub(), ...
                ["S1", "S2"], ...
                [3; 5], ...
                [], ...
                []);

            testCase.verifyEqual( ...
                penalty.evaluate(zeros(2, 1)), 0);

        end

        function createsGrowthRatePenalty(testCase)

            model = helpers.SteadyStateModelStub();
            model.ReactionNames = ["R1", "R2", "biomass"];
            factory = openmebius.mfa.EffluxPenaltyFactory();

            penalty = factory.create( ...
                model, ...
                ["S1"; "S2"], ...
                [3; 5], ...
                [0.5; 2], ...
                [false; false], ...
                GrowthRate = 0.2, ...
                GrowthRateStandardDeviation = 0.1, ...
                GrowthRateFree = true);

            testCase.verifyEqual(penalty.ReactionIndices, 3);
            testCase.verifyEqual(penalty.evaluate([3; 5; 0.4]), 4, ...
                AbsTol = 1e-12);

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
