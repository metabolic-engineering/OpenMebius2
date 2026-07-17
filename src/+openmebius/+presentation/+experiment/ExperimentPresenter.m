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

    end % methods

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

    end % methods (Static, Access = private)

end % classdef
