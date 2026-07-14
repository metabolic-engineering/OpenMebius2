classdef ResultManifestRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ResultManifestRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function writesStartedAndCompletedManifestAtomically(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultManifestRepositoryTest.removeDirectory(resultDirectory));
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);
            repository = ...
                openmebius.infrastructure.result.ResultManifestRepository();
            metadata = ResultManifestRepositoryTest.metadata();

            [isSuccess, msg] = repository.writeStarted( ...
                resultLocation, ...
                metadata);

            testCase.verifyTrue(isSuccess, msg);
            manifestPath = resultLocation.manifestFile(metadata.batchId);
            testCase.verifyTrue(isfile(manifestPath));
            started = repository.read(resultLocation, metadata.batchId);
            testCase.verifyEqual(started.schemaVersion, 1);
            testCase.verifyEqual(string(started.batch.id), metadata.batchId);
            testCase.verifyEqual( ...
                string(started.batch.contentHash), ...
                metadata.contentHash);
            testCase.verifyEqual(string(started.result.status), "running");
            testCase.verifyEqual(string(started.result.file), "bat_001.h5");
            testCase.verifyEqual(string(started.result.sha256), "");
            testCase.verifyEqual( ...
                string(started.software.openMebius2Version), ...
                metadata.openMebius2Version);
            testCase.verifyEqual(string(started.model.sha256), metadata.modelSha256);
            testCase.verifyEqual( ...
                string({started.experiments.sha256})', ...
                metadata.experimentSha256);
            testCase.verifyEqual(started.analysis.config.iteration, 30);

            resultPath = resultLocation.resultFile(metadata.batchId);
            ResultManifestRepositoryTest.writeBytes( ...
                resultPath, ...
                uint8(1:16));
            expectedHash = ...
                string(openmebius.infrastructure.filesystem.FileHasher.hashFile( ...
                resultPath));

            [isSuccess, msg] = repository.writeCompleted( ...
                resultLocation, ...
                metadata, ...
                "2026-07-14T00:01:00.000Z", ...
                false, ...
                false);

            testCase.verifyTrue(isSuccess, msg);
            completed = repository.read(resultLocation, metadata.batchId);
            testCase.verifyEqual(string(completed.result.status), "finished");
            testCase.verifyEqual(string(completed.result.sha256), expectedHash);
            testCase.verifyEqual(completed.result.sizeBytes, 16);
            testCase.verifyEqual( ...
                string(completed.run.finishedAtUtc), ...
                "2026-07-14T00:01:00.000Z");
            testCase.verifyFalse(completed.run.isError);
            testCase.verifyFalse(completed.run.isCanceled);

            listing = dir(resultDirectory);
            fileNames = sort(string({listing(~[listing.isdir]).name}));
            testCase.verifyEqual( ...
                fileNames, ...
                sort(["bat_001.h5", "bat_001.manifest.json"]));

            clear cleanup

        end

        function completedManifestRecordsErrorState(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultManifestRepositoryTest.removeDirectory(resultDirectory));
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);
            repository = ...
                openmebius.infrastructure.result.ResultManifestRepository();
            metadata = ResultManifestRepositoryTest.metadata();

            [isSuccess, msg] = repository.writeCompleted( ...
                resultLocation, ...
                metadata, ...
                "2026-07-14T00:01:00.000Z", ...
                true, ...
                false);

            testCase.verifyTrue(isSuccess, msg);
            document = repository.read(resultLocation, metadata.batchId);
            testCase.verifyEqual(string(document.result.status), "error");
            testCase.verifyTrue(document.run.isError);

            clear cleanup

        end

    end

    methods (Static, Access = private)

        function metadata = metadata()

            metadata = struct( ...
                'schemaVersion', 1, ...
                'batchId', "bat_001", ...
                'contentHash', "sha256:content", ...
                'contentHashVersion', 1, ...
                'configJson', '{"iteration":30}', ...
                'openMebius2Version', "2.4.3", ...
                'matlabRelease', "R2026a", ...
                'matlabVersion', "26.1", ...
                'toolboxesJson', '[]', ...
                'modelFileName', "model.xlsx", ...
                'modelSha256', "model-hash", ...
                'experimentNames', ["exp-a"; "exp-b"], ...
                'experimentFileNames', ["exp-a.xlsx"; "exp-b.xlsx"], ...
                'experimentSha256', ["hash-a"; "hash-b"], ...
                'randomType', "twister", ...
                'randomSeed', uint32(42), ...
                'randomState', uint32([1; 2; 3]), ...
                'startedAtUtc', "2026-07-14T00:00:00.000Z");

        end

        function writeBytes(pathFile, bytes)

            fid = fopen(pathFile, 'wb');

            if fid < 0
                error( ...
                    "ResultManifestRepositoryTest:OpenFailed", ...
                    "Unable to create result fixture: %s", ...
                    pathFile);
            end

            cleanup = onCleanup(@() fclose(fid));
            fwrite(fid, bytes, 'uint8');
            clear cleanup

        end

        function path = sourcePath()

            path = fullfile( ...
                ResultManifestRepositoryTest.repositoryRoot(), ...
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
