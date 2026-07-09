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
            isCanceling = state.Activity == MainActivity.Canceling;
            isRunActive = isRunning || isCanceling;
            isModal = state.Activity == MainActivity.Modal;

            isModelEdit = state.EditTarget == EditTarget.Model;
            isMsEdit = state.EditTarget == EditTarget.MassSpectrometry;
            isExperimentEdit = state.EditTarget == EditTarget.Experiment;
            isTracerEdit = state.EditTarget == EditTarget.Tracer;
            isEditing = state.EditTarget ~= EditTarget.None;

            hasProject = openmebius.presentation.main.MainUIPolicy.getBool( ...
                context, "HasProject", false);

            hasModel = openmebius.presentation.main.MainUIPolicy.getBool( ...
                context, "HasModel", false);

            hasExperiments = openmebius.presentation.main.MainUIPolicy.getBool( ...
                context, "HasExperiments", false);

            hasBatches = openmebius.presentation.main.MainUIPolicy.getBool( ...
                context, "HasBatches", false);

            hasResults = openmebius.presentation.main.MainUIPolicy.getBool( ...
                context, "HasResults", false);

            canRun = openmebius.presentation.main.MainUIPolicy.getBool( ...
                context, "CanRun", false);

            isTemplateMode = openmebius.presentation.main.MainUIPolicy.getBool( ...
                context, "IsTemplateMode", false);

            canCreateProjectFromTemplate = ...
                openmebius.presentation.main.MainUIPolicy.getBool( ...
                context, "CanCreateProjectFromTemplate", isTemplateMode);

            ui = struct();

            % -------------------------------------------------------------
            % Global modal lock
            % -------------------------------------------------------------
            ui.MainInteractionEnabled = ~isModal;
            ui.IsModal = isModal;

            if isModal
                ui.IsBusy = false;
                ui.IsRunning = false;
                return
            end

            % -------------------------------------------------------------
            % Project panel
            % -------------------------------------------------------------
            ui.ProjectPanelEnabled = ...
                ~isBusy && ~isRunActive;

            ui.ProjectDirectoryEnabled = ...
                isIdle && ~hasProject && ~isEditing;

            ui.ProjectBrowseEnabled = ...
                ui.ProjectDirectoryEnabled;

            ui.ProjectLoadEnabled = ...
                isIdle && ~hasProject && ~isEditing;

            ui.TemplateModelDirectoryEnabled = ...
                isIdle && ~hasProject && ~isEditing;

            ui.TemplateModelBrowseEnabled = ...
                ui.TemplateModelDirectoryEnabled;

            ui.TemplateModelLoadEnabled = ...
                isIdle && ~hasProject && ~isEditing;

            ui.ProjectMetadataEditable = ...
                isIdle && hasProject && ~isEditing;

            ui.ProjectSaveEnabled = ...
                isIdle && hasProject && ~isEditing;

            ui.ProjectCreateEnabled = ...
                isIdle && canCreateProjectFromTemplate && ~hasProject && ~isEditing;

            ui.TemplateModelSaveEnabled = ...
                isIdle && hasModel && ~isEditing;

            % -------------------------------------------------------------
            % Stoichiometry tab
            % -------------------------------------------------------------
            ui.ModelEnabled = ...
                hasModel && ...
                ~isBusy && ...
                ~isRunActive && ...
                (~isEditing || isModelEdit);

            ui.ModelEditEnabled = ...
                isIdle && hasModel && ~isEditing;

            ui.ModelTableEditable = ...
                isIdle && isModelEdit;

            ui.ModelSaveEnabled = ...
                ui.ModelTableEditable;

            % -------------------------------------------------------------
            % MS tab
            % -------------------------------------------------------------
            ui.MsEnabled = ...
                hasModel && ...
                ~isBusy && ...
                ~isRunActive && ...
                (~isEditing || isMsEdit);

            ui.MsEditEnabled = ...
                isIdle && hasModel && ~isEditing;

            ui.MsTableEditable = ...
                isIdle && isMsEdit;

            ui.AtomTableEditable = ...
                ui.MsTableEditable;

            ui.MsSaveEnabled = ...
                ui.MsTableEditable;

            % -------------------------------------------------------------
            % Experiment tab
            % -------------------------------------------------------------
            ui.ExperimentEnabled = ...
                hasModel && ...
                ~isBusy && ...
                ~isRunActive && ...
                (~isEditing || isExperimentEdit);

            ui.ExperimentTableEditable = ...
                isIdle && isExperimentEdit;

            ui.BiomassTableEditable = false;

            % -------------------------------------------------------------
            % Tracer tab
            % -------------------------------------------------------------
            ui.TracerEnabled = ...
                hasExperiments && ...
                ~isBusy && ...
                ~isRunActive && ...
                (~isEditing || isTracerEdit);

            ui.TracerTableEditable = ...
                isIdle && isTracerEdit;

            ui.UptakeTableEditable = ...
                ui.TracerTableEditable;

            % -------------------------------------------------------------
            % Batch / Run tab
            % -------------------------------------------------------------
            ui.RunTableEnabled = ...
                hasBatches && ~isBusy;

            ui.RunConfigurationEnabled = ...
                isIdle && hasBatches && ~isEditing;

            ui.RunTableEditable = ...
                isIdle && hasBatches && ~isEditing;

            ui.RunContextMenuEnabled = ...
                ui.RunTableEnabled && ui.RunConfigurationEnabled;

            ui.RunButtonEnabled = ...
                (isIdle && canRun && ~isEditing) || isRunning;

            if isRunning
                ui.RunButtonText = "Cancel";
            elseif isCanceling
                ui.RunButtonText = "Canceling...";
            else
                ui.RunButtonText = "Run";
            end

            if isCanceling
                ui.RunButtonEnabled = false;
            end

            % -------------------------------------------------------------
            % Result tab
            % -------------------------------------------------------------
            ui.ResultEnabled = ...
                hasResults && ~isBusy;

            ui.ResultMainTableEditable = false;
            ui.ResultSubTableEditable = false;

            ui.ResultEditable = false;

            % -------------------------------------------------------------
            % Menus
            % -------------------------------------------------------------
            ui.MenuEnabled = ...
                isIdle && hasProject && ~isEditing;

            % -------------------------------------------------------------
            % Pathway context menu
            % -------------------------------------------------------------
            ui.PathwayContextMenuEnabled = ...
                isIdle && hasModel && ~isEditing;

            % -------------------------------------------------------------
            % Global indication
            % -------------------------------------------------------------
            ui.IsBusy = isBusy;
            ui.IsRunning = isRunning;
            ui.IsCanceling = isCanceling;
            ui.IsRunActive = isRunActive;

        end

    end

    methods (Static, Access = private)

        function value = getBool(context, fieldName, defaultValue)

            arguments
                context struct
                fieldName (1, 1) string
                defaultValue (1, 1) logical = false
            end

            value = defaultValue;

            if ~isfield(context, fieldName)
                return
            end

            try
                raw = context.(fieldName);

                if isempty(raw)
                    return
                end

                value = logical(raw);

                if ~isscalar(value)
                    value = any(value(:));
                end

            catch
                value = defaultValue;
            end

        end

    end

end
