classdef MDVCorrectionPreferenceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MDVCorrectionPreferenceTest.sourcePath());

        end

    end

    methods (Test)

        function defaultsToSkewWhenPreferenceDoesNotExist(testCase)

            fixture = testCase.createFixture();

            testCase.verifyEqual(fixture.Preference.getMethod(), "skew");

        end

        function persistsEverySupportedMethod(testCase)

            fixture = testCase.createFixture();

            for method = fixture.Preference.SupportedMethods
                fixture.Preference.setMethod(method);
                reloaded = openmebius.infrastructure.preferences ...
                    .MDVCorrectionPreference( ...
                    StorageDirectory = fixture.Directory);
                testCase.verifyEqual(reloaded.getMethod(), method);
            end

        end

        function rejectsUnsupportedMethod(testCase)

            fixture = testCase.createFixture();

            testCase.verifyError( ...
                @() fixture.Preference.setMethod("unknown"), ...
            "OpenMebius2:MDVCorrectionPreference:InvalidMethod");

        end

    end

    methods (Access = private)

        function fixture = createFixture(testCase)

            directory = string(tempname);
            mkdir(directory);
            testCase.addTeardown(@() rmdir(directory, "s"));
            fixture = struct( ...
                Directory = directory, ...
                Preference = openmebius.infrastructure.preferences ...
                .MDVCorrectionPreference( ...
                StorageDirectory = directory));

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename("fullpath"))), ...
            "src");

        end

    end

end % classdef
