classdef ExperimentPresenter
    % EXPERIMENTPRESENTER Maps experiment outcomes to UI values.

    methods

        function viewModel = presentWorkspaceTables(obj, experiments)

            viewModel = openmebius.presentation.experiment ...
                .ExperimentWorkspaceViewModel( ...
                InformationTable = ...
                obj.presentInformationTable(experiments), ...
                TracerTable = ...
                obj.presentTracerTable(experiments), ...
                UptakeTable = ...
                obj.presentUptakeTable(experiments));

        end % presentWorkspaceTables

        function viewModel = presentInformationTable(~, experiments)

            viewModel = openmebius.presentation.WorkspaceTableViewModel( ...
                Data = getInfoTable(experiments), ...
                ColumnEditable = true);

        end % presentInformationTable

        function viewModel = presentTracerTable( ...
                ~, experiments, options)

            arguments
                ~
                experiments
                options.ColumnEditable logical = false
            end

            viewModel = openmebius.presentation.WorkspaceTableViewModel( ...
                Data = experiments.getTracerTable(), ...
                ColumnEditable = options.ColumnEditable);

        end % presentTracerTable

        function viewModel = presentUptakeTable(~, experiments)

            viewModel = openmebius.presentation.WorkspaceTableViewModel( ...
                Data = experiments.getUptakeTable(), ...
                ColumnEditable = true);

        end % presentUptakeTable

        function viewModel = presentCalculationStarted(~)

            viewModel = openmebius.presentation.experiment ...
                .ExperimentCalculationViewModel( ...
                SectionStatus = "running");

        end % presentCalculationStarted

        function viewModel = presentCalculationOutcome(~, outcome)

            arguments
                ~
                outcome (1, 1) openmebius.application.experiment ...
                    .ExperimentCalculationOutcome
            end

            if outcome.isSuccess()
                notifications = openmebius.presentation.experiment ...
                    .ExperimentPresenter.successNotifications( ...
                    outcome.Result);
                sectionStatus = "finished";
            else
                message = outcome.ErrorMessage;

                if message == ""
                    message = "MDV calculation failed.";
                end

                notifications = { ...
                    openmebius.presentation.notification ...
                    .Notification.error( ...
                    message, ...
                    Title = "MDV calculation failed", ...
                    ShowAlert = true)};
                sectionStatus = "error";
            end

            viewModel = openmebius.presentation.experiment ...
                .ExperimentCalculationViewModel( ...
                SectionStatus = sectionStatus, ...
                Notifications = notifications);

        end % presentCalculationOutcome

        function viewModel = presentImportStarted(~)

            viewModel = openmebius.presentation.experiment ...
                .ExperimentImportViewModel( ...
                SectionStatus = "running");

        end % presentImportStarted

        function viewModel = presentFileImportCanceled(~)

            notification = openmebius.presentation.notification ...
                .Notification.warning("No file selected.");
            viewModel = openmebius.presentation.experiment ...
                .ExperimentImportViewModel( ...
                Notifications = {notification});

        end % presentFileImportCanceled

        function viewModel = presentFileImportOutcome(obj, outcome)

            viewModel = obj.presentImportOutcome( ...
                outcome, ...
                "Experimental data imported successfully.", ...
                "Experiment import failed");

        end % presentFileImportOutcome

        function viewModel = presentReloadOutcome(obj, outcome)

            viewModel = obj.presentImportOutcome( ...
                outcome, ...
                "Experimental data reloaded.", ...
                "Experiment reload failed");

        end % presentReloadOutcome

        function viewModel = presentRawMSImportOutcome(obj, outcome)

            viewModel = obj.presentImportOutcome( ...
                outcome, ...
                "Raw MS data imported successfully.", ...
                "Raw MS data import failed");

        end % presentRawMSImportOutcome

        function viewModel = presentEditStarted(~)

            viewModel = openmebius.presentation.experiment ...
                .ExperimentEditViewModel( ...
                SectionStatus = "running");

        end % presentEditStarted

        function viewModel = presentInfoSaveOutcome(obj, outcome)

            viewModel = obj.presentEditOutcome( ...
                outcome, "Experiment save failed");

        end % presentInfoSaveOutcome

        function viewModel = presentTracerSaveOutcome(obj, outcome)

            viewModel = obj.presentEditOutcome( ...
                outcome, "Tracer save failed");

        end % presentTracerSaveOutcome

        function viewModel = presentTracerCopySelectionRequired(~)

            notification = openmebius.presentation.notification ...
                .Notification.warning( ...
                "Please select a tracer to copy.");
            viewModel = openmebius.presentation.experiment ...
                .ExperimentEditViewModel( ...
                Notifications = {notification});

        end % presentTracerCopySelectionRequired

        function viewModel = presentTracerCopyOutcome(obj, outcome)

            viewModel = obj.presentEditOutcome( ...
                outcome, ...
                "Tracer copy failed", ...
                SuccessStatus = "", ...
                ErrorStatus = "", ...
                IncludeUpdatedTable = true);

        end % presentTracerCopyOutcome

        function viewModel = presentTracerConfigurationLoadOutcome( ...
                obj, outcome)

            viewModel = obj.presentTracerConfigurationOutcome( ...
                outcome, "Tracer configuration load failed");

        end % presentTracerConfigurationLoadOutcome

        function viewModel = ...
                presentTracerConfigurationPreparationOutcome( ...
                obj, outcome)

            arguments
                obj
                outcome (1, 1) openmebius.application.experiment ...
                    .ExperimentEditOutcome
            end

            if ~outcome.isSuccess()
                viewModel = obj.presentTracerConfigurationOutcome( ...
                    outcome, "Tracer configuration load failed");
                return
            end

            decision = outcome.Result;

            if ~decision.IsAllowed
                notification = openmebius.presentation.notification ...
                    .Notification.warning(decision.Message);
                viewModel = openmebius.presentation.experiment ...
                    .TracerConfigurationViewModel( ...
                    Notifications = {notification});
                return
            end

            viewModel = openmebius.presentation.experiment ...
                .TracerConfigurationViewModel( ...
                IsSuccessful = true, ...
                Position = decision.Position, ...
                EditorTable = decision.EditorTable);

        end % presentTracerConfigurationPreparationOutcome

        function viewModel = presentTracerConfigurationApplyOutcome( ...
                obj, outcome)

            viewModel = obj.presentTracerConfigurationOutcome( ...
                outcome, "Tracer configuration update failed");

        end % presentTracerConfigurationApplyOutcome

    end % methods

    methods (Access = private)

        function viewModel = presentTracerConfigurationOutcome( ...
                ~, outcome, errorTitle)

            arguments
                ~
                outcome (1, 1) openmebius.application.experiment ...
                    .ExperimentEditOutcome
                errorTitle (1, 1) string
            end

            if outcome.isSuccess()
                result = outcome.Result;
                notifications = ...
                    openmebius.presentation.experiment ...
                    .ExperimentPresenter.editNotifications(result);
                viewModel = openmebius.presentation.experiment ...
                    .TracerConfigurationViewModel( ...
                    IsSuccessful = true, ...
                    Position = result.Position, ...
                    EditorTable = result.EditorTable, ...
                    Pattern = result.Pattern, ...
                    Notifications = notifications);
                return
            end

            message = outcome.ErrorMessage;

            if message == ""
                message = errorTitle + ".";
            end

            notification = openmebius.presentation.notification ...
                .Notification.error( ...
                message, ...
                Title = errorTitle, ...
                ShowAlert = true);
            viewModel = openmebius.presentation.experiment ...
                .TracerConfigurationViewModel( ...
                Notifications = {notification});

        end % presentTracerConfigurationOutcome

        function viewModel = presentImportOutcome( ...
                ~, outcome, successMessage, errorTitle)

            arguments
                ~
                outcome (1, 1) openmebius.application.experiment ...
                    .ExperimentImportOutcome
                successMessage (1, 1) string
                errorTitle (1, 1) string
            end

            if outcome.isSuccess()
                notifications = openmebius.presentation.experiment ...
                    .ExperimentPresenter.importNotifications( ...
                    outcome.Result, successMessage);
                sectionStatus = "finished";
                result = outcome.Result;
            else
                message = outcome.ErrorMessage;

                if message == ""
                    message = errorTitle + ".";
                end

                notifications = { ...
                    openmebius.presentation.notification ...
                    .Notification.error( ...
                    message, ...
                    Title = errorTitle, ...
                    ShowAlert = true)};
                sectionStatus = "error";
                result = [];
            end

            viewModel = openmebius.presentation.experiment ...
                .ExperimentImportViewModel( ...
                SectionStatus = sectionStatus, ...
                Result = result, ...
                Notifications = notifications);

        end % presentImportOutcome

        function viewModel = presentEditOutcome( ...
                ~, outcome, errorTitle, options)

            arguments
                ~
                outcome (1, 1) openmebius.application.experiment ...
                    .ExperimentEditOutcome
                errorTitle (1, 1) string
                options.SuccessStatus (1, 1) string = "finished"
                options.ErrorStatus (1, 1) string = "error"
                options.IncludeUpdatedTable (1, 1) logical = false
            end

            updatedTable = table();

            if outcome.isSuccess()
                notifications = openmebius.presentation.experiment ...
                    .ExperimentPresenter.editNotifications(outcome.Result);
                sectionStatus = options.SuccessStatus;

                if options.IncludeUpdatedTable
                    updatedTable = outcome.Result.UpdatedTable;
                end
            else
                message = outcome.ErrorMessage;

                if message == ""
                    message = errorTitle + ".";
                end

                notifications = { ...
                    openmebius.presentation.notification ...
                    .Notification.error( ...
                    message, ...
                    Title = errorTitle, ...
                    ShowAlert = true)};
                sectionStatus = options.ErrorStatus;
            end

            viewModel = openmebius.presentation.experiment ...
                .ExperimentEditViewModel( ...
                SectionStatus = sectionStatus, ...
                UpdatedTable = updatedTable, ...
                Notifications = notifications);

        end % presentEditOutcome

    end % methods (Access = private)

    methods (Static, Access = private)

        function notifications = successNotifications(result)

            messages = string(result.Messages);
            messages = messages(:);

            if isempty(messages)
                messages = "MDV calculation completed.";
            end

            notifications = cell(numel(messages), 1);

            for messageIndex = 1:numel(messages)
                notifications{messageIndex} = ...
                    openmebius.presentation.notification ...
                    .Notification.info(messages(messageIndex));
            end

        end % successNotifications

        function notifications = importNotifications( ...
                result, successMessage)

            messages = string(result.Messages);
            messages = [messages(:); successMessage];
            notifications = cell(numel(messages), 1);

            for messageIndex = 1:numel(messages)
                notifications{messageIndex} = ...
                    openmebius.presentation.notification ...
                    .Notification.info(messages(messageIndex));
            end

        end % importNotifications

        function notifications = editNotifications(result)

            messages = string(result.Messages);
            messages = messages(:);

            if isempty(messages)
                messages = "Experiment data updated.";
            end

            notifications = cell(numel(messages), 1);

            for messageIndex = 1:numel(messages)
                notifications{messageIndex} = ...
                    openmebius.presentation.notification ...
                    .Notification.info(messages(messageIndex));
            end

        end % editNotifications

    end % methods (Static, Access = private)

end % classdef
