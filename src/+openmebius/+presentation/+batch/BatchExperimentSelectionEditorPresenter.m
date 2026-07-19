classdef BatchExperimentSelectionEditorPresenter < handle
    % BATCHEXPERIMENTSELECTIONEDITORPRESENTER Maps RunAddBatch preparation.

    methods

        function viewModel = presentParallelEditor(obj, outcome)

            viewModel = obj.present( ...
                outcome, "Batch experiment editor error");

        end % presentParallelEditor

        function viewModel = presentINSTMFAEditor(obj, outcome)

            viewModel = obj.present( ...
                outcome, "INST-MFA experiment editor error");

        end % presentINSTMFAEditor

    end % methods

    methods (Access = private)

        function viewModel = present(~, outcome, errorTitle)

            arguments
                ~
                outcome (1, 1) openmebius.application.batch ...
                    .BatchExperimentSelectionEditorOutcome
                errorTitle (1, 1) string
            end

            if outcome.isSuccess()
                request = outcome.Result;
                viewModel = openmebius.presentation.batch ...
                    .BatchExperimentSelectionEditorViewModel( ...
                        IsAvailable = true, ...
                        ExperimentNames = request.ExperimentNames, ...
                        Mode = request.Mode, ...
                        BatchId = request.BatchId);
                return
            end

            if isempty(outcome.Exception)
                notification = openmebius.presentation.notification ...
                    .Notification.error( ...
                        outcome.ErrorMessage, ...
                        Title = errorTitle, ...
                        ShowAlert = true);
            else
                notification = openmebius.presentation.notification ...
                    .Notification.fromException( ...
                        outcome.Exception, ...
                        Title = errorTitle, ...
                        ShowAlert = true);
            end

            viewModel = openmebius.presentation.batch ...
                .BatchExperimentSelectionEditorViewModel( ...
                    Notifications = {notification});

        end % present

    end % methods (Access = private)

end % classdef
