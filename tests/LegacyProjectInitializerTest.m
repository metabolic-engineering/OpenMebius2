classdef LegacyProjectInitializerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(LegacyProjectInitializerTest.sourcePath());

        end

    end

    methods (Test)

        function initializeCreatesLegacyArtifactsForNewProject(testCase)

            parentDirectory = string(tempname);
            mkdir(parentDirectory);
            cleanup = onCleanup(@() ...
                LegacyProjectInitializerTest.removeDirectory(parentDirectory));

            createUseCase = ...
                openmebius.application.project.CreateProjectUseCase( ...
                openmebius.infrastructure.project.FileProjectRepository());

            createResult = createUseCase.execute( ...
                ParentDirectory = parentDirectory, ...
                ProjectDirectoryName = "NewProject", ...
                TemplateModelDirectory = ...
                LegacyProjectInitializerTest.templateModelDirectory(), ...
                Metadata = openmebius.domain.project.ProjectMetadata());

            initializer = ...
                openmebius.infrastructure.legacy.LegacyProjectInitializer();

            artifacts = initializer.initialize(createResult.Session);

            testCase.verifyClass(artifacts, ...
                "openmebius.infrastructure.legacy.LegacyProjectArtifacts");
            testCase.verifyClass(artifacts.Model, "EMUModel");
            testCase.verifyClass(artifacts.Experiments, "IOExps");
            testCase.verifyClass(artifacts.Batch, "Batch");
            testCase.verifyClass(artifacts.Result, "IOResult");
            testCase.verifyGreaterThanOrEqual(numel(artifacts.Messages), 4);

            testCase.verifyEqual( ...
                artifacts.Experiments.getExperimentLocation().Directory, ...
                createResult.Session.Paths.ExperimentDirectory);

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                LegacyProjectInitializerTest.repositoryRoot(), ...
                "src");

        end

        function path = templateModelDirectory()

            path = fullfile( ...
                LegacyProjectInitializerTest.repositoryRoot(), ...
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
