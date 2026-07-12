classdef Hdf5ResultRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(Hdf5ResultRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function writeDatasetCreatesHdf5Dataset(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                Hdf5ResultRepositoryTest.removeDirectory(resultDirectory));

            repository = openmebius.infrastructure.result.Hdf5ResultRepository();
            pathFile = fullfile(resultDirectory, "result.h5");
            values = [1.0; 2.0; 3.0];

            [isSuccess, msg] = repository.writeDataset( ...
                pathFile, ...
                "/flux", ...
                values);

            testCase.verifyTrue(isSuccess, msg);
            testCase.verifyEqual(h5read(pathFile, "/flux"), values);

            clear cleanup

        end

        function assertResultDirectoryRejectsMissingDirectory(testCase)

            repository = openmebius.infrastructure.result.Hdf5ResultRepository();
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(fullfile(tempdir, "missing-openmebius-hdf5-result"));

            testCase.verifyError( ...
                @() repository.assertResultDirectory(resultLocation), ...
                "OpenMebius2:Hdf5ResultRepository:DirectoryNotFound");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile(Hdf5ResultRepositoryTest.repositoryRoot(), "src");

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
