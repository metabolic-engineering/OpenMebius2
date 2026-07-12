classdef ResultRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(ResultRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function openCreatesResultObject(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(resultDirectory));

            repository = openmebius.infrastructure.result.ResultRepository();
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);

            result = repository.open(resultLocation);

            testCase.verifyClass(result, "IOResult");
            testCase.verifyEqual( ...
                result.getResultLocation().Directory, ...
                resultDirectory);

            clear cleanup

        end

        function openRejectsMissingDirectory(testCase)

            repository = openmebius.infrastructure.result.ResultRepository();
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(fullfile(tempdir, "missing-openmebius-result-repo"));

            testCase.verifyError( ...
                @() repository.open(resultLocation), ...
                "OpenMebius2:ResultRepository:ResultLoadFailed");

        end

        function writeExcelTableCanBeReadBack(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(resultDirectory));

            repository = openmebius.infrastructure.result.ResultRepository();
            pathFile = fullfile(resultDirectory, "result.xlsx");
            sourceTable = table( ...
                ["r1"; "r2"], ...
                [1.0; 2.0], ...
                VariableNames = ["Reaction", "Flux"]);

            [isSuccess, msg] = repository.writeExcelTable( ...
                pathFile, ...
                sourceTable, ...
                "Overview", ...
                WriteRowNames = false);

            testCase.verifyTrue(isSuccess, msg);
            loaded = readtable(pathFile, Sheet = "Overview");
            testCase.verifyEqual(string(loaded.Reaction), sourceTable.Reaction);
            testCase.verifyEqual(loaded.Flux, sourceTable.Flux);

            clear cleanup

        end

        function writeCsvTableCanBeReadBack(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(resultDirectory));

            repository = openmebius.infrastructure.result.ResultRepository();
            pathFile = fullfile(resultDirectory, "result.csv");
            sourceTable = table( ...
                ["r1"; "r2"], ...
                [1.0; 2.0], ...
                VariableNames = ["Reaction", "Flux"]);

            [isSuccess, msg] = repository.writeCsvTable( ...
                pathFile, ...
                sourceTable, ...
                WriteRowNames = false);

            testCase.verifyTrue(isSuccess, msg);
            loaded = readtable(pathFile);
            testCase.verifyEqual(string(loaded.Reaction), sourceTable.Reaction);
            testCase.verifyEqual(loaded.Flux, sourceTable.Flux);

            clear cleanup

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile(ResultRepositoryTest.repositoryRoot(), "src");

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
