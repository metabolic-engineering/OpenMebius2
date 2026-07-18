classdef ModelPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsTemplateLoadStarted(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();

            viewModel = presenter.presentTemplateLoadStarted();

            testCase.verifyEqual(viewModel.SectionStatus, "running");
            testCase.verifyEmpty(viewModel.Result);

        end

        function presentsLoadedTemplate(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            result = struct("Messages", ["Folder found."; "Model loaded."]);
            outcome = openmebius.application.model ...
                .ModelOperationOutcome("finished", Result = result);

            viewModel = presenter.presentTemplateLoadOutcome(outcome);
            messages = cellfun( ...
                @(notification) notification.Message, ...
                viewModel.Notifications);

            testCase.verifyEqual(viewModel.SectionStatus, "running");
            testCase.verifyEqual(viewModel.CompletionStatus, "finished");
            testCase.verifyEqual(viewModel.Result, result);
            testCase.verifyEqual( ...
                messages, ...
                ["Folder found."; "Model loaded."; ...
                 "Constructing EMU network..."]);
            testCase.verifyEqual( ...
                viewModel.CompletionNotification.Message, ...
                "EMU network was successfully constructed.");

        end

        function presentsTemplateLoadFailure(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            outcome = openmebius.application.model ...
                .ModelOperationOutcome( ...
                    "error", ErrorMessage = "Load failed.");

            viewModel = presenter.presentTemplateLoadOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyEmpty(viewModel.Result);
            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual( ...
                notification.Title, "Template model load failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

    end % methods (Test)

end % classdef
