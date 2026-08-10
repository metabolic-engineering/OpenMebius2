classdef DuplicateProjectUseCaseTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(DuplicateProjectUseCaseTest.sourcePath());

        end

    end

    methods (Test)

        function executeCopiesProjectAndRenamesMetadata(testCase)

            [root, sourceSession, cleanup] = ...
                DuplicateProjectUseCaseTest.fixture(); %#ok<ASGLU>
            useCase = openmebius.application.project ...
                .DuplicateProjectUseCase( ...
                openmebius.infrastructure.project ...
                .FileProjectRepository());

            result = useCase.execute( ...
                SourceSession = sourceSession, ...
                ParentDirectory = root, ...
                ProjectDirectoryName = "CurrentProject_2");

            destination = fullfile(root, "CurrentProject_2");
            copiedMetadata = openmebius.infrastructure.project ...
                .FileProjectRepository.readMetadata( ...
                result.Session.Paths.SettingFile);

            testCase.verifyEqual( ...
                result.Session.Paths.RootDirectory, destination);
            testCase.verifyTrue(isfile(fullfile( ...
                destination, "model", "nested", "fixture.txt")));
            testCase.verifyEqual(copiedMetadata.Name, "CurrentProject_2");
            testCase.verifyEqual(copiedMetadata.Author, "Author");
            testCase.verifyEqual(copiedMetadata.Organism, "Organism");
            testCase.verifyEqual(sourceSession.Metadata.Name, "CurrentProject");

        end

        function executeRejectsExistingDestination(testCase)

            [root, sourceSession, cleanup] = ...
                DuplicateProjectUseCaseTest.fixture(); %#ok<ASGLU>
            mkdir(fullfile(root, "CurrentProject_2"));
            useCase = openmebius.application.project ...
                .DuplicateProjectUseCase( ...
                openmebius.infrastructure.project ...
                .FileProjectRepository());

            testCase.verifyError( ...
                @() useCase.execute( ...
                SourceSession = sourceSession, ...
                ParentDirectory = root, ...
                ProjectDirectoryName = "CurrentProject_2"), ...
            "OpenMebius2:ProjectDuplicate:DirectoryAlreadyExists");

        end

        function executeRejectsDestinationInsideSource(testCase)

            [~, sourceSession, cleanup] = ...
                DuplicateProjectUseCaseTest.fixture(); %#ok<ASGLU>
            useCase = openmebius.application.project ...
                .DuplicateProjectUseCase( ...
                openmebius.infrastructure.project ...
                .FileProjectRepository());

            testCase.verifyError( ...
                @() useCase.execute( ...
                SourceSession = sourceSession, ...
                ParentDirectory = sourceSession.Paths.RootDirectory, ...
                ProjectDirectoryName = "NestedCopy"), ...
            "OpenMebius2:ProjectDuplicate:DestinationInsideSource");

        end

    end

    methods (Static, Access = private)

        function [root, session, cleanup] = fixture()

            root = string(tempname);
            mkdir(root);
            cleanup = onCleanup(@() ...
                DuplicateProjectUseCaseTest.removeDirectory(root));
            projectDirectory = fullfile(root, "CurrentProject");
            paths = openmebius.domain.project.ProjectPaths( ...
                projectDirectory);
            metadata = openmebius.domain.project.ProjectMetadata( ...
                Name = "CurrentProject", ...
                Author = "Author", ...
                Organism = "Organism");
            session = openmebius.domain.project.ProjectSession( ...
                metadata, paths);
            repository = openmebius.infrastructure.project ...
                .FileProjectRepository();
            repository.saveProject(session);
            openmebius.infrastructure.project.FileProjectRepository ...
                .ensureLayout(paths);
            nestedDirectory = fullfile(paths.ModelDirectory, "nested");
            mkdir(nestedDirectory);
            DuplicateProjectUseCaseTest.writeFixture( ...
                fullfile(nestedDirectory, "fixture.txt"));

        end

        function writeFixture(path)

            fileID = fopen(path, "w");

            if fileID < 0
                error("DuplicateProjectUseCaseTest:FixtureWriteFailed", ...
                    "Could not write fixture file: %s", path);
            end

            cleanup = onCleanup(@() fclose(fileID));
            fprintf(fileID, "fixture");

        end

        function path = sourcePath()

            path = fullfile( ...
                DuplicateProjectUseCaseTest.repositoryRoot(), "src");

        end

        function root = repositoryRoot()

            root = fileparts(fileparts(mfilename("fullpath")));

        end

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, "s");
            end

        end

    end

end
