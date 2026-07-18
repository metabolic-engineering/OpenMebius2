classdef ExperimentPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsCalculationStarted(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();

            viewModel = presenter.presentCalculationStarted();

            testCase.verifyEqual(viewModel.SectionStatus, "running");
            testCase.verifyEmpty(viewModel.Notifications);

        end

        function presentsEachSuccessMessageOnce(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            result = struct("Messages", ["Tables updated."; "MDV updated."]);
            outcome = openmebius.application.experiment ...
                .ExperimentCalculationOutcome( ...
                    "finished", Result = result);

            viewModel = presenter.presentCalculationOutcome(outcome);

            messages = cellfun( ...
                @(notification) notification.Message, ...
                viewModel.Notifications);
            testCase.verifyEqual(viewModel.SectionStatus, "finished");
            testCase.verifyEqual( ...
                messages, ["Tables updated."; "MDV updated."]);

        end

        function presentsFailureAsAlert(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            outcome = openmebius.application.experiment ...
                .ExperimentCalculationOutcome( ...
                    "error", ErrorMessage = "Calculation failed.");

            viewModel = presenter.presentCalculationOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual( ...
                notification.Title, "MDV calculation failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

        function presentsImportStarted(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();

            viewModel = presenter.presentImportStarted();

            testCase.verifyEqual(viewModel.SectionStatus, "running");
            testCase.verifyEmpty(viewModel.Result);
            testCase.verifyEmpty(viewModel.Notifications);

        end

        function presentsCanceledFileSelection(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();

            viewModel = presenter.presentFileImportCanceled();
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.SectionStatus, "");
            testCase.verifyEqual(notification.Level, "warning");
            testCase.verifyEqual(notification.Message, "No file selected.");

        end

        function presentsFileImportResultAndMessages(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            result = struct("Messages", ["Copied."; "Reloaded."]);
            outcome = openmebius.application.experiment ...
                .ExperimentImportOutcome( ...
                    "finished", Result = result);

            viewModel = presenter.presentFileImportOutcome(outcome);
            messages = cellfun( ...
                @(notification) notification.Message, ...
                viewModel.Notifications);

            testCase.verifyEqual(viewModel.SectionStatus, "finished");
            testCase.verifyEqual(viewModel.Result, result);
            testCase.verifyEqual( ...
                messages, ...
                ["Copied."; "Reloaded."; ...
                 "Experimental data imported successfully."]);

        end

        function presentsRawImportFailureAsAlert(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            outcome = openmebius.application.experiment ...
                .ExperimentImportOutcome( ...
                    "error", ErrorMessage = "Raw import failed.");

            viewModel = presenter.presentRawMSImportOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyEmpty(viewModel.Result);
            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual( ...
                notification.Title, "Raw MS data import failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

        function presentsExperimentEditStarted(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();

            viewModel = presenter.presentEditStarted();

            testCase.verifyEqual(viewModel.SectionStatus, "running");
            testCase.verifyEmpty(viewModel.UpdatedTable);
            testCase.verifyEmpty(viewModel.Notifications);

        end

        function presentsInfoSaveOutcome(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            result = struct("Messages", ["Updated."; "Saved."]);
            outcome = openmebius.application.experiment ...
                .ExperimentEditOutcome( ...
                    "finished", Result = result);

            viewModel = presenter.presentInfoSaveOutcome(outcome);
            messages = cellfun( ...
                @(notification) notification.Message, ...
                viewModel.Notifications);

            testCase.verifyEqual(viewModel.SectionStatus, "finished");
            testCase.verifyEqual(messages, ["Updated."; "Saved."]);

        end

        function presentsTracerCopyTable(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            updatedTable = table( ...
                ["12C1~1"; "12C1~1"], VariableNames = "Tracer");
            result = struct( ...
                "Messages", "Tracer copied.", ...
                "UpdatedTable", updatedTable);
            outcome = openmebius.application.experiment ...
                .ExperimentEditOutcome( ...
                    "finished", Result = result);

            viewModel = presenter.presentTracerCopyOutcome(outcome);

            testCase.verifyEqual(viewModel.SectionStatus, "");
            testCase.verifyEqual( ...
                viewModel.UpdatedTable, updatedTable);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Message, ...
                "Tracer copied.");

        end

        function presentsTracerSaveFailureAsAlert(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            outcome = openmebius.application.experiment ...
                .ExperimentEditOutcome( ...
                    "error", ErrorMessage = "Save failed.");

            viewModel = presenter.presentTracerSaveOutcome(outcome);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(viewModel.SectionStatus, "error");
            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual(notification.Title, "Tracer save failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

        function presentsTracerConfigurationLoad(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            editorTable = table( ...
                true, "U-13C", 1, ...
                VariableNames = ["Select", "Label", "Ratio"]);
            result = openmebius.application.experiment ...
                .TracerConfigurationResult( ...
                    Position = [2, 3], ...
                    EditorTable = editorTable);
            outcome = openmebius.application.experiment ...
                .ExperimentEditOutcome("finished", Result = result);

            viewModel = presenter ...
                .presentTracerConfigurationLoadOutcome(outcome);

            testCase.verifyTrue(viewModel.IsSuccessful);
            testCase.verifyEqual(viewModel.Position, [2, 3]);
            testCase.verifyEqual(viewModel.EditorTable, editorTable);

        end

        function presentsTracerConfigurationApply(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            result = openmebius.application.experiment ...
                .TracerConfigurationResult( ...
                    Position = [1, 2], Pattern = "U-13C~1");
            outcome = openmebius.application.experiment ...
                .ExperimentEditOutcome("finished", Result = result);

            viewModel = presenter ...
                .presentTracerConfigurationApplyOutcome(outcome);

            testCase.verifyTrue(viewModel.IsSuccessful);
            testCase.verifyEqual(viewModel.Pattern, "U-13C~1");

        end

        function presentsTracerConfigurationFailure(testCase)

            presenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            outcome = openmebius.application.experiment ...
                .ExperimentEditOutcome( ...
                    "error", ErrorMessage = "Load failed.");

            viewModel = presenter ...
                .presentTracerConfigurationLoadOutcome(outcome);

            testCase.verifyFalse(viewModel.IsSuccessful);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Title, ...
                "Tracer configuration load failed");
            testCase.verifyTrue( ...
                viewModel.Notifications{1}.ShowAlert);

        end

    end % methods (Test)

end % classdef
