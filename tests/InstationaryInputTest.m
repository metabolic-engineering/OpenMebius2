classdef InstationaryInputTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(InstationaryInputTest.sourcePath());

        end

    end

    methods (Test)

        function storesColumnVectors(testCase)

            input = openmebius.mfa.InstationaryInput( ...
                PoolSizes = [2; 4], ...
                TimePoints = [0; 1; 2]);

            testCase.verifyEqual(input.PoolSizes, [2; 4]);
            testCase.verifyEqual(input.TimePoints, [0; 1; 2]);

        end

        function rejectsInvalidPoolSize(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.InstationaryInput( ...
                PoolSizes = [2; 0], ...
                TimePoints = [0; 1]), ...
                "OpenMebius2:InstationaryInput:InvalidPoolSize");

        end

        function rejectsInvalidTimePoints(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.InstationaryInput( ...
                PoolSizes = [2; 4], ...
                TimePoints = 0), ...
                "OpenMebius2:InstationaryInput:InvalidTimePoints");

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
