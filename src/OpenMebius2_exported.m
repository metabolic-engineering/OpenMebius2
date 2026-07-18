classdef OpenMebius2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        OpenMebius2UIFigure matlab.ui.Figure
        ApplicationMenu matlab.ui.container.Menu
        ReloadWindowMenu matlab.ui.container.Menu
        ClearcacheMenu matlab.ui.container.Menu
        PreferencesMenu matlab.ui.container.Menu
        ExperimentaldataMenu matlab.ui.container.Menu
        ExporttemplateExcelfileMenu matlab.ui.container.Menu
        FilesMenu matlab.ui.container.Menu
        ImportMSdatafromtextfilesMenu matlab.ui.container.Menu
        ModelMenu matlab.ui.container.Menu
        BatchMenu matlab.ui.container.Menu
        ViewMenu matlab.ui.container.Menu
        ViewReportMenu matlab.ui.container.Menu
        HelpMenu matlab.ui.container.Menu
        ViewlogsMenu matlab.ui.container.Menu
        OpenMebius2manualMenu matlab.ui.container.Menu
        AboutOpenMebius2Menu matlab.ui.container.Menu
        GridLayout matlab.ui.container.GridLayout
        GridLayout10 matlab.ui.container.GridLayout
        SubUIAxes matlab.ui.control.UIAxes
        MainUIAxes matlab.ui.control.UIAxes
        GridLayout9 matlab.ui.container.GridLayout
        LogTextArea matlab.ui.control.TextArea
        TabGroup matlab.ui.container.TabGroup
        StoichiometryTab matlab.ui.container.Tab
        GridLayout11 matlab.ui.container.GridLayout
        GridLayout12 matlab.ui.container.GridLayout
        ModelReloadButton matlab.ui.control.Button
        ModelEditButton matlab.ui.control.Button
        ModelSaveButton matlab.ui.control.Button
        ModelTable matlab.ui.control.Table
        MSTab matlab.ui.container.Tab
        GridLayout11_2 matlab.ui.container.GridLayout
        GridLayout13 matlab.ui.container.GridLayout
        AtomTable matlab.ui.control.Table
        MSTable matlab.ui.control.Table
        GridLayout12_2 matlab.ui.container.GridLayout
        MSReloadButton matlab.ui.control.Button
        MSEditButton matlab.ui.control.Button
        MSSaveButton matlab.ui.control.Button
        ExperimentTab matlab.ui.container.Tab
        GridLayout11_3 matlab.ui.container.GridLayout
        GridLayout13_2 matlab.ui.container.GridLayout
        ExpTable matlab.ui.control.Table
        GridLayout14 matlab.ui.container.GridLayout
        BiomassTable matlab.ui.control.Table
        GridLayout12_3 matlab.ui.container.GridLayout
        ExpCalculationButton matlab.ui.control.Button
        ExpImportButton matlab.ui.control.Button
        ExpReloadButton matlab.ui.control.Button
        ExpSaveButton matlab.ui.control.Button
        TracerTab matlab.ui.container.Tab
        GridLayout11_4 matlab.ui.container.GridLayout
        GridLayout15 matlab.ui.container.GridLayout
        LabelTable matlab.ui.control.Table
        UptakeTable matlab.ui.control.Table
        GridLayout12_4 matlab.ui.container.GridLayout
        TracerConfigButton matlab.ui.control.Button
        TracerReloadButton matlab.ui.control.Button
        TracerSaveButton matlab.ui.control.Button
        RunTab matlab.ui.container.Tab
        GridLayout11_5 matlab.ui.container.GridLayout
        GridLayout12_5 matlab.ui.container.GridLayout
        RunAutoButton matlab.ui.control.Button
        RunConfigButton matlab.ui.control.Button
        RunReloadButton matlab.ui.control.Button
        RunSaveButton matlab.ui.control.Button
        RunRunButton matlab.ui.control.Button
        RunTable matlab.ui.control.Table
        ResultTab matlab.ui.container.Tab
        GridLayout11_6 matlab.ui.container.GridLayout
        GridLayout15_2 matlab.ui.container.GridLayout
        ResultSubTable matlab.ui.control.Table
        ResultMainTable matlab.ui.control.Table
        GridLayout12_7 matlab.ui.container.GridLayout
        ResultDropDown matlab.ui.control.DropDown
        GridLayout12_6 matlab.ui.container.GridLayout
        ResultReportButton matlab.ui.control.Button
        ResultReloadButton matlab.ui.control.Button
        ResultSaveButton matlab.ui.control.Button
        GridLayout2 matlab.ui.container.GridLayout
        StatusHTML matlab.ui.control.HTML
        ProjectPanel matlab.ui.container.Panel
        GridLayout3 matlab.ui.container.GridLayout
        GridLayout16_2 matlab.ui.container.GridLayout
        TemplateModelBrowseButton matlab.ui.control.Button
        TemplateModelDirectoryDropDown matlab.ui.control.DropDown
        GridLayout16 matlab.ui.container.GridLayout
        ProjectBrowseButton matlab.ui.control.Button
        ProjectDirectoryDropDown matlab.ui.control.DropDown
        ProjectCreateButton matlab.ui.control.Button
        TemplateModelSaveButton matlab.ui.control.Button
        GridLayout5_3 matlab.ui.container.GridLayout
        TemplateModelLoadButton matlab.ui.control.Button
        ProjectLabel_2 matlab.ui.control.Label
        GridLayout5_2 matlab.ui.container.GridLayout
        ProjectSaveButton matlab.ui.control.Button
        GridLayout8 matlab.ui.container.GridLayout
        OrganismEditField matlab.ui.control.EditField
        OrganismEditFieldLabel matlab.ui.control.Label
        GridLayout7 matlab.ui.container.GridLayout
        ProjectAuthorEditField matlab.ui.control.EditField
        ProjectauthorEditFieldLabel matlab.ui.control.Label
        GridLayout5 matlab.ui.container.GridLayout
        ProjectLoadButton matlab.ui.control.Button
        GridLayout4 matlab.ui.container.GridLayout
        ProjectNameEditField matlab.ui.control.EditField
        ProjectnameEditFieldLabel matlab.ui.control.Label
        ProjectLabel matlab.ui.control.Label
        ContextMenu matlab.ui.container.ContextMenu
        AddLabelMenu matlab.ui.container.Menu
        RemoveLabelMenu matlab.ui.container.Menu
        ExperimentContextMenu matlab.ui.container.ContextMenu
        ViewMStableMenu matlab.ui.container.Menu
        ContextMenuRun matlab.ui.container.ContextMenu
        AddbatchMenu matlab.ui.container.Menu
        RemovethisbatchMenu matlab.ui.container.Menu
        ParallellabelingMenu matlab.ui.container.Menu
        ContextMenu2 matlab.ui.container.ContextMenu
        RelativetoMenu matlab.ui.container.Menu
        ContextMenuResultSelect matlab.ui.container.ContextMenu
        RangeplotMenu matlab.ui.container.Menu
        ViewsuggestionMenu matlab.ui.container.Menu
        ContextMenu3 matlab.ui.container.ContextMenu
        CopythistracerforallentriesMenu matlab.ui.container.Menu
    end

    properties (Access = public)

        calcStatus (4, 1) string {mustBeMember(calcStatus, ["init", "running", "finished", "error"])} = "init";
        typeSimulation (1, 1) string {mustBeMember(typeSimulation, ["MDV", "Flux", "Label"])} = "Flux";
        model;
        exp;
        batch;
        result;
        report;

        LabelConfigApp;
        TracerConfigApp;
        RunConfigApp;
        MSViewApp;
        ComparisonViewApp;
        RunAddBatchApp;
        ViewSuggestionApp;
        RangePlotFigure;
        LogApp;
        ProgressBar CustomProgressBar

        % Styles
        styleError = uistyle('BackgroundColor', '#FFAABB');
        styleErrorDark = uistyle('BackgroundColor', '#332225');

        % Styles for results
        styleIsPassed = uistyle('FontColor', '#009E73', 'FontWeight', 'bold');
        styleIsNotPassed = uistyle('FontColor', '#D55E00', 'FontWeight', 'bold');
        styleIsPassedDark = uistyle('FontColor', '#004834', 'FontWeight', 'bold');
        styleIsNotPassedDark = uistyle('FontColor', '#331700', 'FontWeight', 'bold');

        % Table styles
        styleSuccessIcon = uistyle('Icon', 'success', 'IconAlignment', 'rightmargin');
        styleWarningIcon = uistyle('Icon', 'warning', 'IconAlignment', 'rightmargin');
        styleErrorIcon = uistyle('Icon', 'error', 'IconAlignment', 'rightmargin');
        styleQuestionIcon = uistyle('Icon', 'question', 'IconAlignment', 'rightmargin');
        styleInfoIcon = uistyle('Icon', 'info', 'IconAlignment', 'rightmargin');

    end % properties (Access = public)

    %% Private properties

    properties (Access = private)

        % Directory
        directoryModel (1, 1) string
        directoryExp (1, 1) string
        directoryResult (1, 1) string

        % Editable array for locking and unlocking
        ModelTableEditable logical
        MSTableEditable logical
        AtomTableEditable logical
        BiomassTableEditable logical
        TracerTableEditable logical
        UptakeTableEditable logical
        RunTableEditable logical
        ResultMainTableEditable logical
        ResultSubTableEditable logical

    end % properties (Access=private)

    properties (Access = private)

        AppDependencies openmebius.bootstrap.MainAppDependencies
        Presenter openmebius.presentation.main.MainPresenter
        ProjectPresenter openmebius.presentation.project.ProjectPresenter
        ModelPresenter openmebius.presentation.model.ModelPresenter
        LabelConfigPresenter openmebius.presentation.model.LabelConfigPresenter
        BatchPresenter openmebius.presentation.batch.BatchPresenter
        RunConfigPresenter openmebius.presentation.batch.RunConfigPresenter
        BatchExperimentSelectionEditorPresenter openmebius.presentation.batch.BatchExperimentSelectionEditorPresenter
        ExperimentPresenter openmebius.presentation.experiment.ExperimentPresenter
        ResultPresenter openmebius.presentation.result.ResultPresenter
        ResultPlotPresenter openmebius.presentation.result.ResultPlotPresenter
        DialogService openmebius.presentation.dialog.AppDialogService
        ProjectOperationController openmebius.application.project.ProjectOperationController
        ProjectSession openmebius.domain.project.ProjectSession
        ModelOperationController openmebius.application.model.ModelOperationController
        LabelConfigurationLaunchController openmebius.application.model.LabelConfigurationLaunchController
        BatchOperationController openmebius.application.batch.BatchOperationController
        BatchConfigurationController openmebius.application.batch.BatchConfigurationController
        BatchConfigurationLaunchController openmebius.application.batch.BatchConfigurationLaunchController
        BatchExperimentSelectionEditorController openmebius.application.batch.BatchExperimentSelectionEditorController
        BatchRunController openmebius.application.batch.BatchRunController
        ResultOperationController openmebius.application.result.ResultOperationController
        ExperimentImportController openmebius.application.experiment.ExperimentImportController
        ExperimentCalculationController openmebius.application.experiment.ExperimentCalculationController
        ExperimentEditController openmebius.application.experiment.ExperimentEditController

        LegacyListeners event.listener = event.listener.empty(0, 1)

        SlackNotifier openmebius.infrastructure.notification.SlackWebhookNotifier

        PreferencesApp
        PreferencesListeners event.listener = event.listener.empty(0, 1)
        LabelConfigListeners event.listener = event.listener.empty(0, 1)
        TracerConfigListeners event.listener = event.listener.empty(0, 1)
        MSViewListeners event.listener = event.listener.empty(0, 1)
        ComparisonViewListeners event.listener = event.listener.empty(0, 1)
        RunConfigListeners event.listener = event.listener.empty(0, 1)
        RunAddBatchListeners event.listener = event.listener.empty(0, 1)

        MainInteractionSnapshot cell = {}

    end % properties (Access=private)

    methods (Access = public)

        %% Public check methods
        function isDark = isDarkTheme(app)
            bgColor = app.OpenMebius2UIFigure.Color;
            % The sum of RGB values is less than a certain threshold to determine if it is a dark theme
            brightness = sum(bgColor);
            isDark = brightness < 1.5; % The threshold can be adjusted empirically (1.5 to 1.8 is a guideline)
        end % function isDarkTheme

        function LogText(app, text)

            arguments
                app OpenMebius2
                text string
            end

            app.appendLogText(text);

        end % function LogText

        function LogTextDate(app, text, level)

            arguments
                app OpenMebius2
                text string
                level string
            end

            notification = ...
                openmebius.presentation.notification.Notification( ...
                text, ...
                level);

            app.showNotification(notification);

        end % function LogTextDate

        function saveHistory(app)

            projectHistory = app.ProjectDirectoryDropDown.Items;
            tempModelHistory = app.TemplateModelDirectoryDropDown.Items;

            system = System();
            directoryLog = system.getCacheDirectory();

            if isempty(directoryLog)
                return;
            end

            fileLog = fullfile(directoryLog, 'history.mat');

            if ~isfolder(directoryLog)
                mkdir(directoryLog);
            end

            save(fileLog, 'projectHistory', 'tempModelHistory');

        end % function saveHistory

        function clearHistory(app)

            app.ProjectDirectoryDropDown.Items = {};
            app.TemplateModelDirectoryDropDown.Items = {};
            app.saveHistory();

        end % function clearHistory

        %% Public update functions
        function updateStatus(app, section, status)
            % UPDATESTATUS Update the status table with the current status

            arguments
                app
                section string {mustBeMember(section, ["model", "experiment", "batch", "result"])}
                status string {mustBeMember(status, ["init", "running", "finished", "error"])}
            end

            [app.calcStatus, rows] = ...
                openmebius.presentation.status.StatusPresenter.update( ...
                app.calcStatus, ...
                section, ...
                status);

            initStatusTable(app, update = true, rows = rows);

        end % method updateStatus

        function updateBatchTable(app)

            loadBatchTable(app);
            app.refreshPresentation();

        end % function updateBatchTable

        %% Public test methods
        function testResultSubTableCellSelection(app)
            % TESTRESULTSUBTABLECELLSELECTION Test the cell selection in the ResultSubTable
            %
            % Trigger the event.

            selection = app.ResultSubTable.Selection;

            ResultSubTableCellSelection(app, selection);

        end % function testResultSubTableCellSelection

        function testResultMainTableCellSelection(app)
            % TESTRESULTMAINTABLECELLSELECTION Test the cell selection in the ResultMainTable
            %
            % Trigger the event.

            selection = app.ResultMainTable.Selection;

            ResultMainTableCellSelection(app, selection);

        end % function testResultMainTableCellSelection

    end % methods (Access = public)

    methods (Access = protected)

        %% Protected wrapper functions
        function [folder, isOK] = uiGetDirWrap(app, options)

            arguments
                app
                options.Parent = []
                options.Title (1, 1) string = "Select folder"
                options.StartPath (1, 1) string = string(pwd)
            end

            [folder, isOK] = app.DialogService.selectFolder( ...
                Title = options.Title, ...
                StartPath = options.StartPath);

        end % function uiGetDirWrap

        function [files, isOK] = uiGetFileWrap(app, options)

            arguments
                app
                options.Parent = []
                options.Filter = "*.*"
                options.Title (1, 1) string = "Select file"
                options.StartPath (1, 1) string = string(pwd)
                options.MultiSelect (1, 1) string {mustBeMember(options.MultiSelect, ["off", "on"])} = "off"
                options.Save (1, 1) logical = false
                options.DefaultName (1, 1) string = ""
            end

            [files, isOK] = app.DialogService.selectFile( ...
                Filter = options.Filter, ...
                Title = options.Title, ...
                StartPath = options.StartPath, ...
                MultiSelect = options.MultiSelect, ...
                Save = options.Save, ...
                DefaultName = options.DefaultName);

        end % function uiGetFileWrap

        function [answer, isOK] = uiInputDlgWrap(app, options)

            arguments
                app
                options.Prompt (1, :) string = "Input"
                options.Title (1, 1) string = "Input dialog"
                options.Default (1, :) string = ""
                options.Dims (1, 2) double = [1 50]
            end

            [answer, isOK] = app.DialogService.inputText( ...
                Prompt = options.Prompt, ...
                Title = options.Title, ...
                Default = options.Default, ...
                Dims = options.Dims);

        end % function uiInputDlgWrap

        function [answer, isOK] = uiConfirmWrap(app, message, title, options)

            arguments
                app
                message (1, 1) string
                title (1, 1) string = "Confirm"
                options.Options (1, :) string = ["OK", "Cancel"]
                options.DefaultOption (1, 1) string = "OK"
                options.CancelOption (1, 1) string = "Cancel"
                options.Icon (1, 1) string = "question"
            end

            [answer, isOK] = app.DialogService.confirm( ...
                message, ...
                title, ...
                Options = options.Options, ...
                DefaultOption = options.DefaultOption, ...
                CancelOption = options.CancelOption, ...
                Icon = options.Icon);

        end % function uiConfirmWrap

        function uiAlertWrap(app, message, options)

            arguments
                app
                message (1, 1) string
                options.Title (1, 1) string = "Message"
                options.Icon (1, 1) string = "info"
                options.Interpreter (1, 1) string = "none"
            end

            app.DialogService.alert( ...
                message, ...
                Title = options.Title, ...
                Icon = options.Icon, ...
                Interpreter = options.Interpreter);

        end % function uiAlertWrap

    end % methods (Access = protected)

    methods (Access = private)

        %% Private presentation adapter functions
        function applyApplicationDependencies(app, dependencies)

            arguments
                app
                dependencies (1, 1) openmebius.bootstrap ...
                    .MainAppDependencies
            end

            app.AppDependencies = dependencies;
            app.Presenter = dependencies.MainPresenter;
            app.ProjectPresenter = dependencies.ProjectPresenter;
            app.ModelPresenter = dependencies.ModelPresenter;
            app.LabelConfigPresenter = dependencies.LabelConfigPresenter;
            app.BatchPresenter = dependencies.BatchPresenter;
            app.RunConfigPresenter = dependencies.RunConfigPresenter;
            app.BatchExperimentSelectionEditorPresenter = ...
                dependencies.BatchExperimentSelectionEditorPresenter;
            app.ExperimentPresenter = dependencies.ExperimentPresenter;
            app.ResultPresenter = dependencies.ResultPresenter;
            app.ResultPlotPresenter = dependencies.ResultPlotPresenter;
            app.ProjectOperationController = ...
                dependencies.ProjectOperationController;
            app.ModelOperationController = ...
                dependencies.ModelOperationController;
            app.LabelConfigurationLaunchController = ...
                dependencies.LabelConfigurationLaunchController;
            app.BatchOperationController = ...
                dependencies.BatchOperationController;
            app.BatchConfigurationController = ...
                dependencies.BatchConfigurationController;
            app.BatchConfigurationLaunchController = ...
                dependencies.BatchConfigurationLaunchController;
            app.BatchExperimentSelectionEditorController = ...
                dependencies.BatchExperimentSelectionEditorController;
            app.BatchRunController = dependencies.BatchRunController;
            app.ResultOperationController = ...
                dependencies.ResultOperationController;
            app.ExperimentImportController = ...
                dependencies.ExperimentImportController;
            app.ExperimentCalculationController = ...
                dependencies.ExperimentCalculationController;
            app.ExperimentEditController = ...
                dependencies.ExperimentEditController;
            app.SlackNotifier = dependencies.SlackNotifier;

        end % applyApplicationDependencies

        function renderMainViewModel(app, viewModel)
            % RENDERMAINVIEWMODEL Render the main view model
            % renderMainViewModel(app, viewModel)
            %
            %  Input:
            %   viewModel: An object of class MainViewModel

            if isempty(viewModel)
                return
            end

            if isprop(viewModel, "UiState")
                app.renderUiState(viewModel.UiState);
                return
            end

            % For transitional versions where viewModel may be a struct.
            if isstruct(viewModel) && isfield(viewModel, "UiState")
                app.renderUiState(viewModel.UiState);
                return
            end

            error( ...
                "OpenMebius2:Presentation:InvalidViewModel", ...
            "MainViewModel must contain UiState.");

        end % method renderMainViewModel

        function renderProjectOperationViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            if viewModel.ModelStatus ~= ""
                app.updateStatus("model", viewModel.ModelStatus);
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

            if isempty(viewModel.Session)
                return
            end

            try
                app.applyProjectSession(viewModel.Session);
                app.ensureProjectDirectoryItem( ...
                    viewModel.Session.Paths.RootDirectory);

                if ~isempty(viewModel.Artifacts)
                    app.applyLegacyProjectArtifacts(viewModel.Artifacts);
                end

                switch viewModel.ArtifactMode
                    case "open"
                        app.renderLegacyProjectArtifacts();
                        app.refreshPresentation();

                    case "create"
                        app.renderCreatedProjectArtifacts();
                        app.refreshPresentation();
                end
            catch exception
                app.updateStatus("model", "error");

                if viewModel.ArtifactMode == "create"
                    title = "Project create failed";
                else
                    title = "Project load failed";
                end

                app.notifyException( ...
                    exception, ...
                    Title = title, ...
                    Alert = true);
            end

        end % renderProjectOperationViewModel

        function renderModelOperationViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            if viewModel.SectionStatus ~= ""
                app.updateStatus("model", viewModel.SectionStatus);
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

            try
                app.applyModelValidationStyles( ...
                    viewModel.ValidationStyles);

                for reportIndex = 1:numel(viewModel.ValidationReports)
                    app.showModelValidationReport( ...
                        viewModel.ValidationReports{reportIndex});
                end

                if ~isempty(viewModel.Result)
                    app.applyTemplateModelLoadResult(viewModel.Result);

                    pause(0.5)

                    app.loadEMUModel();
                    app.loadPathway();
                end

                if ~isempty(viewModel.CompletionNotification)
                    app.showNotification( ...
                        viewModel.CompletionNotification);
                end

                if viewModel.CompletionStatus ~= ""
                    app.updateStatus( ...
                        "model", ...
                        viewModel.CompletionStatus);
                end

                if viewModel.FinishEditCommit
                    app.finishPresentationEditCommit( ...
                        viewModel.EditCommitSucceeded);
                end
            catch exception
                if viewModel.FinishEditCommit
                    app.finishPresentationEditCommit(false);
                end

                app.updateStatus("model", "error");
                app.notifyException( ...
                    exception, ...
                    Title = viewModel.ErrorTitle, ...
                    Alert = true);
            end

        end % renderModelOperationViewModel

        function renderModelPathwayEditViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

            if ~isempty(viewModel.UpdatedModelTable)
                app.ModelTable.Data = viewModel.UpdatedModelTable;
                app.ModelTable.ColumnName = ...
                    viewModel.UpdatedModelTable.Properties.VariableNames;
                app.ModelTable.RowName = ...
                    viewModel.UpdatedModelTable.Properties.RowNames;
            end

            if ~isempty(viewModel.Pathway.Image)
                app.renderPathwayPlot(viewModel.Pathway);
            end

        end % renderModelPathwayEditViewModel

        function applyModelValidationStyles(app, styleRules)

            if isempty(styleRules)
                return
            end

            targets = string({styleRules.Target});

            if any(targets == "model")
                app.resetModelTableColorFormat();
            end

            if any(targets == "ms" | targets == "atom")
                app.resetMSTableColorFormat();
            end

            for ruleIndex = 1:numel(styleRules)
                rows = styleRules(ruleIndex).Rows;

                if isempty(rows)
                    continue
                end

                switch string(styleRules(ruleIndex).Target)
                    case "model"
                        target = app.ModelTable;

                    case "ms"
                        target = app.MSTable;

                    case "atom"
                        target = app.AtomTable;

                    otherwise
                        error( ...
                            "OpenMebius2:Model:InvalidStyleTarget", ...
                            "Unknown model style target: %s", ...
                            string(styleRules(ruleIndex).Target));
                end

                addStyle( ...
                    target, ...
                    app.styleError, ...
                    'row', ...
                    rows);
            end

        end % applyModelValidationStyles

        function renderLegacyProjectArtifacts(app)

            % -------------------------------------------------------------
            % Model UI
            % -------------------------------------------------------------
            app.updateStatus("model", "running");

            app.notifyInfo("Constructing EMU network...");

            loadEMUModel(app)

            loadPathway(app)

            app.notifyInfo("EMU network was successfully constructed.");
            app.updateStatus("model", "finished");

            % -------------------------------------------------------------
            % Experiment UI
            % -------------------------------------------------------------
            app.updateStatus("experiment", "running");

            loadExpData(app)

            app.updateStatus("experiment", "finished");

            % -------------------------------------------------------------
            % Batch UI
            % -------------------------------------------------------------
            app.updateStatus("batch", "running");

            loadBatchTable(app)

            app.updateStatus("batch", "finished");
            app.notifyInfo("Batch table loaded successfully.");

            % -------------------------------------------------------------
            % Result UI
            % -------------------------------------------------------------
            app.updateStatus("result", "running");

            loadResult(app)

            if isempty(app.ResultSubTable.Data)
                app.updateStatus("result", "init");
                app.notifyInfo("No result files found in the results directory.");
            else
                app.updateStatus("result", "finished");
                app.notifyInfo("Result files loaded successfully.");
            end

        end % method renderLegacyProjectArtifacts

        function renderCreatedProjectArtifacts(app)

            app.updateStatus("model", "running");

            app.notifyInfo("Constructing EMU network...");

            pause(0.5)

            loadEMUModel(app)

            loadPathway(app)

            app.updateStatus("model", "finished");
            app.notifyInfo("New project created and model loaded successfully.");

            app.updateStatus("experiment", "init");
            app.updateStatus("batch", "init");
            app.updateStatus("result", "init");

        end % method renderCreatedProjectArtifacts

        function renderBatchTable(app, viewModel)

            if isempty(viewModel)
                return
            end

            removeStyle(app.RunTable);

            app.RunTable.Data = viewModel.Data;

            if isempty(viewModel.Data)
                app.RunTable.ColumnName = [];
                app.RunTable.RowName = [];
                app.RunTable.ColumnEditable = false;
                return
            end

            app.RunTable.ColumnName = ...
                viewModel.Data.Properties.VariableNames;

            app.RunTable.RowName = ...
                viewModel.Data.Properties.RowNames;

            app.RunTable.ColumnEditable = ...
                viewModel.ColumnEditable;

            app.applyBatchStyleRules(viewModel.StyleRules);

        end % method renderBatchTable

        function renderBatchOperationViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            if ~isempty(viewModel.TableViewModel)
                app.renderBatchTable(viewModel.TableViewModel);
                app.refreshPresentation();
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

        end % renderBatchOperationViewModel

        function renderRunConfigLaunchViewModel(app, viewModel)

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

            if ~viewModel.IsAvailable
                return
            end

            app.closeRunConfigApp();
            context = openmebius.presentation.batch ...
                .RunConfigContext( ...
                    Session = viewModel.Session, ...
                    Presenter = app.RunConfigPresenter, ...
                    Editor = viewModel.Editor, ...
                    ConfigurationController = ...
                        app.BatchConfigurationController, ...
                    ExperimentEditController = ...
                        app.ExperimentEditController, ...
                    ExperimentPresenter = ...
                        app.ExperimentPresenter, ...
                    ExperimentSelectionController = ...
                        app.BatchExperimentSelectionEditorController, ...
                    ExperimentSelectionPresenter = ...
                        app.BatchExperimentSelectionEditorPresenter);
            app.RunConfigApp = RunConfig(context);
            app.attachRunConfigListeners(app.RunConfigApp);

        end % renderRunConfigLaunchViewModel

        function renderLabelConfigLaunchViewModel(app, viewModel)

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

            if ~viewModel.IsAvailable
                return
            end

            app.closeLabelConfigApp();
            context = openmebius.presentation.model ...
                .LabelConfigContext( ...
                    LabelTable = viewModel.LabelTable, ...
                    RatioTables = viewModel.RatioTables);
            app.LabelConfigApp = LabelConfig(context);
            app.attachLabelConfigListeners(app.LabelConfigApp);

        end % renderLabelConfigLaunchViewModel

        function renderBatchProgress(app, viewModel)

            if isempty(viewModel)
                return
            end

            app.ensureProgressBar();

            app.ProgressBar.setProgress( ...
                viewModel.Rate, ...
                viewModel.Message);

            drawnow limitrate

        end % method renderBatchProgress

        function renderBatchRunViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            if viewModel.SectionStatus ~= ""
                app.updateStatus("batch", viewModel.SectionStatus);
            end

            if ~isempty(viewModel.Notification)
                app.showNotification(viewModel.Notification);
            end

            if viewModel.CompletionStatus ~= ""
                app.notifySlackBatchCompleted( ...
                    viewModel.CompletionStatus, ...
                    ErrorMessage = viewModel.ErrorMessage, ...
                    DeltaTime = viewModel.ElapsedTime);
            end

        end % renderBatchRunViewModel

        function renderExperimentCalculationViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            app.updateStatus("experiment", viewModel.SectionStatus);

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

        end % renderExperimentCalculationViewModel

        function renderExperimentImportViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            if ~isempty(viewModel.Result)
                app.renderExperimentImportResult( ...
                    viewModel.Result, ...
                    LogMessages = false);
            end

            if viewModel.SectionStatus ~= ""
                app.updateStatus( ...
                    "experiment", ...
                    viewModel.SectionStatus);
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

        end % renderExperimentImportViewModel

        function renderExperimentEditViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            if ~isempty(viewModel.UpdatedTable)
                app.LabelTable.Data = viewModel.UpdatedTable;
            end

            if viewModel.SectionStatus ~= ""
                app.updateStatus( ...
                    "experiment", ...
                    viewModel.SectionStatus);
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

        end % renderExperimentEditViewModel

        function renderResultOperationViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            if ~isempty(viewModel.Report)
                app.report = viewModel.Report;
            end

            if ~isempty(viewModel.Suggestion)
                app.ViewSuggestionApp = ...
                    ViewSuggestion(viewModel.Suggestion);
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

        end % renderResultOperationViewModel

        function renderResultRelativeViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

            if viewModel.RelativeTo == ""
                return
            end

            app.loadMainResultTable( ...
                relative = true, ...
                relativeTo = viewModel.RelativeTo);

        end % renderResultRelativeViewModel

        function renderResultRangePlotViewModel(app, viewModel)

            if isempty(viewModel)
                return
            end

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

            if isempty(viewModel.UpperBounds) || ...
                    isempty(viewModel.LowerBounds)
                return
            end

            if app.isLoadedObject(app.RangePlotFigure)
                delete(app.RangePlotFigure);
            end

            rangeFigure = uifigure( ...
                'Name', 'Flux range plot', ...
                'Position', [120 80 1100 820]);
            app.RangePlotFigure = rangeFigure;
            layout = uigridlayout(rangeFigure, [1 1]);
            layout.Padding = [12 12 12 12];
            axes = uiaxes(layout);
            axes.Layout.Row = 1;
            axes.Layout.Column = 1;

            try
                RangePlot( ...
                    axes, ...
                    viewModel.UpperBounds, ...
                    viewModel.LowerBounds, ...
                    Bestfit = viewModel.BestFits, ...
                    BestfitStyle = "triangle", ...
                    FontSize = 10, ...
                    ReactionNames = viewModel.ReactionNames);
                title(axes, "Flux ranges");
                xlabel(axes, "Flux");
            catch exception
                delete(rangeFigure);
                app.RangePlotFigure = [];
                app.notifyException( ...
                    exception, ...
                    Title = "Range plot failed", ...
                    Alert = true);
            end

        end % renderResultRangePlotViewModel

        function renderResultMainTable(app, viewModel)

            if isempty(viewModel)
                return
            end

            removeStyle(app.ResultMainTable);

            app.ResultMainTable.Data = viewModel.Data;

            try
                app.ResultMainTable.UserData = struct( ...
                    "RawData", viewModel.RawData);
            catch
                % If UserData is unavailable for some MATLAB release,
                % updateResultPlot will fall back to ResultMainTable.Data.
            end

            if isempty(viewModel.Data)
                app.ResultMainTable.ColumnName = [];
                app.ResultMainTable.RowName = [];
                app.ResultMainTable.ColumnEditable = false;
                return
            end

            app.ResultMainTable.ColumnName = ...
                viewModel.Data.Properties.VariableNames;

            app.ResultMainTable.RowName = ...
                viewModel.Data.Properties.RowNames;

            app.ResultMainTable.ColumnEditable = ...
                viewModel.ColumnEditable;

            app.applyResultStyleRules( ...
                app.ResultMainTable, ...
                viewModel.StyleRules);

        end % method renderResultMainTable

        function renderResultSubTable(app, viewModel)

            if isempty(viewModel)
                return
            end

            removeStyle(app.ResultSubTable);

            app.ResultSubTable.Data = viewModel.Data;

            if isempty(viewModel.Data)
                app.ResultSubTable.ColumnName = [];
                app.ResultSubTable.RowName = [];
                app.ResultSubTable.ColumnEditable = false;
                return
            end

            app.ResultSubTable.ColumnName = ...
                viewModel.Data.Properties.VariableNames;

            app.ResultSubTable.RowName = ...
                viewModel.Data.Properties.RowNames;

            app.ResultSubTable.ColumnEditable = ...
                viewModel.ColumnEditable;

            app.applyResultStyleRules( ...
                app.ResultSubTable, ...
                viewModel.StyleRules);

        end % method renderResultSubTable

        function renderResultPlot(app, viewModel)

            if isempty(viewModel)
                return
            end

            if ~isempty(viewModel.Notification)
                app.showNotification(viewModel.Notification);
            end

            switch viewModel.Kind

                case openmebius.presentation.result.ResultPlotKind.None
                    app.clearResultPlots();

                case openmebius.presentation.result.ResultPlotKind.OverviewFlux
                    app.renderOverviewResultPlot(viewModel);

                otherwise
                    app.clearResultPlots();
            end

        end % method renderResultPlot

        function renderOverviewResultPlot(app, viewModel)

            mainPlot = viewModel.MainPlot;
            subPlot = viewModel.SubPlot;

            app.MainUIAxes.Visible = 'on';
            app.SubUIAxes.Visible = 'on';

            if isfield(mainPlot, "Kind") && mainPlot.Kind == "pathway"
                app.renderPathwayPlot(mainPlot.Pathway);

            else
                cla(app.MainUIAxes);
            end

            if isfield(subPlot, "Kind") && ...
                    subPlot.Kind == "monte-carlo-ci"
                app.renderMonteCarloConfidenceInterval(subPlot);

            else
                cla(app.SubUIAxes);
            end

        end % method renderOverviewResultPlot

        function renderPathwayPlot(app, viewModel)

            axes = app.MainUIAxes;
            cla(axes);

            if isempty(viewModel) || isempty(viewModel.Image)
                return
            end

            pathwayImage = viewModel.Image;

            if viewModel.IsDarkTheme
                pathwayImage = app.convertPathwayImageForDarkTheme( ...
                    pathwayImage);
            end

            pathwayGraphic = image( ...
                axes, pathwayImage, 'HitTest', 'off');
            imageRatio = size(pathwayImage, 1) / ...
                size(pathwayImage, 2);
            axes.DataAspectRatio = [1 imageRatio 1];
            axes.Visible = 'off';
            axis(axes, 'image');
            title(axes, 'Metabolic Pathway');
            xlabel(axes, '');
            ylabel(axes, '');
            axes.HitTest = 'on';
            axes.PickableParts = 'all';
            axes.ContextMenu = app.ContextMenu;
            pathwayGraphic.ContextMenu = app.ContextMenu;

            if viewModel.IsDarkTheme
                labelColor = '#FFFFFF';
            else
                labelColor = '#000000';
            end

            for labelIndex = 1:numel(viewModel.Labels)

                if ~isfinite(viewModel.X(labelIndex)) || ...
                        ~isfinite(viewModel.Y(labelIndex))
                    continue
                end

                if viewModel.Highlight(labelIndex)
                    color = '#009E73';
                    weight = 'bold';
                else
                    color = labelColor;
                    weight = 'normal';
                end

                text( ...
                    axes, ...
                    viewModel.X(labelIndex), ...
                    viewModel.Y(labelIndex), ...
                    viewModel.Labels(labelIndex), ...
                    'Color', color, ...
                    'FontSize', 14, ...
                    'FontWeight', weight);
            end

        end % renderPathwayPlot

        function imageOut = convertPathwayImageForDarkTheme(~, imageIn)

            if isa(imageIn, 'uint8')
                imageIn = im2double(imageIn);
            end

            if size(imageIn, 3) == 1
                imageOut = 1 - imageIn;
                return
            end

            if size(imageIn, 3) == 3
                hsvImage = rgb2hsv(imageIn);
                hsvImage(:, :, 3) = 0.9 - hsvImage(:, :, 3);
                hsvImage(:, :, 3) = max( ...
                    0.2, min(hsvImage(:, :, 3), 0.95));
                imageOut = hsv2rgb(hsvImage);
                return
            end

            imageOut = imageIn;

        end % convertPathwayImageForDarkTheme

        function renderMonteCarloConfidenceInterval(app, plotData)

            lowerBounds = double(plotData.LowerBounds(:)');
            upperBounds = double(plotData.UpperBounds(:)');
            bestFit = double(plotData.BestFit);
            iterationCount = numel(lowerBounds);

            finiteValues = [ ...
                lowerBounds(isfinite(lowerBounds)), ...
                upperBounds(isfinite(upperBounds)), ...
                bestFit(isfinite(bestFit))];

            if iterationCount == 0 || isempty(finiteValues)
                cla(app.SubUIAxes);
                return
            end

            yMinimum = min(finiteValues);
            yMaximum = max(finiteValues);
            yMargin = max(0.1 * (yMaximum - yMinimum), 0.1);
            iterations = 1:iterationCount;
            axes = app.SubUIAxes;

            cla(axes);
            axes.Visible = 'on';
            axes.FontSize = 16;
            axes.FontName = 'Arial';
            axes.XLim = [0 iterationCount + 1];
            axes.YLim = [yMinimum - yMargin yMaximum + yMargin];
            axes.XLabel.String = "Iteration";
            axes.YLabel.String = "Flux";
            axes.Title.String = plotData.Title;
            axes.XTick = 0:100:iterationCount;
            axes.XTickLabel = string(axes.XTick);
            axes.XTickLabelRotation = 0;

            hold(axes, 'on');
            plot( ...
                axes, iterations, repmat(bestFit, size(iterations)), ...
                '-', ...
                'Color', "#E69F00", ...
                'LineWidth', 3, ...
                'DisplayName', 'Best Fit');
            plot( ...
                axes, iterations, lowerBounds, ...
                '-', ...
                'Color', "#56B4E9", ...
                'LineWidth', 3, ...
                'DisplayName', 'Flux LB');
            plot( ...
                axes, iterations, upperBounds, ...
                '-', ...
                'Color', "#009E73", ...
                'LineWidth', 3, ...
                'DisplayName', 'Flux UB');
            legend(axes, 'show', 'Location', 'best');
            hold(axes, 'off');

        end % renderMonteCarloConfidenceInterval

        function clearResultPlots(app)

            cla(app.MainUIAxes);
            cla(app.SubUIAxes);

            app.MainUIAxes.Visible = 'on';
            app.SubUIAxes.Visible = 'on';

        end % method clearResultPlots

        function renderUiState(app, ui)
            % RENDERUISTATE Render the UI state
            % renderUiState(app, ui)
            %
            %  Input:
            %   ui: An object of class UiState

            if isempty(ui)
                return
            end

            if isfield(ui, "MainInteractionEnabled")

                app.applyMainInteractionEnabled(ui.MainInteractionEnabled);

                if ~ui.MainInteractionEnabled
                    return
                end

            end

            % Project panel
            % ---------------------------------------------------------------------
            if isfield(ui, "ProjectPanelEnabled")
                app.ProjectPanel.Enable = app.onOff(ui.ProjectPanelEnabled);
            end

            if isfield(ui, "ProjectBrowseEnabled")
                app.ProjectBrowseButton.Enable = app.onOff(ui.ProjectBrowseEnabled);
            end

            if isfield(ui, "ProjectDirectoryEnabled")
                app.ProjectDirectoryDropDown.Enable = ...
                    app.onOff(ui.ProjectDirectoryEnabled);
            end

            if isfield(ui, "ProjectLoadEnabled")
                app.ProjectLoadButton.Enable = app.onOff(ui.ProjectLoadEnabled);
            end

            if isfield(ui, "ProjectMetadataEditable")
                value = app.onOff(ui.ProjectMetadataEditable);
                app.ProjectNameEditField.Enable = value;
                app.ProjectAuthorEditField.Enable = value;
                app.OrganismEditField.Enable = value;
            end

            if isfield(ui, "ProjectSaveEnabled")
                app.ProjectSaveButton.Enable = app.onOff(ui.ProjectSaveEnabled);
            end

            if isfield(ui, "TemplateModelBrowseEnabled")
                app.TemplateModelBrowseButton.Enable = ...
                    app.onOff(ui.TemplateModelBrowseEnabled);
            end

            if isfield(ui, "TemplateModelDirectoryEnabled")
                app.TemplateModelDirectoryDropDown.Enable = ...
                    app.onOff(ui.TemplateModelDirectoryEnabled);
            end

            if isfield(ui, "TemplateModelLoadEnabled")
                app.TemplateModelLoadButton.Enable = ...
                    app.onOff(ui.TemplateModelLoadEnabled);
            end

            if isfield(ui, "TemplateModelSaveEnabled")
                app.TemplateModelSaveButton.Enable = ...
                    app.onOff(ui.TemplateModelSaveEnabled);
            end

            if isfield(ui, "ProjectCreateEnabled")
                app.ProjectCreateButton.Enable = ...
                    app.onOff(ui.ProjectCreateEnabled);
            end

            % Stoichiometry tab
            if isfield(ui, "ModelEnabled")
                value = app.onOff(ui.ModelEnabled);
                app.ModelTable.Enable = value;
                app.ModelReloadButton.Enable = value;
            end

            if isfield(ui, "ModelEditEnabled")
                app.ModelEditButton.Enable = app.onOff(ui.ModelEditEnabled);
            end

            if isfield(ui, "ModelSaveEnabled")
                app.ModelSaveButton.Enable = app.onOff(ui.ModelSaveEnabled);
            end

            if isfield(ui, "ModelTableEditable")
                app.applyTableEditable(app.ModelTable, ui.ModelTableEditable);
            end

            % MS tab
            if isfield(ui, "MsEnabled")
                value = app.onOff(ui.MsEnabled);
                app.MSTable.Enable = value;
                app.AtomTable.Enable = value;
                app.MSReloadButton.Enable = value;
            end

            if isfield(ui, "MsEditEnabled")
                app.MSEditButton.Enable = app.onOff(ui.MsEditEnabled);
            end

            if isfield(ui, "MsSaveEnabled")
                app.MSSaveButton.Enable = app.onOff(ui.MsSaveEnabled);
            end

            if isfield(ui, "MsTableEditable")
                app.applyTableEditable(app.MSTable, ui.MsTableEditable);
            end

            if isfield(ui, "AtomTableEditable")
                app.applyTableEditable(app.AtomTable, ui.AtomTableEditable);
            end

            % Experiment tab
            if isfield(ui, "ExperimentEnabled")
                value = app.onOff(ui.ExperimentEnabled);
                app.ExpTable.Enable = value;
                app.BiomassTable.Enable = value;
                app.ExpCalculationButton.Enable = value;
                app.ExpImportButton.Enable = value;
                app.ExpReloadButton.Enable = value;
                app.ExpSaveButton.Enable = value;

                app.applyContextMenu( ...
                    app.ExpTable, ...
                    app.ExperimentContextMenu, ...
                    ui.ExperimentEnabled);
            end

            if isfield(ui, "ExperimentTableEditable")
                app.applyTableEditable(app.ExpTable, ui.ExperimentTableEditable);
            end

            if isfield(ui, "BiomassTableEditable")
                app.applyTableEditable(app.BiomassTable, ui.BiomassTableEditable);
            end

            % Tracer tab
            if isfield(ui, "TracerEnabled")
                value = app.onOff(ui.TracerEnabled);
                app.UptakeTable.Enable = value;
                app.LabelTable.Enable = value;
                app.TracerConfigButton.Enable = value;
                app.TracerReloadButton.Enable = value;
                app.TracerSaveButton.Enable = value;

                app.applyContextMenu( ...
                    app.LabelTable, ...
                    app.ContextMenu3, ...
                    ui.TracerEnabled);
            end

            if isfield(ui, "TracerTableEditable")
                app.applyTableEditable(app.LabelTable, ui.TracerTableEditable);
            end

            if isfield(ui, "UptakeTableEditable")
                app.applyTableEditable(app.UptakeTable, ui.UptakeTableEditable);
            end

            % Run tab
            if isfield(ui, "RunConfigurationEnabled")
                value = app.onOff(ui.RunConfigurationEnabled);
                app.RunAutoButton.Enable = value;
                app.RunConfigButton.Enable = value;
                app.RunReloadButton.Enable = value;
                app.RunSaveButton.Enable = value;
            end

            if isfield(ui, "RunTableEnabled")
                app.RunTable.Enable = app.onOff(ui.RunTableEnabled);
            end

            if isfield(ui, "RunContextMenuEnabled")
                app.applyContextMenu( ...
                    app.RunTable, ...
                    app.ContextMenuRun, ...
                    ui.RunContextMenuEnabled);

            elseif isfield(ui, "RunTableEnabled")
                app.applyContextMenu( ...
                    app.RunTable, ...
                    app.ContextMenuRun, ...
                    ui.RunTableEnabled);
            end

            if isfield(ui, "RunTableEditable")

                if ui.RunTableEditable
                    app.restoreRunTableEditable();
                else
                    app.rememberRunTableEditable();
                    app.applyTableEditable(app.RunTable, false);
                end

            end

            if isfield(ui, "RunButtonEnabled")
                app.RunRunButton.Enable = app.onOff(ui.RunButtonEnabled);
            end

            if isfield(ui, "RunButtonText")
                app.RunRunButton.Text = char(ui.RunButtonText);
            end

            % Result tab
            if isfield(ui, "ResultEnabled")
                value = app.onOff(ui.ResultEnabled);
                app.ResultDropDown.Enable = value;
                app.ResultMainTable.Enable = value;
                app.ResultSubTable.Enable = value;
                app.ResultReportButton.Enable = value;
                app.ResultReloadButton.Enable = value;
                app.ResultSaveButton.Enable = value;

                app.applyContextMenu( ...
                    app.ResultMainTable, ...
                    app.ContextMenu2, ...
                    ui.ResultEnabled);

                app.applyContextMenu( ...
                    app.ResultSubTable, ...
                    app.ContextMenuResultSelect, ...
                    ui.ResultEnabled);
            end

            if isfield(ui, "ResultMainTableEditable")
                app.applyTableEditable(app.ResultMainTable, ...
                    ui.ResultMainTableEditable);
            end

            if isfield(ui, "ResultSubTableEditable")
                app.applyTableEditable(app.ResultSubTable, ...
                    ui.ResultSubTableEditable);
            end

            % Menu
            if isfield(ui, "MenuEnabled")
                value = app.onOff(ui.MenuEnabled);
                app.FilesMenu.Enable = value;
                app.ModelMenu.Enable = value;
                app.BatchMenu.Enable = value;
                app.ViewMenu.Enable = value;
            end

            % Pathway context menu
            if isfield(ui, "PathwayContextMenuEnabled")
                app.applyContextMenu( ...
                    app.MainUIAxes, ...
                    app.ContextMenu, ...
                    ui.PathwayContextMenuEnabled);
            end

        end % method renderUiState

        function value = onOff(~, enabled)

            if enabled
                value = 'on';
            else
                value = 'off';
            end

        end

        function applyContextMenu(~, component, contextMenu, enabled)

            if enabled
                component.ContextMenu = contextMenu;
            else
                component.ContextMenu = [];
            end

        end

        function applyTableEditable(~, tableObject, editable)
            % APPLYTABLEEDITABLE
            % Applies a scalar or vector editable flag to a UITable.

            if isempty(tableObject)
                return
            end

            if isempty(tableObject.Data)
                tableObject.ColumnEditable = false;
                return
            end

            if isscalar(editable)
                n = 1;

                try

                    if istable(tableObject.Data)
                        n = width(tableObject.Data);
                    else
                        n = size(tableObject.Data, 2);
                    end

                catch
                    n = 1;
                end

                tableObject.ColumnEditable = repmat(logical(editable), 1, n);
                return
            end

            tableObject.ColumnEditable = logical(editable);
        end

        function initializePresentation(app)

            app.requireApplicationDependency( ...
                app.Presenter, "MainPresenter");

            app.refreshPresentation();

        end % method initializePresentation

        function refreshPresentation(app)

            context = app.capturePresentationContext();
            viewModel = app.Presenter.refresh(context);
            app.renderMainViewModel(viewModel);

        end % method refreshPresentation

        function cleanup = beginPresentationOperation(app)

            context = app.capturePresentationContext();
            viewModel = app.Presenter.beginOperation(context);
            app.renderMainViewModel(viewModel);

            cleanup = onCleanup(@() app.finishPresentationOperation());

        end % method beginPresentationOperation

        function finishPresentationOperation(app)

            if isempty(app.Presenter)
                return
            end

            context = app.capturePresentationContext();
            viewModel = app.Presenter.finishOperation(context);
            app.renderMainViewModel(viewModel);

        end % method finishPresentationOperation

        function beginPresentationEditCommit(app)

            context = app.capturePresentationContext();

            viewModel = app.Presenter.beginEditCommit(context);

            app.renderMainViewModel(viewModel);

        end

        function finishPresentationEditCommit(app, success)

            arguments
                app
                success (1, 1) logical
            end

            context = app.capturePresentationContext();

            viewModel = app.Presenter.finishEditCommit(context, success);

            app.renderMainViewModel(viewModel);

        end

        function resetPresentation(app)

            app.requireApplicationDependency( ...
                app.Presenter, "MainPresenter");

            context = app.capturePresentationContext();

            viewModel = app.Presenter.reset(context);

            app.renderMainViewModel(viewModel);

        end

        function beginPresentationRun(app)

            context = app.capturePresentationContext();
            viewModel = app.Presenter.beginRun(context);
            app.renderMainViewModel(viewModel);
            drawnow;

        end % method beginPresentationRun

        function finishPresentationRun(app)

            if isempty(app.Presenter)
                return
            end

            context = app.capturePresentationContext();
            viewModel = app.Presenter.finishRun(context);
            app.renderMainViewModel(viewModel);

        end % method finishPresentationRun

        function finishPresentationRunSafely(app)

            try

                if isempty(app.Presenter)
                    return
                end

                context = app.capturePresentationContext();
                viewModel = app.Presenter.finishRun(context);
                app.renderMainViewModel(viewModel);
                drawnow;

            catch ME

                try
                    app.LogTextDate( ...
                        "Failed to restore run UI state: " + string(ME.message), ...
                    "Error");
                catch
                end

            end

        end % method finishPresentationRunSafely

        function requestPresentationCancelRun(app)

            context = app.capturePresentationContext();
            viewModel = app.Presenter.requestCancelRun(context);
            app.renderMainViewModel(viewModel);
            drawnow;

        end % method requestPresentationCancelRun

        function beginPresentationEdit(app, target)

            context = app.capturePresentationContext();
            viewModel = app.Presenter.beginEdit(target, context);
            app.renderMainViewModel(viewModel);

        end % method beginPresentationEdit

        function finishPresentationEdit(app)

            context = app.capturePresentationContext();
            viewModel = app.Presenter.finishEdit(context);
            app.renderMainViewModel(viewModel);

        end % method finishPresentationEdit

        function rememberRunTableEditable(app)

            if isempty(app.RunTable)
                return
            end

            if isempty(app.RunTable.Data)
                return
            end

            try
                current = app.RunTable.ColumnEditable;

                if isempty(current)
                    return
                end

                app.RunTableEditable = logical(current);

            catch
                % Do not fail rendering due to transient UITable state.
            end

        end % method rememberRunTableEditable

        function restoreRunTableEditable(app)

            try

                if isempty(app.RunTableEditable)
                    return
                end

                app.RunTable.ColumnEditable = app.RunTableEditable;

            catch
                % If the table shape has changed, keep current ColumnEditable.
            end

        end % method restoreRunTableEditable

        function context = capturePresentationContext(app)

            context = struct();

            % ---------------------------------------------------------------------
            % Project paths
            % ---------------------------------------------------------------------

            context.ProjectDirectory = ...
                app.safeStringScalar(app.ProjectDirectoryDropDown.Value);

            context.TemplateModelDirectory = ...
                app.safeStringScalar(app.TemplateModelDirectoryDropDown.Value);

            context.DirectoryModel = app.safeStringScalar(app.directoryModel);
            context.DirectoryExp = app.safeStringScalar(app.directoryExp);
            context.DirectoryResult = app.safeStringScalar(app.directoryResult);

            context.ProjectDirectoryExists = ...
                context.ProjectDirectory ~= "" && isfolder(context.ProjectDirectory);

            context.TemplateModelDirectoryExists = ...
                context.TemplateModelDirectory ~= "" && ...
                isfolder(context.TemplateModelDirectory);

            context.DirectoryModelExists = ...
                context.DirectoryModel ~= "" && isfolder(context.DirectoryModel);

            context.DirectoryExpExists = ...
                context.DirectoryExp ~= "" && isfolder(context.DirectoryExp);

            context.DirectoryResultExists = ...
                context.DirectoryResult ~= "" && isfolder(context.DirectoryResult);

            % ---------------------------------------------------------------------
            % Project metadata fields
            % ---------------------------------------------------------------------
            context.ProjectName = ...
                app.safeStringScalar(app.ProjectNameEditField.Value);

            context.ProjectAuthor = ...
                app.safeStringScalar(app.ProjectAuthorEditField.Value);

            context.Organism = ...
                app.safeStringScalar(app.OrganismEditField.Value);

            context.HasProjectMetadata = ...
                context.ProjectName ~= "" || ...
                context.ProjectAuthor ~= "" || ...
                context.Organism ~= "";

            % ---------------------------------------------------------------------
            % Legacy domain objects
            % ---------------------------------------------------------------------
            context.HasModelObject = app.isLoadedObject(app.model);
            context.HasExperimentObject = app.isLoadedObject(app.exp);
            context.HasBatchObject = app.isLoadedObject(app.batch);
            context.HasResultObject = app.isLoadedObject(app.result);

            context.HasModelError = app.objectHasError(app.model);
            context.HasExperimentError = app.objectHasError(app.exp);
            context.HasBatchError = app.objectHasError(app.batch);
            context.HasResultError = app.objectHasError(app.result);

            context.HasModel = ...
                context.HasModelObject && ~context.HasModelError;

            context.HasExperiments = ...
                context.HasExperimentObject && ~context.HasExperimentError;

            context.HasBatches = ...
                context.HasBatchObject && ~context.HasBatchError;

            % In the current GUI, the Result tab can be useful as soon as IOResult
            % exists, even if no result rows are displayed yet.
            context.HasResults = ...
                context.HasResultObject && ~context.HasResultError;

            % A project is considered fully loaded only when the project directories
            % and the four major legacy objects are available.
            context.HasProject = ...
                context.ProjectDirectoryExists && ...
                context.DirectoryModelExists && ...
                context.DirectoryExpExists && ...
                context.DirectoryResultExists && ...
                context.HasModel && ...
                context.HasExperiments && ...
                context.HasBatches && ...
                context.HasResults;

            % Template mode is used after loading a template model but before
            % creating a full project.
            context.IsTemplateMode = ...
                ~context.HasProject && ...
                context.TemplateModelDirectoryExists && ...
                context.HasModel;

            context.CanCreateProjectFromTemplate = context.IsTemplateMode;

            % ---------------------------------------------------------------------
            % Status table state
            % ---------------------------------------------------------------------
            calcStatus = strings(4, 1);
            calcStatus(:) = "init";

            try
                n = min(4, numel(app.calcStatus));
                calcStatus(1:n) = string(app.calcStatus(1:n));
            catch
                % Keep default "init" values.
            end

            context.Status = struct();
            context.Status.Model = calcStatus(1);
            context.Status.Experiment = calcStatus(2);
            context.Status.Batch = calcStatus(3);
            context.Status.Result = calcStatus(4);

            % ---------------------------------------------------------------------
            % Table contents
            % ---------------------------------------------------------------------
            context.ModelTableRowCount = app.tableRowCount(app.ModelTable.Data);
            context.MSTableRowCount = app.tableRowCount(app.MSTable.Data);
            context.AtomTableRowCount = app.tableRowCount(app.AtomTable.Data);
            context.ExpTableRowCount = app.tableRowCount(app.ExpTable.Data);
            context.BiomassTableRowCount = app.tableRowCount(app.BiomassTable.Data);
            context.UptakeTableRowCount = app.tableRowCount(app.UptakeTable.Data);
            context.LabelTableRowCount = app.tableRowCount(app.LabelTable.Data);
            context.RunTableRowCount = app.tableRowCount(app.RunTable.Data);
            context.ResultSubTableRowCount = app.tableRowCount(app.ResultSubTable.Data);
            context.ResultMainTableRowCount = app.tableRowCount(app.ResultMainTable.Data);

            context.HasModelRows = context.ModelTableRowCount > 0;
            context.HasMSRows = context.MSTableRowCount > 0;
            context.HasExperimentRows = context.ExpTableRowCount > 0;
            context.HasTracerRows = context.LabelTableRowCount > 0 || ...
                context.UptakeTableRowCount > 0;
            context.HasBatchRows = context.RunTableRowCount > 0;
            context.HasResultRows = context.ResultSubTableRowCount > 0;

            % For the first Presenter / UiPolicy step, this should approximate the
            % current GUI behavior without changing domain logic.
            context.CanRun = ...
                context.HasProject && ...
                context.HasModel && ...
                context.HasExperiments && ...
                context.HasBatches && ...
                context.HasBatchRows && ...
                context.DirectoryResultExists;

            % ---------------------------------------------------------------------
            % Current edit states inferred from existing UI
            % ---------------------------------------------------------------------
            context.IsModelEditing = ...
                app.isEnabled(app.ModelSaveButton) && ...
                app.hasEditableColumn(app.ModelTable.ColumnEditable);

            context.IsMSEditing = ...
                app.isEnabled(app.MSSaveButton) && ...
                (app.hasEditableColumn(app.MSTable.ColumnEditable) || ...
                app.hasEditableColumn(app.AtomTable.ColumnEditable));

            % Current implementation has no explicit Experiment / Tracer edit mode.
            % Their tables are edited directly when the tab is unlocked.
            context.IsExperimentEditing = false;
            context.IsTracerEditing = false;

            context.IsAnyTableEditing = ...
                context.IsModelEditing || ...
                context.IsMSEditing || ...
                context.IsExperimentEditing || ...
                context.IsTracerEditing;

            % ---------------------------------------------------------------------
            % Running / child-window states
            % ---------------------------------------------------------------------
            context.IsBatchRunning = ...
                app.safeStringScalar(app.RunRunButton.Text) == "Cancel";

            context.IsProjectPanelLocked = ...
                ~app.isEnabled(app.ProjectPanel);

            context.HasOpenChildApp = any([
                                           app.isLoadedObject(app.LabelConfigApp)
                                           app.isLoadedObject(app.TracerConfigApp)
                                           app.isLoadedObject(app.RunConfigApp)
                                           app.isLoadedObject(app.MSViewApp)
                                           app.isLoadedObject(app.ComparisonViewApp)
                                           app.isLoadedObject(app.RunAddBatchApp)
                                           app.isLoadedObject(app.ViewSuggestionApp)
                                           app.isLoadedObject(app.LogApp)
                                           ]);

            context.HasProgressBar = app.isLoadedObject(app.ProgressBar);

            % ---------------------------------------------------------------------
            % Current selections
            % ---------------------------------------------------------------------
            context.SelectedRunRows = app.selectedRows(app.RunTable);
            context.SelectedResultRows = app.selectedRows(app.ResultSubTable);
            context.SelectedResultDetailRows = app.selectedRows(app.ResultMainTable);
            context.SelectedModelRows = app.selectedRows(app.ModelTable);
            context.SelectedExperimentRows = app.selectedRows(app.ExpTable);
            context.SelectedTracerRows = app.selectedRows(app.LabelTable);

            context.HasSelectedRunRows = ~isempty(context.SelectedRunRows);
            context.HasSelectedResultRows = ~isempty(context.SelectedResultRows);
            context.HasSelectedModelRows = ~isempty(context.SelectedModelRows);
            context.HasSelectedExperimentRows = ~isempty(context.SelectedExperimentRows);
            context.HasSelectedTracerRows = ~isempty(context.SelectedTracerRows);

            % ---------------------------------------------------------------------
            % Current view mode
            % ---------------------------------------------------------------------
            context.CurrentTab = "";

            try

                if ~isempty(app.TabGroup.SelectedTab)
                    context.CurrentTab = ...
                        app.safeStringScalar(app.TabGroup.SelectedTab.Title);
                end

            catch
                context.CurrentTab = "";
            end

            context.ResultMode = ...
                app.safeStringScalar(app.ResultDropDown.Value);

            if context.ResultMode == ""
                context.ResultMode = "Overview";
            end

            context.TypeSimulation = ...
                app.safeStringScalar(app.typeSimulation);

            if context.TypeSimulation == ""
                context.TypeSimulation = "Flux";
            end

            % ---------------------------------------------------------------------
            % Current enabled state, useful during migration only.
            % Do not let MainUiPolicy depend on all of these permanently.
            % ---------------------------------------------------------------------
            context.LegacyUi = struct();

            context.LegacyUi.ProjectLoadEnabled = ...
                app.isEnabled(app.ProjectLoadButton);

            context.LegacyUi.TemplateModelLoadEnabled = ...
                app.isEnabled(app.TemplateModelLoadButton);

            context.LegacyUi.ProjectCreateEnabled = ...
                app.isEnabled(app.ProjectCreateButton);

            context.LegacyUi.TemplateModelSaveEnabled = ...
                app.isEnabled(app.TemplateModelSaveButton);

            context.LegacyUi.ModelEditEnabled = ...
                app.isEnabled(app.ModelEditButton);

            context.LegacyUi.ModelSaveEnabled = ...
                app.isEnabled(app.ModelSaveButton);

            context.LegacyUi.MSEditEnabled = ...
                app.isEnabled(app.MSEditButton);

            context.LegacyUi.MSSaveEnabled = ...
                app.isEnabled(app.MSSaveButton);

            context.LegacyUi.RunButtonEnabled = ...
                app.isEnabled(app.RunRunButton);

            context.LegacyUi.RunButtonText = ...
                app.safeStringScalar(app.RunRunButton.Text);

            context.LegacyUi.ResultReloadEnabled = ...
                app.isEnabled(app.ResultReloadButton);

        end % method capturePresentationContext

        function [status, msg] = extractGeneralMessagePayload(~, event)

            payload = event;

            % Unwrap event.EventData / BatchProgressEventData / nested struct.
            for i = 1:5

                if isstruct(payload) && ...
                        isfield(payload, 'status') && ...
                        isfield(payload, 'msg')
                    break
                end

                if isobject(payload)

                    try

                        if isprop(payload, 'data')
                            payload = payload.data;
                            continue
                        end

                    catch
                    end

                end

                if isstruct(payload) && isfield(payload, 'data')
                    payload = payload.data;
                    continue
                end

                break
            end

            if ~isstruct(payload) || ...
                    ~isfield(payload, 'status') || ...
                    ~isfield(payload, 'msg')

                error( ...
                    "OpenMebius2:Notification:InvalidGeneralMessagePayload", ...
                "GeneralMsg event does not contain status/msg payload.");
            end

            status = lower(string(payload.status));
            msg = string(payload.msg);

            if isempty(msg)
                msg = "";
            else
                msg = msg(1);
            end

            if isempty(status)
                status = "info";
            else
                status = status(1);
            end

            switch status
                case {"info", "warning", "error", "success"}
                    % keep
                case {"warn"}
                    status = "warning";
                case {"err", "exception"}
                    status = "error";
                case {"ok", "finished", "complete", "completed"}
                    status = "success";
                otherwise
                    status = "info";
            end

        end % method extractGeneralMessagePayload

        function tf = isLoadedObject(app, value)
            % ISLOADEDOBJECT
            % True when the value exists and, if it is a handle object, is valid.
            % This method intentionally does not inspect UI components.

            tf = false;

            if isempty(value)
                return
            end

            try

                if isobject(value)

                    try

                        if any(~isvalid(value), "all")
                            return
                        end

                    catch
                        % Some value objects do not support isvalid.
                        % In that case, non-empty is treated as loaded.
                    end

                end

                if app.objectHasError(value)
                    return
                end

                tf = true;

            catch
                tf = false;
            end

        end % function isLoadedObject

        function tf = objectHasError(~, value)
            % OBJECTHASERROR
            % Checks common legacy isError property without throwing.

            tf = false;

            if isempty(value)
                return
            end

            try

                if isobject(value) && isprop(value, "isError")
                    raw = value.isError;

                    if isempty(raw)
                        tf = false;
                    elseif islogical(raw)
                        tf = any(raw(:));
                    elseif isnumeric(raw)
                        tf = any(logical(raw(:)));
                    elseif isstring(raw) || ischar(raw)
                        raw = string(raw);
                        tf = any(raw == "true" | raw == "1" | raw == "error");
                    else
                        tf = false;
                    end

                end

            catch
                % If error state cannot be inspected, do not mark it as error.
                tf = false;
            end

        end % function objectHasError

        function n = tableRowCount(~, data)
            % TABLEROWCOUNT
            % Returns row count for table, cell, numeric array, string array, etc.

            n = 0;

            if isempty(data)
                return
            end

            try

                if istable(data)
                    n = height(data);
                else
                    n = size(data, 1);
                end

            catch
                n = 0;
            end

        end % function tableRowCount

        function n = tableWidthCount(~, data)
            % TABLEWIDTHCOUNT
            % Returns column count for table-like data.

            n = 0;

            if isempty(data)
                return
            end

            try

                if istable(data)
                    n = width(data);
                else
                    n = size(data, 2);
                end

            catch
                n = 0;
            end

        end % function tableWidthCount

        function tf = isEnabled(~, componentOrValue)
            % ISENABLED
            % Accepts either a UI component with Enable property or the Enable value.

            tf = false;

            try

                if ischar(componentOrValue) || isstring(componentOrValue)
                    value = string(componentOrValue);
                else
                    value = string(componentOrValue.Enable);
                end

                if isempty(value)
                    return
                end

                value = lower(value(1));

                tf = value == "on" || value == "true" || value == "1";

            catch
                tf = false;
            end

        end % function isEnabled

        function tf = hasEditableColumn(~, columnEditable)
            % HASEDITABLECOLUMN
            % True if any column is editable.

            tf = false;

            if isempty(columnEditable)
                return
            end

            try
                tf = any(logical(columnEditable(:)));
            catch
                tf = false;
            end

        end % function hasEditableColumn

        function rows = selectedRows(~, tableObject)
            % SELECTEDROWS
            % Extracts unique selected row indices from a UITable.

            rows = zeros(0, 1);

            try
                selection = tableObject.Selection;

                if isempty(selection)
                    return
                end

                if size(selection, 2) >= 1
                    rows = unique(selection(:, 1));
                    rows = rows(:);
                end

            catch
                rows = zeros(0, 1);
            end

        end % function selectedRows

        function value = safeStringScalar(~, raw)
            % SAFESTRINGSCALAR
            % Converts raw UI or property value to a non-missing scalar string.

            value = "";

            if isempty(raw)
                return
            end

            try
                value = string(raw);

                if isempty(value)
                    value = "";
                    return
                end

                value = value(1);

                if ismissing(value)
                    value = "";
                end

            catch
                value = "";
            end

        end % function safeStringScalar

        %% Private notification function
        function showNotification(app, notification)
            % SHOWNOTIFICATION
            % Central notification sink for OpenMebius2.mlapp.
            % showNotification(notification)

            if isempty(notification)
                return
            end

            if numel(notification) > 1

                for i = 1:numel(notification)
                    app.showNotification(notification(i));
                end

                return
            end

            if ~isa(notification, ...
                "openmebius.presentation.notification.Notification")

                notification = ...
                    openmebius.presentation.notification.Notification.info( ...
                    string(notification));

            end

            app.appendLogText( ...
                notification.Message, ...
                notification.Level, ...
                notification.Timestamp);

            if notification.ShowAlert

                uialert( ...
                    app.OpenMebius2UIFigure, ...
                    char(notification.Message), ...
                    char(notification.Title), ...
                    "Icon", char(notification.alertIcon()), ...
                    "Interpreter", "none");

            end

        end % method showNotification

        function openMSComparison(app)

            presenter = openmebius.presentation.experiment ...
                .ComparisonViewPresenter(app.exp);
            catalogViewModel = presenter.presentCatalog();

            for notificationIndex = 1:numel( ...
                    catalogViewModel.Notifications)
                app.showNotification( ...
                    catalogViewModel.Notifications{notificationIndex});
            end

            if ~catalogViewModel.IsAvailable
                return
            end

            app.closeComparisonViewApp();
            context = openmebius.presentation.experiment ...
                .ComparisonViewContext( ...
                    Presenter = presenter, ...
                    InitialCatalog = catalogViewModel);
            app.ComparisonViewApp = ComparisonView(context);
            app.attachComparisonViewListeners(app.ComparisonViewApp);

        end % method openMSComparison

        function appendLogText(app, text, level, timestamp)
            % APPENDLOGTEXT
            % Normalize and append log text to LogTextArea.

            arguments
                app
                text
                level string = "Info"
                timestamp (1, 1) datetime = datetime("now")
            end

            text = openmebius.infrastructure.logging.Logger ...
                .formatDatedLines( ...
                text, ...
                level, ...
                Timestamp = timestamp);

            before = app.LogTextArea.Value;
            app.LogTextArea.Value = [before; text(:)];

            scroll(app.LogTextArea, "bottom");

            drawnow limitrate

        end % method appendLogText

        function notifyInfo(app, message, options)

            arguments
                app
                message (1, 1) string
                options.Title (1, 1) string = ""
                options.Alert (1, 1) logical = false
            end

            app.showNotification( ...
                openmebius.presentation.notification.Notification.info( ...
                message, ...
                Title = options.Title, ...
                ShowAlert = options.Alert));

        end % method notifyInfo

        function notifyWarning(app, message, options)

            arguments
                app
                message (1, 1) string
                options.Title (1, 1) string = ""
                options.Alert (1, 1) logical = false
            end

            app.showNotification( ...
                openmebius.presentation.notification.Notification.warning( ...
                message, ...
                Title = options.Title, ...
                ShowAlert = options.Alert));

        end % method notifyWarning

        function notifyError(app, message, options)

            arguments
                app
                message (1, 1) string
                options.Title (1, 1) string = ""
                options.Alert (1, 1) logical = false
            end

            app.showNotification( ...
                openmebius.presentation.notification.Notification.error( ...
                message, ...
                Title = options.Title, ...
                ShowAlert = options.Alert));

        end % method notifyError

        function showModelValidationReport(app, validationReport)

            arguments
                app
                validationReport (1, 1) openmebius.domain.model ...
                    .ModelValidationReport
            end

            for i = 1:numel(validationReport.Warnings)
                app.notifyWarning(validationReport.Warnings(i));
            end

            if ~validationReport.IsValid
                app.notifyError(validationReport.ErrorMessage);
                return
            end

            for i = 1:numel(validationReport.Messages)
                app.notifyInfo(validationReport.Messages(i));
            end

        end % showModelValidationReport

        function notifyException(app, exception, options)

            arguments
                app
                exception
                options.Title (1, 1) string = "Error"
                options.Alert (1, 1) logical = false
            end

            app.showNotification( ...
                openmebius.presentation.notification.Notification.fromException( ...
                exception, ...
                Title = options.Title, ...
                ShowAlert = options.Alert));

        end % method notifyException

        function requireApplicationDependency(~, dependency, name)

            arguments
                ~
                dependency
                name (1, 1) string
            end

            isInvalidHandle = isa(dependency, "handle") && ...
                ~isvalid(dependency);

            if isempty(dependency) || isInvalidHandle
                error( ...
                    "OpenMebius2:Composition:MissingDependency", ...
                    "%s was not provided by MainAppCompositionRoot.", ...
                    name);
            end

        end % requireApplicationDependency

        function attachLegacyListeners(app)

            app.LegacyListeners = event.listener.empty(0, 1);

            if ~isempty(app.batch) && isvalid(app.batch)

                app.LegacyListeners(end + 1, 1) = addlistener( ...
                    app.batch, ...
                    'ProgressUpdate', ...
                    @(src, event) statusBatch(app, event));

                app.LegacyListeners(end + 1, 1) = addlistener( ...
                    app.batch, ...
                    'GeneralMsg', ...
                    @(src, event) statusGeneralMsg(app, event));

                app.LegacyListeners(end + 1, 1) = addlistener( ...
                    app.batch, ...
                    'FluxResult', ...
                    @(src, event) updateResult(app, event));

            end

            if ~isempty(app.result) && isvalid(app.result)

                app.LegacyListeners(end + 1, 1) = addlistener( ...
                    app.result, ...
                    'GeneralMsg', ...
                    @(src, event) statusGeneralMsg(app, event));

            end

        end % method attachLegacyListeners

        function detachLegacyListeners(app)

            if isempty(app.LegacyListeners)
                return
            end

            for i = 1:numel(app.LegacyListeners)

                try

                    if isvalid(app.LegacyListeners(i))
                        delete(app.LegacyListeners(i));
                    end

                catch
                    % Ignore listener cleanup errors.
                end

            end

            app.LegacyListeners = event.listener.empty(0, 1);

        end % method detachLegacyListeners

        function attachPreferencesListeners(app, preferencesApp)

            app.detachPreferencesListeners();

            if isempty(preferencesApp) || ~isvalid(preferencesApp)
                return
            end

            app.PreferencesListeners(1, 1) = addlistener( ...
                preferencesApp, ...
                "PreferencesClosed", ...
                @(src, event) app.onPreferencesClosed(src, event));

        end % method attachPreferencesListeners

        function detachPreferencesListeners(app)

            if isempty(app.PreferencesListeners)
                return
            end

            for i = 1:numel(app.PreferencesListeners)

                try

                    if isvalid(app.PreferencesListeners(i))
                        delete(app.PreferencesListeners(i));
                    end

                catch
                end

            end

            app.PreferencesListeners = event.listener.empty(0, 1);

        end % method detachPreferencesListeners

        function attachRunConfigListeners(app, runConfigApp)

            app.detachRunConfigListeners();
            listeners = event.listener.empty(0, 1);
            listeners(end + 1, 1) = addlistener( ...
                runConfigApp, ...
                "Applied", ...
                @(source, event) ...
                    app.onRunConfigurationApplied(source, event));
            listeners(end + 1, 1) = addlistener( ...
                runConfigApp, ...
                "BatchExperimentSelectionApplied", ...
                @(source, event) ...
                    app.onBatchExperimentSelectionApplied(source, event));
            listeners(end + 1, 1) = addlistener( ...
                runConfigApp, ...
                "NotificationRequested", ...
                @(source, event) ...
                    app.onNotificationRequested(source, event));
            listeners(end + 1, 1) = addlistener( ...
                runConfigApp, ...
                "Closed", ...
                @(source, event) ...
                    app.onRunConfigurationClosed(source, event));
            app.RunConfigListeners = listeners;

        end % attachRunConfigListeners

        function detachRunConfigListeners(app)

            app.RunConfigListeners = app.deleteListeners( ...
                app.RunConfigListeners);

        end % detachRunConfigListeners

        function closeRunConfigApp(app)

            app.detachRunConfigListeners();
            childApp = app.RunConfigApp;
            app.RunConfigApp = [];

            if isempty(childApp)
                return
            end

            try
                if isvalid(childApp)
                    delete(childApp);
                end
            catch
            end

        end % closeRunConfigApp

        function attachLabelConfigListeners(app, labelConfigApp)

            app.detachLabelConfigListeners();
            listeners = event.listener.empty(0, 1);
            listeners(end + 1, 1) = addlistener( ...
                labelConfigApp, ...
                "Applied", ...
                @(source, event) ...
                    app.onLabelConfigurationApplied(source, event));
            listeners(end + 1, 1) = addlistener( ...
                labelConfigApp, ...
                "NotificationRequested", ...
                @(source, event) ...
                    app.onNotificationRequested( ...
                        source, event));
            listeners(end + 1, 1) = addlistener( ...
                labelConfigApp, ...
                "Closed", ...
                @(source, event) ...
                    app.onLabelConfigurationClosed(source, event));
            app.LabelConfigListeners = listeners;

        end % attachLabelConfigListeners

        function detachLabelConfigListeners(app)

            app.LabelConfigListeners = app.deleteListeners( ...
                app.LabelConfigListeners);

        end % detachLabelConfigListeners

        function closeLabelConfigApp(app)

            app.detachLabelConfigListeners();
            childApp = app.LabelConfigApp;
            app.LabelConfigApp = [];

            if isempty(childApp)
                return
            end

            try
                if isvalid(childApp)
                    delete(childApp);
                end
            catch
            end

        end % closeLabelConfigApp

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

            app.TracerConfigListeners = app.deleteListeners( ...
                app.TracerConfigListeners);

        end % detachTracerConfigListeners

        function closeTracerConfigApp(app)

            app.detachTracerConfigListeners();
            childApp = app.TracerConfigApp;
            app.TracerConfigApp = [];

            if isempty(childApp)
                return
            end

            try
                if isvalid(childApp)
                    delete(childApp);
                end
            catch
            end

        end % closeTracerConfigApp

        function attachMSViewListeners(app, msViewApp)

            app.detachMSViewListeners();
            listeners = event.listener.empty(0, 1);
            listeners(end + 1, 1) = addlistener( ...
                msViewApp, ...
                "ComparisonRequested", ...
                @(~, ~) app.openMSComparison());
            listeners(end + 1, 1) = addlistener( ...
                msViewApp, ...
                "Closed", ...
                @(source, event) app.onMSViewClosed(source, event));
            app.MSViewListeners = listeners;

        end % attachMSViewListeners

        function detachMSViewListeners(app)

            app.MSViewListeners = app.deleteListeners( ...
                app.MSViewListeners);

        end % detachMSViewListeners

        function closeMSViewApp(app)

            app.detachMSViewListeners();
            childApp = app.MSViewApp;
            app.MSViewApp = [];

            if isempty(childApp)
                return
            end

            try
                if isvalid(childApp)
                    delete(childApp);
                end
            catch
            end

        end % closeMSViewApp

        function attachComparisonViewListeners(app, comparisonViewApp)

            app.detachComparisonViewListeners();
            listeners = event.listener.empty(0, 1);
            listeners(end + 1, 1) = addlistener( ...
                comparisonViewApp, ...
                "NotificationRequested", ...
                @(source, event) ...
                    app.onNotificationRequested(source, event));
            listeners(end + 1, 1) = addlistener( ...
                comparisonViewApp, ...
                "Closed", ...
                @(source, event) ...
                    app.onComparisonViewClosed(source, event));
            app.ComparisonViewListeners = listeners;

        end % attachComparisonViewListeners

        function detachComparisonViewListeners(app)

            app.ComparisonViewListeners = app.deleteListeners( ...
                app.ComparisonViewListeners);

        end % detachComparisonViewListeners

        function closeComparisonViewApp(app)

            app.detachComparisonViewListeners();
            childApp = app.ComparisonViewApp;
            app.ComparisonViewApp = [];

            if isempty(childApp)
                return
            end

            try
                if isvalid(childApp)
                    delete(childApp);
                end
            catch
            end

        end % closeComparisonViewApp

        function attachRunAddBatchListeners(app, runAddBatchApp)

            app.detachRunAddBatchListeners();
            listeners = event.listener.empty(0, 1);
            listeners(end + 1, 1) = addlistener( ...
                runAddBatchApp, ...
                "Applied", ...
                @(source, event) ...
                    app.onBatchExperimentSelectionApplied(source, event));
            listeners(end + 1, 1) = addlistener( ...
                runAddBatchApp, ...
                "Closed", ...
                @(source, event) ...
                    app.onRunAddBatchClosed(source, event));
            app.RunAddBatchListeners = listeners;

        end % attachRunAddBatchListeners

        function detachRunAddBatchListeners(app)

            app.RunAddBatchListeners = app.deleteListeners( ...
                app.RunAddBatchListeners);

        end % detachRunAddBatchListeners

        function listeners = deleteListeners(~, listeners)

            for listenerIndex = 1:numel(listeners)
                try
                    if isvalid(listeners(listenerIndex))
                        delete(listeners(listenerIndex));
                    end
                catch
                end
            end

            listeners = event.listener.empty(0, 1);

        end % deleteListeners

        function onBatchExperimentSelectionApplied(app, ~, event)

            outcome = app.BatchOperationController ...
                .applyExperimentSelection( ...
                    app.batch, event.Selection);
            app.renderBatchOperationViewModel( ...
                app.BatchPresenter ...
                .presentExperimentSelectionOutcome( ...
                    outcome, app.batch));

        end % onBatchExperimentSelectionApplied

        function onRunAddBatchClosed(app, ~, ~)

            app.RunAddBatchApp = [];

        end % onRunAddBatchClosed

        function closeRunAddBatchApp(app)

            app.detachRunAddBatchListeners();
            childApp = app.RunAddBatchApp;
            app.RunAddBatchApp = [];

            if isempty(childApp)
                return
            end

            try
                if isvalid(childApp)
                    delete(childApp);
                end
            catch
            end

        end % closeRunAddBatchApp

        function onRunConfigurationApplied(app, ~, ~)

            app.updateBatchTable();

        end % onRunConfigurationApplied

        function onRunConfigurationClosed(app, ~, ~)

            app.RunConfigApp = [];
            app.refreshPresentation();

        end % onRunConfigurationClosed

        function onLabelConfigurationApplied(app, ~, event)

            outcome = app.ModelOperationController ...
                .applyLabelConfiguration( ...
                    app.model, ...
                    app.exp, ...
                    app.batch, ...
                    event.LabelTable, ...
                    event.RatioTables);
            app.renderModelOperationViewModel( ...
                app.ModelPresenter ...
                    .presentLabelConfigurationOutcome(outcome));

        end % onLabelConfigurationApplied

        function onNotificationRequested(app, ~, event)

            app.showNotification(event.Notification);

        end % onNotificationRequested

        function onLabelConfigurationClosed(app, ~, ~)

            app.LabelConfigApp = [];
            app.refreshPresentation();

        end % onLabelConfigurationClosed

        function renderTracerConfigurationViewModel(app, viewModel)

            app.renderTracerConfigurationNotifications(viewModel);

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

        end % renderTracerConfigurationViewModel

        function onTracerConfigurationApplied(app, ~, event)

            outcome = app.ExperimentEditController ...
                .applyTracerConfiguration( ...
                    event.Position, event.EditorTable);
            viewModel = app.ExperimentPresenter ...
                .presentTracerConfigurationApplyOutcome(outcome);
            app.renderTracerConfigurationNotifications(viewModel);

            if viewModel.IsSuccessful
                position = viewModel.Position;
                app.LabelTable.Data{position(1), position(2)} = ...
                    {char(viewModel.Pattern)};
            end

        end % onTracerConfigurationApplied

        function onTracerConfigurationClosed(app, ~, ~)

            app.TracerConfigApp = [];
            app.refreshPresentation();

        end % onTracerConfigurationClosed

        function onMSViewClosed(app, ~, ~)

            app.MSViewApp = [];
            app.refreshPresentation();

        end % onMSViewClosed

        function onComparisonViewClosed(app, ~, ~)

            app.ComparisonViewApp = [];
            app.refreshPresentation();

        end % onComparisonViewClosed

        function renderTracerConfigurationNotifications(app, viewModel)

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

        end % renderTracerConfigurationNotifications

        %% Apply Session
        function applyMainInteractionEnabled(app, enabled)

            arguments
                app
                enabled (1, 1) logical
            end

            if enabled
                app.restoreMainInteraction();
            else
                app.lockMainInteraction();
            end

        end % method applyMainInteractionEnabled

        function lockMainInteraction(app)

            if ~isempty(app.MainInteractionSnapshot)
                return
            end

            app.MainInteractionSnapshot = {};

            objects = findall(app.OpenMebius2UIFigure);

            for i = 1:numel(objects)

                obj = objects(i);

                try

                    if isprop(obj, "Enable")

                        app.MainInteractionSnapshot(end + 1, :) = { ...
                                                                       obj, ...
                                                                       obj.Enable}; %#ok<AGROW>

                        obj.Enable = 'off';

                    end

                catch
                    % Ignore components that cannot be locked.
                end

            end

            drawnow limitrate

        end % method lockMainInteraction

        function restoreMainInteraction(app)

            if isempty(app.MainInteractionSnapshot)
                return
            end

            snapshot = app.MainInteractionSnapshot;
            app.MainInteractionSnapshot = {};

            for i = 1:size(snapshot, 1)

                obj = snapshot{i, 1};
                value = snapshot{i, 2};

                try

                    if isvalid(obj) && isprop(obj, "Enable")
                        obj.Enable = value;
                    end

                catch
                    % Ignore stale UI handles.
                end

            end

            drawnow limitrate

        end % method restoreMainInteraction

        function applyProjectSession(app, session)

            arguments
                app
                session openmebius.domain.project.ProjectSession
            end

            app.ProjectSession = session;

            app.ProjectDirectoryDropDown.Value = ...
                session.Paths.RootDirectory;

            app.ProjectNameEditField.Value = ...
                session.Metadata.Name;

            app.ProjectAuthorEditField.Value = ...
                session.Metadata.Author;

            app.OrganismEditField.Value = ...
                session.Metadata.Organism;

            app.directoryModel = ...
                session.Paths.ModelDirectory;

            app.directoryExp = ...
                session.Paths.ExperimentDirectory;

            app.directoryResult = ...
                session.Paths.ResultDirectory;

        end % method applyProjectSession

        function ensureProjectDirectoryItem(app, projectDirectory)

            projectDirectory = string(projectDirectory);
            items = string(app.ProjectDirectoryDropDown.Items);

            if ~any(items == projectDirectory)
                items(end + 1) = projectDirectory;
                app.ProjectDirectoryDropDown.Items = items;
            end

        end % ensureProjectDirectoryItem

        function projectDirectory = resolveProjectOpenInput(app, projectInput)

            arguments
                app
                projectInput (1, 1) string
            end

            projectDirectory = ...
                openmebius.infrastructure.project.FileProjectRepository ...
                .resolveProjectDirectory(projectInput);

        end % method resolveProjectOpenInput

        function projectInput = normalizeStartupProjectInput(~, projectInput)
            % NORMALIZESTARTUPPROJECTINPUT
            % Normalizes optional startup argument.
            %
            % Accepts:
            %   ""
            %   project directory
            %   setting.om2
            %   setting.json

            if nargin < 2 || isempty(projectInput)
                projectInput = "";
                return
            end

            try
                projectInput = string(projectInput);
            catch
                projectInput = "";
                return
            end

            if isempty(projectInput)
                projectInput = "";
                return
            end

            projectInput = strtrim(projectInput(1));

            if ismissing(projectInput)
                projectInput = "";
            end

        end % method normalizeStartupProjectInput

        function applyLegacyProjectArtifacts(app, artifacts)

            arguments
                app
                artifacts openmebius.infrastructure.legacy.LegacyProjectArtifacts
            end

            app.detachLegacyListeners();

            app.model = artifacts.Model;
            app.exp = artifacts.Experiments;
            app.batch = artifacts.Batch;
            app.result = artifacts.Result;

            app.attachLegacyListeners();

        end % method applyLegacyProjectArtifacts

        function applyTemplateModelLoadResult(app, templateModelResult)

            arguments
                app
                templateModelResult ...
                    openmebius.application.model.TemplateModelLoadResult
            end

            app.model = templateModelResult.Model;

        end % method applyTemplateModelLoadResult

        function applyExperimentImportResult(app, result)

            arguments
                app
                result openmebius.application.experiment.ExperimentImportResult
            end

            app.detachLegacyListeners();

            app.exp = result.Experiments;
            app.batch = result.Batch;

            app.attachLegacyListeners();

        end % method applyExperimentImportResult

        function result = reloadExperimentState(app, options)

            arguments
                app
                options.LogMessages (1, 1) logical = true
            end


            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory(app.directoryExp);

            outcome = app.ExperimentImportController.reload( ...
                experimentLocation, ...
                app.model);
            outcome.rethrowFailure();
            result = outcome.Result;

            app.renderExperimentImportResult( ...
                result, ...
                LogMessages = options.LogMessages);

        end % method reloadExperimentState

        function renderExperimentImportResult(app, result, options)

            arguments
                app
                result openmebius.application.experiment.ExperimentImportResult
                options.LogMessages (1, 1) logical = true
            end

            app.applyExperimentImportResult(result);
            app.loadExpData();
            loadBatchTable(app);

            if options.LogMessages

                for i = 1:numel(result.Messages)
                    app.LogTextDate(result.Messages(i), "Info");
                end

            end

        end % method renderExperimentImportResult

        function applyBatchStyleRules(app, styleRules)

            if isempty(styleRules)
                return
            end

            for i = 1:numel(styleRules)

                style = app.batchStyleFromKey(styleRules(i).StyleKey);

                addStyle( ...
                    app.RunTable, ...
                    style, ...
                    'cell', ...
                    [styleRules(i).Rows, styleRules(i).Columns]);

            end

        end % method applyBatchStyleRules

        function style = batchStyleFromKey(app, styleKey)

            switch lower(string(styleKey))

                case "info"
                    style = app.styleInfoIcon;

                case "success"
                    style = app.styleSuccessIcon;

                case "warning"
                    style = app.styleWarningIcon;

                case "error"
                    style = app.styleErrorIcon;

                case "question"
                    style = app.styleQuestionIcon;

                otherwise
                    error( ...
                        "OpenMebius2:Batch:UnknownStyleKey", ...
                        "Unknown batch style key: %s", string(styleKey));
            end

        end % method batchStyleFromKey

        function style = resultStyleFromRule(app, rule)

            key = lower(string(rule.StyleKey));

            switch key

                case "chi2-passed"

                    if app.isDarkTheme()
                        style = app.styleIsPassedDark;
                    else
                        style = app.styleIsPassed;
                    end

                case "chi2-failed"

                    if app.isDarkTheme()
                        style = app.styleIsNotPassedDark;
                    else
                        style = app.styleIsNotPassed;
                    end

                case "align-right"
                    style = uistyle("HorizontalAlignment", "right");

                case "background"
                    style = uistyle("BackgroundColor", char(rule.Value));

                otherwise
                    error( ...
                        "OpenMebius2:Result:UnknownStyleKey", ...
                        "Unknown result style key: %s", key);
            end

        end % method resultStyleFromRule

        function applyResultStyleRules(app, tableObject, styleRules)

            if isempty(styleRules)
                return
            end

            for i = 1:numel(styleRules)

                style = app.resultStyleFromRule(styleRules(i));

                target = char(styleRules(i).Target);

                switch string(styleRules(i).Target)

                    case "cell"
                        addStyle( ...
                            tableObject, ...
                            style, ...
                            target, ...
                            [styleRules(i).Rows, styleRules(i).Columns]);

                    case "column"
                        addStyle( ...
                            tableObject, ...
                            style, ...
                            target, ...
                            styleRules(i).Columns);

                    case "row"
                        addStyle( ...
                            tableObject, ...
                            style, ...
                            target, ...
                            styleRules(i).Rows);

                    otherwise
                        error( ...
                            "OpenMebius2:Result:InvalidStyleTarget", ...
                            "Unknown style target: %s", string(styleRules(i).Target));
                end

            end

        end % method applyResultStyleRules

        function ensureProgressBar(app)

            if isempty(app.ProgressBar) || ~isvalid(app.ProgressBar)
                app.ProgressBar = CustomProgressBar(app.GridLayout2, 3, 1);
            end

        end % method ensureProgressBar

        function rows = selectedTableRows(~, tableObject)

            rows = zeros(0, 1);

            try
                selection = tableObject.Selection;

                if isempty(selection)
                    return
                end

                if isvector(selection)
                    rows = selection(:);
                else
                    rows = selection(:, 1);
                end

                rows = double(rows(:));
                rows = rows(~isnan(rows));
                rows = rows(rows >= 1);
                rows = unique(rows, "stable");

                data = tableObject.Data;

                if isempty(data)
                    rows = zeros(0, 1);
                    return
                end

                if istable(data)
                    maxRow = height(data);
                else
                    maxRow = size(data, 1);
                end

                rows = rows(rows <= maxRow);

            catch
                rows = zeros(0, 1);
            end

        end % method selectedTableRows

        function removeSelectedBatches(app)

            selectedRows = app.selectedTableRows(app.RunTable);

            if isempty(selectedRows)
                app.notifyWarning("Please select a batch to remove.");
                return
            end

            batchIds = string(app.RunTable.Data.ID(selectedRows));
            [answer, isOK] = app.uiConfirmWrap( ...
                "Are you sure you want to remove the selected batch?", ...
                "Remove Batch", ...
                Options = ["Yes", "No"], ...
                DefaultOption = "No", ...
                CancelOption = "No", ...
                Icon = "warning");

            if ~isOK || answer ~= "Yes"
                return
            end

            outcome = app.BatchOperationController.remove( ...
                app.batch, batchIds);
            app.renderBatchOperationViewModel( ...
                app.BatchPresenter.presentRemoveOutcome( ...
                    outcome, app.batch));

        end % removeSelectedBatches

        function context = captureResultPlotContext(app)

            context = struct();

            context.Mode = string(app.ResultDropDown.Value);

            context.SelectedMainRows = ...
                app.selectedTableRows(app.ResultMainTable);

            context.SelectedSubRows = ...
                app.selectedTableRows(app.ResultSubTable);

            context.MainTableData = app.getResultMainRawData();
            context.SubTableData = app.ResultSubTable.Data;

            context.MainTableRowNames = ...
                app.getResultReactionIds(context.MainTableData);
            context.SubTableRowNames = string.empty(0, 1);

            try
                context.SubTableRowNames = string(app.ResultSubTable.RowName);
            catch
                context.SubTableRowNames = string.empty(0, 1);
            end

        end % method captureResultPlotContext

        function reactionID = selectedModelReactionID(app)

            reactionID = "";
            selectedRows = app.selectedTableRows(app.ModelTable);
            data = app.ModelTable.Data;

            if isempty(selectedRows) || ~istable(data) || ...
                    isempty(data.Properties.RowNames)
                return
            end

            selectedRow = selectedRows(1);
            reactionIDs = string(data.Properties.RowNames);

            if selectedRow >= 1 && selectedRow <= numel(reactionIDs)
                reactionID = reactionIDs(selectedRow);
            end

        end % selectedModelReactionID

        %% Slack notification helpers
        function notifySlackBatchCompleted(app, status, options)

            arguments
                app
                status (1, 1) string
                options.ErrorMessage (1, 1) string = ""
                options.DeltaTime (1, 1) duration = seconds(0)
            end

            try
                if ~app.SlackNotifier.canNotify()
                    return
                end

                projectName = "";

                try

                    if ~isempty(app.ProjectSession)
                        projectName = app.ProjectSession.Metadata.Name;
                    end

                catch
                    projectName = "";
                end

                message = "Batch calculation " + status + ".";

                if options.ErrorMessage ~= ""
                    message = message + newline + "Error: " + options.ErrorMessage;
                end

                result = app.SlackNotifier.send( ...
                    message, ...
                    Title = "OpenMebius2 Batch Run", ...
                    Status = status, ...
                    ProjectName = projectName, ...
                    BatchStatus = status, ...
                    DeltaTime = options.DeltaTime);

                if result.Success
                    app.notifyInfo("Slack notification sent.");
                elseif ~result.Skipped
                    app.notifyWarning("Slack notification failed: " + result.Message);
                end

            catch ME

                try
                    app.notifyWarning( ...
                        "Slack notification skipped: " + string(ME.message));
                catch
                end

            end

        end % method notifySlackBatchCompleted

        function beginPresentationPreferences(app)

            context = app.capturePresentationContext();
            viewModel = app.Presenter.beginPreferences(context);
            app.renderMainViewModel(viewModel);

        end % method beginPresentationPreferences

        function finishPresentationPreferences(app)

            try
                context = app.capturePresentationContext();
                viewModel = app.Presenter.finishPreferences(context);
                app.renderMainViewModel(viewModel);
            catch ME

                try
                    app.notifyWarning( ...
                        "Failed to restore main UI after Preferences: " + ...
                        string(ME.message));
                catch
                end

                app.restoreMainInteraction();
            end

        end % method finishPresentationPreferences

        %% Private initialization function
        function initLog(app)

            % Initial message
            app.LogTextArea.Value = ...
                "--------------------------------------------------------------------------------------------------------------------------------------------------------------" + newline + ...
                "OpenMebius2 is a MATLAB App for 13C metabolic flux analysis (13C-MFA) and related calculations." + newline + ...
                "Please load a project directory to start the analysis." + newline + ...
                "If you are new to OpenMebius2, please see the documentation and examples at tutorial page." + newline + newline + ...
                "You can use the following resources to try this software:" + newline + ...
                "- GitHub repository: URL" + newline + ...
                "- Tutorial page: URL" + newline + ...
                "- Article: URL" + newline + newline + ...
                "If you use OpenMebius2 in your scientific work, please consider to cite following publication: " + newline + ...
                "For more information, please visit URL" + newline + ...
                "--------------------------------------------------------------------------------------------------------------------------------------------------------------";

        end % function initLog

        function initDirectory(app, directory)
            % Initialize the results directory

            app.directoryModel = fullfile(directory, "model");
            app.directoryExp = fullfile(directory, "experiments");
            app.directoryResult = fullfile(directory, "results");

            % Create the directories if they do not exist
            if ~isfolder(app.directoryModel)
                mkdir(app.directoryModel);
            end

            if ~isfolder(app.directoryExp)
                mkdir(app.directoryExp);
            end

            if ~isfolder(app.directoryResult)
                mkdir(app.directoryResult);
            end

        end % function initResults

        function initStatusTable(app, options)
            % INITSTATUSTABLE Initialize the status component with default values

            arguments
                app
                options.update = false
                options.rows = "";
            end % arguments

            ui = app.StatusHTML;

            if app.isDarkTheme()
                css = [
                       "body { background-color: #222; color: #EEE; margin: 0; padding: 0; font-family: sans-serif; }" ...
                           "table { width: 100%; border-collapse: collapse; }" ...
                           "td { padding: 8px; background-color: #222; border: none; }" ...
                           "td:first-child { width: 10%; text-align: center; }" ...
                           "td:nth-child(2) { width: 20%; }" ...
                           "td:last-child  { width: 70%; }"
                       ];
            else
                css = [
                       "body { background-color: #fff; color: #000; margin: 0; padding: 0; font-family: sans-serif; }" ...
                           "table { width: 100%; border-collapse: collapse; }" ...
                           "td { padding: 8px; background-color: #fff; border: none; }" ...
                           "td:first-child { width: 10%; text-align: center; }" ...
                           "td:nth-child(2) { width: 20%; }" ...
                           "td:last-child  { width: 70%; }"
                       ];
            end % if app.isDarkTheme()

            cssChar = char(strjoin(css, ""));
            htmlHeader = ['<html><head><style>', cssChar, '</style></head><body>'];
            htmlHeader = [htmlHeader, '<table>'];
            htmlFooter = '</table></body></html>';

            if options.update

                % If the table is initialized, we will update it
                rows = options.rows;

                if isempty(rows)
                    rows = {
                            '<tr><td></td><td>Model</td><td>Initializing...</td></tr>', ...
                                '<tr><td></td><td>Experiment</td><td>Initializing...</td></tr>', ...
                                '<tr><td></td><td>Batch</td><td>Initializing...</td></tr>', ...
                                '<tr><td></td><td>Result</td><td>Initializing...</td></tr>'
                            };
                end % if isempty(rows)

            else

                rows = {
                        '<tr><td>ℹ️</td><td>Model</td><td>Not loaded</td></tr>', ...
                            '<tr><td>ℹ️</td><td>Experiment</td><td>Not loaded</td></tr>', ...
                            '<tr><td>ℹ️</td><td>Batch</td><td>Not started</td></tr>', ...
                            '<tr><td>ℹ️</td><td>Result</td><td>Not loaded</td></tr>'
                        };

            end % if options.update

            htmlBody = strjoin(rows, "");
            htmlContent = [htmlHeader, htmlBody, htmlFooter];

            if ~ischar(htmlContent)
                htmlContent = char(htmlContent);
            end % if ~ischar(htmlContent)

            ui.HTMLSource = htmlContent;

            if ~options.update

                % Set the initial status
                app.calcStatus = ...
                    openmebius.presentation.status.StatusPresenter.initial();

            end

        end % function initStatusTable

        function setLogFile(app)

            try
                openmebius.infrastructure.logging.Logger ...
                    .configureDefaultDiary();
            catch ME
                msg = "Could not set log file." + newline + ...
                    string(ME.message);
                app.LogTextDate(msg, "Error");
            end

        end % function setLogFile

        %% Private load function
        function loadHistory(app)

            system = System();
            directoryLog = system.getCacheDirectory();

            if ~isfolder(directoryLog)
                mkdir(directoryLog);
                return
            end

            fileLog = fullfile(directoryLog, 'history.mat');

            if isfile(fileLog)
                load(fileLog, 'projectHistory', 'tempModelHistory');
                app.ProjectDirectoryDropDown.Items = projectHistory;
                app.TemplateModelDirectoryDropDown.Items = tempModelHistory;
                app.ProjectDirectoryDropDown.Value = "";
                app.TemplateModelDirectoryDropDown.Value = "";
            end

        end % method loadHistory

        function renderWorkspaceTable(~, tableObject, viewModel)

            tableObject.Data = viewModel.Data;
            tableObject.ColumnName = viewModel.ColumnName;
            tableObject.RowName = viewModel.RowName;
            tableObject.ColumnEditable = viewModel.ColumnEditable;

        end % renderWorkspaceTable

        function renderModelTableViewModel(app, viewModel)

            app.renderWorkspaceTable(app.ModelTable, viewModel);
            app.resetModelTableColorFormat();

            if ~isempty(viewModel.ErrorRows)
                addStyle( ...
                    app.ModelTable, app.styleError, ...
                    'row', viewModel.ErrorRows);
            end

        end % renderModelTableViewModel

        function renderMassSpectrometryTableViewModels( ...
                app, massSpectrometry, atom)

            app.renderWorkspaceTable(app.MSTable, massSpectrometry);
            app.renderWorkspaceTable(app.AtomTable, atom);
            app.resetMSTableColorFormat();

            if ~isempty(massSpectrometry.ErrorRows)
                addStyle( ...
                    app.MSTable, app.styleError, ...
                    'row', massSpectrometry.ErrorRows);
            end

            if ~isempty(atom.ErrorRows)
                addStyle( ...
                    app.AtomTable, app.styleError, ...
                    'row', atom.ErrorRows);
            end

        end % renderMassSpectrometryTableViewModels

        function renderModelWorkspaceViewModel(app, viewModel)

            app.renderModelTableViewModel(viewModel.ModelTable);
            app.renderMassSpectrometryTableViewModels( ...
                viewModel.MassSpectrometryTable, ...
                viewModel.AtomTable);
            app.renderWorkspaceTable( ...
                app.BiomassTable, viewModel.BiomassTable);

        end % renderModelWorkspaceViewModel

        function renderExperimentWorkspaceViewModel(app, viewModel)

            app.renderWorkspaceTable( ...
                app.ExpTable, viewModel.InformationTable);
            app.renderWorkspaceTable( ...
                app.LabelTable, viewModel.TracerTable);
            app.renderWorkspaceTable( ...
                app.UptakeTable, viewModel.UptakeTable);

        end % renderExperimentWorkspaceViewModel

        function loadEMUModel(app)

            viewModel = app.ModelPresenter ...
                .presentWorkspaceTables(app.model);
            app.renderModelWorkspaceViewModel(viewModel);

        end % function loadEMUModel

        function loadModelTable(app, options)

            arguments
                app
                options.ColumnEditable logical = false
            end

            viewModel = app.ModelPresenter.presentModelTable( ...
                app.model, ...
                ColumnEditable = options.ColumnEditable);
            app.renderModelTableViewModel(viewModel);

        end % function loadModelTable

        function loadMSTable(app, options)

            arguments
                app
                options.isColumnEditable = false
            end

            [massSpectrometry, atom] = app.ModelPresenter ...
                .presentMassSpectrometryTables( ...
                    app.model, ...
                    ColumnEditable = options.isColumnEditable);
            app.renderMassSpectrometryTableViewModels( ...
                massSpectrometry, atom);

        end % function loadMSTable

        function loadTracerTable(app)

            columnEditable = app.LabelTable.ColumnEditable;

            if isempty(columnEditable)
                columnEditable = false;
            end

            viewModel = app.ExperimentPresenter.presentTracerTable( ...
                app.exp, ColumnEditable = columnEditable);
            app.renderWorkspaceTable(app.LabelTable, viewModel);

        end % function loadTracerTable

        function loadPathway(app)

            viewModel = app.ModelPresenter.presentPathway( ...
                app.model, ...
                IsDarkTheme = app.isDarkTheme());

            if ~isempty(viewModel.Notification)
                app.showNotification(viewModel.Notification);
            end

            app.renderPathwayPlot(viewModel);

            if isempty(viewModel.Image)
                return
            end

            msg = openmebius.infrastructure.logging.Logger ...
                .formatDatedMessage("Pathway loaded successfully", "Info");
            app.LogText(msg);

        end % function loadPathway

        function loadExpData(app)

            viewModel = app.ExperimentPresenter ...
                .presentWorkspaceTables(app.exp);
            app.renderExperimentWorkspaceViewModel(viewModel);

        end % function loadExpData

        function loadBatchTable(app)


            if isempty(app.batch) || ~isvalid(app.batch)
                msg = "Batch object is not valid.";
                app.notifyError(msg);
                app.updateStatus("batch", "error");
                return
            end

            app.ensureProgressBar();

            viewModel = app.BatchPresenter.presentTable(app.batch);

            app.renderBatchTable(viewModel);

        end % function loadBatchTable

        function loadResult(app)


            if isempty(app.result) || ~isvalid(app.result)
                msg = "Result object is not valid.";
                app.notifyError(msg);
                app.updateStatus("result", "error");
                return
            end

            viewModel = app.ResultPresenter.presentIndex( ...
                app.result, ...
                app.batch);

            app.renderResultSubTable(viewModel);

            app.renderResultMainTable( ...
                openmebius.presentation.result.ResultTableViewModel());

            if isempty(viewModel.Data)
                return
            end

        end % method loadResult

        function loadMainResultTable(app, options)

            arguments
                app
                options.relative = false
                options.relativeTo = ""
            end

            type = string(app.ResultDropDown.Value);
            rows = app.selectedTableRows(app.ResultSubTable);

            if isempty(rows)
                return
            end

            switch type

                case "Overview"

                    row = rows(1);
                    batchID = string(app.ResultSubTable.Data.ID(row));

                    loadResultOverView( ...
                        app, ...
                        batchID, ...
                        relative = options.relative, ...
                        relativeTo = options.relativeTo);

                case {"Details", "Detailed"}

                    row = rows(1);
                    batchID = string(app.ResultSubTable.Data.ID(row));

                    loadResultDetailed(app, batchID);

                case "Comparison"

                    if numel(rows) < 2
                        msg = "Please select at least two results for comparison.";
                        LogTextDate(app, msg, "Warning");
                        return
                    end

                    batchIDs = string(app.ResultSubTable.Data.ID(rows));
                    names = string(app.ResultSubTable.Data.Name(rows));

                    loadResultComparison( ...
                        app, ...
                        batchIDs, ...
                        names, ...
                        relative = options.relative, ...
                        relativeTo = options.relativeTo);

                otherwise

                    error( ...
                        "OpenMebius2:Result:InvalidViewMode", ...
                        "Unknown result view mode: %s", type);
            end

        end % method loadMainResultTable

        function loadResultOverView(app, batchID, options)

            arguments
                app
                batchID string
                options.relative = false
                options.relativeTo = ""
            end


            viewModel = app.ResultPresenter.presentMain( ...
                app.result, ...
                "Overview", ...
                batchID, ...
                "", ...
                Relative = options.relative, ...
                RelativeTo = options.relativeTo, ...
                IsDarkTheme = app.isDarkTheme());

            app.renderResultMainTable(viewModel);

        end % method loadResultOverView

        function loadResultDetailed(app, batchID)


            viewModel = app.ResultPresenter.presentMain( ...
                app.result, ...
                "Details", ...
                batchID, ...
                "", ...
                IsDarkTheme = app.isDarkTheme());

            app.renderResultMainTable(viewModel);

        end % method loadResultDetailed

        function loadResultComparison(app, batchIDs, names, options)

            arguments
                app
                batchIDs string
                names string
                options.relative = false
                options.relativeTo = ""
            end


            viewModel = app.ResultPresenter.presentMain( ...
                app.result, ...
                "Comparison", ...
                batchIDs, ...
                names, ...
                Relative = options.relative, ...
                RelativeTo = options.relativeTo, ...
                IsDarkTheme = app.isDarkTheme());

            app.renderResultMainTable(viewModel);

        end % method loadResultComparison

        function loadSubResultTable(app, ~, ~, ~, ~)


            viewModel = app.ResultPresenter.presentIndex( ...
                app.result, ...
                app.batch);

            app.renderResultSubTable(viewModel);

        end % method loadSubResultTable

        %% Private reset function
        function resetAllComponents(app)
            % RESETALLCOMPONENTS Reset all table data

            % Reset table data
            app.ModelTable.Data = [];
            app.MSTable.Data = [];
            app.AtomTable.Data = [];
            app.ExpTable.Data = [];
            app.BiomassTable.Data = [];
            app.UptakeTable.Data = [];
            app.LabelTable.Data = [];
            app.RunTable.Data = [];
            app.ResultMainTable.Data = [];
            app.ResultSubTable.Data = [];

            % Reset table column names
            app.ModelTable.ColumnName = [];
            app.MSTable.ColumnName = [];
            app.AtomTable.ColumnName = [];
            app.ExpTable.ColumnName = [];
            app.BiomassTable.ColumnName = [];
            app.UptakeTable.ColumnName = [];
            app.LabelTable.ColumnName = [];
            app.RunTable.ColumnName = [];
            app.ResultMainTable.ColumnName = [];
            app.ResultSubTable.ColumnName = [];

            % Reset table row names
            app.ModelTable.RowName = [];
            app.MSTable.RowName = [];
            app.AtomTable.RowName = [];
            app.ExpTable.RowName = [];
            app.BiomassTable.RowName = [];
            app.UptakeTable.RowName = [];
            app.LabelTable.RowName = [];
            app.RunTable.RowName = [];
            app.ResultMainTable.RowName = [];
            app.ResultSubTable.RowName = [];

            % Reset figure and plot
            cla(app.MainUIAxes);
            app.MainUIAxes.XLim = [0 1];
            app.MainUIAxes.YLim = [0 1];
            app.MainUIAxes.XTick = [];
            app.MainUIAxes.YTick = [];
            app.MainUIAxes.XLabel.String = "";
            app.MainUIAxes.YLabel.String = "";
            app.MainUIAxes.Title.String = "";
            app.MainUIAxes.XLabel.Visible = 'off';
            app.MainUIAxes.YLabel.Visible = 'off';
            app.MainUIAxes.Title.Visible = 'off';
            app.MainUIAxes.XColor = 'none';
            app.MainUIAxes.YColor = 'none';
            app.MainUIAxes.XGrid = 'off';
            app.MainUIAxes.YGrid = 'off';

            % Reset subplot
            app.SubUIAxes.XLim = [0 1];
            app.SubUIAxes.YLim = [0 1];
            app.SubUIAxes.XTick = [];
            app.SubUIAxes.YTick = [];
            app.SubUIAxes.XLabel.String = "";
            app.SubUIAxes.YLabel.String = "";
            app.SubUIAxes.Title.String = "";
            app.SubUIAxes.XLabel.Visible = 'off';
            app.SubUIAxes.YLabel.Visible = 'off';
            app.SubUIAxes.Title.Visible = 'off';
            app.SubUIAxes.XColor = 'none';
            app.SubUIAxes.YColor = 'none';
            app.SubUIAxes.XGrid = 'off';
            app.SubUIAxes.YGrid = 'off';

        end % method resetAllComponents

        function resetTableColorFormat(app)

            resetModelTableColorFormat(app);
            resetMSTableColorFormat(app);

        end % function resetTableColorFormat

        function resetModelTableColorFormat(app)
            removeStyle(app.ModelTable);
        end

        function resetMSTableColorFormat(app)
            removeStyle(app.MSTable);
            removeStyle(app.AtomTable);
        end

        function resetResultTableColorFormat(app)
            removeStyle(app.ResultSubTable);
            removeStyle(app.ResultMainTable);
        end

        %% Private update function
        function [icon, text] = updateStatusModel(~, status)
            % UPDATESTATUSMODEL Update the model status in the status table

            arguments
                ~
                status string {mustBeMember(status, ["init", "running", "finished", "error"])}
            end

            switch status

                case "init"
                    icon = "ℹ️";
                    text = "Model not loaded";

                case "running"
                    icon = "⏳";
                    text = "Loading model...";

                case "finished"
                    icon = "✅";
                    text = "Model loaded successfully";

                case "error"
                    icon = "❌";
                    text = "Error loading model";

            end % switch status

        end % function updateStatusModel

        function [icon, text] = updateStatusExperiment(~, status)
            % UPDATESTATUSEXPERIMENT Update the experiment status in the status table

            arguments
                ~
                status string {mustBeMember(status, ["init", "running", "finished", "error"])}
            end

            switch status

                case "init"
                    icon = "ℹ️";
                    text = "Experiment data not loaded";

                case "running"
                    icon = "⏳";
                    text = "Loading experiment data...";

                case "finished"
                    icon = "✅";
                    text = "Experiment data loaded successfully";

                case "error"
                    icon = "❌";
                    text = "Error loading experiment data";

            end % switch status

        end % function updateStatusExperiment

        function [icon, text] = updateStatusBatch(~, status)
            % UPDATESTATUSBATCH Update the batch status in the status table

            arguments
                ~
                status string {mustBeMember(status, ["init", "running", "finished", "error"])}
            end

            switch status

                case "init"
                    icon = "ℹ️";
                    text = "Batch not started";

                case "running"
                    icon = "⏳";
                    text = "Running batch...";

                case "finished"
                    icon = "✅";
                    text = "Batch run completed successfully";

                case "error"
                    icon = "❌";
                    text = "Error in batch run";

            end % switch status

        end % function updateStatusBatch

        function [icon, text] = updateStatusResult(~, status)
            % UPDATESTATUSRESULT Update the result status in the status table

            arguments
                ~
                status string {mustBeMember(status, ["init", "running", "finished", "error"])}
            end

            switch status

                case "init"
                    icon = "ℹ️";
                    text = "Result not loaded";

                case "running"
                    icon = "⏳";
                    text = "Loading result...";

                case "finished"
                    icon = "✅";
                    text = "Result loaded successfully";

                case "error"
                    icon = "❌";
                    text = "Error loading result";

            end % switch status

        end % function updateStatusResult

        function updateResult(app, ~)

            loadResult(app);

            % Drawnow
            drawnow;

        end % function updateResult

        function updateResultPlot(app)

            context = app.captureResultPlotContext();
            viewModel = app.ResultPlotPresenter.present( ...
                app.model, ...
                app.result, ...
                context, ...
                IsDarkTheme = app.isDarkTheme());
            app.renderResultPlot(viewModel);

        end % method updateResultPlot

        %% Private clipboard function
        function clipboardText = copyTableToClipboard(~, tableObject)
            % COPYTABLETOCLIPBOARD Copy the specified table content to clipboard

            data = tableObject.Data;
            [numRows, numCols] = size(data);

            % Copy only selected range if available (rectangular bounding box)
            r1 = 1; r2 = numRows;
            c1 = 1; c2 = numCols;

            if isprop(tableObject, 'Selection')
                sel = tableObject.Selection;

                if ~isempty(sel) && size(sel, 2) >= 2
                    rows = sel(:, 1);
                    cols = sel(:, 2);
                    r1 = double(max(1, min(rows, [], "all")));
                    r2 = double(min(numRows, max(rows, [], "all")));
                    c1 = double(max(1, min(cols, [], "all")));
                    c2 = double(min(numCols, max(cols, [], "all")));
                end

            end

            numRowsOut = max(0, r2 - r1 + 1);
            lines = strings(numRowsOut, 1);

            TAB = char(9);
            CRLF = char([13 10]);

            outRow = 0;

            r1 = r1(1); r2 = r2(1);
            c1 = c1(1); c2 = c2(1);

            for i = r1:r2

                outRow = outRow + 1;

                rowCells = strings(1, max(0, c2 - c1 + 1));

                outCol = 0;

                for j = c1:c2

                    outCol = outCol + 1;

                    if istable(data) || iscell(data)
                        v = data{i, j};
                    else
                        v = data(i, j);
                    end

                    rowCells(outCol) = localToStringScalar(v);
                end

                lines(outRow) = strjoin(rowCells, TAB);

            end

            clipboardText = strjoin(lines, CRLF);

            % Copy as char to keep Excel-friendly plain text
            clipboard('copy', char(clipboardText));

            function s = localToStringScalar(v)
                % Convert table cell content into a scalar string.
                % Treat missing/empty as "" to avoid propagating <missing>.
                if iscell(v)

                    if isempty(v)
                        s = "";
                        return;
                    end

                    if isscalar(v)
                        s = localToStringScalar(v{1});
                        return;
                    end

                    s = localToStringScalar(v{1});
                    return;
                end

                if isstring(v)

                    if isempty(v)
                        s = "";
                        return;
                    end

                    s = v(1);

                    if ismissing(s)
                        s = "";
                    end

                    return;
                end

                if ischar(v)
                    s = string(v);
                    return;
                end

                if ismissing(v)
                    s = "";
                    return;
                end

                try
                    s = string(v);

                    if ismissing(s)
                        s = "";
                    end

                catch
                    s = "";
                end

            end

        end % function copyTableToClipboard

        function pasteClipboardToTable(~, tableObject)
            % PASTECLIPBOARDTOTABLE Paste clipboard content to the specified table

            clipboardContent = clipboard('paste');
            rows = regexp(clipboardContent, '\r\n|\n|\r', 'split');

            if ~isempty(rows) && isempty(rows{end})
                rows(end) = [];
            end

            numRows = length(rows);

            data = tableObject.Data;
            isTableData = istable(data);

            % Paste starting position (top-left of current selection)
            startRow = 1;
            startCol = 1;

            if isprop(tableObject, 'Selection')
                sel = tableObject.Selection;

                if ~isempty(sel) && size(sel, 2) >= 2
                    startRow = max(1, min(sel(:, 1)));
                    startCol = max(1, min(sel(:, 2)));
                end

            end

            if isTableData
                maxRows = height(data);
                maxCols = width(data);
            else
                maxRows = size(tableObject.Data, 1);
                maxCols = size(tableObject.Data, 2);
            end

            for i = 1:numRows

                if isempty(rows{i})
                    continue
                end

                cols = regexp(rows{i}, '\t', 'split');
                numCols = length(cols);

                for j = 1:numCols

                    targetRow = startRow + (i - 1);
                    targetCol = startCol + (j - 1);

                    if targetRow > maxRows || targetCol > maxCols
                        continue
                    end

                    token = cols{j};

                    if ischar(token)
                        token = strrep(token, char(13), '');
                    end

                    if isTableData
                        existing = data{targetRow, targetCol};

                        if isnumeric(existing)
                            v = str2double(token);

                            if isnan(v)
                                v = NaN;
                            end

                            data{targetRow, targetCol} = v;

                        elseif islogical(existing)
                            t = strtrim(token);
                            data{targetRow, targetCol} = any(strcmpi(t, {'1', 'true', 't', 'yes', 'y'}));

                        else
                            data{targetRow, targetCol} = string(token);
                        end

                    else
                        tableObject.Data{targetRow, targetCol} = token;
                    end

                end

            end

            if isTableData
                tableObject.Data = data;
            end

        end % function pasteClipboardToTable

        %% Style functions
        function setBatchInitialStyle(app, status)


            if isempty(app.RunTable.Data)
                return
            end

            styleRules = ...
                app.BatchPresenter.styleRulesForStatus( ...
                app.RunTable.Data, ...
                status);

            app.applyBatchStyleRules(styleRules);

        end

        function data = getResultMainRawData(app)

            data = app.ResultMainTable.Data;

            try
                userData = app.ResultMainTable.UserData;

                if isstruct(userData) && ...
                        isfield(userData, "RawData") && ...
                        ~isempty(userData.RawData)

                    data = userData.RawData;
                end

            catch
                data = app.ResultMainTable.Data;
            end

        end % method getResultMainRawData

        function rxnIDs = getResultReactionIds(app, tableData)

            rxnIDs = strings(0, 1);

            try
                rxnIDs = string(app.ResultMainTable.RowName);
                rxnIDs = rxnIDs(:);

                if ~isempty(rxnIDs) && any(rxnIDs ~= "")
                    return
                end

            catch
            end

            try
                rxnIDs = string(tableData.Properties.RowNames);
                rxnIDs = rxnIDs(:);

                if ~isempty(rxnIDs) && any(rxnIDs ~= "")
                    return
                end

            catch
            end

            candidates = ["ID", "RxnID", "Reaction", "ReactionID"];

            try
                names = string(tableData.Properties.VariableNames);

                for i = 1:numel(candidates)
                    idx = find(names == candidates(i), 1);

                    if ~isempty(idx)
                        rxnIDs = string(tableData{:, idx});
                        rxnIDs = rxnIDs(:);
                        return
                    end

                end

            catch
            end

        end % method getResultReactionIds

        %% Status function
        function statusBatch(app, data)


            viewModel = ...
                app.BatchPresenter.presentProgress( ...
                data, ...
                app.RunTable.Data);

            if ~isempty(viewModel.Notification)
                app.showNotification(viewModel.Notification);
            end

            app.applyBatchStyleRules(viewModel.StyleRules);

            app.renderBatchProgress(viewModel);

        end % function statusBatch

        function statusGeneralMsg(app, event)

            try
                [status, msg] = app.extractGeneralMessagePayload(event);

                notification = ...
                    openmebius.presentation.notification.Notification( ...
                    msg, ...
                    status);

                app.showNotification(notification);

            catch ME
                % Event callback内で例外を握り潰すと通知消失に見えるため、
                % 最低限LogTextAreaへ落とす。
                try
                    app.appendLogText( ...
                        openmebius.infrastructure.logging.Logger ...
                        .formatDatedMessage( ...
                        "Failed to handle GeneralMsg event: " + ...
                        string(ME.message), ...
                    "Error"));
                catch
                    disp(ME.message)
                end

            end

        end % method statusGeneralMsg

        function checkLatestVersionOnStartup(app)
            % CHECKLATESTVERSIONONSTARTUP Checks whether a newer version exists.
            % Update failures must not prevent application startup.

            try
                currentVersion = System.getCurrentVersion();
                [latestVersion, releaseURL] = System.getLatestOpenMebius2Version();

                if System.isVersionNewer(latestVersion, currentVersion)
                    msg = "A newer OpenMebius2 version is available: " + latestVersion + ...
                        " (current: " + currentVersion + ").";
                    app.LogTextDate(msg, "Warning");

                    answer = uiconfirm(app.OpenMebius2UIFigure, ...
                        char(msg + newline + "Open the GitHub releases page?"), ...
                        'Update available', ...
                        'Options', {'Open releases', 'Later'}, ...
                        'DefaultOption', 1, ...
                        'CancelOption', 2, ...
                        'Icon', 'warning');

                    if strcmp(answer, 'Open releases')
                        web(char(releaseURL), '-browser');
                    end

                else
                    msg = "OpenMebius2 is up to date: " + currentVersion + ".";
                    app.LogTextDate(msg, "Info");
                end

            catch ME
                msg = "Unable to check for OpenMebius2 updates: " + string(ME.message);
                app.LogTextDate(msg, "Warning");
            end

        end % method checkLatestVersionOnStartup

    end % methods (Access = private)

    %% Private callback functions
    methods (Access = private)

        function onPreferencesClosed(app, src, event)

            app.detachPreferencesListeners();
            app.PreferencesApp = [];
            app.finishPresentationPreferences();

        end % method onPreferencesClosed

    end % methods (Access = private)

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, filepath)

            app.setLogFile();

            app.DialogService = ...
                openmebius.presentation.dialog.AppDialogService( ...
                app.OpenMebius2UIFigure);

            dependencies = openmebius.bootstrap ...
                .MainAppCompositionRoot.create();
            app.applyApplicationDependencies(dependencies);

            if nargin < 2
                filepath = "";
            else
                filepath = string(filepath);
            end

            loadHistory(app)

            initLog(app)

            initStatusTable(app);

            app.initializePresentation();

            checkLatestVersionOnStartup(app);

            filepath = app.normalizeStartupProjectInput(filepath);

            if filepath ~= ""

                try
                    projectDirectory = app.resolveProjectOpenInput(filepath);

                    if projectDirectory ~= ""
                        app.ProjectDirectoryDropDown.Value = projectDirectory;
                        ProjectLoadButtonPushed(app);
                    end

                catch ME
                    app.notifyException( ...
                        ME, ...
                        Title = "Project open failed", ...
                        Alert = true);
                end

            end

        end

        % Close request function: OpenMebius2UIFigure
        function OpenMebius2UIFigureCloseRequest(app, event)

            saveHistory(app)
            delete(app)

        end

        % Button pushed function: ProjectBrowseButton
        function ProjectBrowseButtonPushed(app, event)

            [projectDirectory, isOK] = app.uiGetDirWrap( ...
                Title = "Select Project Directory", ...
                StartPath = app.ProjectDirectoryDropDown.Value);

            if ~isOK
                return
            end

            % If the directory is equal to the current directory, do nothing
            if strcmp(app.ProjectDirectoryDropDown.Value, projectDirectory)
                return;
            end

            % Update the dropdown value
            app.ProjectDirectoryDropDown.Value = projectDirectory;

            % Add the directory to the item
            if ~any(strcmp(app.ProjectDirectoryDropDown.Items, projectDirectory))
                app.ProjectDirectoryDropDown.Items{end + 1} = projectDirectory;
            end

            % Update the status
            updateStatus(app, "model", "init");

            app.refreshPresentation();

        end

        % Button pushed function: ProjectLoadButton
        function ProjectLoadButtonPushed(app, ~)

            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>
            app.renderProjectOperationViewModel( ...
                app.ProjectPresenter.presentLoadStarted());

            outcome = app.ProjectOperationController.open( ...
                string(app.ProjectDirectoryDropDown.Value));
            app.renderProjectOperationViewModel( ...
                app.ProjectPresenter.presentOpenOutcome(outcome));

        end

        % Button pushed function: ProjectSaveButton
        function ProjectSaveButtonPushed(app, ~)


            metadata = openmebius.domain.project.ProjectMetadata( ...
                Name = string(app.ProjectNameEditField.Value), ...
                Author = string(app.ProjectAuthorEditField.Value), ...
                Organism = string(app.OrganismEditField.Value));
            outcome = app.ProjectOperationController.save( ...
                app.ProjectSession, ...
                string(app.ProjectDirectoryDropDown.Value), ...
                metadata);
            app.renderProjectOperationViewModel( ...
                app.ProjectPresenter.presentSaveOutcome(outcome));

        end

        % Button pushed function: ProjectCreateButton
        function ProjectCreateButtonPushed(app, ~)

            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>

            [answ, ok] = app.uiInputDlgWrap( ...
                Prompt = "Enter the name of the new project directory:", ...
                Title = "Create Project Directory", ...
                Default = "NewProject" ...
            );

            if ok
                directoryName = answ(1); % string
            else
                directoryName = ""; % cancel時
            end

            if isempty(directoryName)
                return; % User canceled the dialog
            end % if isempty(directoryName)

            directoryName = directoryName{1};

            if isempty(directoryName)
                app.notifyError("Project directory name cannot be empty.");
                return
            end % if isempty(directoryName)

            projectParentDirectory = app.uiGetDirWrap( ...
                StartPath = app.ProjectDirectoryDropDown.Value, ...
                Title = "Select Parent Directory for New Project" ...
            );

            if isequal(projectParentDirectory, 0) || ...
                    (isstring(projectParentDirectory) && strlength(projectParentDirectory) == 0)
                return;
            end

            projectParentDirectory = string(projectParentDirectory);
            templateModelDirectory = string( ...
                app.TemplateModelDirectoryDropDown.Value);

            app.renderProjectOperationViewModel( ...
                app.ProjectPresenter.presentCreateStarted());

            metadata = openmebius.domain.project.ProjectMetadata( ...
                Name = string(app.ProjectNameEditField.Value), ...
                Author = string(app.ProjectAuthorEditField.Value), ...
                Organism = string(app.OrganismEditField.Value));
            outcome = app.ProjectOperationController.create( ...
                ParentDirectory = projectParentDirectory, ...
                ProjectDirectoryName = string(directoryName), ...
                TemplateModelDirectory = templateModelDirectory, ...
                Metadata = metadata);
            app.renderProjectOperationViewModel( ...
                app.ProjectPresenter.presentCreateOutcome(outcome));

        end

        % Value changed function: ProjectDirectoryDropDown
        function ProjectDirectoryDropDownValueChanged(app, event)

            value = string(app.ProjectDirectoryDropDown.Value);

            try
                value = app.resolveProjectOpenInput(value);
            catch ME
                msg = "Selected project path does not exist: " + ...
                    string(app.ProjectDirectoryDropDown.Value);

                LogTextDate(app, msg + newline + string(ME.message), "Error");
                return
            end

            app.ProjectDirectoryDropDown.Value = value;

            if ~any(strcmp(app.ProjectDirectoryDropDown.Items, value))
                app.ProjectDirectoryDropDown.Items{end + 1} = value;
            end

        end

        % Button pushed function: TemplateModelBrowseButton
        function TemplateModelBrowseButtonPushed(app, event)

            [templateModelDirectory, isOK] = app.uiGetDirWrap( ...
                Title = "Select Template Model Directory", ...
                StartPath = app.TemplateModelDirectoryDropDown.Value);

            if ~isOK
                return
            end

            % If the directory is equal to the current directory, do nothing
            if strcmp(app.TemplateModelDirectoryDropDown.Value, templateModelDirectory)
                return;
            end

            % Update the dropdown value
            app.TemplateModelDirectoryDropDown.Value = templateModelDirectory;

            % Add the directory to the item
            if ~any(strcmp(app.TemplateModelDirectoryDropDown.Items, templateModelDirectory))
                app.TemplateModelDirectoryDropDown.Items{end + 1} = templateModelDirectory;
            end

            app.refreshPresentation();
        end

        % Button pushed function: TemplateModelLoadButton
        function TemplateModelLoadButtonPushed(app, ~)

            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>
            app.renderModelOperationViewModel( ...
                app.ModelPresenter.presentTemplateLoadStarted());

            modelLocation = openmebius.domain.model.ModelLocation ...
                .fromDirectory( ...
                    string(app.TemplateModelDirectoryDropDown.Value));
            outcome = app.ModelOperationController.loadTemplate( ...
                modelLocation);
            app.renderModelOperationViewModel( ...
                app.ModelPresenter.presentTemplateLoadOutcome(outcome));

        end

        % Button pushed function: TemplateModelSaveButton
        function TemplateModelSaveButtonPushed(app, event)

        end

        % Value changed function: TemplateModelDirectoryDropDown
        function TemplateModelDirectoryDropDownValueChanged(app, event)

            value = app.TemplateModelDirectoryDropDown.Value;

            % Check directory exists
            if ~isfolder(value)
                msg = "Selected directory does not exist: " + value;
                LogTextDate(app, msg, "Error");
                return
            end % if ~isfolder(value)

            % Add the directory to the item
            if ~any(strcmp(app.TemplateModelDirectoryDropDown.Items, value))
                app.TemplateModelDirectoryDropDown.Items{end + 1} = value;
            end % if exist

        end

        % Button pushed function: ModelReloadButton
        function ModelReloadButtonPushed(app, event)

            if strcmp(app.ModelEditButton.Enable, 'off')
                columnEditable = true(1, width(app.ModelTable.Data));
                loadModelTable(app, ColumnEditable = columnEditable);
            else
                loadModelTable(app);
            end

            loadPathway(app);

            app.LogTextDate("Model table reloaded", "Info");
        end

        % Button pushed function: ModelEditButton
        function ModelEditButtonPushed(app, event)

            import openmebius.presentation.main.EditTarget

            app.beginPresentationEdit(EditTarget.Model);

            app.LogTextDate("Model table is now editable", "Info");
        end

        % Button pushed function: ModelSaveButton
        function ModelSaveButtonPushed(app, ~)

            app.beginPresentationEditCommit();
            app.renderModelOperationViewModel( ...
                app.ModelPresenter.presentModelSaveStarted());

            outcome = app.ModelOperationController.saveModelTable( ...
                app.model, ...
                app.ModelTable.Data);
            app.renderModelOperationViewModel( ...
                app.ModelPresenter.presentModelSaveOutcome(outcome));

        end

        % Cell selection callback: ModelTable
        function ModelTableCellSelection(app, event)

            indices = event.Indices;

            if isempty(indices)
                return
            end

            row = indices(1, 1);

            if ~istable(app.ModelTable.Data) || ...
                    row < 1 || row > height(app.ModelTable.Data)
                return
            end

            reactionIDs = string(app.ModelTable.Data.Properties.RowNames);

            if row > numel(reactionIDs)
                return
            end

            viewModel = app.ModelPresenter.presentPathway( ...
                app.model, ...
                HighlightReactionIDs = reactionIDs(row), ...
                IsDarkTheme = app.isDarkTheme());

            if ~isempty(viewModel.Notification)
                app.showNotification(viewModel.Notification);
            end

            app.renderPathwayPlot(viewModel);
        end

        % Menu selected function: AddLabelMenu
        function AddLabelMenuSelected(app, ~)

            point = get(app.MainUIAxes, 'CurrentPoint');
            position = [point(1, 1) point(1, 2)];
            reactionID = app.selectedModelReactionID();
            outcome = app.ModelOperationController ...
                .setPathwayLabelPosition( ...
                    app.model, reactionID, position);
            app.renderModelPathwayEditViewModel( ...
                app.ModelPresenter.presentPathwayEditOutcome( ...
                    outcome, IsDarkTheme = app.isDarkTheme()));

        end

        % Menu selected function: RemoveLabelMenu
        function RemoveLabelMenuSelected(app, ~)

            reactionID = app.selectedModelReactionID();
            outcome = app.ModelOperationController ...
                .removePathwayLabelPosition( ...
                    app.model, reactionID);
            app.renderModelPathwayEditViewModel( ...
                app.ModelPresenter.presentPathwayEditOutcome( ...
                    outcome, IsDarkTheme = app.isDarkTheme()));

        end

        % Button pushed function: MSReloadButton
        function MSReloadButtonPushed(app, event)

            if strcmp(app.MSEditButton.Enable, 'off')
                columnEditable = true;
                loadMSTable(app, isColumnEditable = columnEditable);
            else
                loadMSTable(app);
            end

            msg = openmebius.infrastructure.logging.Logger ...
                .formatDatedMessage("MS table reloaded", "Info");
            app.LogText(msg);
        end

        % Button pushed function: MSEditButton
        function MSEditButtonPushed(app, event)

            import openmebius.presentation.main.EditTarget

            app.beginPresentationEdit(EditTarget.MassSpectrometry);

            app.LogTextDate("MS table is now editable", "Info");
        end

        % Button pushed function: MSSaveButton
        function MSSaveButtonPushed(app, ~)

            app.beginPresentationEditCommit();
            app.renderModelOperationViewModel( ...
                app.ModelPresenter ...
                .presentMassSpectrometrySaveStarted());

            outcome = app.ModelOperationController ...
                .saveMassSpectrometry( ...
                    app.model, ...
                    app.MSTable.Data, ...
                    app.AtomTable.Data);
            app.renderModelOperationViewModel( ...
                app.ModelPresenter ...
                .presentMassSpectrometrySaveOutcome(outcome));

        end

        % Button pushed function: ExpCalculationButton
        function ExpCalculationButtonPushed(app, event)

            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>
            app.renderExperimentCalculationViewModel( ...
                app.ExperimentPresenter.presentCalculationStarted());

            outcome = app.ExperimentCalculationController.calculate( ...
                app.model, ...
                app.exp, ...
                app.batch, ...
                app.ExpTable.Data, ...
                app.UptakeTable.Data, ...
                app.LabelTable.Data);
            app.renderExperimentCalculationViewModel( ...
                app.ExperimentPresenter ...
                .presentCalculationOutcome(outcome));

        end

        % Button pushed function: ExpImportButton
        function ExpImportButtonPushed(app, ~)

            % Wrap
            [files, isOK] = app.uiGetFileWrap( ...
                Filter = {'*.xlsx;*.xls', 'Excel Files (*.xlsx, *.xls)'}, ...
                Title = 'Select Experimental Data File', ...
                MultiSelect = "on" ...
            );

            if ~isOK || isempty(files)
                app.renderExperimentImportViewModel( ...
                    app.ExperimentPresenter ...
                    .presentFileImportCanceled());
                return
            end

            files = string(files(:));
            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>
            app.renderExperimentImportViewModel( ...
                app.ExperimentPresenter.presentImportStarted());

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory(app.directoryExp);
            outcome = app.ExperimentImportController.importFiles( ...
                experimentLocation, ...
                files, ...
                app.model);
            app.renderExperimentImportViewModel( ...
                app.ExperimentPresenter ...
                .presentFileImportOutcome(outcome));

        end

        % Button pushed function: ExpReloadButton
        function ExpReloadButtonPushed(app, ~)

            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>
            app.renderExperimentImportViewModel( ...
                app.ExperimentPresenter.presentImportStarted());

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory(app.directoryExp);
            outcome = app.ExperimentImportController.reload( ...
                experimentLocation, ...
                app.model);
            app.renderExperimentImportViewModel( ...
                app.ExperimentPresenter.presentReloadOutcome(outcome));

        end

        % Button pushed function: ExpSaveButton
        function ExpSaveButtonPushed(app, ~)

            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>
            app.renderExperimentEditViewModel( ...
                app.ExperimentPresenter.presentEditStarted());

            outcome = app.ExperimentEditController.saveInfo( ...
                app.model, ...
                app.exp, ...
                app.batch, ...
                app.ExpTable.Data);
            app.renderExperimentEditViewModel( ...
                app.ExperimentPresenter ...
                .presentInfoSaveOutcome(outcome));

        end

        % Key press function: ExpTable
        function ExpTableKeyPress(app, event)

            key = event.Key;
            modifier = event.Modifier;
            isCtrlC = any(strcmp(modifier, 'control')) && strcmp(key, 'c');
            isCtrlV = any(strcmp(modifier, 'control')) && strcmp(key, 'v');

            if isCtrlC
                app.copyTableToClipboard(app.ExpTable);
            end

            if isCtrlV
                app.pasteClipboardToTable(app.ExpTable);
            end

        end

        % Menu selected function: ViewMStableMenu
        function ViewMStableMenuSelected(app, event)

            idx = app.ExpTable.Selection;

            if isempty(idx)
                msg = openmebius.infrastructure.logging.Logger ...
                    .formatDatedMessage( ...
                    "Please select an experiment to view MS data.", ...
                "Warning");
                app.LogText(msg);
                return
            end

            if size(idx, 1) > 1
                msg = openmebius.infrastructure.logging.Logger ...
                    .formatDatedMessage( ...
                    "Please select only one experiment to view MS data.", ...
                "Warning");
                app.LogText(msg);
                return
            end

            idxRow = idx(1, 1);

            cleanupPresentation = app.beginPresentationOperation();
            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(app.exp);

            if ~presenter.hasCalculatedMDV()
                app.notifyWarning( ...
                    "MDV-derived tables have not been calculated. " + ...
                    "Press Calculate MDV in the Experiment tab before " + ...
                    "viewing MDV, biomass-corrected MDV or enrichment data.");
            end

            app.closeMSViewApp();
            context = openmebius.presentation.experiment ...
                .MSViewContext( ...
                    Presenter = presenter, ...
                    InitialExperimentIndex = idxRow, ...
                    IsDarkTheme = app.isDarkTheme());
            app.MSViewApp = MSView(context);
            app.attachMSViewListeners(app.MSViewApp);
        end

        % Button pushed function: TracerConfigButton
        function LabelConfigButtonPushed(app, ~)

            cleanupPresentation = ...
                app.beginPresentationOperation(); %#ok<NASGU>
            outcome = app.LabelConfigurationLaunchController ...
                .prepare(app.model);
            viewModel = app.LabelConfigPresenter ...
                .presentLaunchOutcome(outcome);
            app.renderLabelConfigLaunchViewModel(viewModel);
        end

        % Button pushed function: TracerReloadButton
        function TracerReloadButtonPushed(app, event)

            app.loadTracerTable();
            msg = openmebius.infrastructure.logging.Logger ...
                .formatDatedMessage( ...
                "Tracer and uptake tables reloaded", ...
            "Info");
            app.LogText(msg);
        end

        % Button pushed function: TracerSaveButton
        function TracerSaveButtonPushed(app, ~)

            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>
            app.renderExperimentEditViewModel( ...
                app.ExperimentPresenter.presentEditStarted());

            outcome = app.ExperimentEditController.saveTracer( ...
                app.model, ...
                app.exp, ...
                app.batch, ...
                app.UptakeTable.Data, ...
                app.LabelTable.Data);
            app.renderExperimentEditViewModel( ...
                app.ExperimentPresenter ...
                .presentTracerSaveOutcome(outcome));

        end

        % Double-clicked callback: LabelTable
        function LabelTableDoubleClicked(app, event)

            displayRow = event.InteractionInformation.DisplayRow;
            displayColumn = event.InteractionInformation.DisplayColumn;

            if isempty(displayRow) || isempty(displayColumn)
                return
            end

            cleanupPresentation = ...
                app.beginPresentationOperation(); %#ok<NASGU>
            position = [displayRow, displayColumn];
            outcome = app.ExperimentEditController ...
                .prepareTracerConfiguration( ...
                    app.exp, app.LabelTable.Data, position);
            viewModel = app.ExperimentPresenter ...
                .presentTracerConfigurationPreparationOutcome(outcome);
            app.renderTracerConfigurationViewModel(viewModel);
        end

        % Key press function: UptakeTable
        function UptakeTableKeyPress(app, event)

            key = event.Key;
            modifier = event.Modifier;

            isCtrlC = strcmp(key, 'c') && ismember('control', modifier);
            isCtrlV = strcmp(key, 'v') && ismember('control', modifier);

            if isCtrlC
                app.copyTableToClipboard(app.UptakeTable);
            end

            if isCtrlV
                app.pasteClipboardToTable(app.UptakeTable);
            end

        end

        % Button pushed function: RunAutoButton
        function RunAutoButtonPushed(app, ~)

            outcome = app.BatchOperationController.autoFill(app.batch);
            app.renderBatchOperationViewModel( ...
                app.BatchPresenter.presentAutoFillOutcome( ...
                    outcome, app.batch));
        end

        % Button pushed function: RunConfigButton
        function RunConfigButtonPushed(app, ~)

            requestFactory = @() app.RunConfigPresenter ...
                .createLaunchRequest( ...
                    app.RunTable.Data, app.RunTable.Selection);
            outcome = app.BatchConfigurationLaunchController.prepare( ...
                app.batch, app.exp, requestFactory);
            updateBatchTable(app);

            cleanupPresentation = app.beginPresentationOperation();
            viewModel = app.RunConfigPresenter ...
                .presentLaunchOutcome(outcome);
            app.renderRunConfigLaunchViewModel(viewModel);
        end

        % Button pushed function: RunReloadButton
        function RunReloadButtonPushed(app, ~)

            app.renderBatchOperationViewModel( ...
                app.BatchPresenter.presentReloaded(app.batch));
        end

        % Button pushed function: RunSaveButton
        function RunSaveButtonPushed(app, ~)

            outcome = app.BatchOperationController.save( ...
                app.batch, app.RunTable.Data);
            app.renderBatchOperationViewModel( ...
                app.BatchPresenter.presentSaveOutcome( ...
                    outcome, app.batch));
        end

        % Button pushed function: RunRunButton
        function RunRunButtonPushed(app, event)


            if app.Presenter.isRunning()

                app.requestPresentationCancelRun();

                app.renderBatchRunViewModel( ...
                    app.BatchPresenter.presentCancelRequested());
                app.BatchRunController.cancel(app.batch);

                return
            end

            app.beginPresentationRun();
            cleanupPresentation = onCleanup( ...
                @() app.finishPresentationRunSafely());

            app.renderBatchRunViewModel( ...
                app.BatchPresenter.presentRunStarted());

            updateBatchTable(app);

            % updateBatchTable may reset RunTable.ColumnEditable.
            app.refreshPresentation();

            outcome = app.BatchRunController.run( ...
                app.batch, app.directoryResult);
            app.renderBatchRunViewModel( ...
                app.BatchPresenter.presentRunOutcome(outcome));
            outcome.rethrowFailure();

        end

        % Menu selected function: AddbatchMenu
        function RunAddbatchMenuSelected(app, ~)

            outcome = app.BatchExperimentSelectionEditorController ...
                .prepareParallel(app.exp);
            viewModel = app.BatchExperimentSelectionEditorPresenter ...
                .presentParallelEditor(outcome);

            for notificationIndex = 1:numel(viewModel.Notifications)
                app.showNotification( ...
                    viewModel.Notifications{notificationIndex});
            end

            if ~viewModel.IsAvailable
                return
            end

            app.closeRunAddBatchApp();
            context = openmebius.presentation.batch ...
                .RunAddBatchContext(Editor = viewModel);
            app.RunAddBatchApp = RunAddBatch(context);
            app.attachRunAddBatchListeners(app.RunAddBatchApp);
        end

        % Menu selected function: RemovethisbatchMenu
        function RunRemovethisbatchMenuSelected(app, ~)

            app.removeSelectedBatches();

        end

        % Menu selected function: ParallellabelingMenu
        function RunParallellabelingMenuSelected(app, event)

        end

        % Key press function: RunTable
        function RunKeyPress(app, event)

            if strcmp(event.Key, 'delete')
                app.removeSelectedBatches();
            end

        end

        % Value changed function: ResultDropDown
        function ResultDropDownValueChanged(app, event)

            loadMainResultTable(app);
            updateResultPlot(app);
        end

        % Cell selection callback: ResultSubTable
        function ResultSubTableCellSelection(app, event)

            loadMainResultTable(app);
            updateResultPlot(app);
        end

        % Cell edit callback: ResultSubTable
        function ResultSubTableCellEdit(app, event)

        end

        % Cell selection callback: ResultMainTable
        function ResultMainTableCellSelection(app, event)

            updateResultPlot(app);
        end

        % Button pushed function: ResultReportButton
        function ResultReportButtonPushed(app, ~)

            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(app.directoryResult);
            outcome = app.ResultOperationController.generateReport( ...
                resultLocation, ...
                app.model, ...
                app.exp, ...
                app.result, ...
                IsDeployed = isdeployed);
            app.renderResultOperationViewModel( ...
                app.ResultPresenter.presentReportOutcome(outcome));

        end

        % Button pushed function: ResultReloadButton
        function ResultReloadButtonPushed(app, ~)

            app.updateResult();
            app.renderResultOperationViewModel( ...
                app.ResultPresenter.presentReloaded());
        end

        % Button pushed function: ResultSaveButton
        function ResultSaveButtonPushed(app, ~)

            [folder, isOK] = app.uiGetDirWrap( ...
                StartPath = app.directoryResult, ...
                Title = "Select Directory to Save Result Files" ...
            );

            if ~isOK
                return
            end

            selectedRows = app.selectedTableRows(app.ResultSubTable);

            if isempty(selectedRows)
                app.renderResultOperationViewModel( ...
                    app.ResultPresenter ...
                    .presentExportSelectionRequired());
                return
            end

            batchIDs = app.ResultSubTable.Data.ID;
            selectedBatchIDs = string(batchIDs(selectedRows));
            selectedBatchIDs = selectedBatchIDs(:);
            batchNames = app.ResultSubTable.Data.Name;
            selectedBatchNames = string(batchNames(selectedRows));
            selectedBatchNames = selectedBatchNames(:);
            outputLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(folder);
            outcome = app.ResultOperationController.exportResults( ...
                app.result, ...
                selectedBatchIDs, ...
                selectedBatchNames, ...
                outputLocation);
            app.renderResultOperationViewModel( ...
                app.ResultPresenter.presentExportOutcome(outcome));

        end

        % Menu selected function: ReloadWindowMenu
        function ReloadWindowMenuSelected(app, event)

            loadHistory(app)
            initLog(app)
            cleanupPresentation = app.beginPresentationOperation();

            % Reset all components
            resetAllComponents(app);

            % Reset status
            updateStatus(app, "model", "init");
            updateStatus(app, "experiment", "init");
            updateStatus(app, "batch", "init");
            updateStatus(app, "result", "init");
        end

        % Menu selected function: PreferencesMenu
        function PreferencesMenuSelected(app, event)

            try

                if ~isempty(app.PreferencesApp) && isvalid(app.PreferencesApp)
                    figure(app.PreferencesApp.PreferencesUIFigure);
                    return
                end

            catch
                app.PreferencesApp = [];
            end

            try
                app.beginPresentationPreferences();

                app.PreferencesApp = Preferences(app.SlackNotifier);

                app.attachPreferencesListeners(app.PreferencesApp);

            catch ME
                app.finishPresentationPreferences();
                app.notifyException( ...
                    ME, ...
                    Title = "Preferences failed", ...
                    Alert = true);
            end

        end

        % Menu selected function: RelativetoMenu
        function RelativetoMenuSelected(app, ~)

            selectedRows = ...
                app.selectedTableRows(app.ResultMainTable);
            viewModel = app.ResultPresenter ...
                .presentRelativeSelection( ...
                    app.ResultMainTable.RowName, ...
                    selectedRows);
            app.renderResultRelativeViewModel(viewModel);
        end

        % Menu selected function: RangeplotMenu
        function RangeplotMenuSelected(app, ~)

            selectedRows = ...
                app.selectedTableRows(app.ResultSubTable);
            batchIDs = strings(0, 1);
            batchNames = strings(0, 1);
            data = app.ResultSubTable.Data;

            if ~isempty(selectedRows) && istable(data) && ...
                    all(ismember(["ID", "Name"], ...
                        string(data.Properties.VariableNames))) && ...
                    all(selectedRows <= height(data))
                batchIDs = string(data.ID(selectedRows));
                batchNames = string(data.Name(selectedRows));
                batchIDs = batchIDs(:);
                batchNames = batchNames(:);
            end

            outcome = app.ResultOperationController.prepareRangePlot( ...
                app.result, batchIDs, batchNames);
            app.renderResultRangePlotViewModel( ...
                app.ResultPresenter.presentRangePlotOutcome(outcome));

        end

        % Menu selected function: ViewsuggestionMenu
        function ViewsuggestionMenuSelected(app, ~)

            selectedRows = ...
                app.selectedTableRows(app.ResultSubTable);
            batchIDs = strings(0, 1);
            batchNames = strings(0, 1);

            if ~isempty(selectedRows)
                batchIDs = string( ...
                    app.ResultSubTable.Data.ID(selectedRows));
                batchNames = string( ...
                    app.ResultSubTable.Data.Name(selectedRows));
                batchIDs = batchIDs(:);
                batchNames = batchNames(:);
            end

            outcome = app.ResultOperationController.loadSuggestion( ...
                app.result, batchIDs, batchNames);
            app.renderResultOperationViewModel( ...
                app.ResultPresenter.presentSuggestionOutcome(outcome));
        end

        % Menu selected function: CopythistracerforallentriesMenu
        function CopythistracerforallentriesMenuSelected(app, ~)

            currentData = app.LabelTable.Data;
            selected = app.LabelTable.Selection;

            if isempty(selected)
                app.renderExperimentEditViewModel( ...
                    app.ExperimentPresenter ...
                    .presentTracerCopySelectionRequired());
                return
            end

            outcome = app.ExperimentEditController ...
                .copyTracerToAllEntries( ...
                app.model, ...
                app.exp, ...
                app.batch, ...
                currentData, ...
                selected);
            app.renderExperimentEditViewModel( ...
                app.ExperimentPresenter ...
                .presentTracerCopyOutcome(outcome));

        end

        % Menu selected function: ImportMSdatafromtextfilesMenu
        function ImportMSdatafromtextfilesMenuSelected(app, ~)

            [importDirectory, isOK] = app.uiGetDirWrap( ...
                Title = "Select Directory Containing MS Data Text Files", ...
                StartPath = app.directoryExp);

            if ~isOK
                return
            end

            cleanupPresentation = app.beginPresentationOperation(); %#ok<NASGU>
            app.renderExperimentImportViewModel( ...
                app.ExperimentPresenter.presentImportStarted());

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory(app.directoryExp);
            outcome = app.ExperimentImportController ...
                .importShimadzuASCII( ...
                    importDirectory, ...
                    experimentLocation, ...
                    app.model);
            app.renderExperimentImportViewModel( ...
                app.ExperimentPresenter ...
                .presentRawMSImportOutcome(outcome));

        end

        % Menu selected function: OpenMebius2manualMenu
        function OpenMebius2manualMenuSelected(app, event)

            try
                msg = "Opening the OpenMebius2 manual in your web browser.";
                app.LogTextDate(msg, "Info");
                web('https://github.com/metabolic-engineering/OpenMebius2', '-browser');
            catch
                msg = "Unable to open the OpenMebius2 manual. Please check your internet connection.";
                app.LogTextDate(msg, "Error");
            end

        end

        % Menu selected function: AboutOpenMebius2Menu
        function AboutOpenMebius2MenuSelected(app, event)

            msg = "This is a test message";

            app.showNotification( ...
                openmebius.presentation.notification.Notification.info( ...
                msg, ...
                Title = "About OpenMebius2", ...
                ShowAlert = true));
        end

        % Menu selected function: ClearcacheMenu
        function ClearcacheMenuSelected(app, event)

            % Clear cache directory
            app.clearHistory();
        end

        % Menu selected function: ExporttemplateExcelfileMenu
        function ExporttemplateExcelfileMenuSelected(app, ~)


            if isempty(app.model) || ~isvalid(app.model)
                app.renderModelOperationViewModel( ...
                    app.ModelPresenter ...
                    .presentTemplateExportUnavailable());
                return
            end

            app.renderModelOperationViewModel( ...
                app.ModelPresenter.presentTemplateExportStarted());

            [file, isOK] = app.uiGetFileWrap( ...
                Filter = {'*.xlsx', 'Excel Files (*.xlsx)'}, ...
                Title = 'Save Template Excel File', ...
                MultiSelect = "off", ...
                DefaultName = "Template_MS_Table.xlsx", ...
                Save = true ...
            );

            if ~isOK
                return
            end

            cleanupPresentation = ...
                app.beginPresentationOperation(); %#ok<NASGU>
            outcome = app.ModelOperationController ...
                .exportMassSpectrometryTemplate( ...
                    app.model, string(file));
            app.renderModelOperationViewModel( ...
                app.ModelPresenter ...
                .presentTemplateExportOutcome(outcome));

        end

        % Menu selected function: ViewlogsMenu
        function ViewlogsMenuSelected(app, event)

            app.LogApp = AppLogs();
        end

        % Key press function: OpenMebius2UIFigure
        function OpenMebius2UIFigureKeyPress(app, event)

            modifier = event.Modifier;
            key = event.Key;

            % F5
            isF5 = strcmp(key, 'f5') && isempty(modifier);

            if isF5

                % TabGroup
                currentTab = app.TabGroup.SelectedTab.Title;

                switch currentTab
                    case "Stoichiometry"
                        app.ModelReloadButtonPushed();
                    case "MS"
                        app.MSReloadButtonPushed();
                    case "Experiment"
                        app.ExpReloadButtonPushed();
                    case "Tracer"
                        app.TracerReloadButtonPushed();
                    case "Batch"
                        app.RunReloadButtonPushed();
                    case "Result"
                        app.ResultReloadButtonPushed();
                end % switch

            end % if isF5

        end

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create OpenMebius2UIFigure and hide until all components are created
            app.OpenMebius2UIFigure = uifigure('Visible', 'off');
            app.OpenMebius2UIFigure.Position = [100 100 1920 1080];
            app.OpenMebius2UIFigure.Name = 'OpenMebius2';
            app.OpenMebius2UIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.OpenMebius2UIFigure.CloseRequestFcn = createCallbackFcn(app, @OpenMebius2UIFigureCloseRequest, true);
            app.OpenMebius2UIFigure.KeyPressFcn = createCallbackFcn(app, @OpenMebius2UIFigureKeyPress, true);
            app.OpenMebius2UIFigure.WindowState = 'maximized';

            % Create ApplicationMenu
            app.ApplicationMenu = uimenu(app.OpenMebius2UIFigure);
            app.ApplicationMenu.Text = 'Application';

            % Create ReloadWindowMenu
            app.ReloadWindowMenu = uimenu(app.ApplicationMenu);
            app.ReloadWindowMenu.MenuSelectedFcn = createCallbackFcn(app, @ReloadWindowMenuSelected, true);
            app.ReloadWindowMenu.Text = 'Reload Window';

            % Create ClearcacheMenu
            app.ClearcacheMenu = uimenu(app.ApplicationMenu);
            app.ClearcacheMenu.MenuSelectedFcn = createCallbackFcn(app, @ClearcacheMenuSelected, true);
            app.ClearcacheMenu.Text = 'Clear cache';

            % Create PreferencesMenu
            app.PreferencesMenu = uimenu(app.ApplicationMenu);
            app.PreferencesMenu.MenuSelectedFcn = createCallbackFcn(app, @PreferencesMenuSelected, true);
            app.PreferencesMenu.Text = 'Preferences';

            % Create ExperimentaldataMenu
            app.ExperimentaldataMenu = uimenu(app.OpenMebius2UIFigure);
            app.ExperimentaldataMenu.Text = 'Experimental data';

            % Create ExporttemplateExcelfileMenu
            app.ExporttemplateExcelfileMenu = uimenu(app.ExperimentaldataMenu);
            app.ExporttemplateExcelfileMenu.MenuSelectedFcn = createCallbackFcn(app, @ExporttemplateExcelfileMenuSelected, true);
            app.ExporttemplateExcelfileMenu.Text = 'Export template Excel file';

            % Create FilesMenu
            app.FilesMenu = uimenu(app.OpenMebius2UIFigure);
            app.FilesMenu.Text = 'Files';

            % Create ImportMSdatafromtextfilesMenu
            app.ImportMSdatafromtextfilesMenu = uimenu(app.FilesMenu);
            app.ImportMSdatafromtextfilesMenu.MenuSelectedFcn = createCallbackFcn(app, @ImportMSdatafromtextfilesMenuSelected, true);
            app.ImportMSdatafromtextfilesMenu.Text = 'Import MS data from text files';

            % Create ModelMenu
            app.ModelMenu = uimenu(app.OpenMebius2UIFigure);
            app.ModelMenu.Text = 'Model';

            % Create BatchMenu
            app.BatchMenu = uimenu(app.OpenMebius2UIFigure);
            app.BatchMenu.Text = 'Batch';

            % Create ViewMenu
            app.ViewMenu = uimenu(app.OpenMebius2UIFigure);
            app.ViewMenu.Text = 'View';

            % Create ViewReportMenu
            app.ViewReportMenu = uimenu(app.ViewMenu);
            app.ViewReportMenu.Text = 'View Report';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.OpenMebius2UIFigure);
            app.HelpMenu.Text = 'Help';

            % Create ViewlogsMenu
            app.ViewlogsMenu = uimenu(app.HelpMenu);
            app.ViewlogsMenu.MenuSelectedFcn = createCallbackFcn(app, @ViewlogsMenuSelected, true);
            app.ViewlogsMenu.Text = 'View logs';

            % Create OpenMebius2manualMenu
            app.OpenMebius2manualMenu = uimenu(app.HelpMenu);
            app.OpenMebius2manualMenu.MenuSelectedFcn = createCallbackFcn(app, @OpenMebius2manualMenuSelected, true);
            app.OpenMebius2manualMenu.Text = 'OpenMebius2 manual';

            % Create AboutOpenMebius2Menu
            app.AboutOpenMebius2Menu = uimenu(app.HelpMenu);
            app.AboutOpenMebius2Menu.MenuSelectedFcn = createCallbackFcn(app, @AboutOpenMebius2MenuSelected, true);
            app.AboutOpenMebius2Menu.Text = 'About OpenMebius2';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.OpenMebius2UIFigure);
            app.GridLayout.ColumnWidth = {'3x', '8x', '4x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'60x', '27x', '5x'};
            app.GridLayout2.RowSpacing = 5;
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 1;

            % Create ProjectPanel
            app.ProjectPanel = uipanel(app.GridLayout2);
            app.ProjectPanel.Title = 'Project';
            app.ProjectPanel.Layout.Row = 1;
            app.ProjectPanel.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.ProjectPanel);
            app.GridLayout3.ColumnWidth = {'1x'};
            app.GridLayout3.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 28, 'fit', 'fit', 'fit', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create ProjectLabel
            app.ProjectLabel = uilabel(app.GridLayout3);
            app.ProjectLabel.FontSize = 18;
            app.ProjectLabel.Layout.Row = 1;
            app.ProjectLabel.Layout.Column = 1;
            app.ProjectLabel.Text = 'Project directory';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout3);
            app.GridLayout4.ColumnWidth = {'3x', '7x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Padding = [0 0 0 0];
            app.GridLayout4.Layout.Row = 4;
            app.GridLayout4.Layout.Column = 1;

            % Create ProjectnameEditFieldLabel
            app.ProjectnameEditFieldLabel = uilabel(app.GridLayout4);
            app.ProjectnameEditFieldLabel.Layout.Row = 1;
            app.ProjectnameEditFieldLabel.Layout.Column = 1;
            app.ProjectnameEditFieldLabel.Text = 'Project name';

            % Create ProjectNameEditField
            app.ProjectNameEditField = uieditfield(app.GridLayout4, 'text');
            app.ProjectNameEditField.Layout.Row = 1;
            app.ProjectNameEditField.Layout.Column = 2;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout3);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Padding = [0 0 0 0];
            app.GridLayout5.Layout.Row = 3;
            app.GridLayout5.Layout.Column = 1;

            % Create ProjectLoadButton
            app.ProjectLoadButton = uibutton(app.GridLayout5, 'push');
            app.ProjectLoadButton.ButtonPushedFcn = createCallbackFcn(app, @ProjectLoadButtonPushed, true);
            app.ProjectLoadButton.Layout.Row = 1;
            app.ProjectLoadButton.Layout.Column = 3;
            app.ProjectLoadButton.Text = 'Load';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout3);
            app.GridLayout7.ColumnWidth = {'3x', '7x'};
            app.GridLayout7.RowHeight = {'1x'};
            app.GridLayout7.Padding = [0 0 0 0];
            app.GridLayout7.Layout.Row = 5;
            app.GridLayout7.Layout.Column = 1;

            % Create ProjectauthorEditFieldLabel
            app.ProjectauthorEditFieldLabel = uilabel(app.GridLayout7);
            app.ProjectauthorEditFieldLabel.Layout.Row = 1;
            app.ProjectauthorEditFieldLabel.Layout.Column = 1;
            app.ProjectauthorEditFieldLabel.Text = 'Project author';

            % Create ProjectAuthorEditField
            app.ProjectAuthorEditField = uieditfield(app.GridLayout7, 'text');
            app.ProjectAuthorEditField.Layout.Row = 1;
            app.ProjectAuthorEditField.Layout.Column = 2;

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout3);
            app.GridLayout8.ColumnWidth = {'3x', '7x'};
            app.GridLayout8.RowHeight = {'1x'};
            app.GridLayout8.Padding = [0 0 0 0];
            app.GridLayout8.Layout.Row = 6;
            app.GridLayout8.Layout.Column = 1;

            % Create OrganismEditFieldLabel
            app.OrganismEditFieldLabel = uilabel(app.GridLayout8);
            app.OrganismEditFieldLabel.Layout.Row = 1;
            app.OrganismEditFieldLabel.Layout.Column = 1;
            app.OrganismEditFieldLabel.Text = 'Organism';

            % Create OrganismEditField
            app.OrganismEditField = uieditfield(app.GridLayout8, 'text');
            app.OrganismEditField.Layout.Row = 1;
            app.OrganismEditField.Layout.Column = 2;

            % Create GridLayout5_2
            app.GridLayout5_2 = uigridlayout(app.GridLayout3);
            app.GridLayout5_2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout5_2.RowHeight = {'1x'};
            app.GridLayout5_2.Padding = [0 0 0 0];
            app.GridLayout5_2.Layout.Row = 7;
            app.GridLayout5_2.Layout.Column = 1;

            % Create ProjectSaveButton
            app.ProjectSaveButton = uibutton(app.GridLayout5_2, 'push');
            app.ProjectSaveButton.ButtonPushedFcn = createCallbackFcn(app, @ProjectSaveButtonPushed, true);
            app.ProjectSaveButton.Layout.Row = 1;
            app.ProjectSaveButton.Layout.Column = 3;
            app.ProjectSaveButton.Text = 'Save';

            % Create ProjectLabel_2
            app.ProjectLabel_2 = uilabel(app.GridLayout3);
            app.ProjectLabel_2.FontSize = 18;
            app.ProjectLabel_2.Layout.Row = 8;
            app.ProjectLabel_2.Layout.Column = 1;
            app.ProjectLabel_2.Text = 'Template model file';

            % Create GridLayout5_3
            app.GridLayout5_3 = uigridlayout(app.GridLayout3);
            app.GridLayout5_3.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout5_3.RowHeight = {'1x'};
            app.GridLayout5_3.Padding = [0 0 0 0];
            app.GridLayout5_3.Layout.Row = 10;
            app.GridLayout5_3.Layout.Column = 1;

            % Create TemplateModelLoadButton
            app.TemplateModelLoadButton = uibutton(app.GridLayout5_3, 'push');
            app.TemplateModelLoadButton.ButtonPushedFcn = createCallbackFcn(app, @TemplateModelLoadButtonPushed, true);
            app.TemplateModelLoadButton.Layout.Row = 1;
            app.TemplateModelLoadButton.Layout.Column = 3;
            app.TemplateModelLoadButton.Text = 'Load';

            % Create TemplateModelSaveButton
            app.TemplateModelSaveButton = uibutton(app.GridLayout3, 'push');
            app.TemplateModelSaveButton.ButtonPushedFcn = createCallbackFcn(app, @TemplateModelSaveButtonPushed, true);
            app.TemplateModelSaveButton.Enable = 'off';
            app.TemplateModelSaveButton.Layout.Row = 11;
            app.TemplateModelSaveButton.Layout.Column = 1;
            app.TemplateModelSaveButton.Text = 'Save model as template';

            % Create ProjectCreateButton
            app.ProjectCreateButton = uibutton(app.GridLayout3, 'push');
            app.ProjectCreateButton.ButtonPushedFcn = createCallbackFcn(app, @ProjectCreateButtonPushed, true);
            app.ProjectCreateButton.Enable = 'off';
            app.ProjectCreateButton.Layout.Row = 12;
            app.ProjectCreateButton.Layout.Column = 1;
            app.ProjectCreateButton.Text = 'Create project from template model';

            % Create GridLayout16
            app.GridLayout16 = uigridlayout(app.GridLayout3);
            app.GridLayout16.ColumnWidth = {'7x', '3x'};
            app.GridLayout16.RowHeight = {'1x'};
            app.GridLayout16.Padding = [0 0 0 0];
            app.GridLayout16.Layout.Row = 2;
            app.GridLayout16.Layout.Column = 1;

            % Create ProjectDirectoryDropDown
            app.ProjectDirectoryDropDown = uidropdown(app.GridLayout16);
            app.ProjectDirectoryDropDown.Items = {};
            app.ProjectDirectoryDropDown.Editable = 'on';
            app.ProjectDirectoryDropDown.ValueChangedFcn = createCallbackFcn(app, @ProjectDirectoryDropDownValueChanged, true);
            app.ProjectDirectoryDropDown.Layout.Row = 1;
            app.ProjectDirectoryDropDown.Layout.Column = 1;
            app.ProjectDirectoryDropDown.Value = {};

            % Create ProjectBrowseButton
            app.ProjectBrowseButton = uibutton(app.GridLayout16, 'push');
            app.ProjectBrowseButton.ButtonPushedFcn = createCallbackFcn(app, @ProjectBrowseButtonPushed, true);
            app.ProjectBrowseButton.Layout.Row = 1;
            app.ProjectBrowseButton.Layout.Column = 2;
            app.ProjectBrowseButton.Text = 'Browse';

            % Create GridLayout16_2
            app.GridLayout16_2 = uigridlayout(app.GridLayout3);
            app.GridLayout16_2.ColumnWidth = {'7x', '3x'};
            app.GridLayout16_2.RowHeight = {'1x'};
            app.GridLayout16_2.Padding = [0 0 0 0];
            app.GridLayout16_2.Layout.Row = 9;
            app.GridLayout16_2.Layout.Column = 1;

            % Create TemplateModelDirectoryDropDown
            app.TemplateModelDirectoryDropDown = uidropdown(app.GridLayout16_2);
            app.TemplateModelDirectoryDropDown.Items = {};
            app.TemplateModelDirectoryDropDown.Editable = 'on';
            app.TemplateModelDirectoryDropDown.ValueChangedFcn = createCallbackFcn(app, @TemplateModelDirectoryDropDownValueChanged, true);
            app.TemplateModelDirectoryDropDown.Layout.Row = 1;
            app.TemplateModelDirectoryDropDown.Layout.Column = 1;
            app.TemplateModelDirectoryDropDown.Value = {};

            % Create TemplateModelBrowseButton
            app.TemplateModelBrowseButton = uibutton(app.GridLayout16_2, 'push');
            app.TemplateModelBrowseButton.ButtonPushedFcn = createCallbackFcn(app, @TemplateModelBrowseButtonPushed, true);
            app.TemplateModelBrowseButton.Layout.Row = 1;
            app.TemplateModelBrowseButton.Layout.Column = 2;
            app.TemplateModelBrowseButton.Text = 'Browse';

            % Create StatusHTML
            app.StatusHTML = uihtml(app.GridLayout2);
            app.StatusHTML.Layout.Row = 2;
            app.StatusHTML.Layout.Column = 1;

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout);
            app.GridLayout9.ColumnWidth = {'1x'};
            app.GridLayout9.RowHeight = {'7x', '3x'};
            app.GridLayout9.Padding = [0 0 0 0];
            app.GridLayout9.Layout.Row = 1;
            app.GridLayout9.Layout.Column = 2;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout9);
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = 1;

            % Create StoichiometryTab
            app.StoichiometryTab = uitab(app.TabGroup);
            app.StoichiometryTab.Title = 'Stoichiometry';

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.StoichiometryTab);
            app.GridLayout11.ColumnWidth = {'1x'};
            app.GridLayout11.RowHeight = {'1x', 'fit'};

            % Create ModelTable
            app.ModelTable = uitable(app.GridLayout11);
            app.ModelTable.ColumnName = '';
            app.ModelTable.RowName = {};
            app.ModelTable.CellSelectionCallback = createCallbackFcn(app, @ModelTableCellSelection, true);
            app.ModelTable.Multiselect = 'off';
            app.ModelTable.Enable = 'off';
            app.ModelTable.Layout.Row = 1;
            app.ModelTable.Layout.Column = 1;

            % Create GridLayout12
            app.GridLayout12 = uigridlayout(app.GridLayout11);
            app.GridLayout12.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout12.RowHeight = {'1x'};
            app.GridLayout12.Layout.Row = 2;
            app.GridLayout12.Layout.Column = 1;

            % Create ModelSaveButton
            app.ModelSaveButton = uibutton(app.GridLayout12, 'push');
            app.ModelSaveButton.ButtonPushedFcn = createCallbackFcn(app, @ModelSaveButtonPushed, true);
            app.ModelSaveButton.Enable = 'off';
            app.ModelSaveButton.Layout.Row = 1;
            app.ModelSaveButton.Layout.Column = 8;
            app.ModelSaveButton.Text = 'Save';

            % Create ModelEditButton
            app.ModelEditButton = uibutton(app.GridLayout12, 'push');
            app.ModelEditButton.ButtonPushedFcn = createCallbackFcn(app, @ModelEditButtonPushed, true);
            app.ModelEditButton.Enable = 'off';
            app.ModelEditButton.Layout.Row = 1;
            app.ModelEditButton.Layout.Column = 7;
            app.ModelEditButton.Text = 'Edit';

            % Create ModelReloadButton
            app.ModelReloadButton = uibutton(app.GridLayout12, 'push');
            app.ModelReloadButton.ButtonPushedFcn = createCallbackFcn(app, @ModelReloadButtonPushed, true);
            app.ModelReloadButton.Enable = 'off';
            app.ModelReloadButton.Layout.Row = 1;
            app.ModelReloadButton.Layout.Column = 6;
            app.ModelReloadButton.Text = 'Reload';

            % Create MSTab
            app.MSTab = uitab(app.TabGroup);
            app.MSTab.Title = 'MS';

            % Create GridLayout11_2
            app.GridLayout11_2 = uigridlayout(app.MSTab);
            app.GridLayout11_2.ColumnWidth = {'1x'};
            app.GridLayout11_2.RowHeight = {'1x', 'fit'};

            % Create GridLayout12_2
            app.GridLayout12_2 = uigridlayout(app.GridLayout11_2);
            app.GridLayout12_2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout12_2.RowHeight = {'1x'};
            app.GridLayout12_2.Layout.Row = 2;
            app.GridLayout12_2.Layout.Column = 1;

            % Create MSSaveButton
            app.MSSaveButton = uibutton(app.GridLayout12_2, 'push');
            app.MSSaveButton.ButtonPushedFcn = createCallbackFcn(app, @MSSaveButtonPushed, true);
            app.MSSaveButton.Enable = 'off';
            app.MSSaveButton.Layout.Row = 1;
            app.MSSaveButton.Layout.Column = 8;
            app.MSSaveButton.Text = 'Save';

            % Create MSEditButton
            app.MSEditButton = uibutton(app.GridLayout12_2, 'push');
            app.MSEditButton.ButtonPushedFcn = createCallbackFcn(app, @MSEditButtonPushed, true);
            app.MSEditButton.Enable = 'off';
            app.MSEditButton.Layout.Row = 1;
            app.MSEditButton.Layout.Column = 7;
            app.MSEditButton.Text = 'Edit';

            % Create MSReloadButton
            app.MSReloadButton = uibutton(app.GridLayout12_2, 'push');
            app.MSReloadButton.ButtonPushedFcn = createCallbackFcn(app, @MSReloadButtonPushed, true);
            app.MSReloadButton.Enable = 'off';
            app.MSReloadButton.Layout.Row = 1;
            app.MSReloadButton.Layout.Column = 6;
            app.MSReloadButton.Text = 'Reload';

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.GridLayout11_2);
            app.GridLayout13.ColumnWidth = {'6x', '4x'};
            app.GridLayout13.RowHeight = {'1x'};
            app.GridLayout13.Padding = [0 0 0 0];
            app.GridLayout13.Layout.Row = 1;
            app.GridLayout13.Layout.Column = 1;

            % Create MSTable
            app.MSTable = uitable(app.GridLayout13);
            app.MSTable.ColumnName = '';
            app.MSTable.RowName = {};
            app.MSTable.Multiselect = 'off';
            app.MSTable.Enable = 'off';
            app.MSTable.Layout.Row = 1;
            app.MSTable.Layout.Column = 1;

            % Create AtomTable
            app.AtomTable = uitable(app.GridLayout13);
            app.AtomTable.ColumnName = '';
            app.AtomTable.RowName = {};
            app.AtomTable.Multiselect = 'off';
            app.AtomTable.Enable = 'off';
            app.AtomTable.Layout.Row = 1;
            app.AtomTable.Layout.Column = 2;

            % Create ExperimentTab
            app.ExperimentTab = uitab(app.TabGroup);
            app.ExperimentTab.Title = 'Experiment';

            % Create GridLayout11_3
            app.GridLayout11_3 = uigridlayout(app.ExperimentTab);
            app.GridLayout11_3.ColumnWidth = {'1x'};
            app.GridLayout11_3.RowHeight = {'1x', 'fit'};

            % Create GridLayout12_3
            app.GridLayout12_3 = uigridlayout(app.GridLayout11_3);
            app.GridLayout12_3.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout12_3.RowHeight = {'1x'};
            app.GridLayout12_3.Layout.Row = 2;
            app.GridLayout12_3.Layout.Column = 1;

            % Create ExpSaveButton
            app.ExpSaveButton = uibutton(app.GridLayout12_3, 'push');
            app.ExpSaveButton.ButtonPushedFcn = createCallbackFcn(app, @ExpSaveButtonPushed, true);
            app.ExpSaveButton.Enable = 'off';
            app.ExpSaveButton.Layout.Row = 1;
            app.ExpSaveButton.Layout.Column = 8;
            app.ExpSaveButton.Text = 'Save';

            % Create ExpReloadButton
            app.ExpReloadButton = uibutton(app.GridLayout12_3, 'push');
            app.ExpReloadButton.ButtonPushedFcn = createCallbackFcn(app, @ExpReloadButtonPushed, true);
            app.ExpReloadButton.Enable = 'off';
            app.ExpReloadButton.Layout.Row = 1;
            app.ExpReloadButton.Layout.Column = 7;
            app.ExpReloadButton.Text = 'Reload';

            % Create ExpImportButton
            app.ExpImportButton = uibutton(app.GridLayout12_3, 'push');
            app.ExpImportButton.ButtonPushedFcn = createCallbackFcn(app, @ExpImportButtonPushed, true);
            app.ExpImportButton.Enable = 'off';
            app.ExpImportButton.Layout.Row = 1;
            app.ExpImportButton.Layout.Column = 6;
            app.ExpImportButton.Text = 'Import data';

            % Create ExpCalculationButton
            app.ExpCalculationButton = uibutton(app.GridLayout12_3, 'push');
            app.ExpCalculationButton.ButtonPushedFcn = createCallbackFcn(app, @ExpCalculationButtonPushed, true);
            app.ExpCalculationButton.Enable = 'off';
            app.ExpCalculationButton.Layout.Row = 1;
            app.ExpCalculationButton.Layout.Column = 5;
            app.ExpCalculationButton.Text = 'Calculate';

            % Create GridLayout13_2
            app.GridLayout13_2 = uigridlayout(app.GridLayout11_3);
            app.GridLayout13_2.ColumnWidth = {'7x', '3x'};
            app.GridLayout13_2.RowHeight = {'1x'};
            app.GridLayout13_2.Padding = [0 0 0 0];
            app.GridLayout13_2.Layout.Row = 1;
            app.GridLayout13_2.Layout.Column = 1;

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.GridLayout13_2);
            app.GridLayout14.ColumnWidth = {'1x'};
            app.GridLayout14.RowHeight = {'1x'};
            app.GridLayout14.Padding = [0 0 0 0];
            app.GridLayout14.Layout.Row = 1;
            app.GridLayout14.Layout.Column = 2;

            % Create BiomassTable
            app.BiomassTable = uitable(app.GridLayout14);
            app.BiomassTable.ColumnName = '';
            app.BiomassTable.RowName = {};
            app.BiomassTable.Enable = 'off';
            app.BiomassTable.Layout.Row = 1;
            app.BiomassTable.Layout.Column = 1;

            % Create ExpTable
            app.ExpTable = uitable(app.GridLayout13_2);
            app.ExpTable.ColumnName = '';
            app.ExpTable.RowName = {};
            app.ExpTable.Enable = 'off';
            app.ExpTable.KeyPressFcn = createCallbackFcn(app, @ExpTableKeyPress, true);
            app.ExpTable.Layout.Row = 1;
            app.ExpTable.Layout.Column = 1;

            % Create TracerTab
            app.TracerTab = uitab(app.TabGroup);
            app.TracerTab.Title = 'Tracer';

            % Create GridLayout11_4
            app.GridLayout11_4 = uigridlayout(app.TracerTab);
            app.GridLayout11_4.ColumnWidth = {'1x'};
            app.GridLayout11_4.RowHeight = {'1x', 'fit'};

            % Create GridLayout12_4
            app.GridLayout12_4 = uigridlayout(app.GridLayout11_4);
            app.GridLayout12_4.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout12_4.RowHeight = {'1x'};
            app.GridLayout12_4.Layout.Row = 2;
            app.GridLayout12_4.Layout.Column = 1;

            % Create TracerSaveButton
            app.TracerSaveButton = uibutton(app.GridLayout12_4, 'push');
            app.TracerSaveButton.ButtonPushedFcn = createCallbackFcn(app, @TracerSaveButtonPushed, true);
            app.TracerSaveButton.Enable = 'off';
            app.TracerSaveButton.Layout.Row = 1;
            app.TracerSaveButton.Layout.Column = 8;
            app.TracerSaveButton.Text = 'Save';

            % Create TracerReloadButton
            app.TracerReloadButton = uibutton(app.GridLayout12_4, 'push');
            app.TracerReloadButton.ButtonPushedFcn = createCallbackFcn(app, @TracerReloadButtonPushed, true);
            app.TracerReloadButton.Enable = 'off';
            app.TracerReloadButton.Layout.Row = 1;
            app.TracerReloadButton.Layout.Column = 7;
            app.TracerReloadButton.Text = 'Reload';

            % Create TracerConfigButton
            app.TracerConfigButton = uibutton(app.GridLayout12_4, 'push');
            app.TracerConfigButton.ButtonPushedFcn = createCallbackFcn(app, @LabelConfigButtonPushed, true);
            app.TracerConfigButton.Enable = 'off';
            app.TracerConfigButton.Layout.Row = 1;
            app.TracerConfigButton.Layout.Column = 6;
            app.TracerConfigButton.Text = 'Config';

            % Create GridLayout15
            app.GridLayout15 = uigridlayout(app.GridLayout11_4);
            app.GridLayout15.ColumnWidth = {'5x', '5x'};
            app.GridLayout15.RowHeight = {'1x'};
            app.GridLayout15.Padding = [0 0 0 0];
            app.GridLayout15.Layout.Row = 1;
            app.GridLayout15.Layout.Column = 1;

            % Create UptakeTable
            app.UptakeTable = uitable(app.GridLayout15);
            app.UptakeTable.ColumnName = '';
            app.UptakeTable.RowName = {};
            app.UptakeTable.Enable = 'off';
            app.UptakeTable.KeyPressFcn = createCallbackFcn(app, @UptakeTableKeyPress, true);
            app.UptakeTable.Layout.Row = 1;
            app.UptakeTable.Layout.Column = 1;

            % Create LabelTable
            app.LabelTable = uitable(app.GridLayout15);
            app.LabelTable.ColumnName = '';
            app.LabelTable.RowName = {};
            app.LabelTable.DoubleClickedFcn = createCallbackFcn(app, @LabelTableDoubleClicked, true);
            app.LabelTable.Enable = 'off';
            app.LabelTable.Layout.Row = 1;
            app.LabelTable.Layout.Column = 2;

            % Create RunTab
            app.RunTab = uitab(app.TabGroup);
            app.RunTab.Title = 'Run';

            % Create GridLayout11_5
            app.GridLayout11_5 = uigridlayout(app.RunTab);
            app.GridLayout11_5.ColumnWidth = {'1x'};
            app.GridLayout11_5.RowHeight = {'1x', 'fit'};

            % Create RunTable
            app.RunTable = uitable(app.GridLayout11_5);
            app.RunTable.ColumnName = '';
            app.RunTable.RowName = {};
            app.RunTable.Enable = 'off';
            app.RunTable.KeyPressFcn = createCallbackFcn(app, @RunKeyPress, true);
            app.RunTable.Layout.Row = 1;
            app.RunTable.Layout.Column = 1;

            % Create GridLayout12_5
            app.GridLayout12_5 = uigridlayout(app.GridLayout11_5);
            app.GridLayout12_5.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout12_5.RowHeight = {'1x'};
            app.GridLayout12_5.Layout.Row = 2;
            app.GridLayout12_5.Layout.Column = 1;

            % Create RunRunButton
            app.RunRunButton = uibutton(app.GridLayout12_5, 'push');
            app.RunRunButton.ButtonPushedFcn = createCallbackFcn(app, @RunRunButtonPushed, true);
            app.RunRunButton.Enable = 'off';
            app.RunRunButton.Layout.Row = 1;
            app.RunRunButton.Layout.Column = 8;
            app.RunRunButton.Text = 'Run';

            % Create RunSaveButton
            app.RunSaveButton = uibutton(app.GridLayout12_5, 'push');
            app.RunSaveButton.ButtonPushedFcn = createCallbackFcn(app, @RunSaveButtonPushed, true);
            app.RunSaveButton.Enable = 'off';
            app.RunSaveButton.Layout.Row = 1;
            app.RunSaveButton.Layout.Column = 7;
            app.RunSaveButton.Text = 'Save';

            % Create RunReloadButton
            app.RunReloadButton = uibutton(app.GridLayout12_5, 'push');
            app.RunReloadButton.ButtonPushedFcn = createCallbackFcn(app, @RunReloadButtonPushed, true);
            app.RunReloadButton.Enable = 'off';
            app.RunReloadButton.Layout.Row = 1;
            app.RunReloadButton.Layout.Column = 6;
            app.RunReloadButton.Text = 'Reload';

            % Create RunConfigButton
            app.RunConfigButton = uibutton(app.GridLayout12_5, 'push');
            app.RunConfigButton.ButtonPushedFcn = createCallbackFcn(app, @RunConfigButtonPushed, true);
            app.RunConfigButton.Enable = 'off';
            app.RunConfigButton.Layout.Row = 1;
            app.RunConfigButton.Layout.Column = 5;
            app.RunConfigButton.Text = 'Config';

            % Create RunAutoButton
            app.RunAutoButton = uibutton(app.GridLayout12_5, 'push');
            app.RunAutoButton.ButtonPushedFcn = createCallbackFcn(app, @RunAutoButtonPushed, true);
            app.RunAutoButton.Enable = 'off';
            app.RunAutoButton.Layout.Row = 1;
            app.RunAutoButton.Layout.Column = 4;
            app.RunAutoButton.Text = 'Auto';

            % Create ResultTab
            app.ResultTab = uitab(app.TabGroup);
            app.ResultTab.Title = 'Result';

            % Create GridLayout11_6
            app.GridLayout11_6 = uigridlayout(app.ResultTab);
            app.GridLayout11_6.ColumnWidth = {'1x'};
            app.GridLayout11_6.RowHeight = {'fit', '1x', 'fit'};

            % Create GridLayout12_6
            app.GridLayout12_6 = uigridlayout(app.GridLayout11_6);
            app.GridLayout12_6.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout12_6.RowHeight = {'1x'};
            app.GridLayout12_6.Layout.Row = 3;
            app.GridLayout12_6.Layout.Column = 1;

            % Create ResultSaveButton
            app.ResultSaveButton = uibutton(app.GridLayout12_6, 'push');
            app.ResultSaveButton.ButtonPushedFcn = createCallbackFcn(app, @ResultSaveButtonPushed, true);
            app.ResultSaveButton.Enable = 'off';
            app.ResultSaveButton.Layout.Row = 1;
            app.ResultSaveButton.Layout.Column = 8;
            app.ResultSaveButton.Text = 'Save';

            % Create ResultReloadButton
            app.ResultReloadButton = uibutton(app.GridLayout12_6, 'push');
            app.ResultReloadButton.ButtonPushedFcn = createCallbackFcn(app, @ResultReloadButtonPushed, true);
            app.ResultReloadButton.Enable = 'off';
            app.ResultReloadButton.Layout.Row = 1;
            app.ResultReloadButton.Layout.Column = 7;
            app.ResultReloadButton.Text = 'Reload';

            % Create ResultReportButton
            app.ResultReportButton = uibutton(app.GridLayout12_6, 'push');
            app.ResultReportButton.ButtonPushedFcn = createCallbackFcn(app, @ResultReportButtonPushed, true);
            app.ResultReportButton.Enable = 'off';
            app.ResultReportButton.Layout.Row = 1;
            app.ResultReportButton.Layout.Column = 6;
            app.ResultReportButton.Text = 'Report';

            % Create GridLayout12_7
            app.GridLayout12_7 = uigridlayout(app.GridLayout11_6);
            app.GridLayout12_7.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout12_7.RowHeight = {'1x'};
            app.GridLayout12_7.Layout.Row = 1;
            app.GridLayout12_7.Layout.Column = 1;

            % Create ResultDropDown
            app.ResultDropDown = uidropdown(app.GridLayout12_7);
            app.ResultDropDown.Items = {'Overview', 'Details', 'Comparison'};
            app.ResultDropDown.ValueChangedFcn = createCallbackFcn(app, @ResultDropDownValueChanged, true);
            app.ResultDropDown.Enable = 'off';
            app.ResultDropDown.Layout.Row = 1;
            app.ResultDropDown.Layout.Column = 1;
            app.ResultDropDown.Value = 'Overview';

            % Create GridLayout15_2
            app.GridLayout15_2 = uigridlayout(app.GridLayout11_6);
            app.GridLayout15_2.ColumnWidth = {'4x', '6x'};
            app.GridLayout15_2.RowHeight = {'1x'};
            app.GridLayout15_2.Padding = [0 0 0 0];
            app.GridLayout15_2.Layout.Row = 2;
            app.GridLayout15_2.Layout.Column = 1;

            % Create ResultMainTable
            app.ResultMainTable = uitable(app.GridLayout15_2);
            app.ResultMainTable.ColumnName = '';
            app.ResultMainTable.RowName = {};
            app.ResultMainTable.SelectionType = 'row';
            app.ResultMainTable.CellSelectionCallback = createCallbackFcn(app, @ResultMainTableCellSelection, true);
            app.ResultMainTable.Enable = 'off';
            app.ResultMainTable.Layout.Row = 1;
            app.ResultMainTable.Layout.Column = 2;

            % Create ResultSubTable
            app.ResultSubTable = uitable(app.GridLayout15_2);
            app.ResultSubTable.ColumnName = '';
            app.ResultSubTable.RowName = {};
            app.ResultSubTable.SelectionType = 'row';
            app.ResultSubTable.RowStriping = 'off';
            app.ResultSubTable.CellEditCallback = createCallbackFcn(app, @ResultSubTableCellEdit, true);
            app.ResultSubTable.CellSelectionCallback = createCallbackFcn(app, @ResultSubTableCellSelection, true);
            app.ResultSubTable.Enable = 'off';
            app.ResultSubTable.Layout.Row = 1;
            app.ResultSubTable.Layout.Column = 1;

            % Create LogTextArea
            app.LogTextArea = uitextarea(app.GridLayout9);
            app.LogTextArea.Editable = 'off';
            app.LogTextArea.FontSize = 14;
            app.LogTextArea.Layout.Row = 2;
            app.LogTextArea.Layout.Column = 1;

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout);
            app.GridLayout10.ColumnWidth = {'1x'};
            app.GridLayout10.RowHeight = {'6x', '4x'};
            app.GridLayout10.Padding = [0 0 0 0];
            app.GridLayout10.Layout.Row = 1;
            app.GridLayout10.Layout.Column = 3;

            % Create MainUIAxes
            app.MainUIAxes = uiaxes(app.GridLayout10);
            title(app.MainUIAxes, 'Title')
            xlabel(app.MainUIAxes, 'X')
            ylabel(app.MainUIAxes, 'Y')
            zlabel(app.MainUIAxes, 'Z')
            app.MainUIAxes.Layout.Row = 1;
            app.MainUIAxes.Layout.Column = 1;
            app.MainUIAxes.Visible = 'off';

            % Create SubUIAxes
            app.SubUIAxes = uiaxes(app.GridLayout10);
            title(app.SubUIAxes, 'Title')
            xlabel(app.SubUIAxes, 'X')
            ylabel(app.SubUIAxes, 'Y')
            zlabel(app.SubUIAxes, 'Z')
            app.SubUIAxes.Layout.Row = 2;
            app.SubUIAxes.Layout.Column = 1;
            app.SubUIAxes.Visible = 'off';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.OpenMebius2UIFigure);

            % Create AddLabelMenu
            app.AddLabelMenu = uimenu(app.ContextMenu);
            app.AddLabelMenu.MenuSelectedFcn = createCallbackFcn(app, @AddLabelMenuSelected, true);
            app.AddLabelMenu.Text = 'Add Label';

            % Create RemoveLabelMenu
            app.RemoveLabelMenu = uimenu(app.ContextMenu);
            app.RemoveLabelMenu.MenuSelectedFcn = createCallbackFcn(app, @RemoveLabelMenuSelected, true);
            app.RemoveLabelMenu.Text = 'Remove Label';

            % Assign app.ContextMenu
            app.MainUIAxes.ContextMenu = app.ContextMenu;

            % Create ExperimentContextMenu
            app.ExperimentContextMenu = uicontextmenu(app.OpenMebius2UIFigure);

            % Create ViewMStableMenu
            app.ViewMStableMenu = uimenu(app.ExperimentContextMenu);
            app.ViewMStableMenu.MenuSelectedFcn = createCallbackFcn(app, @ViewMStableMenuSelected, true);
            app.ViewMStableMenu.Text = 'View MS table';

            % Assign app.ExperimentContextMenu
            app.ExpTable.ContextMenu = app.ExperimentContextMenu;

            % Create ContextMenuRun
            app.ContextMenuRun = uicontextmenu(app.OpenMebius2UIFigure);

            % Create AddbatchMenu
            app.AddbatchMenu = uimenu(app.ContextMenuRun);
            app.AddbatchMenu.MenuSelectedFcn = createCallbackFcn(app, @RunAddbatchMenuSelected, true);
            app.AddbatchMenu.Text = 'Add batch';

            % Create RemovethisbatchMenu
            app.RemovethisbatchMenu = uimenu(app.ContextMenuRun);
            app.RemovethisbatchMenu.MenuSelectedFcn = createCallbackFcn(app, @RunRemovethisbatchMenuSelected, true);
            app.RemovethisbatchMenu.Text = 'Remove this batch';

            % Create ParallellabelingMenu
            app.ParallellabelingMenu = uimenu(app.ContextMenuRun);
            app.ParallellabelingMenu.MenuSelectedFcn = createCallbackFcn(app, @RunParallellabelingMenuSelected, true);
            app.ParallellabelingMenu.Text = 'Parallel labeling';

            % Assign app.ContextMenuRun
            app.RunTable.ContextMenu = app.ContextMenuRun;

            % Create ContextMenu2
            app.ContextMenu2 = uicontextmenu(app.OpenMebius2UIFigure);

            % Create RelativetoMenu
            app.RelativetoMenu = uimenu(app.ContextMenu2);
            app.RelativetoMenu.MenuSelectedFcn = createCallbackFcn(app, @RelativetoMenuSelected, true);
            app.RelativetoMenu.Text = 'Relative to ...';

            % Assign app.ContextMenu2
            app.ResultMainTable.ContextMenu = app.ContextMenu2;

            % Create ContextMenuResultSelect
            app.ContextMenuResultSelect = uicontextmenu(app.OpenMebius2UIFigure);

            % Create RangeplotMenu
            app.RangeplotMenu = uimenu(app.ContextMenuResultSelect);
            app.RangeplotMenu.MenuSelectedFcn = createCallbackFcn(app, @RangeplotMenuSelected, true);
            app.RangeplotMenu.Text = 'Range plot';

            % Create ViewsuggestionMenu
            app.ViewsuggestionMenu = uimenu(app.ContextMenuResultSelect);
            app.ViewsuggestionMenu.MenuSelectedFcn = createCallbackFcn(app, @ViewsuggestionMenuSelected, true);
            app.ViewsuggestionMenu.Text = 'View suggestion';

            % Assign app.ContextMenuResultSelect
            app.ResultSubTable.ContextMenu = app.ContextMenuResultSelect;

            % Create ContextMenu3
            app.ContextMenu3 = uicontextmenu(app.OpenMebius2UIFigure);

            % Create CopythistracerforallentriesMenu
            app.CopythistracerforallentriesMenu = uimenu(app.ContextMenu3);
            app.CopythistracerforallentriesMenu.MenuSelectedFcn = createCallbackFcn(app, @CopythistracerforallentriesMenuSelected, true);
            app.CopythistracerforallentriesMenu.Text = 'Copy this tracer for all entries';

            % Assign app.ContextMenu3
            app.LabelTable.ContextMenu = app.ContextMenu3;

            % Show the figure after all components are created
            app.OpenMebius2UIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = OpenMebius2_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.OpenMebius2UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end

        end

        % Code that executes before app deletion
        function delete(app)

            app.closeLabelConfigApp();
            app.closeTracerConfigApp();
            app.closeMSViewApp();
            app.closeComparisonViewApp();
            app.closeRunConfigApp();
            app.closeRunAddBatchApp();

            if app.isLoadedObject(app.RangePlotFigure)
                delete(app.RangePlotFigure);
            end

            % Delete UIFigure when app is deleted
            delete(app.OpenMebius2UIFigure)
        end

    end

end
