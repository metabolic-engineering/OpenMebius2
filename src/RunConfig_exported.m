classdef RunConfig_exported < matlab.apps.AppBase

    events
        Applied
        BatchExperimentSelectionApplied
        Closed
        NotificationRequested
    end

    % Properties that correspond to app components
    properties (Access = public)
        BatchconfigUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        TabGroup matlab.ui.container.TabGroup
        GeneralTab matlab.ui.container.Tab
        GridLayout5_2 matlab.ui.container.GridLayout
        GridLayout7_2 matlab.ui.container.GridLayout
        GeneralRestoreDefaultButton matlab.ui.control.Button
        GeneralApplyButton matlab.ui.control.Button
        GeneralCancelButton matlab.ui.control.Button
        GridLayout6_2 matlab.ui.container.GridLayout
        TabGroup2 matlab.ui.container.TabGroup
        MonteCarloTab matlab.ui.container.Tab
        GridLayout9 matlab.ui.container.GridLayout
        GridLayout10_8 matlab.ui.container.GridLayout
        MCMethodDropDown matlab.ui.control.DropDown
        CalculationmethodsDropDownLabel matlab.ui.control.Label
        GridLayout10_7 matlab.ui.container.GridLayout
        MCKNREditField matlab.ui.control.NumericEditField
        ThenumberofrunsiKisubNRsubEditFieldLabel matlab.ui.control.Label
        GridLayout10_6 matlab.ui.container.GridLayout
        MCNasEditField matlab.ui.control.NumericEditField
        CertainthresholdiNisubASsubEditFieldLabel matlab.ui.control.Label
        GridLayout10_5 matlab.ui.container.GridLayout
        MCProximityEditField matlab.ui.control.NumericEditField
        ProximitythresholdepsilonLabel matlab.ui.control.Label
        GridLayout10_4 matlab.ui.container.GridLayout
        MCTTEditField matlab.ui.control.NumericEditField
        TerminationtoleranceTTEditFieldLabel matlab.ui.control.Label
        GridLayout10_3 matlab.ui.container.GridLayout
        MCProcedureDropDown matlab.ui.control.DropDown
        OptimizationprocedureDropDownLabel matlab.ui.control.Label
        GridLayout10_2 matlab.ui.container.GridLayout
        MCMIDSDEditField matlab.ui.control.NumericEditField
        VariationsforMIDserrorLabel matlab.ui.control.Label
        MCFixMIDCheckBox matlab.ui.control.CheckBox
        GridLayout10 matlab.ui.container.GridLayout
        MCLmaxEditField matlab.ui.control.NumericEditField
        maximumnumberoftrialsLsubmaxsubLabel matlab.ui.control.Label
        GridsearchTab matlab.ui.container.Tab
        GridLayout11 matlab.ui.container.GridLayout
        GridLayout12_4 matlab.ui.container.GridLayout
        ThresholdDropDown matlab.ui.control.DropDown
        ThresholdDropDownLabel matlab.ui.control.Label
        GridLayout12_3 matlab.ui.container.GridLayout
        IterationtimesforgridsearchEditField matlab.ui.control.NumericEditField
        IterationtimesforgridsearchEditFieldLabel matlab.ui.control.Label
        GridLayout12_2 matlab.ui.container.GridLayout
        GridintervalDeltaixiEditField matlab.ui.control.NumericEditField
        GridintervalDeltaixiEditFieldLabel matlab.ui.control.Label
        GridLayout12 matlab.ui.container.GridLayout
        ThenumberofgridpointsEditField matlab.ui.control.NumericEditField
        ThenumberofgridpointsEditFieldLabel matlab.ui.control.Label
        DeterminegridintervalautomaticallyCheckBox matlab.ui.control.CheckBox
        GridLayout8 matlab.ui.container.GridLayout
        INSTMFACheckBox matlab.ui.control.CheckBox
        DeleteResultButton matlab.ui.control.CheckBox
        GridLayoutAlgorithm_2 matlab.ui.container.GridLayout
        AlgorithmCIDropDown matlab.ui.control.DropDown
        AlgorithmforCIcalculationDropDownLabel matlab.ui.control.Label
        CalcCICheckBox matlab.ui.control.CheckBox
        PerturbateEffluxCheckBox matlab.ui.control.CheckBox
        SuggestionCheckBox matlab.ui.control.CheckBox
        LargeScaleCheckBox matlab.ui.control.CheckBox
        GridLayoutAlgorithm matlab.ui.container.GridLayout
        AlgorithmDropDown matlab.ui.control.DropDown
        CalculationalgorithmDropDownLabel matlab.ui.control.Label
        GridLayoutIteration matlab.ui.container.GridLayout
        IterationSpinner matlab.ui.control.Spinner
        IterationtimesforcalculationSpinnerLabel matlab.ui.control.Label
        MSfragmentTab matlab.ui.container.Tab
        GridLayout5 matlab.ui.container.GridLayout
        MSTable matlab.ui.control.Table
        GridLayout7 matlab.ui.container.GridLayout
        MSRestoreDefaultButton matlab.ui.control.Button
        MSApplyAllButton matlab.ui.control.Button
        MSCancelButton matlab.ui.control.Button
        EffluxperturbationTab matlab.ui.container.Tab
        GridLayout13 matlab.ui.container.GridLayout
        GridLayout22 matlab.ui.container.GridLayout
        EffluxUITable matlab.ui.control.Table
        GridLayout15 matlab.ui.container.GridLayout
        EffluxRestoreDefaultButton matlab.ui.control.Button
        EffluxApplyButton matlab.ui.control.Button
        EffluxCancelButton matlab.ui.control.Button
        TracersuggestionTab matlab.ui.container.Tab
        GridLayout14 matlab.ui.container.GridLayout
        GridLayout17 matlab.ui.container.GridLayout
        GridLayout18 matlab.ui.container.GridLayout
        LabelTable matlab.ui.control.Table
        GridLayout16 matlab.ui.container.GridLayout
        SuggestionApplyButton matlab.ui.control.Button
        SuggestionRestoreDefaultButton matlab.ui.control.Button
        SuggestionCancelButton matlab.ui.control.Button
        INSTMFATab matlab.ui.container.Tab
        GridLayout13_2 matlab.ui.container.GridLayout
        GridLayout20 matlab.ui.container.GridLayout
        INSTMFATimeCourseUITable matlab.ui.control.Table
        GridLayout21 matlab.ui.container.GridLayout
        INSTMFAPoolUITable matlab.ui.control.Table
        GridLayout15_2 matlab.ui.container.GridLayout
        INSTMFAApplyButton matlab.ui.control.Button
        INSTMFARestoreDefaultButton matlab.ui.control.Button
        INSTMFACancelButton matlab.ui.control.Button
        ContextMenu matlab.ui.container.ContextMenu
        AddnewpatternMenu matlab.ui.container.Menu
        AddnewpatternsMenu matlab.ui.container.Menu
        CopythistracerforallentriesMenu matlab.ui.container.Menu
        ContextMenuINST matlab.ui.container.ContextMenu
        AddexperimentsMenu matlab.ui.container.Menu
        RemoveselectedexperimentMenu matlab.ui.container.Menu
    end

    %% Private properties
    properties (Access = private)
        Session openmebius.application.batch.BatchConfigurationSession
        Presenter openmebius.presentation.batch.RunConfigPresenter
        Controller openmebius.application.batch.BatchConfigurationController
        RunAddBatchApp
        RunAddBatchListeners event.listener = event.listener.empty(0, 1)
        TracerConfigApp
        TracerConfigListeners event.listener = event.listener.empty(0, 1)
        ExperimentEditController openmebius.application.experiment.ExperimentEditController
        ExperimentPresenter openmebius.presentation.experiment.ExperimentPresenter
        MSFragmentTableMetadata
    end

    methods (Access = protected)

        function updateINSTMFATimeCourseTable(app)

            viewModel = app.Presenter.presentINSTMFATables(app.Session);
            app.requestNotifications(viewModel.Notifications);

            if ~viewModel.IsAvailable
                return;
            end

            app.renderTableViewModel( ...
                app.INSTMFATimeCourseUITable, ...
                viewModel.TimePointTable);

        end % updateINSTMFATimeCourseTable

    end % protected methods

    %% Private methods
    methods (Access = private)

        function renderRunConfigViewModel(app, viewModel)
            % RENDERRUNCONFIGVIEWMODEL Render typed configuration values.

            app.IterationSpinner.Value = viewModel.Iteration;
            app.AlgorithmDropDown.Value = viewModel.Algorithm;
            app.LargeScaleCheckBox.Value = viewModel.LargeScale;
            app.SuggestionCheckBox.Value = viewModel.SuggestNextFlux;
            app.PerturbateEffluxCheckBox.Value = ...
                viewModel.PerturbateEfflux;
            app.CalcCICheckBox.Value = viewModel.CalculateCI;
            app.AlgorithmCIDropDown.Value = viewModel.CIAlgorithm;
            app.DeleteResultButton.Value = viewModel.DeleteResultFile;

            app.MCLmaxEditField.Value = viewModel.MCIterations;
            app.MCFixMIDCheckBox.Value = viewModel.MCFixMID;
            app.MCMIDSDEditField.Value = ...
                viewModel.MCMIDStandardDeviation;
            app.MCProcedureDropDown.Value = ...
                viewModel.MCOptimizationProcedure;
            app.MCTTEditField.Value = ...
                viewModel.MCTerminationTolerance;
            app.MCProximityEditField.Value = ...
                viewModel.MCProximityThreshold;
            app.MCNasEditField.Value = viewModel.MCCertainThreshold;
            app.MCKNREditField.Value = viewModel.MCNumberOfRuns;
            app.MCMethodDropDown.Value = ...
                viewModel.MCCalculationMethod;

            app.DeterminegridintervalautomaticallyCheckBox.Value = ...
                viewModel.GridAutomaticInterval;
            app.ThenumberofgridpointsEditField.Value = ...
                viewModel.GridPoints;
            app.GridintervalDeltaixiEditField.Value = viewModel.GridDelta;
            app.IterationtimesforgridsearchEditField.Value = ...
                viewModel.GridIterations;
            app.ThresholdDropDown.Value = viewModel.GridThreshold;

            app.INSTMFACheckBox.Value = viewModel.IsINSTMFA;
            app.INSTMFAPoolUITable.Data = viewModel.INSTMFAPoolTable;
            app.INSTMFATimeCourseUITable.Data = ...
                viewModel.INSTMFATimePointTable;

        end % renderRunConfigViewModel

        function renderTableViewModel(~, component, viewModel)

            component.Data = viewModel.Data;
            component.ColumnName = viewModel.ColumnName;
            component.RowName = viewModel.RowName;
            component.ColumnEditable = viewModel.ColumnEditable;

        end % renderTableViewModel

        function requestNotifications(app, notifications)

            for notificationIndex = 1:numel(notifications)
                eventData = openmebius.presentation.notification ...
                    .NotificationEventData( ...
                        notifications{notificationIndex});
                notify(app, "NotificationRequested", eventData);
            end

        end % requestNotifications

        function enabledisableCIUI(app, ~)
            app.refreshControlState();

        end % enabledisableCIUI

        function enabledisableGridSetting(app)
            app.refreshControlState();

        end % enabledisableGridSetting

        function refreshControlState(app)

            viewModel = app.collectRunConfigViewModel();
            state = app.Presenter.presentControlState(viewModel);
            app.renderControlState(state);

        end % refreshControlState

        function renderControlState(app, state)

            app.AlgorithmCIDropDown.Enable = ...
                app.onOff(state.CIAlgorithmEnabled);
            monteCarlo = app.onOff(state.MonteCarloEnabled);
            app.MCLmaxEditField.Enable = monteCarlo;
            app.MCFixMIDCheckBox.Enable = monteCarlo;
            app.MCMIDSDEditField.Enable = monteCarlo;
            app.MCProcedureDropDown.Enable = monteCarlo;
            app.MCTTEditField.Enable = monteCarlo;
            app.MCProximityEditField.Enable = monteCarlo;
            app.MCNasEditField.Enable = monteCarlo;
            app.MCKNREditField.Enable = monteCarlo;
            app.MCMethodDropDown.Enable = monteCarlo;

            grid = app.onOff(state.GridEnabled);
            app.DeterminegridintervalautomaticallyCheckBox.Enable = grid;
            app.IterationtimesforgridsearchEditField.Enable = grid;
            app.ThresholdDropDown.Enable = grid;
            app.ThenumberofgridpointsEditField.Enable = ...
                app.onOff(state.GridPointsEnabled);
            app.GridintervalDeltaixiEditField.Enable = ...
                app.onOff(state.GridDeltaEnabled);

            app.EffluxUITable.Enable = app.onOff(state.EffluxEnabled);
            app.LabelTable.Enable = app.onOff(state.SuggestionEnabled);
            instMFA = app.onOff(state.INSTMFATablesEnabled);
            app.INSTMFAPoolUITable.Enable = instMFA;
            app.INSTMFATimeCourseUITable.Enable = instMFA;

        end % renderControlState

        function value = onOff(~, enabled)

            if enabled
                value = 'on';
            else
                value = 'off';
            end

        end % onOff

        function enabledisableEffluxPertubation(app)

            isEnable = app.PerturbateEffluxCheckBox.Value;

            if isEnable
                viewModel = app.Presenter.presentEffluxTable(app.Session);
            else
                viewModel = openmebius.presentation.batch ...
                    .RunConfigTableViewModel();
            end

            app.renderTableViewModel(app.EffluxUITable, viewModel);
            app.refreshControlState();

        end % enabledisableEffluxPertubation

        function enabledisableSuggestion(app)
            % ENABLEDISABLESUGGESTION Enable or disable suggestion-related UI components
            % based on the SuggestionCheckBox value

            isSuggestLabel = app.SuggestionCheckBox.Value;

            if isSuggestLabel
                viewModel = app.Presenter ...
                    .presentSuggestionTable(app.Session);
            else
                viewModel = openmebius.presentation.batch ...
                    .RunConfigTableViewModel();
            end

            app.renderTableViewModel(app.LabelTable, viewModel);
            app.refreshControlState();

        end % enabledisableSuggestion

        function enabledisableINSTMFA(app, isINSTMFA)
            % ENABLEDISABLEINSTMFA Enable or disable INST-MFA-related UI components
            % based on the isINSTMFA flag

            if isINSTMFA
                viewModel = app.Presenter ...
                    .presentINSTMFATables(app.Session);
                app.requestNotifications(viewModel.Notifications);

                if ~viewModel.IsAvailable
                    app.INSTMFACheckBox.Value = false;
                    app.renderTableViewModel( ...
                        app.INSTMFAPoolUITable, viewModel.PoolTable);
                    app.renderTableViewModel( ...
                        app.INSTMFATimeCourseUITable, ...
                        viewModel.TimePointTable);
                    app.refreshControlState();
                    return;
                end

                poolTable = viewModel.PoolTable;
                timePointTable = viewModel.TimePointTable;
            else
                poolTable = openmebius.presentation.batch ...
                    .RunConfigTableViewModel();
                timePointTable = openmebius.presentation.batch ...
                    .RunConfigTableViewModel();
            end

            app.renderTableViewModel( ...
                app.INSTMFAPoolUITable, poolTable);
            app.renderTableViewModel( ...
                app.INSTMFATimeCourseUITable, timePointTable);
            app.refreshControlState();

        end % enabledisableINSTMFA

        function editTimeCourse(app)
            % EDITTIMECOURSE Edit the time course table for INST-MFA

            outcome = app.Controller ...
                .prepareINSTMFAExperimentSelection(app.Session);
            viewModel = app.Presenter ...
                .presentExperimentSelectionEditorOutcome(outcome);
            app.requestNotifications(viewModel.Notifications);

            if ~viewModel.IsAvailable
                return;
            end

            app.detachRunAddBatchListeners();
            app.RunAddBatchApp = RunAddBatch( ...
                viewModel.ExperimentNames, ...
                viewModel.Mode, ...
                viewModel.BatchId);
            app.attachRunAddBatchListeners(app.RunAddBatchApp);

        end % editTimeCourse

        function forwardBatchExperimentSelection(app, ~, event)

            eventData = openmebius.presentation.batch ...
                .BatchExperimentSelectionEventData(event.Selection);
            notify( ...
                app, ...
                "BatchExperimentSelectionApplied", ...
                eventData);

        end % forwardBatchExperimentSelection

        function attachRunAddBatchListeners(app, runAddBatchApp)

            app.detachRunAddBatchListeners();
            listeners = event.listener.empty(0, 1);
            listeners(end + 1, 1) = addlistener( ...
                runAddBatchApp, ...
                "Applied", ...
                @(source, event) ...
                    app.forwardBatchExperimentSelection(source, event));
            listeners(end + 1, 1) = addlistener( ...
                runAddBatchApp, ...
                "Closed", ...
                @(source, event) ...
                    app.onRunAddBatchClosed(source, event));
            app.RunAddBatchListeners = listeners;

        end % attachRunAddBatchListeners

        function onRunAddBatchClosed(app, ~, ~)

            app.RunAddBatchApp = [];

        end % onRunAddBatchClosed

        function detachRunAddBatchListeners(app)

            if isempty(app.RunAddBatchListeners)
                return
            end

            for listenerIndex = 1:numel(app.RunAddBatchListeners)
                try
                    if isvalid(app.RunAddBatchListeners(listenerIndex))
                        delete(app.RunAddBatchListeners(listenerIndex));
                    end
                catch
                end
            end

            app.RunAddBatchListeners = event.listener.empty(0, 1);

        end % detachRunAddBatchListeners

        function attachTracerConfigListeners(app, tracerConfigApp)

            app.detachTracerConfigListeners();
            listeners = event.listener.empty(0, 1);
            listeners(end + 1, 1) = addlistener( ...
                tracerConfigApp, ...
                "Applied", ...
                @(source, event) ...
                    app.onTracerConfigurationApplied(source, event));
            listeners(end + 1, 1) = addlistener( ...
                tracerConfigApp, ...
                "Closed", ...
                @(source, event) ...
                    app.onTracerConfigurationClosed(source, event));
            app.TracerConfigListeners = listeners;

        end % attachTracerConfigListeners

        function detachTracerConfigListeners(app)

            for listenerIndex = 1:numel(app.TracerConfigListeners)
                try
                    if isvalid(app.TracerConfigListeners(listenerIndex))
                        delete(app.TracerConfigListeners(listenerIndex));
                    end
                catch
                end
            end

            app.TracerConfigListeners = event.listener.empty(0, 1);

        end % detachTracerConfigListeners

        function openTracerConfiguration(app, position)

            outcome = app.Controller.loadTracerConfiguration( ...
                app.Session, app.ExperimentEditController, position);
            viewModel = app.ExperimentPresenter ...
                .presentTracerConfigurationLoadOutcome(outcome);
            app.renderTracerConfigurationViewModel(viewModel);

            if ~viewModel.IsSuccessful
                return
            end

            app.detachTracerConfigListeners();
            app.TracerConfigApp = TracerConfig( ...
                viewModel.EditorTable, viewModel.Position);
            app.attachTracerConfigListeners(app.TracerConfigApp);

        end % openTracerConfiguration

        function onTracerConfigurationApplied(app, ~, event)

            outcome = app.Controller.applyTracerConfiguration( ...
                app.ExperimentEditController, ...
                event.Position, ...
                event.EditorTable);
            viewModel = app.ExperimentPresenter ...
                .presentTracerConfigurationApplyOutcome(outcome);
            app.renderTracerConfigurationViewModel(viewModel);

            if viewModel.IsSuccessful
                position = viewModel.Position;
                app.LabelTable.Data{position(1), position(2)} = ...
                    {char(viewModel.Pattern)};
            end

        end % onTracerConfigurationApplied

        function onTracerConfigurationClosed(app, ~, ~)

            app.TracerConfigApp = [];

        end % onTracerConfigurationClosed

        function renderTracerConfigurationViewModel(app, viewModel)

            for notificationIndex = 1:numel(viewModel.Notifications)
                eventData = openmebius.presentation.notification ...
                    .NotificationEventData( ...
                        viewModel.Notifications{notificationIndex});
                notify(app, "NotificationRequested", eventData);
            end

        end % renderTracerConfigurationViewModel

        function viewModel = collectRunConfigViewModel(app)

            viewModel = openmebius.presentation.batch ...
                .RunConfigViewModel();
            viewModel.Iteration = app.IterationSpinner.Value;
            viewModel.Algorithm = app.AlgorithmDropDown.Value;
            viewModel.LargeScale = app.LargeScaleCheckBox.Value;
            viewModel.SuggestNextFlux = app.SuggestionCheckBox.Value;
            viewModel.PerturbateEfflux = ...
                app.PerturbateEffluxCheckBox.Value;
            viewModel.CalculateCI = app.CalcCICheckBox.Value;
            viewModel.CIAlgorithm = app.AlgorithmCIDropDown.Value;
            viewModel.DeleteResultFile = app.DeleteResultButton.Value;

            viewModel.MCIterations = app.MCLmaxEditField.Value;
            viewModel.MCFixMID = app.MCFixMIDCheckBox.Value;
            viewModel.MCMIDStandardDeviation = ...
                app.MCMIDSDEditField.Value;
            viewModel.MCOptimizationProcedure = ...
                app.MCProcedureDropDown.Value;
            viewModel.MCTerminationTolerance = app.MCTTEditField.Value;
            viewModel.MCProximityThreshold = ...
                app.MCProximityEditField.Value;
            viewModel.MCCertainThreshold = app.MCNasEditField.Value;
            viewModel.MCNumberOfRuns = app.MCKNREditField.Value;
            viewModel.MCCalculationMethod = app.MCMethodDropDown.Value;

            viewModel.GridAutomaticInterval = ...
                app.DeterminegridintervalautomaticallyCheckBox.Value;
            viewModel.GridPoints = ...
                app.ThenumberofgridpointsEditField.Value;
            viewModel.GridDelta = app.GridintervalDeltaixiEditField.Value;
            viewModel.GridIterations = ...
                app.IterationtimesforgridsearchEditField.Value;
            viewModel.GridThreshold = app.ThresholdDropDown.Value;
            viewModel.IsINSTMFA = app.INSTMFACheckBox.Value;

            if istable(app.EffluxUITable.Data)
                viewModel.EffluxTable = app.EffluxUITable.Data;
            end

            if istable(app.INSTMFAPoolUITable.Data)
                viewModel.INSTMFAPoolTable = ...
                    app.INSTMFAPoolUITable.Data;
            end

            if istable(app.INSTMFATimeCourseUITable.Data)
                viewModel.INSTMFATimePointTable = ...
                    app.INSTMFATimeCourseUITable.Data;
            end

        end % collectRunConfigViewModel

        function wireActionButtons(app)

            restoreButtons = [ ...
                app.GeneralRestoreDefaultButton
                app.MSRestoreDefaultButton
                app.EffluxRestoreDefaultButton
                app.SuggestionRestoreDefaultButton
                app.INSTMFARestoreDefaultButton];
            applyButtons = [ ...
                app.GeneralApplyButton
                app.MSApplyAllButton
                app.EffluxApplyButton
                app.SuggestionApplyButton
                app.INSTMFAApplyButton];
            cancelButtons = [ ...
                app.GeneralCancelButton
                app.MSCancelButton
                app.EffluxCancelButton
                app.SuggestionCancelButton
                app.INSTMFACancelButton];

            for buttonIndex = 1:numel(restoreButtons)
                restoreButtons(buttonIndex).ButtonPushedFcn = ...
                    @(~, ~) app.restoreDefaultValues();
                applyButtons(buttonIndex).ButtonPushedFcn = ...
                    @(~, ~) app.applyCurrentSettings();
                cancelButtons(buttonIndex).ButtonPushedFcn = ...
                    @(~, ~) app.cancelChanges();
            end

        end % wireActionButtons

        function restoreDefaultValues(app)

            effluxData = app.EffluxUITable.Data;
            instPoolData = app.INSTMFAPoolUITable.Data;
            instTimeCourseData = app.INSTMFATimeCourseUITable.Data;
            viewModel = app.Presenter.presentDefaults();
            app.renderRunConfigViewModel(viewModel);

            msData = app.MSTable.Data;

            if istable(msData) && ~isempty(msData)
                msData{:, :} = true(height(msData), width(msData));
                app.MSTable.Data = msData;
            end

            app.enabledisableCIUI(app.CalcCICheckBox.Value);
            app.enabledisableSuggestion();

            app.EffluxUITable.Data = effluxData;
            app.EffluxUITable.Enable = 'off';
            app.EffluxUITable.ColumnEditable = ...
                app.readOnlyColumns(effluxData);

            app.INSTMFAPoolUITable.Data = instPoolData;
            app.INSTMFAPoolUITable.Enable = 'off';
            app.INSTMFAPoolUITable.ColumnEditable = ...
                app.readOnlyColumns(instPoolData);

            app.INSTMFATimeCourseUITable.Data = instTimeCourseData;
            app.INSTMFATimeCourseUITable.Enable = 'off';
            app.INSTMFATimeCourseUITable.ColumnEditable = ...
                app.readOnlyColumns(instTimeCourseData);

        end % restoreDefaultValues

        function applyCurrentSettings(app)

            requestFactory = @() app.Presenter.createApplyRequest( ...
                app.Session, ...
                app.collectRunConfigViewModel(), ...
                app.MSTable.Data, ...
                app.MSFragmentTableMetadata, ...
                app.LabelTable.Data, ...
                app.SuggestionCheckBox.Value);
            outcome = app.Controller.apply( ...
                app.Session, requestFactory);
            viewModel = app.Presenter.presentApplyOutcome(outcome);
            app.requestNotifications(viewModel.Notifications);

            if viewModel.IsSuccessful
                notify(app, "Applied");
            end

        end % applyCurrentSettings

        function cancelChanges(app)

            notify(app, "Closed");
            delete(app);

        end % cancelChanges

        function editable = readOnlyColumns(~, data)

            if istable(data)
                editable = false(1, width(data));
            else
                editable = false(1, 0);
            end

        end % readOnlyColumns

    end % private methods

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn( ...
                app, session, presenter, editor, controller, ...
                experimentController, experimentPresenter)

            app.Session = session;
            app.Presenter = presenter;
            app.Controller = controller;
            app.ExperimentEditController = experimentController;
            app.ExperimentPresenter = experimentPresenter;
            app.renderRunConfigViewModel(editor.Config)
            app.MSFragmentTableMetadata = ...
                editor.MSFragmentTable.Metadata;
            app.renderTableViewModel( ...
                app.MSTable, editor.MSFragmentTable);
            app.renderTableViewModel( ...
                app.EffluxUITable, editor.EffluxTable);
            app.renderTableViewModel( ...
                app.LabelTable, editor.SuggestionTable);
            app.renderTableViewModel( ...
                app.INSTMFAPoolUITable, ...
                editor.INSTMFATables.PoolTable);
            app.renderTableViewModel( ...
                app.INSTMFATimeCourseUITable, ...
                editor.INSTMFATables.TimePointTable);
            app.renderControlState(editor.ControlState);
            app.wireActionButtons()

        end

        % Close request function: BatchconfigUIFigure
        function BatchconfigUIFigureCloseRequest(app, event)

            app.cancelChanges();

        end

        % Callback function: not associated with a component
        function GeneralApplyButtonPushed(app, ~)

            app.applyCurrentSettings();

        end

        % Button pushed function: GeneralApplyButton
        function GeneralApplyButtonPushed2(app, ~)

            app.applyCurrentSettings();

        end

        % Button pushed function: GeneralCancelButton
        function GeneralCancelButtonPushed(app, ~)

            app.cancelChanges();

        end

        % Callback function: not associated with a component
        function MSApplyButtonPushed(app, ~)

            app.applyCurrentSettings();

        end

        % Button pushed function: MSApplyAllButton
        function MSApplyAllButtonPushed(app, ~)

            app.applyCurrentSettings();

        end

        % Button pushed function: MSCancelButton
        function MSCancelButtonPushed(app, ~)

            app.cancelChanges();

        end

        % Value changed function: PerturbateEffluxCheckBox
        function PerturbateEffluxCheckBoxValueChanged(app, event)

            app.enabledisableEffluxPertubation()

        end

        % Callback function: not associated with a component
        function EffluxApplyButtonPushed(app, ~)

            app.applyCurrentSettings();

        end

        % Callback function: not associated with a component
        function EffluxApplyAllButtonPushed(app, ~)

            app.applyCurrentSettings();

        end

        % Button pushed function: EffluxCancelButton
        function EffluxCancelButtonPushed(app, ~)

            app.cancelChanges();

        end

        % Callback function: not associated with a component
        function SuggestionApplyButtonPushed(app, ~)

            app.applyCurrentSettings();

        end

        % Button pushed function: SuggestionCancelButton
        function SuggestionCancelButtonPushed(app, ~)

            app.cancelChanges();

        end

        % Value changed function: CalcCICheckBox
        function CalcCICheckBoxValueChanged(app, event)

            enabledisableCIUI(app, app.CalcCICheckBox.Value)

        end

        % Value changed function: AlgorithmCIDropDown
        function AlgorithmCIDropDownValueChanged(app, event)

            enabledisableCIUI(app, app.CalcCICheckBox.Value)

        end

        % Value changed function:
        % DeterminegridintervalautomaticallyCheckBox
        function DeterminegridintervalautomaticallyCheckBoxValueChanged(app, event)

            enabledisableGridSetting(app)

        end

        % Value changed function: INSTMFACheckBox
        function INSTMFACheckBoxValueChanged(app, event)

            app.SuggestionCheckBox.Value = false;
            enabledisableSuggestion(app)

            enabledisableINSTMFA(app, event.Source.Value)

        end

        % Menu selected function: AddexperimentsMenu
        function AddexperimentsMenuSelected(app, event)

            app.editTimeCourse();

        end

        % Menu selected function: RemoveselectedexperimentMenu
        function RemoveselectedexperimentMenuSelected(app, event)

            selectedRow = app.INSTMFATimeCourseUITable.Selection;
            selectedRow = unique(selectedRow(:, 1));

            if isempty(selectedRow)
                return
            end

        end

        % Value changed function: SuggestionCheckBox
        function SuggestionCheckBoxValueChanged(app, event)

            isSuggestLabel = app.SuggestionCheckBox.Value;

            if isSuggestLabel

                app.CalcCICheckBox.Value = true;
                enabledisableCIUI(app, app.CalcCICheckBox.Value)
                enabledisableSuggestion(app)

            else

                return;

            end

        end

        % Double-clicked callback: LabelTable
        function LabelTableDoubleClicked(app, event)

            displayRow = event.InteractionInformation.DisplayRow;
            displayColumn = event.InteractionInformation.DisplayColumn;

            if isempty(displayRow) || isempty(displayColumn)
                return
            end

            app.openTracerConfiguration( ...
                [displayRow, displayColumn]);

        end

        % Menu selected function: AddnewpatternMenu
        function AddnewpatternMenuSelected(app, event)

            tableNow = app.LabelTable.Data;
            numCol = size(tableNow, 2);
            newRow = strings(1, numCol);
            tableNew = array2table(newRow, 'VariableNames', app.LabelTable.ColumnName');

            tableNow = [tableNow; tableNew];
            app.LabelTable.Data = tableNow;

        end

        % Menu selected function: AddnewpatternsMenu
        function AddnewpatternsMenuSelected(app, event)

            n = inputdlg('Enter the number of new patterns to add:', 'Add New Patterns', [1 50], {'1'});
            nNum = str2double(n{1});

            if isnan(nNum) || nNum <= 0 || mod(nNum, 1) ~= 0
                return;
            end

            tableNow = app.LabelTable.Data;
            numCol = size(tableNow, 2);
            newRows = strings(nNum, numCol);
            tableNew = array2table(newRows, 'VariableNames', app.LabelTable.ColumnName');

            tableNow = [tableNow; tableNew];
            app.LabelTable.Data = tableNow;

        end

        % Menu selected function: CopythistracerforallentriesMenu
        function CopythistracerforallentriesMenuSelected(app, event)

            idxSelection = app.LabelTable.Selection;

            if isempty(idxSelection)
                return;
            end

            selectedLabel = app.LabelTable.Data{idxSelection(1, 1), idxSelection(1, 2)};

            % Replace all entries in the selected column with the selected label
            tableNow = app.LabelTable.Data;
            numRows = size(tableNow, 1);

            for i = 1:numRows
                tableNow{i, idxSelection(1, 2)} = selectedLabel;
            end

            app.LabelTable.Data = tableNow;

        end

        % Key press function: BatchconfigUIFigure
        function BatchconfigUIFigureKeyPress(app, event)

            key = event.Key;

            % Esc
            if strcmp(key, 'escape')
                app.cancelChanges();
            end

        end

        % Callback function: not associated with a component
        function INSTMFAApplyButtonPushed(app, ~)

            app.applyCurrentSettings();

        end

        % Callback function: not associated with a component
        function INSTMFAReloadButtonPushed(app, ~)

            app.restoreDefaultValues();

        end

        % Button pushed function: INSTMFACancelButton
        function INSTMFACancelButtonPushed(app, ~)

            app.cancelChanges();

        end

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create BatchconfigUIFigure and hide until all components are created
            app.BatchconfigUIFigure = uifigure('Visible', 'off');
            app.BatchconfigUIFigure.Position = [100 100 640 480];
            app.BatchconfigUIFigure.Name = 'Batch config';
            app.BatchconfigUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.BatchconfigUIFigure.CloseRequestFcn = createCallbackFcn(app, @BatchconfigUIFigureCloseRequest, true);
            app.BatchconfigUIFigure.KeyPressFcn = createCallbackFcn(app, @BatchconfigUIFigureKeyPress, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.BatchconfigUIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = 1;

            % Create GeneralTab
            app.GeneralTab = uitab(app.TabGroup);
            app.GeneralTab.Title = 'General';

            % Create GridLayout5_2
            app.GridLayout5_2 = uigridlayout(app.GeneralTab);
            app.GridLayout5_2.ColumnWidth = {'1x'};
            app.GridLayout5_2.RowHeight = {'1x', 'fit'};

            % Create GridLayout6_2
            app.GridLayout6_2 = uigridlayout(app.GridLayout5_2);
            app.GridLayout6_2.RowHeight = {'1x'};
            app.GridLayout6_2.Padding = [0 0 0 0];
            app.GridLayout6_2.Layout.Row = 1;
            app.GridLayout6_2.Layout.Column = 1;

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout6_2);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', '1x'};
            app.GridLayout8.Padding = [0 0 0 0];
            app.GridLayout8.Layout.Row = 1;
            app.GridLayout8.Layout.Column = 1;

            % Create GridLayoutIteration
            app.GridLayoutIteration = uigridlayout(app.GridLayout8);
            app.GridLayoutIteration.ColumnWidth = {'7x', '3x'};
            app.GridLayoutIteration.RowHeight = {'1x'};
            app.GridLayoutIteration.Padding = [0 0 0 0];
            app.GridLayoutIteration.Layout.Row = 1;
            app.GridLayoutIteration.Layout.Column = 1;

            % Create IterationtimesforcalculationSpinnerLabel
            app.IterationtimesforcalculationSpinnerLabel = uilabel(app.GridLayoutIteration);
            app.IterationtimesforcalculationSpinnerLabel.Layout.Row = 1;
            app.IterationtimesforcalculationSpinnerLabel.Layout.Column = 1;
            app.IterationtimesforcalculationSpinnerLabel.Text = 'Iteration times for calculation';

            % Create IterationSpinner
            app.IterationSpinner = uispinner(app.GridLayoutIteration);
            app.IterationSpinner.Limits = [1 100000];
            app.IterationSpinner.Layout.Row = 1;
            app.IterationSpinner.Layout.Column = 2;
            app.IterationSpinner.Value = 10;

            % Create GridLayoutAlgorithm
            app.GridLayoutAlgorithm = uigridlayout(app.GridLayout8);
            app.GridLayoutAlgorithm.ColumnWidth = {'6x', '4x'};
            app.GridLayoutAlgorithm.RowHeight = {'1x'};
            app.GridLayoutAlgorithm.Padding = [0 0 0 0];
            app.GridLayoutAlgorithm.Layout.Row = 2;
            app.GridLayoutAlgorithm.Layout.Column = 1;

            % Create CalculationalgorithmDropDownLabel
            app.CalculationalgorithmDropDownLabel = uilabel(app.GridLayoutAlgorithm);
            app.CalculationalgorithmDropDownLabel.Layout.Row = 1;
            app.CalculationalgorithmDropDownLabel.Layout.Column = 1;
            app.CalculationalgorithmDropDownLabel.Text = 'Calculation algorithm';

            % Create AlgorithmDropDown
            app.AlgorithmDropDown = uidropdown(app.GridLayoutAlgorithm);
            app.AlgorithmDropDown.Items = {'IPMs', 'SQP'};
            app.AlgorithmDropDown.Layout.Row = 1;
            app.AlgorithmDropDown.Layout.Column = 2;
            app.AlgorithmDropDown.Value = 'SQP';

            % Create LargeScaleCheckBox
            app.LargeScaleCheckBox = uicheckbox(app.GridLayout8);
            app.LargeScaleCheckBox.Text = 'Large scale problem';
            app.LargeScaleCheckBox.Layout.Row = 3;
            app.LargeScaleCheckBox.Layout.Column = 1;

            % Create SuggestionCheckBox
            app.SuggestionCheckBox = uicheckbox(app.GridLayout8);
            app.SuggestionCheckBox.ValueChangedFcn = createCallbackFcn(app, @SuggestionCheckBoxValueChanged, true);
            app.SuggestionCheckBox.Text = 'Suggest label tracer to increase accuracy';
            app.SuggestionCheckBox.Layout.Row = 4;
            app.SuggestionCheckBox.Layout.Column = 1;

            % Create PerturbateEffluxCheckBox
            app.PerturbateEffluxCheckBox = uicheckbox(app.GridLayout8);
            app.PerturbateEffluxCheckBox.ValueChangedFcn = createCallbackFcn(app, @PerturbateEffluxCheckBoxValueChanged, true);
            app.PerturbateEffluxCheckBox.Text = 'Perturbate efflux';
            app.PerturbateEffluxCheckBox.Layout.Row = 5;
            app.PerturbateEffluxCheckBox.Layout.Column = 1;

            % Create CalcCICheckBox
            app.CalcCICheckBox = uicheckbox(app.GridLayout8);
            app.CalcCICheckBox.ValueChangedFcn = createCallbackFcn(app, @CalcCICheckBoxValueChanged, true);
            app.CalcCICheckBox.Text = 'Calculate confidence intervals of fluxes';
            app.CalcCICheckBox.Layout.Row = 7;
            app.CalcCICheckBox.Layout.Column = 1;

            % Create GridLayoutAlgorithm_2
            app.GridLayoutAlgorithm_2 = uigridlayout(app.GridLayout8);
            app.GridLayoutAlgorithm_2.ColumnWidth = {'6x', '4x'};
            app.GridLayoutAlgorithm_2.RowHeight = {'1x'};
            app.GridLayoutAlgorithm_2.Padding = [0 0 0 0];
            app.GridLayoutAlgorithm_2.Layout.Row = 8;
            app.GridLayoutAlgorithm_2.Layout.Column = 1;

            % Create AlgorithmforCIcalculationDropDownLabel
            app.AlgorithmforCIcalculationDropDownLabel = uilabel(app.GridLayoutAlgorithm_2);
            app.AlgorithmforCIcalculationDropDownLabel.Layout.Row = 1;
            app.AlgorithmforCIcalculationDropDownLabel.Layout.Column = 1;
            app.AlgorithmforCIcalculationDropDownLabel.Text = 'Algorithm for CI calculation';

            % Create AlgorithmCIDropDown
            app.AlgorithmCIDropDown = uidropdown(app.GridLayoutAlgorithm_2);
            app.AlgorithmCIDropDown.Items = {'Monte Carlo', 'Grid search'};
            app.AlgorithmCIDropDown.ValueChangedFcn = createCallbackFcn(app, @AlgorithmCIDropDownValueChanged, true);
            app.AlgorithmCIDropDown.Layout.Row = 1;
            app.AlgorithmCIDropDown.Layout.Column = 2;
            app.AlgorithmCIDropDown.Value = 'Monte Carlo';

            % Create DeleteResultButton
            app.DeleteResultButton = uicheckbox(app.GridLayout8);
            app.DeleteResultButton.Text = 'Delete result file when batch is canceled';
            app.DeleteResultButton.Layout.Row = 9;
            app.DeleteResultButton.Layout.Column = 1;
            app.DeleteResultButton.Value = true;

            % Create INSTMFACheckBox
            app.INSTMFACheckBox = uicheckbox(app.GridLayout8);
            app.INSTMFACheckBox.ValueChangedFcn = createCallbackFcn(app, @INSTMFACheckBoxValueChanged, true);
            app.INSTMFACheckBox.Text = 'Instrationaly-MFA instead of parallel labeling';
            app.INSTMFACheckBox.Layout.Row = 6;
            app.INSTMFACheckBox.Layout.Column = 1;

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.GridLayout6_2);
            app.TabGroup2.Layout.Row = 1;
            app.TabGroup2.Layout.Column = 2;

            % Create MonteCarloTab
            app.MonteCarloTab = uitab(app.TabGroup2);
            app.MonteCarloTab.Title = 'Monte Carlo';

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.MonteCarloTab);
            app.GridLayout9.ColumnWidth = {'1x'};
            app.GridLayout9.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout9.ColumnSpacing = 5;
            app.GridLayout9.Padding = [5 5 5 5];

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout9);
            app.GridLayout10.ColumnWidth = {'7x', '3x'};
            app.GridLayout10.RowHeight = {'1x'};
            app.GridLayout10.Padding = [0 0 0 0];
            app.GridLayout10.Layout.Row = 1;
            app.GridLayout10.Layout.Column = 1;

            % Create maximumnumberoftrialsLsubmaxsubLabel
            app.maximumnumberoftrialsLsubmaxsubLabel = uilabel(app.GridLayout10);
            app.maximumnumberoftrialsLsubmaxsubLabel.Layout.Row = 1;
            app.maximumnumberoftrialsLsubmaxsubLabel.Layout.Column = 1;
            app.maximumnumberoftrialsLsubmaxsubLabel.Interpreter = 'html';
            app.maximumnumberoftrialsLsubmaxsubLabel.Text = 'The number of trials (<i>L</i><sub>max</sub>):';

            % Create MCLmaxEditField
            app.MCLmaxEditField = uieditfield(app.GridLayout10, 'numeric');
            app.MCLmaxEditField.Limits = [10 Inf];
            app.MCLmaxEditField.Layout.Row = 1;
            app.MCLmaxEditField.Layout.Column = 2;
            app.MCLmaxEditField.Value = 500;

            % Create MCFixMIDCheckBox
            app.MCFixMIDCheckBox = uicheckbox(app.GridLayout9);
            app.MCFixMIDCheckBox.Text = 'Fix MIDs'' variations';
            app.MCFixMIDCheckBox.Layout.Row = 2;
            app.MCFixMIDCheckBox.Layout.Column = 1;
            app.MCFixMIDCheckBox.Value = true;

            % Create GridLayout10_2
            app.GridLayout10_2 = uigridlayout(app.GridLayout9);
            app.GridLayout10_2.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_2.RowHeight = {'1x'};
            app.GridLayout10_2.Padding = [0 0 0 0];
            app.GridLayout10_2.Layout.Row = 3;
            app.GridLayout10_2.Layout.Column = 1;

            % Create VariationsforMIDserrorLabel
            app.VariationsforMIDserrorLabel = uilabel(app.GridLayout10_2);
            app.VariationsforMIDserrorLabel.Layout.Row = 1;
            app.VariationsforMIDserrorLabel.Layout.Column = 1;
            app.VariationsforMIDserrorLabel.Text = 'Variations for MIDs'' error:';

            % Create MCMIDSDEditField
            app.MCMIDSDEditField = uieditfield(app.GridLayout10_2, 'numeric');
            app.MCMIDSDEditField.Limits = [1e-10 Inf];
            app.MCMIDSDEditField.Layout.Row = 1;
            app.MCMIDSDEditField.Layout.Column = 2;
            app.MCMIDSDEditField.Value = 0.01;

            % Create GridLayout10_3
            app.GridLayout10_3 = uigridlayout(app.GridLayout9);
            app.GridLayout10_3.ColumnWidth = {'6x', '4x'};
            app.GridLayout10_3.RowHeight = {'1x'};
            app.GridLayout10_3.Padding = [0 0 0 0];
            app.GridLayout10_3.Layout.Row = 4;
            app.GridLayout10_3.Layout.Column = 1;

            % Create OptimizationprocedureDropDownLabel
            app.OptimizationprocedureDropDownLabel = uilabel(app.GridLayout10_3);
            app.OptimizationprocedureDropDownLabel.Layout.Row = 1;
            app.OptimizationprocedureDropDownLabel.Layout.Column = 1;
            app.OptimizationprocedureDropDownLabel.Text = 'Optimization procedure';

            % Create MCProcedureDropDown
            app.MCProcedureDropDown = uidropdown(app.GridLayout10_3);
            app.MCProcedureDropDown.Items = {'Single run', 'Multiple run'};
            app.MCProcedureDropDown.Layout.Row = 1;
            app.MCProcedureDropDown.Layout.Column = 2;
            app.MCProcedureDropDown.Value = 'Multiple run';

            % Create GridLayout10_4
            app.GridLayout10_4 = uigridlayout(app.GridLayout9);
            app.GridLayout10_4.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_4.RowHeight = {'1x'};
            app.GridLayout10_4.Padding = [0 0 0 0];
            app.GridLayout10_4.Layout.Row = 5;
            app.GridLayout10_4.Layout.Column = 1;

            % Create TerminationtoleranceTTEditFieldLabel
            app.TerminationtoleranceTTEditFieldLabel = uilabel(app.GridLayout10_4);
            app.TerminationtoleranceTTEditFieldLabel.Layout.Row = 1;
            app.TerminationtoleranceTTEditFieldLabel.Layout.Column = 1;
            app.TerminationtoleranceTTEditFieldLabel.Text = 'Termination tolerance (TT):';

            % Create MCTTEditField
            app.MCTTEditField = uieditfield(app.GridLayout10_4, 'numeric');
            app.MCTTEditField.Limits = [1e-10 Inf];
            app.MCTTEditField.Layout.Row = 1;
            app.MCTTEditField.Layout.Column = 2;
            app.MCTTEditField.Value = 0.001;

            % Create GridLayout10_5
            app.GridLayout10_5 = uigridlayout(app.GridLayout9);
            app.GridLayout10_5.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_5.RowHeight = {'1x'};
            app.GridLayout10_5.Padding = [0 0 0 0];
            app.GridLayout10_5.Layout.Row = 6;
            app.GridLayout10_5.Layout.Column = 1;

            % Create ProximitythresholdepsilonLabel
            app.ProximitythresholdepsilonLabel = uilabel(app.GridLayout10_5);
            app.ProximitythresholdepsilonLabel.Layout.Row = 1;
            app.ProximitythresholdepsilonLabel.Layout.Column = 1;
            app.ProximitythresholdepsilonLabel.Interpreter = 'html';
            app.ProximitythresholdepsilonLabel.Text = 'Proximity threshold (<i>&epsilon;</i>):';

            % Create MCProximityEditField
            app.MCProximityEditField = uieditfield(app.GridLayout10_5, 'numeric');
            app.MCProximityEditField.Limits = [1e-10 Inf];
            app.MCProximityEditField.Layout.Row = 1;
            app.MCProximityEditField.Layout.Column = 2;
            app.MCProximityEditField.Value = 0.001;

            % Create GridLayout10_6
            app.GridLayout10_6 = uigridlayout(app.GridLayout9);
            app.GridLayout10_6.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_6.RowHeight = {'1x'};
            app.GridLayout10_6.Padding = [0 0 0 0];
            app.GridLayout10_6.Layout.Row = 7;
            app.GridLayout10_6.Layout.Column = 1;

            % Create CertainthresholdiNisubASsubEditFieldLabel
            app.CertainthresholdiNisubASsubEditFieldLabel = uilabel(app.GridLayout10_6);
            app.CertainthresholdiNisubASsubEditFieldLabel.Layout.Row = 1;
            app.CertainthresholdiNisubASsubEditFieldLabel.Layout.Column = 1;
            app.CertainthresholdiNisubASsubEditFieldLabel.Interpreter = 'html';
            app.CertainthresholdiNisubASsubEditFieldLabel.Text = 'Certain threshold (<i>N</i><sub>AS</sub>):';

            % Create MCNasEditField
            app.MCNasEditField = uieditfield(app.GridLayout10_6, 'numeric');
            app.MCNasEditField.Limits = [1 Inf];
            app.MCNasEditField.Layout.Row = 1;
            app.MCNasEditField.Layout.Column = 2;
            app.MCNasEditField.Value = 3;

            % Create GridLayout10_7
            app.GridLayout10_7 = uigridlayout(app.GridLayout9);
            app.GridLayout10_7.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_7.RowHeight = {'1x'};
            app.GridLayout10_7.Padding = [0 0 0 0];
            app.GridLayout10_7.Layout.Row = 8;
            app.GridLayout10_7.Layout.Column = 1;

            % Create ThenumberofrunsiKisubNRsubEditFieldLabel
            app.ThenumberofrunsiKisubNRsubEditFieldLabel = uilabel(app.GridLayout10_7);
            app.ThenumberofrunsiKisubNRsubEditFieldLabel.Layout.Row = 1;
            app.ThenumberofrunsiKisubNRsubEditFieldLabel.Layout.Column = 1;
            app.ThenumberofrunsiKisubNRsubEditFieldLabel.Interpreter = 'html';
            app.ThenumberofrunsiKisubNRsubEditFieldLabel.Text = 'The number of runs (<i>K</i><sub>NR</sub>):';

            % Create MCKNREditField
            app.MCKNREditField = uieditfield(app.GridLayout10_7, 'numeric');
            app.MCKNREditField.Limits = [10 Inf];
            app.MCKNREditField.Layout.Row = 1;
            app.MCKNREditField.Layout.Column = 2;
            app.MCKNREditField.Value = 50;

            % Create GridLayout10_8
            app.GridLayout10_8 = uigridlayout(app.GridLayout9);
            app.GridLayout10_8.ColumnWidth = {'5x', '5x'};
            app.GridLayout10_8.RowHeight = {'1x'};
            app.GridLayout10_8.Padding = [0 0 0 0];
            app.GridLayout10_8.Layout.Row = 9;
            app.GridLayout10_8.Layout.Column = 1;

            % Create CalculationmethodsDropDownLabel
            app.CalculationmethodsDropDownLabel = uilabel(app.GridLayout10_8);
            app.CalculationmethodsDropDownLabel.Layout.Row = 1;
            app.CalculationmethodsDropDownLabel.Layout.Column = 1;
            app.CalculationmethodsDropDownLabel.Text = 'Calculation methods';

            % Create MCMethodDropDown
            app.MCMethodDropDown = uidropdown(app.GridLayout10_8);
            app.MCMethodDropDown.Items = {'Discarding', 'Mean-varianced'};
            app.MCMethodDropDown.Layout.Row = 1;
            app.MCMethodDropDown.Layout.Column = 2;
            app.MCMethodDropDown.Value = 'Discarding';

            % Create GridsearchTab
            app.GridsearchTab = uitab(app.TabGroup2);
            app.GridsearchTab.Title = 'Grid search';

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.GridsearchTab);
            app.GridLayout11.ColumnWidth = {'1x'};
            app.GridLayout11.RowHeight = {'fit', 'fit', 'fit', 'fit', '1x', '1x'};
            app.GridLayout11.Padding = [5 5 5 5];

            % Create DeterminegridintervalautomaticallyCheckBox
            app.DeterminegridintervalautomaticallyCheckBox = uicheckbox(app.GridLayout11);
            app.DeterminegridintervalautomaticallyCheckBox.ValueChangedFcn = createCallbackFcn(app, @DeterminegridintervalautomaticallyCheckBoxValueChanged, true);
            app.DeterminegridintervalautomaticallyCheckBox.Text = 'Determine grid interval automatically';
            app.DeterminegridintervalautomaticallyCheckBox.Layout.Row = 1;
            app.DeterminegridintervalautomaticallyCheckBox.Layout.Column = 1;
            app.DeterminegridintervalautomaticallyCheckBox.Value = true;

            % Create GridLayout12
            app.GridLayout12 = uigridlayout(app.GridLayout11);
            app.GridLayout12.ColumnWidth = {'7x', '3x'};
            app.GridLayout12.RowHeight = {'1x'};
            app.GridLayout12.Padding = [0 0 0 0];
            app.GridLayout12.Layout.Row = 2;
            app.GridLayout12.Layout.Column = 1;

            % Create ThenumberofgridpointsEditFieldLabel
            app.ThenumberofgridpointsEditFieldLabel = uilabel(app.GridLayout12);
            app.ThenumberofgridpointsEditFieldLabel.Layout.Row = 1;
            app.ThenumberofgridpointsEditFieldLabel.Layout.Column = 1;
            app.ThenumberofgridpointsEditFieldLabel.Text = 'The number of grid points';

            % Create ThenumberofgridpointsEditField
            app.ThenumberofgridpointsEditField = uieditfield(app.GridLayout12, 'numeric');
            app.ThenumberofgridpointsEditField.Limits = [10 Inf];
            app.ThenumberofgridpointsEditField.Layout.Row = 1;
            app.ThenumberofgridpointsEditField.Layout.Column = 2;
            app.ThenumberofgridpointsEditField.Value = 10;

            % Create GridLayout12_2
            app.GridLayout12_2 = uigridlayout(app.GridLayout11);
            app.GridLayout12_2.ColumnWidth = {'7x', '3x'};
            app.GridLayout12_2.RowHeight = {'1x'};
            app.GridLayout12_2.Padding = [0 0 0 0];
            app.GridLayout12_2.Layout.Row = 3;
            app.GridLayout12_2.Layout.Column = 1;

            % Create GridintervalDeltaixiEditFieldLabel
            app.GridintervalDeltaixiEditFieldLabel = uilabel(app.GridLayout12_2);
            app.GridintervalDeltaixiEditFieldLabel.Layout.Row = 1;
            app.GridintervalDeltaixiEditFieldLabel.Layout.Column = 1;
            app.GridintervalDeltaixiEditFieldLabel.Interpreter = 'html';
            app.GridintervalDeltaixiEditFieldLabel.Text = 'Grid interval (&Delta;<i>x</i>):';

            % Create GridintervalDeltaixiEditField
            app.GridintervalDeltaixiEditField = uieditfield(app.GridLayout12_2, 'numeric');
            app.GridintervalDeltaixiEditField.Limits = [0.1 Inf];
            app.GridintervalDeltaixiEditField.Layout.Row = 1;
            app.GridintervalDeltaixiEditField.Layout.Column = 2;
            app.GridintervalDeltaixiEditField.Value = 1;

            % Create GridLayout12_3
            app.GridLayout12_3 = uigridlayout(app.GridLayout11);
            app.GridLayout12_3.ColumnWidth = {'7x', '3x'};
            app.GridLayout12_3.RowHeight = {'1x'};
            app.GridLayout12_3.Padding = [0 0 0 0];
            app.GridLayout12_3.Layout.Row = 4;
            app.GridLayout12_3.Layout.Column = 1;

            % Create IterationtimesforgridsearchEditFieldLabel
            app.IterationtimesforgridsearchEditFieldLabel = uilabel(app.GridLayout12_3);
            app.IterationtimesforgridsearchEditFieldLabel.Layout.Row = 1;
            app.IterationtimesforgridsearchEditFieldLabel.Layout.Column = 1;
            app.IterationtimesforgridsearchEditFieldLabel.Text = 'Iteration times for grid search';

            % Create IterationtimesforgridsearchEditField
            app.IterationtimesforgridsearchEditField = uieditfield(app.GridLayout12_3, 'numeric');
            app.IterationtimesforgridsearchEditField.Limits = [1 Inf];
            app.IterationtimesforgridsearchEditField.Layout.Row = 1;
            app.IterationtimesforgridsearchEditField.Layout.Column = 2;
            app.IterationtimesforgridsearchEditField.Value = 30;

            % Create GridLayout12_4
            app.GridLayout12_4 = uigridlayout(app.GridLayout11);
            app.GridLayout12_4.ColumnWidth = {'6x', '4x'};
            app.GridLayout12_4.RowHeight = {'fit'};
            app.GridLayout12_4.Padding = [0 0 0 0];
            app.GridLayout12_4.Layout.Row = 5;
            app.GridLayout12_4.Layout.Column = 1;

            % Create ThresholdDropDownLabel
            app.ThresholdDropDownLabel = uilabel(app.GridLayout12_4);
            app.ThresholdDropDownLabel.Layout.Row = 1;
            app.ThresholdDropDownLabel.Layout.Column = 1;
            app.ThresholdDropDownLabel.Text = 'Threshold';

            % Create ThresholdDropDown
            app.ThresholdDropDown = uidropdown(app.GridLayout12_4);
            app.ThresholdDropDown.Items = {'F-distribution', 'Chi-squared'};
            app.ThresholdDropDown.Layout.Row = 1;
            app.ThresholdDropDown.Layout.Column = 2;
            app.ThresholdDropDown.Value = 'F-distribution';

            % Create GridLayout7_2
            app.GridLayout7_2 = uigridlayout(app.GridLayout5_2);
            app.GridLayout7_2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7_2.RowHeight = {'1x'};
            app.GridLayout7_2.Padding = [0 0 0 0];
            app.GridLayout7_2.Layout.Row = 2;
            app.GridLayout7_2.Layout.Column = 1;

            % Create GeneralCancelButton
            app.GeneralCancelButton = uibutton(app.GridLayout7_2, 'push');
            app.GeneralCancelButton.ButtonPushedFcn = createCallbackFcn(app, @GeneralCancelButtonPushed, true);
            app.GeneralCancelButton.Layout.Row = 1;
            app.GeneralCancelButton.Layout.Column = 5;
            app.GeneralCancelButton.Text = 'Cancel';

            % Create GeneralApplyButton
            app.GeneralApplyButton = uibutton(app.GridLayout7_2, 'push');
            app.GeneralApplyButton.ButtonPushedFcn = createCallbackFcn(app, @GeneralApplyButtonPushed2, true);
            app.GeneralApplyButton.Layout.Row = 1;
            app.GeneralApplyButton.Layout.Column = 4;
            app.GeneralApplyButton.Text = 'Apply';

            % Create GeneralRestoreDefaultButton
            app.GeneralRestoreDefaultButton = uibutton(app.GridLayout7_2, 'push');
            app.GeneralRestoreDefaultButton.Layout.Row = 1;
            app.GeneralRestoreDefaultButton.Layout.Column = 3;
            app.GeneralRestoreDefaultButton.Text = 'Restore default';

            % Create MSfragmentTab
            app.MSfragmentTab = uitab(app.TabGroup);
            app.MSfragmentTab.Title = 'MS fragment';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.MSfragmentTab);
            app.GridLayout5.ColumnWidth = {'1x'};
            app.GridLayout5.RowHeight = {'1x', 'fit'};

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout5);
            app.GridLayout7.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.RowHeight = {'1x'};
            app.GridLayout7.Padding = [0 0 0 0];
            app.GridLayout7.Layout.Row = 2;
            app.GridLayout7.Layout.Column = 1;

            % Create MSCancelButton
            app.MSCancelButton = uibutton(app.GridLayout7, 'push');
            app.MSCancelButton.ButtonPushedFcn = createCallbackFcn(app, @MSCancelButtonPushed, true);
            app.MSCancelButton.Layout.Row = 1;
            app.MSCancelButton.Layout.Column = 5;
            app.MSCancelButton.Text = 'Cancel';

            % Create MSApplyAllButton
            app.MSApplyAllButton = uibutton(app.GridLayout7, 'push');
            app.MSApplyAllButton.ButtonPushedFcn = createCallbackFcn(app, @MSApplyAllButtonPushed, true);
            app.MSApplyAllButton.Layout.Row = 1;
            app.MSApplyAllButton.Layout.Column = 4;
            app.MSApplyAllButton.Text = 'Apply';

            % Create MSRestoreDefaultButton
            app.MSRestoreDefaultButton = uibutton(app.GridLayout7, 'push');
            app.MSRestoreDefaultButton.Layout.Row = 1;
            app.MSRestoreDefaultButton.Layout.Column = 3;
            app.MSRestoreDefaultButton.Text = 'Restore default';

            % Create MSTable
            app.MSTable = uitable(app.GridLayout5);
            app.MSTable.ColumnName = '';
            app.MSTable.RowName = {};
            app.MSTable.Layout.Row = 1;
            app.MSTable.Layout.Column = 1;

            % Create EffluxperturbationTab
            app.EffluxperturbationTab = uitab(app.TabGroup);
            app.EffluxperturbationTab.Title = 'Efflux perturbation';

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.EffluxperturbationTab);
            app.GridLayout13.ColumnWidth = {'1x'};
            app.GridLayout13.RowHeight = {'1x', 'fit'};

            % Create GridLayout15
            app.GridLayout15 = uigridlayout(app.GridLayout13);
            app.GridLayout15.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout15.RowHeight = {'1x'};
            app.GridLayout15.Padding = [0 0 0 0];
            app.GridLayout15.Layout.Row = 2;
            app.GridLayout15.Layout.Column = 1;

            % Create EffluxCancelButton
            app.EffluxCancelButton = uibutton(app.GridLayout15, 'push');
            app.EffluxCancelButton.ButtonPushedFcn = createCallbackFcn(app, @EffluxCancelButtonPushed, true);
            app.EffluxCancelButton.Layout.Row = 1;
            app.EffluxCancelButton.Layout.Column = 5;
            app.EffluxCancelButton.Text = 'Cancel';

            % Create EffluxApplyButton
            app.EffluxApplyButton = uibutton(app.GridLayout15, 'push');
            app.EffluxApplyButton.Layout.Row = 1;
            app.EffluxApplyButton.Layout.Column = 4;
            app.EffluxApplyButton.Text = 'Apply';

            % Create EffluxRestoreDefaultButton
            app.EffluxRestoreDefaultButton = uibutton(app.GridLayout15, 'push');
            app.EffluxRestoreDefaultButton.Layout.Row = 1;
            app.EffluxRestoreDefaultButton.Layout.Column = 3;
            app.EffluxRestoreDefaultButton.Text = 'Restore default';

            % Create GridLayout22
            app.GridLayout22 = uigridlayout(app.GridLayout13);
            app.GridLayout22.RowHeight = {'1x'};
            app.GridLayout22.Padding = [0 0 0 0];
            app.GridLayout22.Layout.Row = 1;
            app.GridLayout22.Layout.Column = 1;

            % Create EffluxUITable
            app.EffluxUITable = uitable(app.GridLayout22);
            app.EffluxUITable.ColumnName = '';
            app.EffluxUITable.RowName = {};
            app.EffluxUITable.Enable = 'off';
            app.EffluxUITable.Layout.Row = 1;
            app.EffluxUITable.Layout.Column = 1;

            % Create TracersuggestionTab
            app.TracersuggestionTab = uitab(app.TabGroup);
            app.TracersuggestionTab.Title = 'Tracer suggestion';

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.TracersuggestionTab);
            app.GridLayout14.ColumnWidth = {'1x'};
            app.GridLayout14.RowHeight = {'1x', 'fit'};

            % Create GridLayout16
            app.GridLayout16 = uigridlayout(app.GridLayout14);
            app.GridLayout16.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout16.RowHeight = {'1x'};
            app.GridLayout16.Padding = [0 0 0 0];
            app.GridLayout16.Layout.Row = 2;
            app.GridLayout16.Layout.Column = 1;

            % Create SuggestionCancelButton
            app.SuggestionCancelButton = uibutton(app.GridLayout16, 'push');
            app.SuggestionCancelButton.ButtonPushedFcn = createCallbackFcn(app, @SuggestionCancelButtonPushed, true);
            app.SuggestionCancelButton.Layout.Row = 1;
            app.SuggestionCancelButton.Layout.Column = 5;
            app.SuggestionCancelButton.Text = 'Cancel';

            % Create SuggestionRestoreDefaultButton
            app.SuggestionRestoreDefaultButton = uibutton(app.GridLayout16, 'push');
            app.SuggestionRestoreDefaultButton.Layout.Row = 1;
            app.SuggestionRestoreDefaultButton.Layout.Column = 3;
            app.SuggestionRestoreDefaultButton.Text = 'Restore default';

            % Create SuggestionApplyButton
            app.SuggestionApplyButton = uibutton(app.GridLayout16, 'push');
            app.SuggestionApplyButton.Layout.Row = 1;
            app.SuggestionApplyButton.Layout.Column = 4;
            app.SuggestionApplyButton.Text = 'Apply';

            % Create GridLayout17
            app.GridLayout17 = uigridlayout(app.GridLayout14);
            app.GridLayout17.RowHeight = {'1x'};
            app.GridLayout17.Padding = [0 0 0 0];
            app.GridLayout17.Layout.Row = 1;
            app.GridLayout17.Layout.Column = 1;

            % Create LabelTable
            app.LabelTable = uitable(app.GridLayout17);
            app.LabelTable.ColumnName = '';
            app.LabelTable.RowName = {};
            app.LabelTable.DoubleClickedFcn = createCallbackFcn(app, @LabelTableDoubleClicked, true);
            app.LabelTable.Enable = 'off';
            app.LabelTable.Layout.Row = 1;
            app.LabelTable.Layout.Column = 1;

            % Create GridLayout18
            app.GridLayout18 = uigridlayout(app.GridLayout17);
            app.GridLayout18.ColumnWidth = {'1x'};
            app.GridLayout18.RowHeight = {'fit', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout18.Padding = [0 0 0 0];
            app.GridLayout18.Layout.Row = 1;
            app.GridLayout18.Layout.Column = 2;

            % Create INSTMFATab
            app.INSTMFATab = uitab(app.TabGroup);
            app.INSTMFATab.Title = 'INST-MFA';

            % Create GridLayout13_2
            app.GridLayout13_2 = uigridlayout(app.INSTMFATab);
            app.GridLayout13_2.ColumnWidth = {'1x'};
            app.GridLayout13_2.RowHeight = {'1x', 'fit'};

            % Create GridLayout15_2
            app.GridLayout15_2 = uigridlayout(app.GridLayout13_2);
            app.GridLayout15_2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout15_2.RowHeight = {'1x'};
            app.GridLayout15_2.Padding = [0 0 0 0];
            app.GridLayout15_2.Layout.Row = 2;
            app.GridLayout15_2.Layout.Column = 1;

            % Create INSTMFACancelButton
            app.INSTMFACancelButton = uibutton(app.GridLayout15_2, 'push');
            app.INSTMFACancelButton.ButtonPushedFcn = createCallbackFcn(app, @INSTMFACancelButtonPushed, true);
            app.INSTMFACancelButton.Layout.Row = 1;
            app.INSTMFACancelButton.Layout.Column = 5;
            app.INSTMFACancelButton.Text = 'Cancel';

            % Create INSTMFARestoreDefaultButton
            app.INSTMFARestoreDefaultButton = uibutton(app.GridLayout15_2, 'push');
            app.INSTMFARestoreDefaultButton.Layout.Row = 1;
            app.INSTMFARestoreDefaultButton.Layout.Column = 3;
            app.INSTMFARestoreDefaultButton.Text = 'Restore default';

            % Create INSTMFAApplyButton
            app.INSTMFAApplyButton = uibutton(app.GridLayout15_2, 'push');
            app.INSTMFAApplyButton.Layout.Row = 1;
            app.INSTMFAApplyButton.Layout.Column = 4;
            app.INSTMFAApplyButton.Text = 'Apply';

            % Create GridLayout20
            app.GridLayout20 = uigridlayout(app.GridLayout13_2);
            app.GridLayout20.RowHeight = {'1x'};
            app.GridLayout20.Padding = [0 0 0 0];
            app.GridLayout20.Layout.Row = 1;
            app.GridLayout20.Layout.Column = 1;

            % Create GridLayout21
            app.GridLayout21 = uigridlayout(app.GridLayout20);
            app.GridLayout21.ColumnWidth = {'1x'};
            app.GridLayout21.RowHeight = {'1x'};
            app.GridLayout21.Padding = [0 0 0 0];
            app.GridLayout21.Layout.Row = 1;
            app.GridLayout21.Layout.Column = 1;

            % Create INSTMFAPoolUITable
            app.INSTMFAPoolUITable = uitable(app.GridLayout21);
            app.INSTMFAPoolUITable.ColumnName = '';
            app.INSTMFAPoolUITable.RowName = {};
            app.INSTMFAPoolUITable.Enable = 'off';
            app.INSTMFAPoolUITable.Layout.Row = 1;
            app.INSTMFAPoolUITable.Layout.Column = 1;

            % Create INSTMFATimeCourseUITable
            app.INSTMFATimeCourseUITable = uitable(app.GridLayout20);
            app.INSTMFATimeCourseUITable.ColumnName = '';
            app.INSTMFATimeCourseUITable.RowName = {};
            app.INSTMFATimeCourseUITable.Layout.Row = 1;
            app.INSTMFATimeCourseUITable.Layout.Column = 2;

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.BatchconfigUIFigure);

            % Create AddnewpatternMenu
            app.AddnewpatternMenu = uimenu(app.ContextMenu);
            app.AddnewpatternMenu.MenuSelectedFcn = createCallbackFcn(app, @AddnewpatternMenuSelected, true);
            app.AddnewpatternMenu.Text = 'Add new pattern';

            % Create AddnewpatternsMenu
            app.AddnewpatternsMenu = uimenu(app.ContextMenu);
            app.AddnewpatternsMenu.MenuSelectedFcn = createCallbackFcn(app, @AddnewpatternsMenuSelected, true);
            app.AddnewpatternsMenu.Text = 'Add new patterns';

            % Create CopythistracerforallentriesMenu
            app.CopythistracerforallentriesMenu = uimenu(app.ContextMenu);
            app.CopythistracerforallentriesMenu.MenuSelectedFcn = createCallbackFcn(app, @CopythistracerforallentriesMenuSelected, true);
            app.CopythistracerforallentriesMenu.Text = 'Copy this tracer for all entries';

            % Assign app.ContextMenu
            app.LabelTable.ContextMenu = app.ContextMenu;

            % Create ContextMenuINST
            app.ContextMenuINST = uicontextmenu(app.BatchconfigUIFigure);

            % Create AddexperimentsMenu
            app.AddexperimentsMenu = uimenu(app.ContextMenuINST);
            app.AddexperimentsMenu.MenuSelectedFcn = createCallbackFcn(app, @AddexperimentsMenuSelected, true);
            app.AddexperimentsMenu.Text = 'Add experiments';

            % Create RemoveselectedexperimentMenu
            app.RemoveselectedexperimentMenu = uimenu(app.ContextMenuINST);
            app.RemoveselectedexperimentMenu.MenuSelectedFcn = createCallbackFcn(app, @RemoveselectedexperimentMenuSelected, true);
            app.RemoveselectedexperimentMenu.Text = 'Remove selected experiment';

            % Assign app.ContextMenuINST
            app.INSTMFATimeCourseUITable.ContextMenu = app.ContextMenuINST;

            % Show the figure after all components are created
            app.BatchconfigUIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = RunConfig_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.BatchconfigUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end

        end

        % Code that executes before app deletion
        function delete(app)

            app.detachRunAddBatchListeners();
            app.detachTracerConfigListeners();

            if ~isempty(app.RunAddBatchApp)
                try
                    if isvalid(app.RunAddBatchApp)
                        delete(app.RunAddBatchApp);
                    end
                catch
                end
            end

            if ~isempty(app.TracerConfigApp)
                try
                    if isvalid(app.TracerConfigApp)
                        delete(app.TracerConfigApp);
                    end
                catch
                end
            end

            % Delete UIFigure when app is deleted
            delete(app.BatchconfigUIFigure)
        end

    end

end
