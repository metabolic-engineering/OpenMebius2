classdef ResultLocationTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ResultLocationTest.sourcePath());

        end

    end

    methods (Test)

        function summaryReportFileUsesResultDirectory(testCase)

            resultDirectory = fullfile(tempdir, "openmebius-results");
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);

            testCase.verifyEqual( ...
                resultLocation.summaryReportFile(), ...
                fullfile(resultDirectory, "summary"));

        end

        function resultFileUsesHdf5Extension(testCase)

            resultDirectory = fullfile(tempdir, "openmebius-results");
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);

            testCase.verifyEqual( ...
                resultLocation.resultFile("batch-1"), ...
                fullfile(resultDirectory, "batch-1.h5"));

        end

        function hasDirectoryRejectsEmptyDirectory(testCase)

            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory("");

            testCase.verifyFalse(resultLocation.hasDirectory());
            testCase.verifyFalse(resultLocation.directoryExists());

        end

        function directoryExistsDetectsExistingDirectory(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultLocationTest.removeDirectory(resultDirectory));

            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);

            testCase.verifyTrue(resultLocation.hasDirectory());
            testCase.verifyTrue(resultLocation.directoryExists());

        end

        function directoryExistsRejectsMissingDirectory(testCase)

            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(fullfile(tempdir, "missing-openmebius-results"));

            testCase.verifyTrue(resultLocation.hasDirectory());
            testCase.verifyFalse(resultLocation.directoryExists());

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                ResultLocationTest.repositoryRoot(), ...
                "src");

        end

        function path = repositoryRoot()

            path = fileparts(fileparts(mfilename("fullpath")));

        end

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, "s");
            end

        end

    end

end
