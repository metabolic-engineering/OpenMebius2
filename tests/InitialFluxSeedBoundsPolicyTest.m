classdef InitialFluxSeedBoundsPolicyTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(InitialFluxSeedBoundsPolicyTest.sourcePath());

        end

    end

    methods (Test)

        function intersectsMeasurementRangesWithPhysicalBounds(testCase)

            policy = openmebius.mfa.InitialFluxSeedBoundsPolicy();

            [lowerBounds, upperBounds] = policy.apply( ...
                [0; -100; 5], ...
                [100; 100; 50], ...
                [1; 3], ...
                [10; 60], ...
                [2; 5]);

            testCase.verifyEqual(lowerBounds, [4; -100; 45]);
            testCase.verifyEqual(upperBounds, [16; 100; 50]);

        end

        function acceptsCustomSigmaMultiplier(testCase)

            policy = openmebius.mfa.InitialFluxSeedBoundsPolicy();

            [lowerBounds, upperBounds] = policy.apply( ...
                0, 100, 1, 20, 2, SigmaMultiplier = 5);

            testCase.verifyEqual(lowerBounds, 10);
            testCase.verifyEqual(upperBounds, 30);

        end

        function preservesBoundsWithoutFreeEffluxMeasurements(testCase)

            policy = openmebius.mfa.InitialFluxSeedBoundsPolicy();
            physicalLowerBounds = [-10; 0];
            physicalUpperBounds = [10; 20];

            [lowerBounds, upperBounds] = policy.apply( ...
                physicalLowerBounds, ...
                physicalUpperBounds, ...
                zeros(0, 1), ...
                zeros(0, 1), ...
                zeros(0, 1));

            testCase.verifyEqual(lowerBounds, physicalLowerBounds);
            testCase.verifyEqual(upperBounds, physicalUpperBounds);

        end

        function rejectsMeasurementRangeOutsidePhysicalBounds(testCase)

            policy = openmebius.mfa.InitialFluxSeedBoundsPolicy();

            testCase.verifyError( ...
                @() policy.apply(0, 10, 1, 20, 1), ...
                "OpenMebius2:InitialFluxSeedBounds:" + ...
            "EmptyIntersection");

        end

        function rejectsMeasurementDimensionMismatch(testCase)

            policy = openmebius.mfa.InitialFluxSeedBoundsPolicy();

            testCase.verifyError( ...
                @() policy.apply( ...
                [0; 0], [10; 10], [1; 2], 5, [1; 1]), ...
                "OpenMebius2:InitialFluxSeedBounds:" + ...
            "MeasurementDimensionMismatch");

        end

        function rejectsInvalidReactionIndex(testCase)

            policy = openmebius.mfa.InitialFluxSeedBoundsPolicy();

            testCase.verifyError( ...
                @() policy.apply([0; 0], [10; 10], 3, 5, 1), ...
                "OpenMebius2:InitialFluxSeedBounds:" + ...
            "InvalidReactionIndex");

        end

        function rejectsDuplicateReactionIndex(testCase)

            policy = openmebius.mfa.InitialFluxSeedBoundsPolicy();

            testCase.verifyError( ...
                @() policy.apply(0, 10, [1; 1], [4; 5], [1; 1]), ...
                "OpenMebius2:InitialFluxSeedBounds:" + ...
            "DuplicateReactionIndex");

        end

        function rejectsInvalidSigmaMultiplier(testCase)

            policy = openmebius.mfa.InitialFluxSeedBoundsPolicy();
            errorID = "OpenMebius2:InitialFluxSeedBounds:" + ...
                "InvalidSigmaMultiplier";

            for multiplier = [0, -1, Inf, NaN]
                testCase.verifyError( ...
                    @() policy.apply( ...
                    0, 10, 1, 5, 1, ...
                    SigmaMultiplier = multiplier), ...
                    errorID);
            end

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
