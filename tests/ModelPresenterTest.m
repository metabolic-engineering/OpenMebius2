classdef ModelPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function presentsModelWorkspaceTables(testCase)

            model = helpers.ModelWorkspaceTableStub();
            presenter = openmebius.presentation.model.ModelPresenter();

            viewModel = presenter.presentWorkspaceTables(model);

            testCase.verifyEqual( ...
                viewModel.ModelTable.Data, model.ModelTable);
            testCase.verifyEqual( ...
                viewModel.ModelTable.ErrorRows, ...
                model.InvalidModelRows);
            testCase.verifyEqual( ...
                viewModel.MassSpectrometryTable.ErrorRows, ...
                model.InvalidMassSpectrometryRows);
            testCase.verifyEqual( ...
                viewModel.AtomTable.ErrorRows, ...
                model.InvalidAtomRows);
            testCase.verifyFalse( ...
                any(viewModel.BiomassTable.ColumnEditable));

        end

        function presentsEditableModelAndMassSpectrometryTables(testCase)

            model = helpers.ModelWorkspaceTableStub();
            presenter = openmebius.presentation.model.ModelPresenter();

            modelTable = presenter.presentModelTable( ...
                model, ColumnEditable = [true, false]);
            [massSpectrometry, atom] = presenter ...
                .presentMassSpectrometryTables( ...
                    model, ColumnEditable = true);

            testCase.verifyEqual( ...
                modelTable.ColumnEditable, [true, false]);
            testCase.verifyTrue( ...
                all(massSpectrometry.ColumnEditable));
            testCase.verifyTrue(all(atom.ColumnEditable));

        end

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
                .ModelOperationOutcome(true, Result = result);

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
                    false, ErrorMessage = "Load failed.");

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
                .ModelOperationOutcome(true, Result = result);

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
                .ModelOperationOutcome(true, Result = result);

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
                .ModelOperationOutcome(true, Result = result);

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
                    false, ErrorMessage = "Save failed.");

            viewModel = presenter.presentModelSaveOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyTrue(viewModel.FinishEditCommit);
            testCase.verifyFalse(viewModel.EditCommitSucceeded);
            testCase.verifyEqual(notification.Title, "Model table save failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

        function presentsTemplateExportUnavailable(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();

            viewModel = presenter.presentTemplateExportUnavailable();
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual( ...
                notification.Title, "Template export unavailable");
            testCase.verifyFalse(notification.ShowAlert);

        end

        function presentsTemplateExportSuccess(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            result = openmebius.application.model ...
                .MassSpectrometryTemplateExportResult( ...
                    OutputPath = "template.xlsx", ...
                    Messages = ["Exported."; "template.xlsx"]);
            outcome = openmebius.application.model ...
                .ModelOperationOutcome(true, Result = result);

            viewModel = presenter.presentTemplateExportOutcome(outcome);
            messages = cellfun( ...
                @(notification) notification.Message, ...
                viewModel.Notifications);

            testCase.verifyEqual( ...
                messages, ["Exported."; "template.xlsx"]);

        end

        function presentsTemplateExportFailure(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            outcome = openmebius.application.model ...
                .ModelOperationOutcome( ...
                    false, ErrorMessage = "Write failed.");

            viewModel = presenter.presentTemplateExportOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual(notification.Title, "Template export failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

        function presentsPathwayData(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            model = helpers.PathwayModelStub();
            model.PathwayData = openmebius.application.model ...
                .ModelPathwayData( ...
                    Image = uint8(ones(2, 3, 3)), ...
                    ReactionIDs = ["R1"; "R2"], ...
                    X = [10; 20], ...
                    Y = [30; 40]);

            viewModel = presenter.presentPathway( ...
                model, ...
                Labels = [1.234; 2.345; 9.999], ...
                HighlightReactionIDs = "R2", ...
                IsDarkTheme = true);

            testCase.verifyEqual(viewModel.Labels, ["1.23"; "2.35"]);
            testCase.verifyEqual(viewModel.X, [10; 20]);
            testCase.verifyEqual(viewModel.Y, [30; 40]);
            testCase.verifyEqual(viewModel.Highlight, [false; true]);
            testCase.verifyTrue(viewModel.IsDarkTheme);
            testCase.verifyEmpty(viewModel.Notification);

        end

        function usesReactionIdsAsDefaultPathwayLabels(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            model = helpers.PathwayModelStub();
            model.PathwayData = openmebius.application.model ...
                .ModelPathwayData( ...
                    Image = ones(2), ...
                    ReactionIDs = ["R1"; "R2"], ...
                    X = [1; 2], ...
                    Y = [3; 4]);

            viewModel = presenter.presentPathway(model);

            testCase.verifyEqual(viewModel.Labels, ["R1"; "R2"]);

        end

        function presentsMissingPathwayAsWarning(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();

            viewModel = presenter.presentPathway( ...
                helpers.PathwayModelStub());

            testCase.verifyEmpty(viewModel.Image);
            testCase.verifyEqual(viewModel.Notification.Level, "warning");

        end

        function presentsPathwayLabelEdit(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            pathwayData = openmebius.application.model.ModelPathwayData( ...
                Image = ones(2), ...
                ReactionIDs = "R1", ...
                X = 2.5, ...
                Y = 4.5);
            modelTable = table( ...
                2.5, 4.5, ...
                'VariableNames', {'x', 'y'}, ...
                'RowNames', {'R1'});
            result = openmebius.application.model ...
                .PathwayLabelEditResult( ...
                    ReactionID = "R1", ...
                    Position = [2.5 4.5], ...
                    IsRemoved = false, ...
                    ModelTable = modelTable, ...
                    PathwayData = pathwayData, ...
                    Messages = "Position updated.");
            outcome = openmebius.application.model ...
                .ModelOperationOutcome(true, Result = result);

            viewModel = presenter.presentPathwayEditOutcome( ...
                outcome, IsDarkTheme = true);

            testCase.verifyEqual(viewModel.UpdatedModelTable, modelTable);
            testCase.verifyEqual(viewModel.Pathway.X, 2.5);
            testCase.verifyTrue(viewModel.Pathway.Highlight);
            testCase.verifyTrue(viewModel.Pathway.IsDarkTheme);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Message, ...
                "Position updated.");

        end

        function presentsKnownPathwayLabelErrorAsWarning(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            exception = MException( ...
                "OpenMebius2:PathwayLabel:ReactionRequired", ...
                "Please select a reaction.");
            outcome = openmebius.application.model ...
                .ModelOperationOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);

            viewModel = presenter.presentPathwayEditOutcome(outcome);

            testCase.verifyEmpty(viewModel.UpdatedModelTable);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Level, "warning");

        end

        function presentsLabelConfigurationSuccess(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            result = openmebius.application.model ...
                .LabelConfigurationUpdateResult( ...
                    Messages = "Applied.");
            outcome = openmebius.application.model ...
                .ModelOperationOutcome(true, Result = result);

            viewModel = presenter ...
                .presentLabelConfigurationOutcome(outcome);

            testCase.verifyEqual( ...
                viewModel.CompletionStatus, "finished");
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Message, "Applied.");
            testCase.verifyEmpty(viewModel.Result);

        end

        function presentsLabelConfigurationFailure(testCase)

            presenter = openmebius.presentation.model.ModelPresenter();
            outcome = openmebius.application.model ...
                .ModelOperationOutcome( ...
                    false, ErrorMessage = "Apply failed.");

            viewModel = presenter ...
                .presentLabelConfigurationOutcome(outcome);

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Title, ...
                "Label configuration update failed");
            testCase.verifyTrue( ...
                viewModel.Notifications{1}.ShowAlert);

        end

    end % methods (Test)

end % classdef
