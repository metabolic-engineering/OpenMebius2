classdef BatchPresenter < handle

    methods

        function viewModel = presentTable(obj, batch)

            if obj.isInvalidHandle(batch)
                error( ...
                    "OpenMebius2:Batch:InvalidBatchObject", ...
                    "Batch object is not valid.");
            end

            [batchGUI, columnEditable] = getBatchForGUI(batch);

            if isempty(batchGUI)
                viewModel = ...
                    openmebius.presentation.batch.BatchTableViewModel( ...
                    Data = table(), ...
                    ColumnEditable = false(1, 0));
                return
            end

            rawData = batchGUI;
            batchGUI.ID = openmebius.presentation ...
                .IdentifierFormatter.short(batchGUI.ID);

            if any(batchGUI.Properties.VariableNames == "Experiment")
                batchGUI.Experiment = string(batchGUI.Experiment);
            end

            ids = rawData.ID;
            status = getBatchStatus(batch, ids);

            styleRules = obj.styleRulesForStatus(batchGUI, status);

            viewModel = ...
                openmebius.presentation.batch.BatchTableViewModel( ...
                Data = batchGUI, ...
                RawData = rawData, ...
                ColumnEditable = columnEditable, ...
                StyleRules = styleRules);

        end

        function viewModel = presentRunStarted(~)

            viewModel = ...
                openmebius.presentation.batch.BatchRunViewModel( ...
                SectionStatus = "running", ...
                Notification = openmebius.presentation.notification ...
                .Notification.info("Batch jobs are running..."));

        end % presentRunStarted

        function viewModel = presentCancelRequested(~)

            viewModel = ...
                openmebius.presentation.batch.BatchRunViewModel( ...
                Notification = openmebius.presentation.notification ...
                .Notification.info( ...
                "Canceling batch jobs. " + ...
                "It may take several minutes..."));

        end % presentCancelRequested

        function viewModel = presentRunOutcome(~, outcome)

            arguments
                ~
                outcome (1, 1) openmebius.application.batch.BatchRunOutcome
            end

            if outcome.isSuccess()
                sectionStatus = "finished";
                completionStatus = "finished";
                message = "All batch jobs are completed.";
                notification = openmebius.presentation.notification ...
                    .Notification.info(message);
            elseif outcome.isCanceled()
                sectionStatus = "finished";
                completionStatus = "canceled";
                message = "Batch jobs are canceled.";
                notification = openmebius.presentation.notification ...
                    .Notification.info(message);
            else
                sectionStatus = "error";
                completionStatus = "error";
                message = outcome.ErrorMessage;

                if message == ""
                    message = "Batch jobs failed.";
                end

                notification = openmebius.presentation.notification ...
                    .Notification.error(message);
            end

            viewModel = ...
                openmebius.presentation.batch.BatchRunViewModel( ...
                SectionStatus = sectionStatus, ...
                Notification = notification, ...
                CompletionStatus = completionStatus, ...
                ElapsedTime = outcome.ElapsedTime, ...
                ErrorMessage = outcome.ErrorMessage);

        end % presentRunOutcome

        function viewModel = presentAutoFillOutcome(obj, outcome, batch)

            viewModel = obj.presentOperationOutcome( ...
                outcome, ...
                batch, ...
                "Batch table has been automatically filled.", ...
                "Batch auto fill failed");

        end % presentAutoFillOutcome

        function viewModel = presentReloaded(obj, batch)

            notification = openmebius.presentation.notification ...
                .Notification.info("Batch table reloaded");
            viewModel = openmebius.presentation.batch ...
                .BatchOperationViewModel( ...
                TableViewModel = obj.presentTable(batch), ...
                Notifications = {notification});

        end % presentReloaded

        function viewModel = presentSaveOutcome(obj, outcome, batch)

            viewModel = obj.presentOperationOutcome( ...
                outcome, ...
                batch, ...
                "Batch table has been saved.", ...
                "Batch table save failed");

        end % presentSaveOutcome

        function viewModel = presentRemoveOutcome(obj, outcome, batch)

            viewModel = obj.presentOperationOutcome( ...
                outcome, ...
                batch, ...
                "Selected batch has been removed.", ...
                "Batch removal failed");

        end % presentRemoveOutcome

        function viewModel = presentDuplicateOutcome(obj, outcome, batch)

            viewModel = obj.presentOperationOutcome( ...
                outcome, ...
                batch, ...
                "Selected batch has been duplicated.", ...
                "Batch duplication failed");

        end % presentDuplicateOutcome

        function viewModel = presentExperimentSelectionOutcome( ...
                obj, outcome, batch)

            viewModel = obj.presentOperationOutcome( ...
                outcome, ...
                batch, ...
                "Batch experiments have been updated.", ...
                "Batch experiment update failed");

        end % presentExperimentSelectionOutcome

        function styleRules = styleRulesForStatus(obj, tableData, status)

            if isempty(tableData)
                styleRules = struct( ...
                    "Rows", {}, ...
                    "Columns", {}, ...
                    "StyleKey", {});
                return
            end

            status = string(status);
            status = status(:);

            n = min(height(tableData), numel(status));

            styleRules = struct( ...
                "Rows", {}, ...
                "Columns", {}, ...
                "StyleKey", {});

            for i = 1:n

                styleRules(end + 1, 1) = struct( ...
                    "Rows", i, ...
                    "Columns", 1, ...
                    "StyleKey", obj.statusToStyleKey(status(i))); %#ok<AGROW>

            end

        end

        function viewModel = presentProgress(obj, progress, currentTableData)

            batchId = string(progress.id);
            status = lower(string(progress.status));
            rate = double(progress.rate);

            if isfield(progress, "message") && ...
                    strlength(string(progress.message)) > 0
                message = string(progress.message);
            else
                message = obj.progressMessage(batchId, status);
            end

            row = obj.findBatchRow(currentTableData, batchId);

            if isempty(row)
                styleRules = struct( ...
                    "Rows", {}, ...
                    "Columns", {}, ...
                    "StyleKey", {});
            else
                styleRules = struct( ...
                    "Rows", row, ...
                    "Columns", 1, ...
                    "StyleKey", obj.statusToStyleKey(status));
            end

            if status == "running"
                notification = [];
            else
                notification = ...
                    openmebius.presentation.notification.Notification ...
                    .fromBatchStatus(message, status);
            end

            viewModel = ...
                openmebius.presentation.batch.BatchProgressViewModel( ...
                BatchId = batchId, ...
                Status = status, ...
                Rate = rate, ...
                Message = message, ...
                StyleRules = styleRules, ...
                Notification = notification);

        end

    end

    methods (Access = private)

        function viewModel = presentOperationOutcome( ...
                obj, outcome, batch, successMessage, errorTitle)

            arguments
                obj
                outcome (1, 1) openmebius.application.batch ...
                    .BatchOperationOutcome
                batch
                successMessage (1, 1) string
                errorTitle (1, 1) string
            end

            if outcome.isSuccess()
                notification = openmebius.presentation.notification ...
                    .Notification.info(successMessage);
                viewModel = openmebius.presentation.batch ...
                    .BatchOperationViewModel( ...
                    TableViewModel = obj.presentTable(batch), ...
                    Notifications = {notification}, ...
                    ErrorTitle = errorTitle);
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
            viewModel = openmebius.presentation.batch ...
                .BatchOperationViewModel( ...
                Notifications = {notification}, ...
                ErrorTitle = errorTitle);

        end % presentOperationOutcome

        function tf = isInvalidHandle(~, value)

            tf = isempty(value);

            if tf
                return
            end

            try
                tf = ~isvalid(value);
            catch
                tf = false;
            end

        end

        function key = statusToStyleKey(~, status)

            status = lower(string(status));

            switch status

                case "ready"
                    key = "info";

                case "running"
                    key = "info";

                case "finished"
                    key = "success";

                case "warning"
                    key = "warning";

                case "canceled"
                    key = "warning";

                case "error"
                    key = "error";

                case "question"
                    key = "question";

                otherwise
                    error( ...
                        "OpenMebius2:Batch:UnknownStatus", ...
                        "Unknown batch status: %s", status);
            end

        end

        function row = findBatchRow(~, tableData, batchId)

            row = [];

            if isempty(tableData)
                return
            end

            if ~istable(tableData)
                return
            end

            if ~any(tableData.Properties.VariableNames == "ID")
                return
            end

            row = find(string(tableData.ID) == batchId, 1);

        end

        function message = progressMessage(~, batchId, status)

            batchId = openmebius.presentation ...
                .IdentifierFormatter.short(batchId);

            switch lower(string(status))

                case "finished"
                    message = "Batch " + batchId + " is completed.";

                case "warning"
                    message = "Batch " + batchId + " completed with warnings.";

                case "error"
                    message = "Batch " + batchId + " failed.";

                case "question"
                    message = "Batch " + batchId + " requires attention.";

                case "running"
                    message = "Batch " + batchId + " is running.";

                otherwise
                    message = "Batch " + batchId + " status: " + status;
            end

        end

    end

end
