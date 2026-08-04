classdef MFAExperimentListNormalizerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAExperimentListNormalizerTest.sourcePath());

        end

    end

    methods (Test)

        function unwrapsNestedScalarCells(testCase)

            normalizer = openmebius.mfa.MFAExperimentListNormalizer();

            result = normalizer.normalize({{{'E1', 'E2'}}});

            testCase.verifyEqual(result, ["E1"; "E2"]);

        end

        function normalizesStringAndNumericRows(testCase)

            normalizer = openmebius.mfa.MFAExperimentListNormalizer();

            testCase.verifyEqual( ...
                normalizer.normalize(["E1", "E2"]), ...
                ["E1"; "E2"]);
            testCase.verifyEqual( ...
                normalizer.normalize([3, 1]), ...
                [3; 1]);

        end

        function rejectsUnsupportedValues(testCase)

            normalizer = openmebius.mfa.MFAExperimentListNormalizer();

            testCase.verifyError( ...
                @() normalizer.normalize(struct), ...
                "OpenMebius2:MFAExperimentListNormalizer:" + ...
                "InvalidExperimentList");

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
