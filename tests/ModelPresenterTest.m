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

        function presentsValidModelEdit(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            report = openmebius.domain.model.ModelValidationReport.success( ...
                "Model updated.");
            result = openmebius.application.model.ModelEditResult( ...
                ModelReport = report);
            outcome = openmebius.application.model ...
                .ModelOperationOutcome("finished", Result = result);

            viewModel = presenter.presentModelSaveOutcome(outcome);

            testCase.verifyEqual(viewModel.CompletionStatus, "finished");
            testCase.verifyTrue(viewModel.FinishEditCommit);
            testCase.verifyTrue(viewModel.EditCommitSucceeded);
            testCase.verifyEqual(viewModel.ValidationReports{1}, report);
            testCase.verifyEqual( ...
                string(viewModel.ValidationStyles(1).Target), "model");
            testCase.verifyEmpty(viewModel.ValidationStyles(1).Rows);

        end

        function presentsInvalidModelEdit(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            report = openmebius.domain.model.ModelValidationReport.failure( ...
                "Invalid model.", InvalidRows = [2; 4]);
            result = openmebius.application.model.ModelEditResult( ...
                ModelReport = report);
            outcome = openmebius.application.model ...
                .ModelOperationOutcome("finished", Result = result);

            viewModel = presenter.presentModelSaveOutcome(outcome);

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyTrue(viewModel.FinishEditCommit);
            testCase.verifyFalse(viewModel.EditCommitSucceeded);
            testCase.verifyEqual( ...
                viewModel.ValidationStyles(1).Rows, [2; 4]);

        end

        function presentsValidMassSpectrometryEdit(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            msReport = ...
                openmebius.domain.model.ModelValidationReport.success( ...
                    "MS updated.");
            atomReport = ...
                openmebius.domain.model.ModelValidationReport.success( ...
                    "Atom updated.");
            result = openmebius.application.model.ModelEditResult( ...
                MSReport = msReport, ...
                AtomReport = atomReport);
            outcome = openmebius.application.model ...
                .ModelOperationOutcome("finished", Result = result);

            viewModel = ...
                presenter.presentMassSpectrometrySaveOutcome(outcome);

            testCase.verifyTrue(viewModel.EditCommitSucceeded);
            testCase.verifyEqual( ...
                string({viewModel.ValidationStyles.Target})', ...
                ["ms"; "atom"]);
            testCase.verifyEqual( ...
                viewModel.CompletionNotification.Message, ...
                "MS table saved");

        end

        function presentsModelEditException(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            outcome = openmebius.application.model ...
                .ModelOperationOutcome( ...
                    "error", ErrorMessage = "Save failed.");

            viewModel = presenter.presentModelSaveOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyTrue(viewModel.FinishEditCommit);
            testCase.verifyFalse(viewModel.EditCommitSucceeded);
            testCase.verifyEqual(notification.Title, "Model table save failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

    end % methods (Test)

end % classdef
