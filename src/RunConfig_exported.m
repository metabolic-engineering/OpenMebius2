classdef RunConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        BatchconfigUIFigure             matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        TabGroup                        matlab.ui.container.TabGroup
        GeneralTab                      matlab.ui.container.Tab
        GridLayout5_2                   matlab.ui.container.GridLayout
        GridLayout7_2                   matlab.ui.container.GridLayout
        GeneralRestoreDefaultButton     matlab.ui.control.Button
        GeneralCloseButton              matlab.ui.control.Button
        GeneralCancelButton             matlab.ui.control.Button
        GridLayout6_2                   matlab.ui.container.GridLayout
        TabGroup2                       matlab.ui.container.TabGroup
        MonteCarloTab                   matlab.ui.container.Tab
        GridLayout9                     matlab.ui.container.GridLayout
        GridLayout10_8                  matlab.ui.container.GridLayout
        MCMethodDropDown                matlab.ui.control.DropDown
        CalculationmethodsDropDownLabel  matlab.ui.control.Label
        GridLayout10_7                  matlab.ui.container.GridLayout
        MCKNREditField                  matlab.ui.control.NumericEditField
        ThenumberofrunsiKisubNRsubEditFieldLabel  matlab.ui.control.Label
        GridLayout10_6                  matlab.ui.container.GridLayout
        MCNasEditField                  matlab.ui.control.NumericEditField
        CertainthresholdiNisubASsubEditFieldLabel  matlab.ui.control.Label
        GridLayout10_5                  matlab.ui.container.GridLayout
        MCProximityEditField            matlab.ui.control.NumericEditField
        ProximitythresholdepsilonLabel  matlab.ui.control.Label
        GridLayout10_4                  matlab.ui.container.GridLayout
        MCTTEditField                   matlab.ui.control.NumericEditField
        TerminationtoleranceTTEditFieldLabel  matlab.ui.control.Label
        GridLayout10_3                  matlab.ui.container.GridLayout
        MCProcedureDropDown             matlab.ui.control.DropDown
        OptimizationprocedureDropDownLabel  matlab.ui.control.Label
        GridLayout10_2                  matlab.ui.container.GridLayout
        MCMIDSDEditField                matlab.ui.control.NumericEditField
        VariationsforMIDserrorLabel     matlab.ui.control.Label
        MCFixMIDCheckBox                matlab.ui.control.CheckBox
        GridLayout10                    matlab.ui.container.GridLayout
        MCLmaxEditField                 matlab.ui.control.NumericEditField
        maximumnumberoftrialsLsubmaxsubLabel  matlab.ui.control.Label
        GridsearchTab                   matlab.ui.container.Tab
        GridLayout11                    matlab.ui.container.GridLayout
        GridLayout12_5                  matlab.ui.container.GridLayout
        MinimumFLuxRangeEditField       matlab.ui.control.NumericEditField
        MinimumfluxrangeEditFieldLabel  matlab.ui.control.Label
        GridLayout12_6                  matlab.ui.container.GridLayout
        ParallelworkersEditField        matlab.ui.control.NumericEditField
        ParallelworkersEditFieldLabel   matlab.ui.control.Label
        CheckBox                        matlab.ui.control.CheckBox
        GridLayout12_4                  matlab.ui.container.GridLayout
        ThresholdDropDown               matlab.ui.control.DropDown
        ThresholdDropDownLabel          matlab.ui.control.Label
        GridLayout12_3                  matlab.ui.container.GridLayout
        IterationtimesforgridsearchEditField  matlab.ui.control.NumericEditField
        IterationtimesforgridsearchEditFieldLabel  matlab.ui.control.Label
        GridLayout12_2                  matlab.ui.container.GridLayout
        GridintervalDeltaixiEditField   matlab.ui.control.NumericEditField
        GridintervalDeltaixiEditFieldLabel  matlab.ui.control.Label
        GridLayout12                    matlab.ui.container.GridLayout
        ThenumberofgridpointsEditField  matlab.ui.control.NumericEditField
        ThenumberofgridpointsEditFieldLabel  matlab.ui.control.Label
        DeterminegridintervalautomaticallyCheckBox  matlab.ui.control.CheckBox
        GridreactionTab                 matlab.ui.container.Tab
        GridLayout23                    matlab.ui.container.GridLayout
        GridReactionUITable             matlab.ui.control.Table
        GridLayout8                     matlab.ui.container.GridLayout
        INSTMFACheckBox                 matlab.ui.control.CheckBox
        DeleteResultButton              matlab.ui.control.CheckBox
        GridLayoutAlgorithm_2           matlab.ui.container.GridLayout
        AlgorithmCIDropDown             matlab.ui.control.DropDown
        AlgorithmforCIcalculationDropDownLabel  matlab.ui.control.Label
        CalcCICheckBox                  matlab.ui.control.CheckBox
        PerturbateEffluxCheckBox        matlab.ui.control.CheckBox
        SuggestionCheckBox              matlab.ui.control.CheckBox
        GridLayoutIteration             matlab.ui.container.GridLayout
        IterationSpinner                matlab.ui.control.Spinner
        IterationtimesforcalculationSpinnerLabel  matlab.ui.control.Label
        MSfragmentTab                   matlab.ui.container.Tab
        GridLayout5                     matlab.ui.container.GridLayout
        MSTable                         matlab.ui.control.Table
        GridLayout7                     matlab.ui.container.GridLayout
        MSRestoreDefaultButton          matlab.ui.control.Button
        MSCloseButton                   matlab.ui.control.Button
        MSCancelButton                  matlab.ui.control.Button
        OptimizationTab                 matlab.ui.container.Tab
        GridLayout13_3                  matlab.ui.container.GridLayout
        GridLayout22_2                  matlab.ui.container.GridLayout
        GridLayout26                    matlab.ui.container.GridLayout
        GridLayout10_19                 matlab.ui.container.GridLayout
        MCLmaxEditField_2               matlab.ui.control.NumericEditField
        EditFieldLabel_2                matlab.ui.control.Label
        SearchOptimalFiniteDifferenceStepSizeCheckBox  matlab.ui.control.CheckBox
        GridLayout24                    matlab.ui.container.GridLayout
        GridLayout10_17                 matlab.ui.container.GridLayout
        FiniteDifferenceStepSizeEditField  matlab.ui.control.NumericEditField
        EditFieldLabel                  matlab.ui.control.Label
        GridLayout25_2                  matlab.ui.container.GridLayout
        FiniteDifferenceTypeDropDown    matlab.ui.control.DropDown
        DropDownLabel_2                 matlab.ui.control.Label
        GridLayout10_16                 matlab.ui.container.GridLayout
        ConstraintToleranceEditField    matlab.ui.control.NumericEditField
        FluxUBEditFieldLabel_8          matlab.ui.control.Label
        GridLayout10_15                 matlab.ui.container.GridLayout
        OptimalityToleranceEditField    matlab.ui.control.NumericEditField
        FluxUBEditFieldLabel_7          matlab.ui.control.Label
        GridLayout10_14                 matlab.ui.container.GridLayout
        StepToleranceEditField          matlab.ui.control.NumericEditField
        FluxUBEditFieldLabel_6          matlab.ui.control.Label
        GridLayout10_13                 matlab.ui.container.GridLayout
        FunctionToleranceEditField      matlab.ui.control.NumericEditField
        FluxUBEditFieldLabel_5          matlab.ui.control.Label
        GridLayout10_12                 matlab.ui.container.GridLayout
        MaxIterationsEditField          matlab.ui.control.NumericEditField
        FluxUBEditFieldLabel_4          matlab.ui.control.Label
        GridLayout10_11                 matlab.ui.container.GridLayout
        MaxFunctionEvaluationsEditField  matlab.ui.control.NumericEditField
        FluxUBEditFieldLabel_3          matlab.ui.control.Label
        GridLayout10_10                 matlab.ui.container.GridLayout
        FluxLBEditField                 matlab.ui.control.NumericEditField
        FluxUBEditFieldLabel_2          matlab.ui.control.Label
        GridLayout10_9                  matlab.ui.container.GridLayout
        FluxUBEditField                 matlab.ui.control.NumericEditField
        FluxUBEditFieldLabel            matlab.ui.control.Label
        LargeScaleCheckBox              matlab.ui.control.CheckBox
        GridLayout25                    matlab.ui.container.GridLayout
        AlgorithmDropDown               matlab.ui.control.DropDown
        DropDownLabel                   matlab.ui.control.Label
        GridLayout15_3                  matlab.ui.container.GridLayout
        OptimizationRestoreDefaultButton  matlab.ui.control.Button
        OptimizationCloseButton         matlab.ui.control.Button
        OptimizationCancelButton        matlab.ui.control.Button
        EffluxperturbationTab           matlab.ui.container.Tab
        GridLayout13                    matlab.ui.container.GridLayout
        GridLayout22                    matlab.ui.container.GridLayout
        EffluxUITable                   matlab.ui.control.Table
        GridLayout15                    matlab.ui.container.GridLayout
        EffluxRestoreDefaultButton      matlab.ui.control.Button
        EffluxCloseButton               matlab.ui.control.Button
        EffluxCancelButton              matlab.ui.control.Button
        TracersuggestionTab             matlab.ui.container.Tab
        GridLayout14                    matlab.ui.container.GridLayout
        GridLayout17                    matlab.ui.container.GridLayout
        GridLayout18                    matlab.ui.container.GridLayout
        LabelTable                      matlab.ui.control.Table
        GridLayout16                    matlab.ui.container.GridLayout
        SuggestionCloseButton           matlab.ui.control.Button
        SuggestionRestoreDefaultButton  matlab.ui.control.Button
        SuggestionCancelButton          matlab.ui.control.Button
        INSTMFATab                      matlab.ui.container.Tab
        GridLayout13_2                  matlab.ui.container.GridLayout
        GridLayout20                    matlab.ui.container.GridLayout
        INSTMFATimeCourseUITable        matlab.ui.control.Table
        GridLayout21                    matlab.ui.container.GridLayout
        INSTMFAPoolUITable              matlab.ui.control.Table
        GridLayout15_2                  matlab.ui.container.GridLayout
        INSTMFACloseButton              matlab.ui.control.Button
        INSTMFARestoreDefaultButton     matlab.ui.control.Button
        INSTMFACancelButton             matlab.ui.control.Button
        ContextMenu                     matlab.ui.container.ContextMenu
        AddnewpatternMenu               matlab.ui.container.Menu
        AddnewpatternsMenu              matlab.ui.container.Menu
        CopythistracerforallentriesMenu  matlab.ui.container.Menu
        ContextMenuINST                 matlab.ui.container.ContextMenu
        AddexperimentsMenu              matlab.ui.container.Menu
        RemoveselectedexperimentMenu    matlab.ui.container.Menu
    end


    %% Private properties
    properties (Access = private)
        Session openmebius.application.batch.BatchConfigurationSession
        Presenter openmebius.presentation.batch.RunConfigPresenter
        Controller openmebius.application.batch.BatchConfigurationController
        BatchExperimentSelectionEditorController openmebius.application.batch.BatchExperimentSelectionEditorController
        BatchExperimentSelectionEditorPresenter openmebius.presentation.batch.BatchExperimentSelectionEditorPresenter
        RunAddBatchApp
        TracerConfigApp
        ChildAppHost openmebius.presentation.lifecycle.ChildAppHost
        ExperimentEditController openmebius.application.experiment.ExperimentEditController
        ExperimentPresenter openmebius.presentation.experiment.ExperimentPresenter
        MSFragmentTableMetadata
        IsReadOnly (1, 1) logical = false
    end

    events
        Applied
        Closed
        NotificationRequested
        BatchExperimentSelectionApplied
    end % events

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

        function initializeView(app, context)

            app.Session = context.Session;
            app.Presenter = context.Presenter;
            app.Controller = context.ConfigurationController;
            app.ExperimentEditController = ...
                context.ExperimentEditController;
            app.ExperimentPresenter = context.ExperimentPresenter;
            app.BatchExperimentSelectionEditorController = ...
                context.ExperimentSelectionController;
            app.BatchExperimentSelectionEditorPresenter = ...
                context.ExperimentSelectionPresenter;
            app.ChildAppHost = context.ChildAppHost;
            app.PerturbateEffluxCheckBox.Text = ...
                'Perturbate efflux or growth rate (mu)';
            app.EffluxperturbationTab.Title = 'Flux perturbation';
            editor = context.Editor;
            app.IsReadOnly = editor.IsReadOnly;
            app.renderRunConfigViewModel(editor.Config);
            app.MSFragmentTableMetadata = editor.MSFragmentTable.Metadata;
            app.renderTableViewModel(app.MSTable, editor.MSFragmentTable);
            app.renderTableViewModel( ...
                app.GridReactionUITable, editor.GridReactionTable);
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
            app.wireActionButtons();
            app.renderReadOnlyState();

        end % initializeView

        function copySelectedTracerColumn(app)

            selection = app.LabelTable.Selection;

            if isempty(selection)
                return
            end

            column = selection(1, 2);
            selectedLabel = app.LabelTable.Data{selection(1, 1), column};
            tableData = app.LabelTable.Data;

            for row = 1:size(tableData, 1)
                tableData{row, column} = selectedLabel;
            end

            app.LabelTable.Data = tableData;

        end % copySelectedTracerColumn

        function addPatternRows(app)

            answer = inputdlg( ...
                'Enter the number of new patterns to add:', ...
                'Add New Patterns', [1, 50], {'1'});

            if isempty(answer)
                return
            end

            numberOfRows = str2double(answer{1});

            if ~isfinite(numberOfRows) || numberOfRows <= 0 || ...
                    numberOfRows ~= fix(numberOfRows)
                return
            end

            tableData = app.LabelTable.Data;
            newRows = strings(numberOfRows, width(tableData));
            tableData = [tableData; array2table( ...
                             newRows, VariableNames = app.LabelTable.ColumnName.')];
            app.LabelTable.Data = tableData;

        end % addPatternRows

        function renderRunConfigViewModel(app, viewModel)
            % RENDERRUNCONFIGVIEWMODEL Render typed configuration values.

            app.IterationSpinner.Value = viewModel.Iteration;
            app.AlgorithmDropDown.Value = viewModel.Algorithm;
            app.LargeScaleCheckBox.Value = viewModel.LargeScale;
            app.FluxLBEditField.Value = viewModel.FluxLowerBound;
            app.FluxUBEditField.Value = viewModel.FluxUpperBound;
            app.MaxFunctionEvaluationsEditField.Value = ...
                viewModel.FminconMaxFunctionEvaluations;
            app.MaxIterationsEditField.Value = ...
                viewModel.FminconMaxIterations;
            app.FunctionToleranceEditField.Value = ...
                viewModel.FminconFunctionTolerance;
            app.StepToleranceEditField.Value = ...
                viewModel.FminconStepTolerance;
            app.OptimalityToleranceEditField.Value = ...
                viewModel.FminconOptimalityTolerance;
            app.ConstraintToleranceEditField.Value = ...
                viewModel.FminconConstraintTolerance;
            app.FiniteDifferenceTypeDropDown.Value = ...
                viewModel.FminconFiniteDifferenceType;
            app.FiniteDifferenceStepSizeEditField.Value = ...
                viewModel.FminconFiniteDifferenceStepSize;
            app.SearchOptimalFiniteDifferenceStepSizeCheckBox.Value = ...
                viewModel.SearchOptimalFiniteDifferenceStepSize;
            app.MCLmaxEditField_2.Value = ...
                viewModel.FreeEffluxSeedSigmaMultiplier;
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
            app.CheckBox.Value = viewModel.GridParallelExecution;
            app.ThenumberofgridpointsEditField.Value = ...
                viewModel.GridPoints;
            app.GridintervalDeltaixiEditField.Value = viewModel.GridDelta;
            app.IterationtimesforgridsearchEditField.Value = ...
                viewModel.GridIterations;
            app.ParallelworkersEditField.Value = viewModel.GridWorkers;
            app.MinimumFLuxRangeEditField.Value = ...
                viewModel.GridMinimumFluxRange;
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
            app.CheckBox.Enable = ...
                app.onOff(state.GridExecutionModeEnabled);
            app.ParallelworkersEditField.Enable = ...
                app.onOff(state.GridWorkerCountEnabled);
            app.IterationtimesforgridsearchEditField.Enable = grid;
            app.MinimumFLuxRangeEditField.Enable = grid;
            app.ThresholdDropDown.Enable = grid;
            app.ThenumberofgridpointsEditField.Enable = ...
                app.onOff(state.GridPointsEnabled);
            app.GridintervalDeltaixiEditField.Enable = ...
                app.onOff(state.GridDeltaEnabled);
            app.GridReactionUITable.Enable = grid;
            app.renderGridReactionVisibility( ...
                state.GridReactionVisible);

            app.EffluxUITable.Enable = app.onOff(state.EffluxEnabled);
            app.LabelTable.Enable = app.onOff(state.SuggestionEnabled);
            instMFA = app.onOff(state.INSTMFATablesEnabled);
            app.INSTMFAPoolUITable.Enable = instMFA;
            app.INSTMFATimeCourseUITable.Enable = instMFA;
            app.renderMainTabVisibility( ...
                app.EffluxperturbationTab, state.EffluxEnabled);
            app.renderMainTabVisibility( ...
                app.TracersuggestionTab, state.SuggestionEnabled);
            app.renderMainTabVisibility( ...
                app.INSTMFATab, state.INSTMFATablesEnabled);
            app.renderReadOnlyState();

        end % renderControlState

        function renderReadOnlyState(app)

            if ~app.IsReadOnly
                return
            end

            components = findall(app.BatchconfigUIFigure);

            for componentIndex = 1:numel(components)
                component = components(componentIndex);

                if isprop(component, 'Enable')

                    try
                        component.Enable = 'off';
                    catch
                    end

                end

                if isprop(component, 'ColumnEditable') && ...
                        isprop(component, 'Data')

                    try
                        component.ColumnEditable = ...
                            app.readOnlyColumns(component.Data);
                    catch
                    end

                end

            end

            navigationButtons = [ ...
                app.GeneralCloseButton
                app.MSCloseButton
                app.OptimizationCloseButton
                app.EffluxCloseButton
                app.SuggestionCloseButton
                app.INSTMFACloseButton
                app.GeneralCancelButton
                app.MSCancelButton
                app.OptimizationCancelButton
                app.EffluxCancelButton
                app.SuggestionCancelButton
                app.INSTMFACancelButton];

            for buttonIndex = 1:numel(navigationButtons)
                navigationButtons(buttonIndex).Enable = 'on';
            end

        end % renderReadOnlyState

        function renderGridReactionVisibility(app, isVisible)

            if isVisible

                if isempty(app.GridreactionTab.Parent)
                    app.GridreactionTab.Parent = app.TabGroup2;
                end

                return
            end

            if isempty(app.GridreactionTab.Parent)
                return
            end

            if isequal(app.TabGroup2.SelectedTab, ...
                    app.GridreactionTab)
                app.TabGroup2.SelectedTab = app.GridsearchTab;
            end

            app.GridreactionTab.Parent = [];

        end % renderGridReactionVisibility

        function renderMainTabVisibility(app, tab, isVisible)

            if isVisible

                if isempty(tab.Parent)
                    tab.Parent = app.TabGroup;
                end

                return
            end

            if isempty(tab.Parent)
                return
            end

            if isequal(app.TabGroup.SelectedTab, tab)
                app.TabGroup.SelectedTab = app.GeneralTab;
            end

            tab.Parent = [];

        end % renderMainTabVisibility

        function value = onOff(~, enabled)

            if enabled
                value = 'on';
            else
                value = 'off';
            end

        end % onOff

        function enabledisableEffluxPertubation(app)

            isEnable = app.PerturbateEffluxCheckBox.Value;

            if isEnable && ~app.hasTableDefinition( ...
                    app.EffluxUITable.Data)
                viewModel = app.Presenter.presentEffluxTable(app.Session);
                app.renderTableViewModel(app.EffluxUITable, viewModel);
            end

            app.refreshControlState();

        end % enabledisableEffluxPertubation

        function enabledisableSuggestion(app)
            % ENABLEDISABLESUGGESTION Enable or disable suggestion-related UI components
            % based on the SuggestionCheckBox value

            isSuggestLabel = app.SuggestionCheckBox.Value;

            if isSuggestLabel && ~app.hasTableDefinition( ...
                    app.LabelTable.Data)
                viewModel = app.Presenter ...
                    .presentSuggestionTable(app.Session);
                app.renderTableViewModel(app.LabelTable, viewModel);
            end

            app.refreshControlState();

        end % enabledisableSuggestion

        function enabledisableINSTMFA(app, isINSTMFA)
            % ENABLEDISABLEINSTMFA Enable or disable INST-MFA-related UI components
            % based on the isINSTMFA flag

            tablesLoaded = app.hasTableDefinition( ...
                app.INSTMFAPoolUITable.Data) && ...
                app.hasTableDefinition( ...
                app.INSTMFATimeCourseUITable.Data);

            if isINSTMFA && ~tablesLoaded
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
                app.renderTableViewModel( ...
                    app.INSTMFAPoolUITable, poolTable);
                app.renderTableViewModel( ...
                    app.INSTMFATimeCourseUITable, timePointTable);
            end

            app.refreshControlState();

        end % enabledisableINSTMFA

        function editTimeCourse(app)
            % EDITTIMECOURSE Edit the time course table for INST-MFA

            outcome = app.BatchExperimentSelectionEditorController ...
                .prepareINSTMFA(app.Session);
            viewModel = app.BatchExperimentSelectionEditorPresenter ...
                .presentINSTMFAEditor(outcome);
            app.requestNotifications(viewModel.Notifications);

            if ~viewModel.IsAvailable
                return;
            end

            app.closeRunAddBatchApp();
            context = openmebius.presentation.batch ...
                .RunAddBatchContext(Editor = viewModel);
            app.RunAddBatchApp = RunAddBatch(context);
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

            app.ChildAppHost.attach( ...
                "RunAddBatch", ...
                runAddBatchApp, ...
                {"Applied", ...
                 @(source, event) app.forwardBatchExperimentSelection(source, event); ...
                 "Closed", ...
                 @(source, event) app.onRunAddBatchClosed(source, event)});

        end % attachRunAddBatchListeners

        function onRunAddBatchClosed(app, ~, ~)

            app.detachRunAddBatchListeners();
            app.RunAddBatchApp = [];

        end % onRunAddBatchClosed

        function closeRunAddBatchApp(app)

            app.ChildAppHost.close("RunAddBatch");
            app.RunAddBatchApp = [];

        end % closeRunAddBatchApp

        function detachRunAddBatchListeners(app)

            app.ChildAppHost.detach("RunAddBatch");

        end % detachRunAddBatchListeners

        function attachTracerConfigListeners(app, tracerConfigApp)

            app.ChildAppHost.attach( ...
                "TracerConfig", ...
                tracerConfigApp, ...
                {"Applied", ...
                 @(source, event) app.onTracerConfigurationApplied(source, event); ...
                 "Closed", ...
                 @(source, event) app.onTracerConfigurationClosed(source, event)});

        end % attachTracerConfigListeners

        function detachTracerConfigListeners(app)

            app.ChildAppHost.detach("TracerConfig");

        end % detachTracerConfigListeners

        function closeTracerConfigApp(app)

            app.ChildAppHost.close("TracerConfig");
            app.TracerConfigApp = [];

        end % closeTracerConfigApp

        function openTracerConfiguration(app, position)

            outcome = app.Controller.loadTracerConfiguration( ...
                app.Session, app.ExperimentEditController, position);
            viewModel = app.ExperimentPresenter ...
                .presentTracerConfigurationLoadOutcome(outcome);
            app.renderTracerConfigurationViewModel(viewModel);

            if ~viewModel.IsSuccessful
                return
            end

            app.closeTracerConfigApp();
            context = openmebius.presentation.experiment ...
                .TracerConfigContext( ...
                EditorTable = viewModel.EditorTable, ...
                Position = viewModel.Position);
            app.TracerConfigApp = TracerConfig(context);
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

            app.detachTracerConfigListeners();
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
            viewModel.FluxLowerBound = app.FluxLBEditField.Value;
            viewModel.FluxUpperBound = app.FluxUBEditField.Value;
            viewModel.FminconMaxFunctionEvaluations = ...
                app.MaxFunctionEvaluationsEditField.Value;
            viewModel.FminconMaxIterations = ...
                app.MaxIterationsEditField.Value;
            viewModel.FminconFunctionTolerance = ...
                app.FunctionToleranceEditField.Value;
            viewModel.FminconStepTolerance = ...
                app.StepToleranceEditField.Value;
            viewModel.FminconOptimalityTolerance = ...
                app.OptimalityToleranceEditField.Value;
            viewModel.FminconConstraintTolerance = ...
                app.ConstraintToleranceEditField.Value;
            viewModel.FminconFiniteDifferenceType = ...
                app.FiniteDifferenceTypeDropDown.Value;
            viewModel.FminconFiniteDifferenceStepSize = ...
                app.FiniteDifferenceStepSizeEditField.Value;
            viewModel.SearchOptimalFiniteDifferenceStepSize = ...
                app.SearchOptimalFiniteDifferenceStepSizeCheckBox.Value;
            viewModel.FreeEffluxSeedSigmaMultiplier = ...
                app.MCLmaxEditField_2.Value;
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
            viewModel.GridParallelExecution = app.CheckBox.Value;
            viewModel.GridPoints = ...
                app.ThenumberofgridpointsEditField.Value;
            viewModel.GridDelta = app.GridintervalDeltaixiEditField.Value;
            viewModel.GridIterations = ...
                app.IterationtimesforgridsearchEditField.Value;
            viewModel.GridWorkers = app.ParallelworkersEditField.Value;
            viewModel.GridMinimumFluxRange = ...
                app.MinimumFLuxRangeEditField.Value;
            viewModel.GridThreshold = app.ThresholdDropDown.Value;
            viewModel.IsINSTMFA = app.INSTMFACheckBox.Value;

            if istable(app.GridReactionUITable.Data)
                viewModel.GridReactionTable = ...
                    app.GridReactionUITable.Data;
            end

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
                              app.OptimizationRestoreDefaultButton
                              app.EffluxRestoreDefaultButton
                              app.SuggestionRestoreDefaultButton
                              app.INSTMFARestoreDefaultButton];
            closeButtons = [ ...
                                app.GeneralCloseButton
                            app.MSCloseButton
                            app.OptimizationCloseButton
                            app.EffluxCloseButton
                            app.SuggestionCloseButton
                            app.INSTMFACloseButton];
            cancelButtons = [ ...
                                 app.GeneralCancelButton
                             app.MSCancelButton
                             app.OptimizationCancelButton
                             app.EffluxCancelButton
                             app.SuggestionCancelButton
                             app.INSTMFACancelButton];

            for buttonIndex = 1:numel(restoreButtons)
                restoreButtons(buttonIndex).ButtonPushedFcn = ...
                    @(~, ~) app.restoreDefaultValues();
                closeButtons(buttonIndex).ButtonPushedFcn = ...
                    @(~, ~) app.applyCurrentSettings();
                cancelButtons(buttonIndex).ButtonPushedFcn = ...
                    @(~, ~) app.cancelChanges();
            end

        end % wireActionButtons

        function restoreDefaultValues(app)

            if app.IsReadOnly
                return
            end

            msData = app.MSTable.Data;
            effluxData = app.EffluxUITable.Data;
            gridReactionData = app.GridReactionUITable.Data;
            suggestionData = app.LabelTable.Data;
            instPoolData = app.INSTMFAPoolUITable.Data;
            instTimeCourseData = app.INSTMFATimeCourseUITable.Data;
            viewModel = app.Presenter.presentDefaults();
            app.renderRunConfigViewModel(viewModel);
            app.MSTable.Data = msData;

            app.enabledisableCIUI(app.CalcCICheckBox.Value);
            app.enabledisableSuggestion();

            app.GridReactionUITable.Data = gridReactionData;
            app.GridReactionUITable.ColumnEditable = ...
                [true, false, false];

            app.EffluxUITable.Data = effluxData;
            app.EffluxUITable.Enable = 'off';
            app.EffluxUITable.ColumnEditable = ...
                app.readOnlyColumns(effluxData);

            app.LabelTable.Data = suggestionData;

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

            if app.IsReadOnly
                app.closeConfiguration();
                return
            end

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
                app.closeConfiguration();
            end

        end % applyCurrentSettings

        function cancelChanges(app)

            app.closeConfiguration();

        end % cancelChanges

        function closeConfiguration(app)

            if ~isempty(app.ChildAppHost) && isvalid(app.ChildAppHost)
                app.ChildAppHost.closeAll();
            end

            notify(app, "Closed");
            delete(app);

        end % closeConfiguration

        function loaded = hasTableDefinition(~, data)

            loaded = istable(data) && width(data) > 0;

        end % hasTableDefinition

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
        function startupFcn(app, context)

            app.initializeView(context);
        end

        % Close request function: BatchconfigUIFigure
        function BatchconfigUIFigureCloseRequest(app, event)

            app.cancelChanges();
        end

        % Callback function
        function GeneralApplyButtonPushed(app, event)

            app.applyCurrentSettings();
        end

        % Button pushed function: GeneralCloseButton
        function GeneralCloseButtonPushed2(app, event)

            app.applyCurrentSettings();
        end

        % Button pushed function: GeneralCancelButton
        function GeneralCancelButtonPushed(app, event)

            app.cancelChanges();
        end

        % Callback function
        function MSApplyButtonPushed(app, event)

            app.applyCurrentSettings();
        end

        % Button pushed function: MSCloseButton
        function MSCloseButtonPushed(app, event)

            app.applyCurrentSettings();
        end

        % Button pushed function: MSCancelButton
        function MSCancelButtonPushed(app, event)

            app.cancelChanges();
        end

        % Value changed function: PerturbateEffluxCheckBox
        function PerturbateEffluxCheckBoxValueChanged(app, event)

            app.enabledisableEffluxPertubation()

        end

        % Callback function
        function EffluxApplyButtonPushed(app, event)

            app.applyCurrentSettings();
        end

        % Callback function
        function EffluxApplyAllButtonPushed(app, event)

            app.applyCurrentSettings();
        end

        % Button pushed function: EffluxCancelButton
        function EffluxCancelButtonPushed(app, event)

            app.cancelChanges();
        end

        % Callback function
        function SuggestionApplyButtonPushed(app, event)

            app.applyCurrentSettings();
        end

        % Button pushed function: SuggestionCancelButton
        function SuggestionCancelButtonPushed(app, event)

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

        % Value changed function: CheckBox
        function CheckBoxValueChanged(app, event)

            app.refreshControlState();

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

            if app.SuggestionCheckBox.Value
                app.CalcCICheckBox.Value = true;
                app.enabledisableCIUI(app.CalcCICheckBox.Value);
            end

            app.enabledisableSuggestion();
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

            app.addPatternRows();
        end

        % Menu selected function: CopythistracerforallentriesMenu
        function CopythistracerforallentriesMenuSelected(app, event)

            app.copySelectedTracerColumn();
        end

        % Key press function: BatchconfigUIFigure
        function BatchconfigUIFigureKeyPress(app, event)

            key = event.Key;

            % Esc
            if strcmp(key, 'escape')
                app.cancelChanges();
            end
        end

        % Callback function
        function INSTMFAApplyButtonPushed(app, event)

            app.applyCurrentSettings();
        end

        % Callback function
        function INSTMFAReloadButtonPushed(app, event)

            app.restoreDefaultValues();
        end

        % Button pushed function: INSTMFACancelButton
        function INSTMFACancelButtonPushed(app, event)

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
            app.GridLayout8.RowHeight = ...
                {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', ...
                 'fit', 'fit', '1x'};
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

            % Create GridLayout12_6
            app.GridLayout12_6 = uigridlayout(app.GridLayout8);
            app.GridLayout12_6.ColumnWidth = {'7x', '3x'};
            app.GridLayout12_6.RowHeight = {'1x'};
            app.GridLayout12_6.Padding = [0 0 0 0];
            app.GridLayout12_6.Layout.Row = 2;
            app.GridLayout12_6.Layout.Column = 1;

            % Create ParallelworkersEditFieldLabel
            app.ParallelworkersEditFieldLabel = uilabel( ...
                app.GridLayout12_6);
            app.ParallelworkersEditFieldLabel.Layout.Row = 1;
            app.ParallelworkersEditFieldLabel.Layout.Column = 1;
            app.ParallelworkersEditFieldLabel.Text = 'Parallel workers';

            % Create ParallelworkersEditField
            app.ParallelworkersEditField = uieditfield( ...
                app.GridLayout12_6, 'numeric');
            app.ParallelworkersEditField.Limits = [1 Inf];
            app.ParallelworkersEditField.RoundFractionalValues = 'on';
            app.ParallelworkersEditField.Layout.Row = 1;
            app.ParallelworkersEditField.Layout.Column = 2;
            app.ParallelworkersEditField.Value = 58;

            % Create SuggestionCheckBox
            app.SuggestionCheckBox = uicheckbox(app.GridLayout8);
            app.SuggestionCheckBox.ValueChangedFcn = createCallbackFcn(app, @SuggestionCheckBoxValueChanged, true);
            app.SuggestionCheckBox.Text = 'Suggest label tracer to increase accuracy';
            app.SuggestionCheckBox.Layout.Row = 3;
            app.SuggestionCheckBox.Layout.Column = 1;

            % Create PerturbateEffluxCheckBox
            app.PerturbateEffluxCheckBox = uicheckbox(app.GridLayout8);
            app.PerturbateEffluxCheckBox.ValueChangedFcn = createCallbackFcn(app, @PerturbateEffluxCheckBoxValueChanged, true);
            app.PerturbateEffluxCheckBox.Text = 'Perturbate efflux';
            app.PerturbateEffluxCheckBox.Layout.Row = 4;
            app.PerturbateEffluxCheckBox.Layout.Column = 1;

            % Create CalcCICheckBox
            app.CalcCICheckBox = uicheckbox(app.GridLayout8);
            app.CalcCICheckBox.ValueChangedFcn = createCallbackFcn(app, @CalcCICheckBoxValueChanged, true);
            app.CalcCICheckBox.Text = 'Calculate confidence intervals of fluxes';
            app.CalcCICheckBox.Layout.Row = 6;
            app.CalcCICheckBox.Layout.Column = 1;

            % Create GridLayoutAlgorithm_2
            app.GridLayoutAlgorithm_2 = uigridlayout(app.GridLayout8);
            app.GridLayoutAlgorithm_2.ColumnWidth = {'6x', '4x'};
            app.GridLayoutAlgorithm_2.RowHeight = {'1x'};
            app.GridLayoutAlgorithm_2.Padding = [0 0 0 0];
            app.GridLayoutAlgorithm_2.Layout.Row = 7;
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
            app.DeleteResultButton.Layout.Row = 8;
            app.DeleteResultButton.Layout.Column = 1;
            app.DeleteResultButton.Value = true;

            % Create INSTMFACheckBox
            app.INSTMFACheckBox = uicheckbox(app.GridLayout8);
            app.INSTMFACheckBox.ValueChangedFcn = createCallbackFcn(app, @INSTMFACheckBoxValueChanged, true);
            app.INSTMFACheckBox.Text = 'Instrationaly-MFA instead of parallel labeling';
            app.INSTMFACheckBox.Layout.Row = 5;
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
            app.GridLayout11.RowHeight = ...
                {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', '1x'};
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
            app.GridLayout12.Layout.Row = 3;
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
            app.GridLayout12_2.Layout.Row = 4;
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
            app.GridLayout12_3.Layout.Row = 5;
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
            app.GridLayout12_4.Layout.Row = 7;
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

            % Create CheckBox
            app.CheckBox = uicheckbox(app.GridLayout11);
            app.CheckBox.ValueChangedFcn = createCallbackFcn( ...
                app, @CheckBoxValueChanged, true);
            app.CheckBox.Text = 'Execute grid search in parallel';
            app.CheckBox.Layout.Row = 2;
            app.CheckBox.Layout.Column = 1;
            app.CheckBox.Value = true;

            % Create GridLayout12_5
            app.GridLayout12_5 = uigridlayout(app.GridLayout11);
            app.GridLayout12_5.ColumnWidth = {'7x', '3x'};
            app.GridLayout12_5.RowHeight = {'1x'};
            app.GridLayout12_5.Padding = [0 0 0 0];
            app.GridLayout12_5.Layout.Row = 6;
            app.GridLayout12_5.Layout.Column = 1;

            % Create MinimumfluxrangeEditFieldLabel
            app.MinimumfluxrangeEditFieldLabel = uilabel(app.GridLayout12_5);
            app.MinimumfluxrangeEditFieldLabel.Layout.Row = 1;
            app.MinimumfluxrangeEditFieldLabel.Layout.Column = 1;
            app.MinimumfluxrangeEditFieldLabel.Text = 'Minimum flux range';

            % Create MinimumFLuxRangeEditField
            app.MinimumFLuxRangeEditField = uieditfield(app.GridLayout12_5, 'numeric');
            app.MinimumFLuxRangeEditField.Limits = [0 Inf];
            app.MinimumFLuxRangeEditField.Layout.Row = 1;
            app.MinimumFLuxRangeEditField.Layout.Column = 2;
            app.MinimumFLuxRangeEditField.Value = 1e-06;

            % Create GridreactionTab
            app.GridreactionTab = uitab(app.TabGroup2);
            app.GridreactionTab.Title = 'Grid reaction';

            % Create GridLayout23
            app.GridLayout23 = uigridlayout(app.GridreactionTab);
            app.GridLayout23.ColumnWidth = {'1x'};
            app.GridLayout23.RowHeight = {'1x'};
            app.GridLayout23.Padding = [5 5 5 5];

            % Create GridReactionUITable
            app.GridReactionUITable = uitable(app.GridLayout23);
            app.GridReactionUITable.ColumnName = '';
            app.GridReactionUITable.RowName = {};
            app.GridReactionUITable.Layout.Row = 1;
            app.GridReactionUITable.Layout.Column = 1;

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

            % Create GeneralCloseButton
            app.GeneralCloseButton = uibutton(app.GridLayout7_2, 'push');
            app.GeneralCloseButton.ButtonPushedFcn = createCallbackFcn(app, @GeneralCloseButtonPushed2, true);
            app.GeneralCloseButton.Layout.Row = 1;
            app.GeneralCloseButton.Layout.Column = 4;
            app.GeneralCloseButton.Text = 'Close';

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

            % Create MSCloseButton
            app.MSCloseButton = uibutton(app.GridLayout7, 'push');
            app.MSCloseButton.ButtonPushedFcn = createCallbackFcn(app, @MSCloseButtonPushed, true);
            app.MSCloseButton.Layout.Row = 1;
            app.MSCloseButton.Layout.Column = 4;
            app.MSCloseButton.Text = 'Close';

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

            % Create OptimizationTab
            app.OptimizationTab = uitab(app.TabGroup);
            app.OptimizationTab.Title = 'Optimization';

            % Create GridLayout13_3
            app.GridLayout13_3 = uigridlayout(app.OptimizationTab);
            app.GridLayout13_3.ColumnWidth = {'1x'};
            app.GridLayout13_3.RowHeight = {'1x', 'fit'};

            % Create GridLayout15_3
            app.GridLayout15_3 = uigridlayout(app.GridLayout13_3);
            app.GridLayout15_3.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout15_3.RowHeight = {'1x'};
            app.GridLayout15_3.Padding = [0 0 0 0];
            app.GridLayout15_3.Layout.Row = 2;
            app.GridLayout15_3.Layout.Column = 1;

            % Create OptimizationCancelButton
            app.OptimizationCancelButton = uibutton(app.GridLayout15_3, 'push');
            app.OptimizationCancelButton.Layout.Row = 1;
            app.OptimizationCancelButton.Layout.Column = 5;
            app.OptimizationCancelButton.Text = 'Cancel';

            % Create OptimizationCloseButton
            app.OptimizationCloseButton = uibutton(app.GridLayout15_3, 'push');
            app.OptimizationCloseButton.Layout.Row = 1;
            app.OptimizationCloseButton.Layout.Column = 4;
            app.OptimizationCloseButton.Text = 'Close';

            % Create OptimizationRestoreDefaultButton
            app.OptimizationRestoreDefaultButton = uibutton(app.GridLayout15_3, 'push');
            app.OptimizationRestoreDefaultButton.Layout.Row = 1;
            app.OptimizationRestoreDefaultButton.Layout.Column = 3;
            app.OptimizationRestoreDefaultButton.Text = 'Restore default';

            % Create GridLayout22_2
            app.GridLayout22_2 = uigridlayout(app.GridLayout13_3);
            app.GridLayout22_2.RowHeight = {'1x'};
            app.GridLayout22_2.Padding = [0 0 0 0];
            app.GridLayout22_2.Layout.Row = 1;
            app.GridLayout22_2.Layout.Column = 1;

            % Create GridLayout24
            app.GridLayout24 = uigridlayout(app.GridLayout22_2);
            app.GridLayout24.ColumnWidth = {'1x'};
            app.GridLayout24.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};
            app.GridLayout24.Padding = [0 0 0 0];
            app.GridLayout24.Layout.Row = 1;
            app.GridLayout24.Layout.Column = 1;

            % Create GridLayout25
            app.GridLayout25 = uigridlayout(app.GridLayout24);
            app.GridLayout25.ColumnWidth = {'6x', '4x'};
            app.GridLayout25.RowHeight = {'1x'};
            app.GridLayout25.Padding = [0 0 0 0];
            app.GridLayout25.Layout.Row = 1;
            app.GridLayout25.Layout.Column = 1;

            % Create DropDownLabel
            app.DropDownLabel = uilabel(app.GridLayout25);
            app.DropDownLabel.Layout.Row = 1;
            app.DropDownLabel.Layout.Column = 1;
            app.DropDownLabel.Text = 'Calculation algorithm';

            % Create AlgorithmDropDown
            app.AlgorithmDropDown = uidropdown(app.GridLayout25);
            app.AlgorithmDropDown.Items = {'IPMs', 'SQP'};
            app.AlgorithmDropDown.Layout.Row = 1;
            app.AlgorithmDropDown.Layout.Column = 2;
            app.AlgorithmDropDown.Value = 'SQP';

            % Create LargeScaleCheckBox
            app.LargeScaleCheckBox = uicheckbox(app.GridLayout24);
            app.LargeScaleCheckBox.Text = 'Large scale problem';
            app.LargeScaleCheckBox.Layout.Row = 2;
            app.LargeScaleCheckBox.Layout.Column = 1;

            % Create GridLayout10_9
            app.GridLayout10_9 = uigridlayout(app.GridLayout24);
            app.GridLayout10_9.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_9.RowHeight = {'1x'};
            app.GridLayout10_9.Padding = [0 0 0 0];
            app.GridLayout10_9.Layout.Row = 3;
            app.GridLayout10_9.Layout.Column = 1;

            % Create FluxUBEditFieldLabel
            app.FluxUBEditFieldLabel = uilabel(app.GridLayout10_9);
            app.FluxUBEditFieldLabel.Layout.Row = 1;
            app.FluxUBEditFieldLabel.Layout.Column = 1;
            app.FluxUBEditFieldLabel.Text = 'Flux upperbound for FVA';

            % Create FluxUBEditField
            app.FluxUBEditField = uieditfield(app.GridLayout10_9, 'numeric');
            app.FluxUBEditField.Limits = [0 Inf];
            app.FluxUBEditField.Layout.Row = 1;
            app.FluxUBEditField.Layout.Column = 2;
            app.FluxUBEditField.Value = 1000;

            % Create GridLayout10_10
            app.GridLayout10_10 = uigridlayout(app.GridLayout24);
            app.GridLayout10_10.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_10.RowHeight = {'1x'};
            app.GridLayout10_10.Padding = [0 0 0 0];
            app.GridLayout10_10.Layout.Row = 4;
            app.GridLayout10_10.Layout.Column = 1;

            % Create FluxUBEditFieldLabel_2
            app.FluxUBEditFieldLabel_2 = uilabel(app.GridLayout10_10);
            app.FluxUBEditFieldLabel_2.Layout.Row = 1;
            app.FluxUBEditFieldLabel_2.Layout.Column = 1;
            app.FluxUBEditFieldLabel_2.Text = 'Flux lowerbound for FVA';

            % Create FluxLBEditField
            app.FluxLBEditField = uieditfield(app.GridLayout10_10, 'numeric');
            app.FluxLBEditField.Limits = [-Inf 0];
            app.FluxLBEditField.Layout.Row = 1;
            app.FluxLBEditField.Layout.Column = 2;
            app.FluxLBEditField.Value = -1000;

            % Create GridLayout10_11
            app.GridLayout10_11 = uigridlayout(app.GridLayout24);
            app.GridLayout10_11.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_11.RowHeight = {'1x'};
            app.GridLayout10_11.Padding = [0 0 0 0];
            app.GridLayout10_11.Layout.Row = 5;
            app.GridLayout10_11.Layout.Column = 1;

            % Create FluxUBEditFieldLabel_3
            app.FluxUBEditFieldLabel_3 = uilabel(app.GridLayout10_11);
            app.FluxUBEditFieldLabel_3.Layout.Row = 1;
            app.FluxUBEditFieldLabel_3.Layout.Column = 1;
            app.FluxUBEditFieldLabel_3.Text = 'MaxFunctionEvaluations';

            % Create MaxFunctionEvaluationsEditField
            app.MaxFunctionEvaluationsEditField = uieditfield(app.GridLayout10_11, 'numeric');
            app.MaxFunctionEvaluationsEditField.Limits = [1 Inf];
            app.MaxFunctionEvaluationsEditField.Layout.Row = 1;
            app.MaxFunctionEvaluationsEditField.Layout.Column = 2;
            app.MaxFunctionEvaluationsEditField.Value = 3000;

            % Create GridLayout10_12
            app.GridLayout10_12 = uigridlayout(app.GridLayout24);
            app.GridLayout10_12.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_12.RowHeight = {'1x'};
            app.GridLayout10_12.Padding = [0 0 0 0];
            app.GridLayout10_12.Layout.Row = 6;
            app.GridLayout10_12.Layout.Column = 1;

            % Create FluxUBEditFieldLabel_4
            app.FluxUBEditFieldLabel_4 = uilabel(app.GridLayout10_12);
            app.FluxUBEditFieldLabel_4.Layout.Row = 1;
            app.FluxUBEditFieldLabel_4.Layout.Column = 1;
            app.FluxUBEditFieldLabel_4.Text = 'MaxIterations';

            % Create MaxIterationsEditField
            app.MaxIterationsEditField = uieditfield(app.GridLayout10_12, 'numeric');
            app.MaxIterationsEditField.Limits = [1 Inf];
            app.MaxIterationsEditField.Layout.Row = 1;
            app.MaxIterationsEditField.Layout.Column = 2;
            app.MaxIterationsEditField.Value = 1500;

            % Create GridLayout10_13
            app.GridLayout10_13 = uigridlayout(app.GridLayout24);
            app.GridLayout10_13.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_13.RowHeight = {'1x'};
            app.GridLayout10_13.Padding = [0 0 0 0];
            app.GridLayout10_13.Layout.Row = 7;
            app.GridLayout10_13.Layout.Column = 1;

            % Create FluxUBEditFieldLabel_5
            app.FluxUBEditFieldLabel_5 = uilabel(app.GridLayout10_13);
            app.FluxUBEditFieldLabel_5.Layout.Row = 1;
            app.FluxUBEditFieldLabel_5.Layout.Column = 1;
            app.FluxUBEditFieldLabel_5.Text = 'FunctionTolerance';

            % Create FunctionToleranceEditField
            app.FunctionToleranceEditField = uieditfield(app.GridLayout10_13, 'numeric');
            app.FunctionToleranceEditField.Limits = [0 Inf];
            app.FunctionToleranceEditField.Layout.Row = 1;
            app.FunctionToleranceEditField.Layout.Column = 2;
            app.FunctionToleranceEditField.Value = 1e-06;

            % Create GridLayout10_14
            app.GridLayout10_14 = uigridlayout(app.GridLayout24);
            app.GridLayout10_14.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_14.RowHeight = {'1x'};
            app.GridLayout10_14.Padding = [0 0 0 0];
            app.GridLayout10_14.Layout.Row = 8;
            app.GridLayout10_14.Layout.Column = 1;

            % Create FluxUBEditFieldLabel_6
            app.FluxUBEditFieldLabel_6 = uilabel(app.GridLayout10_14);
            app.FluxUBEditFieldLabel_6.Layout.Row = 1;
            app.FluxUBEditFieldLabel_6.Layout.Column = 1;
            app.FluxUBEditFieldLabel_6.Text = 'StepTolerance';

            % Create StepToleranceEditField
            app.StepToleranceEditField = uieditfield(app.GridLayout10_14, 'numeric');
            app.StepToleranceEditField.Limits = [0 Inf];
            app.StepToleranceEditField.Layout.Row = 1;
            app.StepToleranceEditField.Layout.Column = 2;
            app.StepToleranceEditField.Value = 1e-10;

            % Create GridLayout10_15
            app.GridLayout10_15 = uigridlayout(app.GridLayout24);
            app.GridLayout10_15.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_15.RowHeight = {'1x'};
            app.GridLayout10_15.Padding = [0 0 0 0];
            app.GridLayout10_15.Layout.Row = 9;
            app.GridLayout10_15.Layout.Column = 1;

            % Create FluxUBEditFieldLabel_7
            app.FluxUBEditFieldLabel_7 = uilabel(app.GridLayout10_15);
            app.FluxUBEditFieldLabel_7.Layout.Row = 1;
            app.FluxUBEditFieldLabel_7.Layout.Column = 1;
            app.FluxUBEditFieldLabel_7.Text = 'OptimalityTolerance';

            % Create OptimalityToleranceEditField
            app.OptimalityToleranceEditField = uieditfield(app.GridLayout10_15, 'numeric');
            app.OptimalityToleranceEditField.Limits = [0 Inf];
            app.OptimalityToleranceEditField.Layout.Row = 1;
            app.OptimalityToleranceEditField.Layout.Column = 2;
            app.OptimalityToleranceEditField.Value = 1e-08;

            % Create GridLayout10_16
            app.GridLayout10_16 = uigridlayout(app.GridLayout24);
            app.GridLayout10_16.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_16.RowHeight = {'1x'};
            app.GridLayout10_16.Padding = [0 0 0 0];
            app.GridLayout10_16.Layout.Row = 10;
            app.GridLayout10_16.Layout.Column = 1;

            % Create FluxUBEditFieldLabel_8
            app.FluxUBEditFieldLabel_8 = uilabel(app.GridLayout10_16);
            app.FluxUBEditFieldLabel_8.Layout.Row = 1;
            app.FluxUBEditFieldLabel_8.Layout.Column = 1;
            app.FluxUBEditFieldLabel_8.Text = 'ConstraintTolerance';

            % Create ConstraintToleranceEditField
            app.ConstraintToleranceEditField = uieditfield(app.GridLayout10_16, 'numeric');
            app.ConstraintToleranceEditField.Limits = [0 Inf];
            app.ConstraintToleranceEditField.Layout.Row = 1;
            app.ConstraintToleranceEditField.Layout.Column = 2;
            app.ConstraintToleranceEditField.Value = 1e-08;

            % Create GridLayout25_2
            app.GridLayout25_2 = uigridlayout(app.GridLayout24);
            app.GridLayout25_2.ColumnWidth = {'7x', '3x'};
            app.GridLayout25_2.RowHeight = {'1x'};
            app.GridLayout25_2.Padding = [0 0 0 0];
            app.GridLayout25_2.Layout.Row = 11;
            app.GridLayout25_2.Layout.Column = 1;

            % Create DropDownLabel_2
            app.DropDownLabel_2 = uilabel(app.GridLayout25_2);
            app.DropDownLabel_2.Layout.Row = 1;
            app.DropDownLabel_2.Layout.Column = 1;
            app.DropDownLabel_2.Text = 'FiniteDifferenceType';

            % Create FiniteDifferenceTypeDropDown
            app.FiniteDifferenceTypeDropDown = uidropdown(app.GridLayout25_2);
            app.FiniteDifferenceTypeDropDown.Items = {'Forward', 'Central'};
            app.FiniteDifferenceTypeDropDown.Layout.Row = 1;
            app.FiniteDifferenceTypeDropDown.Layout.Column = 2;
            app.FiniteDifferenceTypeDropDown.Value = 'Central';

            % Create GridLayout10_17
            app.GridLayout10_17 = uigridlayout(app.GridLayout24);
            app.GridLayout10_17.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_17.RowHeight = {'1x'};
            app.GridLayout10_17.Padding = [0 0 0 0];
            app.GridLayout10_17.Layout.Row = 12;
            app.GridLayout10_17.Layout.Column = 1;

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.GridLayout10_17);
            app.EditFieldLabel.Layout.Row = 1;
            app.EditFieldLabel.Layout.Column = 1;
            app.EditFieldLabel.Text = 'FiniteDifferenceStepSize';

            % Create FiniteDifferenceStepSizeEditField
            app.FiniteDifferenceStepSizeEditField = uieditfield(app.GridLayout10_17, 'numeric');
            app.FiniteDifferenceStepSizeEditField.Limits = [0 Inf];
            app.FiniteDifferenceStepSizeEditField.Layout.Row = 1;
            app.FiniteDifferenceStepSizeEditField.Layout.Column = 2;
            app.FiniteDifferenceStepSizeEditField.Value = 1e-06;

            % Create GridLayout26
            app.GridLayout26 = uigridlayout(app.GridLayout22_2);
            app.GridLayout26.ColumnWidth = {'1x'};
            app.GridLayout26.RowHeight = {'fit', 'fit', '1x', '1x', '1x'};
            app.GridLayout26.Padding = [0 0 0 0];
            app.GridLayout26.Layout.Row = 1;
            app.GridLayout26.Layout.Column = 2;

            % Create SearchOptimalFiniteDifferenceStepSizeCheckBox
            app.SearchOptimalFiniteDifferenceStepSizeCheckBox = uicheckbox(app.GridLayout26);
            app.SearchOptimalFiniteDifferenceStepSizeCheckBox.Text = 'Search optimal FiniteDifferenceStepSize';
            app.SearchOptimalFiniteDifferenceStepSizeCheckBox.Layout.Row = 1;
            app.SearchOptimalFiniteDifferenceStepSizeCheckBox.Layout.Column = 1;
            app.SearchOptimalFiniteDifferenceStepSizeCheckBox.Value = true;

            % Create GridLayout10_19
            app.GridLayout10_19 = uigridlayout(app.GridLayout26);
            app.GridLayout10_19.ColumnWidth = {'7x', '3x'};
            app.GridLayout10_19.RowHeight = {'1x'};
            app.GridLayout10_19.Padding = [0 0 0 0];
            app.GridLayout10_19.Layout.Row = 2;
            app.GridLayout10_19.Layout.Column = 1;

            % Create EditFieldLabel_2
            app.EditFieldLabel_2 = uilabel(app.GridLayout10_19);
            app.EditFieldLabel_2.Layout.Row = 1;
            app.EditFieldLabel_2.Layout.Column = 1;
            app.EditFieldLabel_2.Interpreter = 'html';
            app.EditFieldLabel_2.Text = 'Restrict efflux perturbation with <i>σ</i>:';

            % Create MCLmaxEditField_2
            app.MCLmaxEditField_2 = uieditfield(app.GridLayout10_19, 'numeric');
            app.MCLmaxEditField_2.Limits = [0 Inf];
            app.MCLmaxEditField_2.Layout.Row = 1;
            app.MCLmaxEditField_2.Layout.Column = 2;
            app.MCLmaxEditField_2.Value = 3;

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

            % Create EffluxCloseButton
            app.EffluxCloseButton = uibutton(app.GridLayout15, 'push');
            app.EffluxCloseButton.Layout.Row = 1;
            app.EffluxCloseButton.Layout.Column = 4;
            app.EffluxCloseButton.Text = 'Close';

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

            % Create SuggestionCloseButton
            app.SuggestionCloseButton = uibutton(app.GridLayout16, 'push');
            app.SuggestionCloseButton.Layout.Row = 1;
            app.SuggestionCloseButton.Layout.Column = 4;
            app.SuggestionCloseButton.Text = 'Close';

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

            % Create INSTMFACloseButton
            app.INSTMFACloseButton = uibutton(app.GridLayout15_2, 'push');
            app.INSTMFACloseButton.Layout.Row = 1;
            app.INSTMFACloseButton.Layout.Column = 4;
            app.INSTMFACloseButton.Text = 'Close';

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

            % Delete UIFigure when app is deleted
            delete(app.BatchconfigUIFigure)
        end
    end
end
