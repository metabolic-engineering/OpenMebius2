classdef ProjectArtifactRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(ProjectArtifactRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function loadCreatesArtifactsForNewProject(testCase)

            parentDirectory = string(tempname);
            mkdir(parentDirectory);
            cleanup = onCleanup(@() ...
                ProjectArtifactRepositoryTest.removeDirectory(parentDirectory));

            createUseCase = ...
                openmebius.application.project.CreateProjectUseCase( ...
                openmebius.infrastructure.project.FileProjectRepository());

            createResult = createUseCase.execute( ...
                ParentDirectory = parentDirectory, ...
                ProjectDirectoryName = "NewProject", ...
                TemplateModelDirectory = ...
                ProjectArtifactRepositoryTest.templateModelDirectory(), ...
                Metadata = openmebius.domain.project.ProjectMetadata());

            repository = openmebius.infrastructure.project ...
                .ProjectArtifactRepository();

            artifacts = repository.load( ...
                createResult.Session, AllowEmptyExperiments = true);

            testCase.verifyClass(artifacts, ...
                "openmebius.application.project.ProjectArtifacts");
            testCase.verifyClass( ...
                artifacts.Model, ...
                "openmebius.application.model.MetabolicModel");
            testCase.verifyClass( ...
                artifacts.Experiments, ...
                "openmebius.application.experiment.ExperimentSet");
            testCase.verifyClass(artifacts.Batch, ...
                "openmebius.application.batch.BatchSession");
            testCase.verifyClass( ...
                artifacts.Result, ...
                "openmebius.application.result.ResultCatalog");
            testCase.verifyGreaterThanOrEqual(numel(artifacts.Messages), 4);

            testCase.verifyEqual( ...
                artifacts.Experiments.getExperimentLocation().Directory, ...
                createResult.Session.Paths.ExperimentDirectory);

        end

        function loadUsesInjectedExperimentRepository(testCase)

            projectDirectory = string(tempname);
            mkdir(projectDirectory);
            cleanup = onCleanup(@() ...
                ProjectArtifactRepositoryTest.removeDirectory(projectDirectory));

            session = openmebius.domain.project.ProjectSession( ...
                openmebius.domain.project.ProjectMetadata(), ...
                openmebius.domain.project.ProjectPaths(projectDirectory));

            modelRepository = helpers.RecordingModelRepository();
            experimentRepository = helpers.RecordingExperimentRepository();
            batchRepository = helpers.RecordingBatchRepository();
            resultRepository = helpers.RecordingResultRepository();

            repository = openmebius.infrastructure.project ...
                .ProjectArtifactRepository( ...
                ModelRepository = modelRepository, ...
                ExperimentRepository = experimentRepository, ...
                BatchRepository = batchRepository, ...
                ResultRepository = resultRepository);

            artifacts = repository.load( ...
                session, AllowEmptyExperiments = true);

            testCase.verifyEqual(modelRepository.LoadCount, 1);
            testCase.verifyEqual(experimentRepository.LoadCount, 0);
            testCase.verifyEqual(experimentRepository.InitializeCount, 1);
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
                ProjectArtifactRepositoryTest.repositoryRoot(), ...
                "src");

        end

        function path = templateModelDirectory()

            path = fullfile( ...
                ProjectArtifactRepositoryTest.repositoryRoot(), ...
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
