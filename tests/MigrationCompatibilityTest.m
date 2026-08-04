classdef MigrationCompatibilityTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MigrationCompatibilityTest.sourcePath());

        end

    end

    methods (Test)

        function opensAndMigratesLegacyProject(testCase)

            [projectDirectory, cleanup] = ...
                MigrationCompatibilityTest.copyTutorial("ecoli");
            testCase.verifyClass(cleanup, "onCleanup");
            paths = openmebius.domain.project.ProjectPaths( ...
                projectDirectory);
            testCase.assertFalse(isfile(paths.SettingFile));

            repository = openmebius.infrastructure.project ...
                .FileProjectRepository();
            session = repository.openProject(projectDirectory);
            service = openmebius.application.project ...
                .ProjectMigrationService(repository);
            service.migrate(session);
            artifacts = openmebius.infrastructure.project ...
                .ProjectArtifactRepository().load(session);

            testCase.verifyEqual( ...
                session.Metadata.Name, "Tutorial data 1");
            testCase.verifyTrue(isfile(paths.SettingFile));
            testCase.verifyClass(artifacts.Model, ...
                "openmebius.application.model.MetabolicModel");
            testCase.verifyEqual( ...
                height(artifacts.Experiments.getInfoTable()), 3);
            testCase.verifyGreaterThan( ...
                height(artifacts.Batch.tableBatchForGUI), 0);

        end

        function loadsAndNormalizesLegacyBatchJson(testCase)

            location = openmebius.domain.experiment ...
                .ExperimentLocation.fromDirectory(fullfile( ...
                    MigrationCompatibilityTest.repositoryRoot(), ...
                    "tutorial", "ecoli", "experiments"));
            repository = openmebius.infrastructure.batch ...
                .BatchJsonRepository();

            [batchTable, isError, message] = repository.load( ...
                location, "batch.json");

            testCase.verifyFalse(isError, string(message));
            testCase.verifyEqual(height(batchTable), 6);
            testCase.verifyTrue(all(batchTable.contentHash == ""));
            testCase.verifyFalse( ...
                isfield(batchTable.config(1), "random"));
            testCase.verifyTrue( ...
                isfield(batchTable.config(1), "INSTMFA"));

        end

        function readsManifestFreeLegacyResult(testCase)

            resultDirectory = fullfile( ...
                MigrationCompatibilityTest.repositoryRoot(), ...
                "tutorial", "ecoli_monte-carlo", "results");
            location = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);
            repository = openmebius.infrastructure.result ...
                .Hdf5ResultRepository();
            resultId = "D493AC3F110B5799";

            data = repository.readResultData(location, resultId);

            testCase.verifyEqual(string(data.ID), resultId);
            testCase.verifyTrue(any(logical(data.status)));
            testCase.verifyTrue(isfield(data, "RSS"));
            testCase.verifyNotEmpty(data.RSS);
            testCase.verifyFalse(location.hasManifestFile(resultId));

        end

        function migratesUnversionedManifestOnRead(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                MigrationCompatibilityTest.removeDirectory( ...
                    resultDirectory));
            location = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);
            fixture = fullfile( ...
                MigrationCompatibilityTest.repositoryRoot(), ...
                "tests", "fixtures", "compatibility", ...
                "legacy-result.manifest.json");
            copyfile(fixture, location.manifestFile("legacy-result"));
            repository = openmebius.infrastructure.result ...
                .ResultManifestRepository();

            document = repository.read(location, "legacy-result");

            testCase.verifyEqual(document.schemaVersion, 1);
            testCase.verifyEqual( ...
                string(document.batch.id), "legacy-result");
            testCase.verifyEqual( ...
                string(document.result.status), "finished");
            testCase.verifyEqual( ...
                document.analysis.config.iteration, 30);
            clear cleanup

        end

    end

    methods (Static, Access = private)

        function [projectDirectory, cleanup] = copyTutorial(name)

            temporaryRoot = string(tempname);
            mkdir(temporaryRoot);
            cleanup = onCleanup(@() ...
                MigrationCompatibilityTest.removeDirectory(temporaryRoot));
            projectDirectory = fullfile(temporaryRoot, name);
            source = fullfile( ...
                MigrationCompatibilityTest.repositoryRoot(), ...
                "tutorial", name);
            [ok, message] = copyfile(source, projectDirectory);

            if ~ok
                error( ...
                    "MigrationCompatibilityTest:CopyFailed", ...
                    "Could not copy tutorial fixture: %s", ...
                    string(message));
            end

        end

        function path = sourcePath()

            path = fullfile( ...
                MigrationCompatibilityTest.repositoryRoot(), "src");

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
