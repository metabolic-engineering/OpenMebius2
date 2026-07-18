classdef ProjectPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsProjectLoadStarted(testCase)

            presenter = openmebius.presentation.project.ProjectPresenter();

            viewModel = presenter.presentLoadStarted();

            testCase.verifyEqual(viewModel.ModelStatus, "running");
            testCase.verifyEmpty(viewModel.Session);

        end

        function presentsOpenedProject(testCase)

            presenter = openmebius.presentation.project.ProjectPresenter();
            result = ProjectPresenterTest.operationResult();
            outcome = openmebius.application.project ...
                .ProjectOperationOutcome("finished", Result = result);

            viewModel = presenter.presentOpenOutcome(outcome);
            messages = cellfun( ...
                @(notification) notification.Message, ...
                viewModel.Notifications);

            testCase.verifyEqual(viewModel.ArtifactMode, "open");
            testCase.verifyEqual(viewModel.Session, result.Session);
            testCase.verifyEqual(viewModel.Artifacts, result.Artifacts);
            testCase.verifyEqual(messages, "Completed.");

        end

        function presentsCreateFailure(testCase)

            presenter = openmebius.presentation.project.ProjectPresenter();
            outcome = openmebius.application.project ...
                .ProjectOperationOutcome( ...
                    "error", ErrorMessage = "Create failed.");

            viewModel = presenter.presentCreateOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.ModelStatus, "error");
            testCase.verifyEqual(viewModel.ArtifactMode, "");
            testCase.verifyEqual(notification.Title, "Project create failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

        function presentsSavedProjectWithoutArtifactRendering(testCase)

            presenter = openmebius.presentation.project.ProjectPresenter();
            result = ProjectPresenterTest.operationResult(Artifacts = []);
            outcome = openmebius.application.project ...
                .ProjectOperationOutcome("finished", Result = result);

            viewModel = presenter.presentSaveOutcome(outcome);

            testCase.verifyEqual(viewModel.ArtifactMode, "");
            testCase.verifyEqual(viewModel.Session, result.Session);
            testCase.verifyEmpty(viewModel.Artifacts);

        end

    end % methods (Test)

    methods (Static, Access = private)

        function result = operationResult(options)

            arguments
                options.Artifacts = struct("Messages", "Artifacts.")
            end

            metadata = openmebius.domain.project.ProjectMetadata( ...
                Name = "Project");
            paths = openmebius.domain.project.ProjectPaths(tempdir);
            session = openmebius.domain.project.ProjectSession( ...
                metadata, paths);
            result = openmebius.application.project ...
                .ProjectOperationResult( ...
                    Session = session, ...
                    Artifacts = options.Artifacts, ...
                    Messages = "Completed.");

        end

    end % methods (Static, Access = private)

end % classdef
