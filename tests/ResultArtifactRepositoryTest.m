classdef ResultArtifactRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ResultArtifactRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function deletesResultAndManifestOnly(testCase)

            fixture = ResultArtifactRepositoryTest.createFixture();
            cleanup = onCleanup(@() ...
                ResultArtifactRepositoryTest.removeDirectory( ...
                fixture.Directory));
            repository = openmebius.infrastructure.result ...
                .ResultArtifactRepository();

            deletedFiles = repository.deleteBatchArtifacts( ...
                fixture.Location, "bat_1");

            testCase.verifyEqual(deletedFiles, fixture.Artifacts);
            testCase.verifyFalse(isfile(fixture.Artifacts(1)));
            testCase.verifyFalse(isfile(fixture.Artifacts(2)));
            testCase.verifyTrue(isfile(fixture.UnrelatedFile));

        end

        function missingArtifactsAreAnIdempotentNoOp(testCase)

            directory = string(tempname);
            mkdir(directory);
            cleanup = onCleanup(@() ...
                ResultArtifactRepositoryTest.removeDirectory(directory));
            repository = openmebius.infrastructure.result ...
                .ResultArtifactRepository();

            deletedFiles = repository.deleteBatchArtifacts( ...
                openmebius.domain.result.ResultLocation ...
                .fromDirectory(directory), ...
                "missing");

            testCase.verifyEqual(deletedFiles, strings(0, 1));

        end

    end

    methods (Static, Access = private)

        function fixture = createFixture()

            directory = string(tempname);
            mkdir(directory);
            location = openmebius.domain.result.ResultLocation ...
                .fromDirectory(directory);
            artifacts = location.resultArtifactFiles("bat_1");
            unrelatedFile = location.reportFile("summary.html");
            ResultArtifactRepositoryTest.writeFile(artifacts(1));
            ResultArtifactRepositoryTest.writeFile(artifacts(2));
            ResultArtifactRepositoryTest.writeFile(unrelatedFile);
            fixture = struct( ...
                'Directory', directory, ...
                'Location', location, ...
                'Artifacts', artifacts, ...
                'UnrelatedFile', unrelatedFile);

        end

        function writeFile(path)

            fid = fopen(path, 'w');
            assert(fid >= 0, "Unable to create test file: " + path);
            cleanup = onCleanup(@() fclose(fid));
            fprintf(fid, 'test');
            clear cleanup

        end

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, 's');
            end

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
