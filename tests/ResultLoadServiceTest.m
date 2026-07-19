classdef ResultLoadServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ResultLoadServiceTest.sourcePath());

        end

    end

    methods (Test)

        function loadBuildsResultForEmptyDirectory(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultLoadServiceTest.removeDirectory(resultDirectory));

            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);

            service = openmebius.application.result.ResultLoadService();

            loadResult = service.load(resultLocation);

            testCase.verifyClass( ...
                loadResult, ...
                "openmebius.application.result.ResultLoadResult");
            testCase.verifyClass( ...
                loadResult.Result, ...
                "openmebius.application.result.ResultCatalog");
            testCase.verifyEqual( ...
                loadResult.ResultLocation.Directory, ...
                resultDirectory);
            testCase.verifyGreaterThanOrEqual(numel(loadResult.Messages), 1);

        end

        function loadRejectsMissingDirectory(testCase)

            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(fullfile(tempdir, "missing-openmebius-results"));

            service = openmebius.application.result.ResultLoadService();

            testCase.verifyError( ...
                @() service.load(resultLocation), ...
                "OpenMebius2:ResultLoad:DirectoryNotFound");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                ResultLoadServiceTest.repositoryRoot(), ...
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
