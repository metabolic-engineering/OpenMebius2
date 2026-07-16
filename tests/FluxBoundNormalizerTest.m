classdef FluxBoundNormalizerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(FluxBoundNormalizerTest.sourcePath());

        end

    end

    methods (Test)

        function collapsesNumericalInversionToMidpoint(testCase)

            normalizer = openmebius.mfa.FluxBoundNormalizer();
            lowerBounds = [1 + 1e-14; -2];
            upperBounds = [1; 3];

            [lowerBounds, upperBounds, adjusted] = ...
                normalizer.normalize(lowerBounds, upperBounds);

            testCase.verifyEqual(lowerBounds(1), upperBounds(1));
            testCase.verifyEqual(lowerBounds(1), 1 + 5e-15, ...
                AbsTol = 1e-15);
            testCase.verifyEqual(lowerBounds(2), -2);
            testCase.verifyEqual(upperBounds(2), 3);
            testCase.verifyEqual(adjusted, [true; false]);

        end

        function preservesMaterialInversion(testCase)

            normalizer = openmebius.mfa.FluxBoundNormalizer();

            [lowerBounds, upperBounds, adjusted] = ...
                normalizer.normalize(2, 1);

            testCase.verifyEqual(lowerBounds, 2);
            testCase.verifyEqual(upperBounds, 1);
            testCase.verifyFalse(adjusted);

        end

        function rejectsMismatchedDimensions(testCase)

            normalizer = openmebius.mfa.FluxBoundNormalizer();

            testCase.verifyError( ...
                @() normalizer.normalize([0; 1], 2), ...
                "OpenMebius2:FluxBoundNormalizer:DimensionMismatch");

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
