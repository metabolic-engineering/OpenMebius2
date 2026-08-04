classdef EMUNetworkCacheRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(EMUNetworkCacheRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function saveAndLoadPreserveSnapshot(testCase)

            fixture = EMUNetworkCacheRepositoryTest.createFixture();
            cleanup = onCleanup(@() ...
                EMUNetworkCacheRepositoryTest.removeDirectory( ...
                    fixture.Directory));
            repository = openmebius.infrastructure.model ...
                .EMUNetworkCacheRepository();
            expected = EMUNetworkCacheRepositoryTest.createSnapshot();

            repository.save( ...
                fixture.Location, ...
                fixture.FileName, ...
                fixture.FileType, ...
                expected);
            [actual, isLoaded] = repository.load( ...
                fixture.Location, ...
                fixture.FileName, ...
                fixture.FileType);

            testCase.verifyTrue(isLoaded);
            testCase.verifyEqual(actual.TableEMU, expected.TableEMU);
            testCase.verifyEqual(actual.GlobalAn, expected.GlobalAn);
            testCase.verifyEqual(actual.GlobalMDVSize, 3);
            testCase.verifyTrue(isfile( ...
                fixture.Location.cacheFile(fixture.FileName)));
            testCase.verifyTrue(isfile( ...
                fixture.Location.hashFile(fixture.FileName)));

            clear cleanup

        end

        function changedModelInvalidatesSnapshot(testCase)

            fixture = EMUNetworkCacheRepositoryTest.createFixture();
            cleanup = onCleanup(@() ...
                EMUNetworkCacheRepositoryTest.removeDirectory( ...
                    fixture.Directory));
            repository = openmebius.infrastructure.model ...
                .EMUNetworkCacheRepository();

            repository.save( ...
                fixture.Location, ...
                fixture.FileName, ...
                fixture.FileType, ...
                EMUNetworkCacheRepositoryTest.createSnapshot());
            EMUNetworkCacheRepositoryTest.writeText( ...
                fixture.ModelFile, ...
                "model-v2");
            [snapshot, isLoaded] = repository.load( ...
                fixture.Location, ...
                fixture.FileName, ...
                fixture.FileType);

            testCase.verifyFalse(isLoaded);
            testCase.verifyEmpty(snapshot);

            clear cleanup

        end

        function legacySnapshotUsesDefaultsForOptionalFields(testCase)

            payload = struct( ...
                "tableEMU", table("A", VariableNames = "EMU"), ...
                "tableEMUReaction", table(), ...
                "tableEMUSizeInfo", table());

            snapshot = openmebius.domain.model.EMUNetworkSnapshot(payload);

            testCase.verifyEmpty(snapshot.GlobalCn);
            testCase.verifyEmpty(snapshot.GlobalCnDiag);
            testCase.verifyEqual(snapshot.GlobalMDVSize, 0);

        end

        function snapshotRejectsMissingRequiredFields(testCase)

            testCase.verifyError( ...
                @() openmebius.domain.model.EMUNetworkSnapshot(struct()), ...
                "OpenMebius2:EMUNetworkSnapshot:MissingField");

        end

    end

    methods (Static, Access = private)

        function fixture = createFixture()

            directory = string(tempname);
            mkdir(directory);
            location = openmebius.domain.model.ModelLocation ...
                .fromDirectory(directory);
            fileName = "metabolic_network";
            fileType = "xlsx";
            modelFile = location.modelFile(fileName, fileType);
            EMUNetworkCacheRepositoryTest.writeText(modelFile, "model-v1");
            fixture = struct( ...
                "Directory", directory, ...
                "Location", location, ...
                "FileName", fileName, ...
                "FileType", fileType, ...
                "ModelFile", modelFile);

        end

        function snapshot = createSnapshot()

            payload = struct( ...
                "tableEMU", table("A", VariableNames = "EMU"), ...
                "tableEMUReaction", table("R1", ...
                    VariableNames = "RxnID"), ...
                "tableEMUSizeInfo", table(1, VariableNames = "EMUSize"), ...
                "searchedProduct", {{"A"}}, ...
                "globalAn", [1, 2; 3, 4], ...
                "globalMDVSize", 3);
            snapshot = openmebius.domain.model.EMUNetworkSnapshot(payload);

        end

        function writeText(pathFile, content)

            fid = fopen(pathFile, "w");

            if fid < 0
                error("Unable to create test file: %s", pathFile);
            end

            cleanup = onCleanup(@() fclose(fid));
            fprintf(fid, "%s", content);
            clear cleanup

        end

        function path = sourcePath()

            path = fullfile( ...
                EMUNetworkCacheRepositoryTest.repositoryRoot(), ...
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
