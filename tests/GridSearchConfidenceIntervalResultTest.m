classdef GridSearchConfidenceIntervalResultTest < ...
        matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(GridSearchConfidenceIntervalResultTest.sourcePath());

        end

    end

    methods (Test)

        function constructsResultForMultipleFluxes(testCase)

            profile = ...
                GridSearchConfidenceIntervalResultTest.createProfile();

            result = openmebius.mfa ...
                .GridSearchConfidenceIntervalResult( ...
                LowerBounds = [1; 10], ...
                UpperBounds = [3; 30], ...
                ProfileData = profile, ...
                ElapsedTime = 2.5);

            testCase.verifyEqual(result.LowerBounds, [1; 10]);
            testCase.verifyEqual(result.UpperBounds, [3; 30]);
            testCase.verifyEqual(result.ProfileData, profile);
            testCase.verifyEqual(result.ElapsedTime, 2.5);
            testCase.verifyFalse(result.IsCanceled);

        end

        function rejectsProfileCountMismatch(testCase)

            profile = ...
                GridSearchConfidenceIntervalResultTest.createProfile();

            constructor = @() openmebius.mfa ...
                .GridSearchConfidenceIntervalResult( ...
                LowerBounds = 1, ...
                UpperBounds = 3, ...
                ProfileData = profile, ...
                ElapsedTime = 2.5);

            testCase.verifyError( ...
                constructor, ...
            "OpenMebius2:GridSearchCI:ProfileSizeMismatch");

        end

        function rejectsBoundSizeMismatch(testCase)

            profile = ...
                GridSearchConfidenceIntervalResultTest.createProfile();

            constructor = @() openmebius.mfa ...
                .GridSearchConfidenceIntervalResult( ...
                LowerBounds = [1; 10], ...
                UpperBounds = 3, ...
                ProfileData = profile, ...
                ElapsedTime = 2.5);

            testCase.verifyError( ...
                constructor, ...
            "OpenMebius2:GridSearchCI:BoundSizeMismatch");

        end

    end

    methods (Static, Access = private)

        function profile = createProfile()

            profile = openmebius.mfa.GridSearchProfileData( ...
                FluxIndices = [1; 2], ...
                FixedFluxValues = zeros(2, 3, 2), ...
                MinimumSumOfSquares = zeros(2, 3, 2));

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename("fullpath"))), ...
            "src");

        end

    end

end
