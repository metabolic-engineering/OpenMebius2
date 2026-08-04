classdef ReversibleFluxMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ReversibleFluxMapperTest.sourcePath());

        end

    end

    methods (Test)

        function mapsFluxColumnsToNetForwardValues(testCase)

            mapped = openmebius.mfa.ReversibleFluxMapper.mapFlux( ...
                [5, 6; 2, 1; 7, 8], [1, 2]);

            testCase.verifyEqual(mapped, [3, 5; 7, 8]);

        end

        function mapsReversibleFluxBounds(testCase)

            [lowerBounds, upperBounds] = ...
                openmebius.mfa.ReversibleFluxMapper.mapBounds( ...
                [1; 0; 4], [5; 2; 8], [1, 2]);

            testCase.verifyEqual(lowerBounds, [-1; 4]);
            testCase.verifyEqual(upperBounds, [5; 8]);

        end

        function rejectsOutOfRangeReactionIndices(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.ReversibleFluxMapper.mapFlux( ...
                [1; 2], [1, 3]), ...
                "OpenMebius2:ReversibleFluxMapper:" + ...
                "InvalidReversibleReactionIndices");

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
