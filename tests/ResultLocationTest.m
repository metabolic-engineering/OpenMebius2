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

    end

end
