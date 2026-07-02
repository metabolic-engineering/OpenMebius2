classdef MainUIPolicy

    methods (Static)

        function ui = evaluate(context, state)

            arguments
                context struct
                state openmebius.presentation.main.MainPresentationState
            end

            import openmebius.presentation.main.MainActivity
            import openmebius.presentation.main.EditTarget

            isIdle = state.Activity == MainActivity.Idle;
            isBusy = state.Activity == MainActivity.Busy;
            isRunning = state.Activity == MainActivity.Running;

            isEditing = state.EditTarget ~= EditTarget.None;

            ui = struct();

            % Project
            ui.ProjectBrowseEnabled = isIdle && ~isEditing;
            ui.ProjectLoadEnabled = isIdle && ~isEditing;
            ui.ProjectMetadataEditable = ...
                isIdle && context.HasProject && ~isEditing;
            ui.ProjectSaveEnabled = ...
                isIdle && context.HasProject && ~isEditing;

            % Model
            ui.ModelEnabled = ...
                context.HasProject && ~isBusy && ~isRunning;

            ui.ModelEditEnabled = ...
                isIdle && context.HasModel && ~isEditing;

            ui.ModelTableEditable = ...
                isIdle && ...
                state.EditTarget == EditTarget.Model;

            ui.ModelSaveEnabled = ui.ModelTableEditable;

            % MS
            ui.MsEnabled = ...
                context.HasModel && ~isBusy && ~isRunning;

            ui.MsEditEnabled = ...
                isIdle && context.HasModel && ~isEditing;

            ui.MsTableEditable = ...
                isIdle && ...
                state.EditTarget == EditTarget.MassSpectrometry;

            ui.MsSaveEnabled = ui.MsTableEditable;

            % Experiment
            ui.ExperimentEnabled = ...
                context.HasModel && ~isBusy && ~isRunning;

            ui.ExperimentTableEditable = ...
                isIdle && ...
                state.EditTarget == EditTarget.Experiment;

            % Tracer
            ui.TracerEnabled = ...
                context.HasExperiments && ~isBusy && ~isRunning;

            ui.TracerTableEditable = ...
                isIdle && ...
                state.EditTarget == EditTarget.Tracer;

            % Run
            ui.RunConfigurationEnabled = ...
                isIdle && context.HasBatches && ~isEditing;

            ui.RunButtonEnabled = ...
                (isIdle && context.CanRun && ~isEditing) || isRunning;

            if isRunning
                ui.RunButtonText = "Cancel";
            else
                ui.RunButtonText = "Run";
            end

            % Result
            ui.ResultEnabled = ...
                context.HasResults && ~isBusy;

            ui.ResultEditable = false;

            % Global indication
            ui.IsBusy = isBusy;
            ui.IsRunning = isRunning;
        end

    end

end
