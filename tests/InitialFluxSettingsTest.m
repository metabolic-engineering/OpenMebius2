classdef InitialFluxSettingsTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(InitialFluxSettingsTest.sourcePath());

        end

    end

    methods (Test)

        function storesPositiveIterationCount(testCase)

            settings = openmebius.mfa.InitialFluxSettings( ...
                IterationCount = 30);

            testCase.verifyEqual(settings.IterationCount, 30);

        end

        function suppliesCurrentBatchDefault(testCase)

            settings = openmebius.mfa.InitialFluxSettings();

            testCase.verifyEqual(settings.IterationCount, 30);

        end

        function rejectsInvalidIterationCount(testCase)

            errorID = "OpenMebius2:InitialFluxSettings:" + ...
                "InvalidIterationCount";

            for value = [0, -1, 1.5, Inf, NaN]
                testCase.verifyError( ...
                    @() openmebius.mfa.InitialFluxSettings( ...
                    IterationCount = value), ...
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
