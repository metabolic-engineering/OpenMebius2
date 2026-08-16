classdef ProjectOperationControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function opensProjectAndLoadsArtifacts(testCase)

            fixture = ProjectOperationControllerTest.fixture();
            fixture.OpenUseCase.Result = fixture.Session;
            fixture.ArtifactService.LoadResult = fixture.Artifacts;
            controller = ProjectOperationControllerTest.controller(fixture);

            outcome = controller.open("project");

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(outcome.Result.Session, fixture.Session);
            testCase.verifyEqual(outcome.Result.Artifacts, fixture.Artifacts);
            testCase.verifyTrue(fixture.OpenUseCase.Called);
            testCase.verifyTrue(fixture.ArtifactService.LoadCalled);
            testCase.verifyEqual(fixture.OpenUseCase.Inputs{1}, "project");

        end

        function savesExistingSession(testCase)

            fixture = ProjectOperationControllerTest.fixture();
            controller = ProjectOperationControllerTest.controller(fixture);
            metadata = openmebius.domain.project.ProjectMetadata( ...
                Name = "Updated", Author = "Author", Organism = "Cell");

            outcome = controller.save( ...
                fixture.Session, "unused", metadata);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyTrue(fixture.Repository.SaveCalled);
            testCase.verifyFalse(fixture.OpenUseCase.Called);
            testCase.verifyEqual( ...
                outcome.Result.Session.Metadata.Name, "Updated");
            testCase.verifyEqual( ...
                outcome.Result.Session.Paths, fixture.Session.Paths);

        end

        function resolvesMissingSessionBeforeSave(testCase)

            fixture = ProjectOperationControllerTest.fixture();
            fixture.OpenUseCase.Result = fixture.Session;
            controller = ProjectOperationControllerTest.controller(fixture);
            metadata = openmebius.domain.project.ProjectMetadata(Name = "Saved");

            outcome = controller.save([], "project", metadata);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyTrue(fixture.OpenUseCase.Called);
            testCase.verifyTrue(fixture.Repository.SaveCalled);

        end

        function createsProjectAndInitializesArtifacts(testCase)

            fixture = ProjectOperationControllerTest.fixture();
            fixture.CreateUseCase.Result = ...
                openmebius.application.project.ProjectCreateResult( ...
                Session = fixture.Session, ...
                Messages = "Created.");
            fixture.ArtifactService.InitializeResult = fixture.Artifacts;
            controller = ProjectOperationControllerTest.controller(fixture);
            metadata = fixture.Session.Metadata;

            outcome = controller.create( ...
                ParentDirectory = "parent", ...
                ProjectDirectoryName = "project", ...
                TemplateModelDirectory = "template", ...
                Metadata = metadata);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyTrue(fixture.CreateUseCase.Called);
            testCase.verifyTrue(fixture.ArtifactService.InitializeCalled);
            testCase.verifyEqual( ...
                outcome.Result.Messages, ...
                ["Created."; "Artifacts initialized."]);

        end

        function duplicatesProjectWithoutLoadingArtifacts(testCase)

            fixture = ProjectOperationControllerTest.fixture();
            fixture.DuplicateUseCase.Result = ...
                openmebius.application.project.ProjectDuplicateResult( ...
                Session = fixture.Session, ...
                Messages = "Duplicated.");
            controller = ProjectOperationControllerTest.controller(fixture);

            outcome = controller.duplicate( ...
                fixture.Session, ...
                ParentDirectory = "parent", ...
                ProjectDirectoryName = "project_2");

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyTrue(fixture.DuplicateUseCase.Called);
            testCase.verifyFalse(fixture.ArtifactService.LoadCalled);
            testCase.verifyEqual(outcome.Result.Messages, "Duplicated.");

        end

        function capturesProjectFailure(testCase)

            fixture = ProjectOperationControllerTest.fixture();
            fixture.OpenUseCase.Exception = MException( ...
                "OpenMebius2:Test:ProjectOpenFailed", ...
                "Project open failed.");
            controller = ProjectOperationControllerTest.controller(fixture);

            outcome = controller.open("project");

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual( ...
                outcome.ErrorMessage, "Project open failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:ProjectOpenFailed");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function fixture = fixture()

            metadata = openmebius.domain.project.ProjectMetadata( ...
                Name = "Project");
            paths = openmebius.domain.project.ProjectPaths(tempdir);
            fixture = struct( ...
                "Session", openmebius.domain.project.ProjectSession( ...
                metadata, paths), ...
                "Artifacts", struct( ...
                "Messages", "Artifacts initialized."), ...
                "Repository", helpers.ProjectRepositoryStub(), ...
                "OpenUseCase", helpers.ProjectUseCaseStub(), ...
                "CreateUseCase", helpers.ProjectUseCaseStub(), ...
                "DuplicateUseCase", helpers.ProjectUseCaseStub(), ...
                "ArtifactService", helpers.ProjectArtifactServiceStub());

        end

        function controller = controller(fixture)

            controller = openmebius.application.project ...
                .ProjectOperationController( ...
                Repository = fixture.Repository, ...
                OpenProjectUseCase = fixture.OpenUseCase, ...
                CreateProjectUseCase = fixture.CreateUseCase, ...
                DuplicateProjectUseCase = fixture.DuplicateUseCase, ...
                ArtifactRepository = fixture.ArtifactService);

        end

    end % methods (Static, Access = private)

end % classdef
