classdef ColorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(fullfile( ...
                fileparts(fileparts(mfilename("fullpath"))), ...
                "src"));

        end

    end

    methods (Test)

        function mapsMissingAndNonfiniteValuesToValidColors(testCase)

            color = Color();

            hex = color.getColorValue( ...
                [0.25, nan, inf, -inf, 1]);

            testCase.verifyNumElements(hex, 5);
            testCase.verifyTrue(all(color.isValidColorHex(hex)));
            testCase.verifyTrue(all(hex(2:4) == hex(1)));

        end

        function mapsAllMissingValuesWithoutIndexingError(testCase)

            color = Color();

            hex = color.getColorValue([nan, nan]);

            testCase.verifyNumElements(hex, 2);
            testCase.verifyTrue(all(color.isValidColorHex(hex)));

        end

        function clampsValuesOutsideNormalizedRange(testCase)

            color = Color();

            boundary = color.getColorValue([0, 1]);
            outside = color.getColorValue([-0.5, 1.5]);

            testCase.verifyEqual(outside, boundary);

        end

    end

end
