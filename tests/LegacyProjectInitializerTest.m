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

        function initializeUsesInjectedExperimentRepository(testCase)

            projectDirectory = string(tempname);
            mkdir(projectDirectory);
            cleanup = onCleanup(@() ...
                LegacyProjectInitializerTest.removeDirectory(projectDirectory));

            session = openmebius.domain.project.ProjectSession( ...
                openmebius.domain.project.ProjectMetadata(), ...
                openmebius.domain.project.ProjectPaths(projectDirectory));

            modelRepository = helpers.RecordingModelRepository();
            experimentRepository = helpers.RecordingExperimentRepository();
            batchRepository = helpers.RecordingBatchRepository();
            resultRepository = helpers.RecordingResultRepository();

            initializer = ...
                openmebius.infrastructure.legacy.LegacyProjectInitializer( ...
                ModelRepository = modelRepository, ...
                ExperimentRepository = experimentRepository, ...
                BatchRepository = batchRepository, ...
                ResultRepository = resultRepository);

            artifacts = initializer.initialize(session);

            testCase.verifyEqual(modelRepository.LoadCount, 1);
            testCase.verifyEqual(experimentRepository.LoadCount, 1);
            testCase.verifyEqual(batchRepository.LoadCount, 1);
            testCase.verifyEqual(resultRepository.OpenCount, 1);

            testCase.verifyEqual( ...
                experimentRepository.LoadedLocation.Directory, ...
                session.Paths.ExperimentDirectory);
            testCase.verifyEqual( ...
                experimentRepository.LoadedModel, ...
                modelRepository.Model);
            testCase.verifyEqual( ...
                batchRepository.LoadedExperiments, ...
                experimentRepository.Experiments);

            testCase.verifyEqual(artifacts.Model, modelRepository.Model);
            testCase.verifyEqual( ...
                artifacts.Experiments, ...
                experimentRepository.Experiments);
            testCase.verifyEqual(artifacts.Batch, batchRepository.Batch);
            testCase.verifyEqual(artifacts.Result, resultRepository.Result);

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
