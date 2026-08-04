classdef EffluxPerturbationProfileFactoryTest < ...
        matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath( ...
                EffluxPerturbationProfileFactoryTest.sourcePath());
            addpath( ...
                EffluxPerturbationProfileFactoryTest.testPath());

        end

    end

    methods (Test)

        function mapsSelectedSubstratesToInternalFluxIndices(testCase)

            model = helpers.SteadyStateModelStub();
            model.ReactionNames = ["R2", "R1"];
            factory = ...
                openmebius.mfa.EffluxPerturbationProfileFactory();

            profile = factory.create( ...
                model, ...
                ["S1", "S2"], ...
                [3; 5], ...
                [0.5; 2], ...
                [true; false]);

            testCase.verifyEqual(profile.ReactionIndices, 2);
            testCase.verifyEqual(profile.ExperimentalValues, 3);
            testCase.verifyEqual(profile.StandardDeviations, 0.5);

        end

        function preservesSelectionOrder(testCase)

            model = helpers.SteadyStateModelStub();
            model.ReactionNames = ["R2", "R1"];
            factory = ...
                openmebius.mfa.EffluxPerturbationProfileFactory();

            profile = factory.create( ...
                model, ...
                ["S1", "S2"], ...
                [3; 5], ...
                [0.5; 2], ...
                [true; true]);

            testCase.verifyEqual(profile.ReactionIndices, [2; 1]);
            testCase.verifyEqual(profile.ExperimentalValues, [3; 5]);
            testCase.verifyEqual( ...
                profile.StandardDeviations, [0.5; 2]);

        end

        function reportsMissingReaction(testCase)

            model = helpers.SteadyStateModelStub();
            model.SubstrateReactionIDs(1) = "missing";
            factory = ...
                openmebius.mfa.EffluxPerturbationProfileFactory();

            testCase.verifyError( ...
                @() factory.create( ...
                model, "S1", 3, 0.5, true), ...
                "OpenMebius2:EffluxPerturbationProfileFactory:" + ...
            "ReactionNotFound");

        end

        function acceptsEmptyConfiguration(testCase)

            factory = ...
                openmebius.mfa.EffluxPerturbationProfileFactory();

            profile = factory.create( ...
                helpers.SteadyStateModelStub(), ...
                ["S1", "S2"], ...
                [3; 5], ...
                [], ...
                []);

            testCase.verifyEqual(profile.MeasurementCount, 0);

        end

        function rejectsDimensionMismatch(testCase)

            factory = ...
                openmebius.mfa.EffluxPerturbationProfileFactory();

            testCase.verifyError( ...
                @() factory.create( ...
                helpers.SteadyStateModelStub(), ...
                ["S1", "S2"], ...
                [3; 5], ...
                [0.5; 2], ...
                true), ...
                "OpenMebius2:EffluxPerturbationProfileFactory:" + ...
            "DimensionMismatch");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
            'src');

        end

        function path = testPath()

            path = fileparts(mfilename('fullpath'));

        end

    end

end
