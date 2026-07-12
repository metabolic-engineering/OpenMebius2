classdef CreateProjectUseCaseTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(CreateProjectUseCaseTest.sourcePath());

        end

    end

    methods (Test)

        function executeCreatesProjectLayoutAndMetadata(testCase)

            parentDirectory = string(tempname);
            mkdir(parentDirectory);
            cleanup = onCleanup(@() ...
                CreateProjectUseCaseTest.removeDirectory(parentDirectory));

            metadata = openmebius.domain.project.ProjectMetadata( ...
                Name = "Created Project", ...
                Author = "OpenMebius", ...
                Organism = "E. coli");

            useCase = openmebius.application.project.CreateProjectUseCase( ...
                openmebius.infrastructure.project.FileProjectRepository());

            result = useCase.execute( ...
                ParentDirectory = parentDirectory, ...
                ProjectDirectoryName = "NewProject", ...
                TemplateModelDirectory = ...
                CreateProjectUseCaseTest.templateModelDirectory(), ...
                Metadata = metadata);

            paths = result.Session.Paths;

            testCase.verifyTrue(isfolder(paths.RootDirectory));
            testCase.verifyTrue(isfolder(paths.ModelDirectory));
            testCase.verifyTrue(isfolder(paths.ExperimentDirectory));
            testCase.verifyTrue(isfolder(paths.ResultDirectory));
            testCase.verifyTrue(isfile(paths.SettingFile));
            testCase.verifyTrue(isfile(paths.LegacySettingFile));
            testCase.verifyTrue( ...
                isfile(fullfile(paths.ModelDirectory, "metabolic_network.xlsx")));

            saved = openmebius.infrastructure.project.FileProjectRepository ...
                .readMetadata(paths.SettingFile);

            testCase.verifyEqual(saved.Name, metadata.Name);
            testCase.verifyEqual(saved.Author, metadata.Author);
            testCase.verifyEqual(saved.Organism, metadata.Organism);
            testCase.verifyGreaterThanOrEqual(numel(result.Messages), 3);

        end

        function executeRejectsExistingProjectDirectory(testCase)

            parentDirectory = string(tempname);
            mkdir(parentDirectory);
            mkdir(fullfile(parentDirectory, "NewProject"));
            cleanup = onCleanup(@() ...
                CreateProjectUseCaseTest.removeDirectory(parentDirectory));

            useCase = openmebius.application.project.CreateProjectUseCase( ...
                openmebius.infrastructure.project.FileProjectRepository());

            testCase.verifyError( ...
                @() useCase.execute( ...
                ParentDirectory = parentDirectory, ...
                ProjectDirectoryName = "NewProject", ...
                TemplateModelDirectory = ...
                CreateProjectUseCaseTest.templateModelDirectory(), ...
                Metadata = openmebius.domain.project.ProjectMetadata()), ...
                "OpenMebius2:ProjectCreate:DirectoryAlreadyExists");

        end

        function executeRejectsMissingTemplateBeforeCreatingProject(testCase)

            parentDirectory = string(tempname);
            mkdir(parentDirectory);
            cleanup = onCleanup(@() ...
                CreateProjectUseCaseTest.removeDirectory(parentDirectory));

            useCase = openmebius.application.project.CreateProjectUseCase( ...
                openmebius.infrastructure.project.FileProjectRepository());

            targetDirectory = fullfile(parentDirectory, "NewProject");

            testCase.verifyError( ...
                @() useCase.execute( ...
                ParentDirectory = parentDirectory, ...
                ProjectDirectoryName = "NewProject", ...
                TemplateModelDirectory = fullfile(parentDirectory, "missing-model"), ...
                Metadata = openmebius.domain.project.ProjectMetadata()), ...
                "OpenMebius2:ProjectCreate:TemplateDirectoryNotFound");

            testCase.verifyFalse(isfolder(targetDirectory));

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                CreateProjectUseCaseTest.repositoryRoot(), ...
                "src");

        end

        function path = templateModelDirectory()

            path = fullfile( ...
                CreateProjectUseCaseTest.repositoryRoot(), ...
                "tutorial", ...
                "ecoli", ...
                "model");

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
