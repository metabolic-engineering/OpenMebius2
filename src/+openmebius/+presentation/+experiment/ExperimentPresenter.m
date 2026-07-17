classdef ExperimentPresenter
    % EXPERIMENTPRESENTER Maps experiment outcomes to UI values.

    methods

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

            switch outcome.Status
                case "finished"
                    notifications = ...
                        openmebius.presentation.experiment ...
                        .ExperimentPresenter.successNotifications( ...
                            outcome.Result);
                    sectionStatus = "finished";

                case "error"
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

    end % methods

    methods (Access = private)

        function viewModel = presentImportOutcome( ...
                ~, outcome, successMessage, errorTitle)

            arguments
                ~
                outcome (1, 1) openmebius.application.experiment ...
                    .ExperimentImportOutcome
                successMessage (1, 1) string
                errorTitle (1, 1) string
            end

            switch outcome.Status
                case "finished"
                    notifications = ...
                        openmebius.presentation.experiment ...
                        .ExperimentPresenter.importNotifications( ...
                            outcome.Result, successMessage);
                    sectionStatus = "finished";
                    result = outcome.Result;

                case "error"
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

    end % methods (Static, Access = private)

end % classdef
