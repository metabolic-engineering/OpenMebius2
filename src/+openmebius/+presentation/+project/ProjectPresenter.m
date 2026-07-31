classdef ProjectPresenter
    % PROJECTPRESENTER Maps project outcomes to UI values.

    methods

        function viewModel = presentLoadStarted(~)

            viewModel = openmebius.presentation.project ...
                .ProjectOperationViewModel(ModelStatus = "running");

        end % presentLoadStarted

        function viewModel = presentCreateStarted(~)

            viewModel = openmebius.presentation.project ...
                .ProjectOperationViewModel(ModelStatus = "running");

        end % presentCreateStarted

        function viewModel = presentOpenOutcome(obj, outcome)

            viewModel = obj.presentOutcome( ...
                outcome, ...
                "open", ...
                "Project load failed", ...
                true);

        end % presentOpenOutcome

        function viewModel = presentSaveOutcome(obj, outcome)

            viewModel = obj.presentOutcome( ...
                outcome, ...
                "", ...
                "Project save failed", ...
                false);

        end % presentSaveOutcome

        function viewModel = presentCreateOutcome(obj, outcome)

            viewModel = obj.presentOutcome( ...
                outcome, ...
                "create", ...
                "Project create failed", ...
                true);

        end % presentCreateOutcome

    end % methods

    methods (Access = private)

        function viewModel = presentOutcome( ...
                obj, outcome, artifactMode, errorTitle, changesModel)

            arguments
                obj
                outcome (1, 1) openmebius.application.project ...
                    .ProjectOperationOutcome
                artifactMode (1, 1) string
                errorTitle (1, 1) string
                changesModel (1, 1) logical
            end

            if outcome.isSuccess()
                result = outcome.Result;
                notifications = obj.successNotifications(result.Messages);
                modelStatus = "";
                session = result.Session;
                artifacts = result.Artifacts;
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
                artifactMode = "";
                session = [];
                artifacts = [];

                if changesModel
                    modelStatus = "error";
                else
                    modelStatus = "";
                end

            end

            viewModel = openmebius.presentation.project ...
                .ProjectOperationViewModel( ...
                ModelStatus = modelStatus, ...
                ArtifactMode = artifactMode, ...
                Session = session, ...
                Artifacts = artifacts, ...
                Notifications = notifications);

        end % presentOutcome

        function notifications = successNotifications(~, messages)

            messages = string(messages);
            messages = messages(:);
            notifications = cell(numel(messages), 1);

            for messageIndex = 1:numel(messages)
                notifications{messageIndex} = ...
                    openmebius.presentation.notification ...
                    .Notification.info(messages(messageIndex));
            end

        end % successNotifications

    end % methods (Access = private)

end % classdef
