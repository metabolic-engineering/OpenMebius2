classdef OpenMebius2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        OpenMebius2UIFigure matlab.ui.Figure
        ApplicationMenu matlab.ui.container.Menu
        ReloadWindowMenu matlab.ui.container.Menu
        ClearcacheMenu matlab.ui.container.Menu
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
        RunAddBatchApp;
        ViewSuggestionApp;
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

        Presenter openmebius.presentation.main.MainPresenter

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

            text_before = app.LogTextArea.Value;
            app.LogTextArea.Value = [text_before; text];

            scroll(app.LogTextArea, 'bottom')

            drawnow

        end % function LogText

        function LogTextDate(app, text, level)

            arguments
                app OpenMebius2
                text string
                level string
            end

            % if model is not defined, just log the text
            if isempty(app.model) || ~isvalid(app.model)
                app.LogText(text)
                return
            end

            msg = app.model.returnDateMsg(text, level);
            app.LogText(msg)

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

        function updateModel(app)

            if isempty(app.model) || ~isvalid(app.model)
                return
            elseif isempty(app.exp) || ~isvalid(app.exp)
                msg = "Experiment data is not loaded. Cannot update model.";
                LogTextDate(app, msg, "Error");
                return
            elseif isempty(app.batch) || ~isvalid(app.batch)
                msg = "Batch data is not loaded. Cannot update model.";
                LogTextDate(app, msg, "Error");
                return
            end

            app.exp.updateModel(app.model);
            app.batch.updateExperimentalData(app.exp);

        end % method updateModel

        function updateBatchTable(app)
            % UPDATEBATCHTABLE Update the batch table with the current batch data

            % Update the batch table with the new data
            removeStyle(app.RunTable);
            loadBatchTable(app, reload = true);

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
        function [folder, isOK] = uiGetDirWrap(~, options)
            % uiGetDirWrap - uigetdir wrapper with flexible texts
            %
            % Usage:
            %   [folder,isOK] = uiGetDirWrap(struct("Title","保存先を選択","StartPath",pwd));
            %   [folder,isOK] = uiGetDirWrap(struct("Parent",app.UIFigure,"Title","Select folder"));
            %
            % options (struct)
            %   Parent    : (optional) uifigure handle for App Designer
            %   Title     : dialog title (string)
            %   StartPath : initial folder (string)

            arguments
                ~
                options.Parent = []
                options.Title (1, 1) string = "Select folder"
                options.StartPath (1, 1) string = string(pwd)
            end

            % uigetdir does not accept Parent in older MATLAB versions.
            % So we keep interface but call uigetdir with (startPath,title).
            folder0 = char(options.StartPath);
            title0 = char(options.Title);

            out = uigetdir(folder0, title0);

            if isequal(out, 0)
                folder = "";
                isOK = false;
            else
                folder = string(out);
                isOK = true;
            end

        end % function uiGetDirWrap

        function [files, isOK] = uiGetFileWrap(~, options)
            % uiGetFileWrap - uigetfile/uiputfile wrapper with flexible texts

            arguments
                ~
                options.Parent = []
                options.Filter = "*.*"
                options.Title (1, 1) string = "Select file"
                options.StartPath (1, 1) string = string(pwd)
                options.MultiSelect (1, 1) string {mustBeMember(options.MultiSelect, ["off", "on"])} = "off"
                options.Save (1, 1) logical = false
                options.DefaultName (1, 1) string = ""
            end

            % ---- normalize filter spec ----
            filterSpec = options.Filter;

            if isstring(filterSpec) && isscalar(filterSpec)
                filterSpec = char(filterSpec);
            end

            if isstring(filterSpec) && ~isscalar(filterSpec)
                filterSpec = cellstr(filterSpec);
            end

            startPath0 = char(options.StartPath);
            title0 = char(options.Title);

            % ---- save mode ----
            if options.Save

                if options.DefaultName ~= ""
                    startPath0 = char(fullfile(options.StartPath, options.DefaultName));
                end

                [fname, fpath] = uiputfile(filterSpec, title0, startPath0);

                if isequal(fname, 0) || isequal(fpath, 0)
                    files = string.empty(0, 1);
                    isOK = false;
                    return;
                end

                file0 = string(fullfile(fpath, fname));

                % ---- overwrite warning ----
                if isfile(file0)
                    answer = questdlg( ...
                        "The file already exists. Do you want to overwrite it?", ...
                        "File exists", ...
                        "Yes", "No", "No");

                    if ~strcmp(answer, "Yes")
                        files = string.empty(0, 1);
                        isOK = false;
                        return;
                    end

                end

                files = file0;
                isOK = true;
                return;
            end

            % ---- open mode ----
            if options.MultiSelect == "on"
                [fname, fpath] = uigetfile(filterSpec, title0, startPath0, "MultiSelect", "on");
            else
                [fname, fpath] = uigetfile(filterSpec, title0, startPath0);
            end

            if isequal(fname, 0) || isequal(fpath, 0)
                files = string.empty(0, 1);
                isOK = false;
                return;
            end

            if iscell(fname)
                files = strings(numel(fname), 1);

                for i = 1:numel(fname)
                    files(i) = string(fullfile(fpath, fname{i}));
                end

            else
                files = string(fullfile(fpath, fname));
            end

            isOK = true;

        end

        function [answer, isOK] = uiInputDlgWrap(~, options)
            % uiInputDlgWrap - inputdlg wrapper with flexible texts and defaults
            %
            % Usage:
            %   [answ,isOK] = uiInputDlgWrap(struct( ...
            %       "Prompt","半径rを入力", ...
            %       "Title","Parameter", ...
            %       "Default","50"));
            %
            % Multiple fields:
            %   opt = struct;
            %   opt.Prompt  = ["x crop"; "y crop"];
            %   opt.Title   = "Crop size";
            %   opt.Default = ["300"; "200"];
            %   [a,isOK] = uiInputDlgWrap(opt);

            arguments
                ~
                options.Prompt (1, :) string = "Input"
                options.Title (1, 1) string = "Input dialog"
                options.Default (1, :) string = ""
                options.Dims (1, 2) double = [1 50] % [rows cols] for each field
            end

            prompt = cellstr(options.Prompt(:));
            title0 = char(options.Title);

            % Default: ensure same length as prompt
            n = numel(prompt);
            def = options.Default(:);

            if numel(def) == 0
                def = repmat("", n, 1);
            elseif isscalar(def) && n > 1
                def = repmat(def, n, 1);
            elseif numel(def) ~= n
                error("uiInputDlgWrap:DefaultSizeMismatch", ...
                "Default must be length 0, 1, or equal to number of prompts.");
            end

            def = cellstr(def);

            out = inputdlg(prompt, title0, options.Dims, def);

            if isempty(out)
                answer = strings(n, 1);
                isOK = false;
            else
                answer = string(out);
                isOK = true;
            end

        end % function uiInputDlgWrap

    end % methods (Access = protected)

    methods (Access = private)

        %% Private presentation adapter functions
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

        function renderUiState(app, ui)
            % RENDERUISTATE Render the UI state
            % renderUiState(app, ui)
            %
            %  Input:
            %   ui: An object of class UiState

            if isempty(ui)
                return
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

            if isempty(app.Presenter)
                app.Presenter = ...
                    openmebius.presentation.main.MainPresenter();
            end

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

            if isempty(app.Presenter)
                app.Presenter = ...
                    openmebius.presentation.main.MainPresenter();
            end

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

        function setLogFile(~)

            system = System();
            directoryLog = system.getCacheDirectory();

            if ~isfolder(directoryLog)

                try
                    mkdir(directoryLog);
                catch ME
                    msg = "Could not create cache directory for log file: " + directoryLog + newline + ME.message;
                    obj.LogTextDate(msg, "Error");
                    return
                end

            end

            fileLog = fullfile(directoryLog, 'openmebius2.log');

            try
                diary(char(fileLog));
            catch ME
                msg = "Could not set log file: " + fileLog + newline + ME.message;
                obj.LogTextDate(msg, "Error");
                return
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

        function loadTable(~, tableObject, tableData, options)

            arguments
                ~
                tableObject
                tableData table
                options.ColumnEditable = false(1, width(tableData))
            end

            tableObject.Data = tableData;
            tableObject.ColumnName = tableData.Properties.VariableNames;
            tableObject.RowName = tableData.Properties.RowNames;
            tableObject.ColumnEditable = options.ColumnEditable;

        end % function loadTable

        function loadEMUModel(app)

            loadModelTable(app)
            loadMSTable(app)
            loadBiomassTable(app)

            if app.model.isError
                app.LogText(app.model.statusMsg);
                return
            end

        end % function loadEMUModel

        function loadModelTable(app, options)

            arguments
                app
                options.ColumnEditable = false(1, width(app.model.getModelTableGUI()))
            end

            tableModel = app.model.getModelTableGUI();
            loadTable(app, app.ModelTable, tableModel, ColumnEditable = options.ColumnEditable);
            errorRows = app.model.getInvalidModelRowIdx();

            resetModelTableColorFormat(app)

            if ~isempty(errorRows)
                addStyle(app.ModelTable, app.styleError, 'row', errorRows);
            end

        end % function loadModelTable

        function loadMSTable(app, options)

            arguments
                app
                options.isColumnEditable = false
            end

            isColumnEditable = options.isColumnEditable;

            % MS data table
            tableMS = app.model.getMSTable();

            if isColumnEditable
                columnEditable = true(1, width(tableMS));
            else
                columnEditable = false(1, width(tableMS));
            end

            loadTable(app, app.MSTable, tableMS, ColumnEditable = columnEditable);
            errorRows = app.model.getInvalidMSRowIdx();

            resetMSTableColorFormat(app);

            if ~isempty(errorRows)
                addStyle(app.MSTable, app.styleError, 'row', errorRows);
            end

            % MS atom table
            tableAtom = app.model.getAtomTable();

            if isColumnEditable
                columnEditable = true(1, width(tableAtom));
            else
                columnEditable = false(1, width(tableAtom));
            end

            loadTable(app, app.AtomTable, tableAtom, ColumnEditable = columnEditable);
            errorRows = app.model.getInvalidAtomRowIdx();

            if ~isempty(errorRows)
                addStyle(app.AtomTable, app.styleError, 'row', errorRows);
            end

        end % function loadMSTable

        function loadBiomassTable(app)

            % Biomass data table
            tableBiomass = app.model.getBiomassTable();
            loadTable(app, app.BiomassTable, tableBiomass);

        end % function loadBiomassTable

        function loadTracerTable(app)

            tableTracer = app.exp.getTracerTable();

            app.LabelTable.Data = tableTracer;
            app.LabelTable.ColumnName = tableTracer.Properties.VariableNames;
            app.LabelTable.RowName = tableTracer.Properties.RowNames;

        end % function loadTracerTable

        function loadUptakeTable(app)

            % Uptake data table
            tableUptake = app.exp.getUptakeTable();

            app.UptakeTable.Data = tableUptake;
            app.UptakeTable.ColumnName = tableUptake.Properties.VariableNames;
            app.UptakeTable.RowName = tableUptake.Properties.RowNames;
            app.UptakeTable.ColumnEditable = true(1, size(tableUptake, 2));

        end % function loadUptakeTable

        function loadPathway(app)

            if ~app.model.isPathwayLoaded
                msg = "Pathway not loaded";
                LogTextDate(app, msg, "Error");
                return
            end

            isDark = isDarkTheme(app);

            drawPathway( ...
                app.model, ...
                app.MainUIAxes, ...
                app.ContextMenu, ...
                darkmode = isDark ...
            );

            app.MainUIAxes.ContextMenu = app.ContextMenu;

            msg = app.model.returnDateMsg("Pathway loaded successfully", "Info");
            app.LogText(msg);

        end % function loadPathway

        function loadExpData(app)

            loadExpTable(app)
            loadTracerTable(app)
            loadUptakeTable(app)

        end % function loadExpData

        function loadExpTable(app)

            tableExps = getInfoTable(app.exp);
            app.ExpTable.Data = tableExps;
            app.ExpTable.ColumnName = tableExps.Properties.VariableNames;
            app.ExpTable.RowName = tableExps.Properties.RowNames;
            app.ExpTable.ColumnEditable = true(1, size(tableExps, 2));

        end % function loadExpTable

        function loadBatchTable(app, options)

            arguments
                app
                options.reload = false
            end % arguments

            if ~options.reload

                updateStatus(app, "batch", "running");

                app.batch = Batch(app.exp);

                addlistener(app.batch, 'ProgressUpdate', @(src, event) statusBatch(app, event));
                addlistener(app.batch, 'GeneralMsg', @(src, event) statusGeneralMsg(app, event));
                addlistener(app.batch, 'FluxResult', @(src, event) updateResult(app, event));

            end % if ~options.reload

            if isempty(app.batch) || ~isvalid(app.batch)
                msg = "Batch object is not valid.";
                app.LogTextDate(msg, "Error");
                app.updateStatus("batch", "error");
                return
            end % if isempty(app.batch) || ~isvalid(app.batch)

            if isempty(app.ProgressBar) || ~isvalid(app.ProgressBar)
                app.ProgressBar = CustomProgressBar(app.GridLayout2, 3, 1);
            end

            [batchGUI, columnEditable] = getBatchForGUI(app.batch);
            batchGUI.Experiment = string(batchGUI.Experiment);

            IDs = batchGUI.ID;
            status = getBatchStatus(app.batch, IDs);
            app.RunTable.Data = batchGUI;
            app.RunTable.ColumnName = batchGUI.Properties.VariableNames;
            setBatchInitialStyle(app, status);

            app.RunTable.ColumnEditable = columnEditable;

            if ~options.reload

                app.updateStatus("batch", "finished");
                msg = "Batch table loaded successfully.";
                LogTextDate(app, msg, "Info");

            end % if ~options.reload

        end % function loadBatchTable

        function loadResult(app, options)

            arguments
                app
                options.reload = false
            end % arguments

            % Create the result object
            if ~options.reload

                app.updateStatus("result", "running");
                app.result = IOResult(app.directoryResult);
                addlistener(app.result, 'GeneralMsg', @(src, event) statusGeneralMsg(app, event));

            end % if ~options.reload

            if isempty(app.result) || ~isvalid(app.result)
                msg = "Result object is not valid.";
                app.LogTextDate(msg, "Error");
                app.updateStatus("result", "error");
                return
            end % if isempty(app.result) || ~isvalid(app.result)

            if app.result.isError

                app.LogText(app.result.statusMsg);
                app.updateStatus("result", "error");
                return

            end % if app.result.isError

            % Load the result files
            % Get the selected batch ID
            batchGUI = getBatchForGUI(app.batch);
            batchID = batchGUI.ID;
            batchStatus = getBatchStatus(app.batch, batchID);
            batchID = batchID(batchStatus == "finished");
            [data, dataMask] = loadResultFiles(app.result, batchID);

            if isempty(data(dataMask))

                if ~options.reload

                    updateStatus(app, "result", "init");
                    msg = "No result files found in the results directory.";
                    LogTextDate(app, msg, "Info");

                end

                return

            end % if isempty(data(dataMask))

            % SubTable
            loadSubResultTable(app, batchGUI, batchID, data, dataMask);

            % Delete MainTable
            if ~isempty(app.ResultMainTable.Data)

                app.ResultMainTable.Data = [];
                app.ResultMainTable.ColumnName = [];
                app.ResultMainTable.RowName = [];

            end % if ~isempty(app.ResultMainTable.Data)

            % Set the status as complete
            if ~options.reload

                updateStatus(app, "result", "finished");
                msg = "Result files loaded successfully.";
                LogTextDate(app, msg, "Info");

            end % if ~options.reload

        end % function loadResult

        function loadMainResultTable(app, options)

            arguments
                app
                options.relative = false
                options.relativeTo = ""
            end

            type = app.ResultDropDown.Value;
            selection = app.ResultSubTable.Selection;

            if isempty(selection)
                return
            end

            switch type

                case "Overview"

                    selection = selection(1);
                    batchID = app.ResultSubTable.Data.ID(selection);
                    loadResultOverView(app, batchID, relative = options.relative, relativeTo = options.relativeTo);

                case "Details"

                    selection = selection(1);
                    batchID = app.ResultSubTable.Data.ID(selection);
                    loadResultDetailed(app, batchID);

                case "Comparison"

                    batchIDs = app.ResultSubTable.Data.ID(selection);
                    Names = app.ResultSubTable.Data.Name(selection);
                    loadResultComparison(app, batchIDs, Names, relative = options.relative, relativeTo = options.relativeTo);

            end % switch type

        end % function loadMainResultTable

        function loadResultOverView(app, batchID, options)

            arguments
                app
                batchID string
                options.relative = false
                options.relativeTo = ""
            end

            if ~options.relative
                tableData = getFluxOverView(app.result, batchID);
            else
                tableData = getFluxOverView( ...
                    app.result, batchID, relative = options.relative, relativeTo = options.relativeTo);
            end

            formattedData = arrayfun(@(x) sprintf('%.2f', x), tableData{:, 2:end}, 'UniformOutput', false);
            formattedData = [tableData(:, 1), cell2table(formattedData)];
            formattedData.Properties.VariableNames = tableData.Properties.VariableNames;

            app.ResultMainTable.Data = formattedData;
            app.ResultMainTable.ColumnName = tableData.Properties.VariableNames;
            app.ResultMainTable.RowName = tableData.Properties.RowNames;
            app.ResultMainTable.ColumnEditable = false(1, size(tableData, 2));

            uiRight = uistyle("HorizontalAlignment", "right");
            addStyle(app.ResultMainTable, uiRight, "column", 2:size(tableData, 2));

        end % function loadResultOverView

        function loadResultDetailed(app, batchID)

            tableRtn = getFluxDetailed(app.result, batchID);
            formattedData = arrayfun(@(x) sprintf('%.4f', x), tableRtn{:, 3:end}, 'UniformOutput', false);
            formattedData = [tableRtn(:, 1:2), cell2table(formattedData)];
            formattedData.Properties.VariableNames = tableRtn.Properties.VariableNames;

            app.ResultMainTable.Data = formattedData;
            app.ResultMainTable.ColumnName = tableRtn.Properties.VariableNames;
            app.ResultMainTable.RowName = tableRtn.Properties.RowNames;
            app.ResultMainTable.ColumnEditable = false(1, size(tableRtn, 2));

            % Right align the table
            uiRight = uistyle("HorizontalAlignment", "right");
            addStyle(app.ResultMainTable, uiRight, "column", 3:size(tableRtn, 2));

            drawnow();

            color = Color();

            for i = 3:size(tableRtn, 2)

                if mod(i, 3) ~= 2
                    continue
                end

                % Get the data for the current column
                data = tableRtn{:, i};

                % Normalize the data
                data = 0.99 * (data - min(data)) / (max(data) - min(data));

                isDark = isDarkTheme(app);

                % Get the color value for the current column
                hex = getColorValue(color, data, "color", "cmthermallight", "isDark", isDark);

                for j = 1:length(data)

                    % Set the color for the current cell
                    addStyle(app.ResultMainTable, uistyle("BackgroundColor", hex(j, :)), 'cell', [j i]);

                end % for j

            end % for i

        end % function loadResultDetailed

        function loadResultComparison(app, batchIDs, names, options)

            arguments
                app
                batchIDs string
                names string
                options.relative = false
                options.relativeTo = ""
            end

            tableData = getFluxComparison( ...
                app.result, batchIDs, names, ...
                relative = options.relative, relativeTo = options.relativeTo);

            if isempty(tableData)
                return
            end

            formattedData = arrayfun(@(x) sprintf('%.2f', x), tableData{:, 2:end}, 'UniformOutput', false);
            formattedData = [tableData(:, 1), cell2table(formattedData)];
            formattedData.Properties.VariableNames = tableData.Properties.VariableNames;

            app.ResultMainTable.Data = formattedData;
            app.ResultMainTable.ColumnName = tableData.Properties.VariableNames;
            app.ResultMainTable.RowName = tableData.Properties.RowNames;
            app.ResultMainTable.ColumnEditable = false(1, size(tableData, 2));

        end % function loadResultComparison

        function loadSubResultTable(app, batchGUI, batchID, data, dataMask)

            data = data(dataMask);
            batchID = batchID(dataMask);
            batchExpList = batchGUI.Name(dataMask);
            RSS = getRSS(app.result, data);
            isPassed = getIsPassedChi2Test(app.result, data);

            % Update the result table
            expListTable = table( ...
                batchID, ...
                batchExpList, ...
                RSS, ...
                'VariableNames', ["ID", "Name", "RSS"] ...
            );

            app.ResultSubTable.Data = expListTable;
            app.ResultSubTable.ColumnName = expListTable.Properties.VariableNames;
            app.ResultSubTable.RowName = expListTable.Properties.RowNames;
            app.ResultSubTable.ColumnEditable = false(1, size(expListTable, 2));

            % Apply color format
            resetResultTableColorFormat(app);

            if ~isempty(data)

                isPassedIdx = find(isPassed);
                isNotPassedIdx = find(~isPassed);

                for i = 1:length(isPassedIdx)

                    addStyle(app.ResultSubTable, app.styleIsPassed, 'cell', [isPassedIdx(i) 3]);

                end % isPassedIdx

                for i = 1:length(isNotPassedIdx)

                    addStyle(app.ResultSubTable, app.styleIsNotPassed, 'cell', [isNotPassedIdx(i) 3]);

                end % isNotPassedIdx

            end % if ~isempty(data)

        end % function loadSubResultTable

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

            loadResult(app, reload = true);

            % Drawnow
            drawnow;

        end % function updateResult

        function updateResultPlot(app)

            type = app.ResultDropDown.Value;
            selectedFlux = app.ResultMainTable.Selection;
            selectedID = app.ResultSubTable.Selection;

            if isempty(selectedFlux) || isempty(selectedID)
                return
            end

            switch type

                case "Overview"

                    selectedFlux = selectedFlux(1);
                    selectedID = selectedID(1);
                    % Reaction ID
                    RxnIDs = app.ResultMainTable.RowName;
                    batchIDs = app.ResultSubTable.Data.ID;
                    RxnID = string(RxnIDs(selectedFlux));
                    Fluxes = app.ResultMainTable.Data.Flux(1:end - 1);
                    batchID = batchIDs(selectedID);

                    % Reaction highlight mask
                    modelTable = getModelTable(app.model);
                    highlightMask = strcmp(modelTable.Properties.RowNames, RxnID);

                    drawFluxLabel( ...
                        app.model, ...
                        app.MainUIAxes, ...
                        Fluxes, ...
                        highlight = highlightMask, ...
                        darkmode = isDarkTheme(app) ...
                    );

                    % Confidence interval plot
                    data = getCIReaction(app.result, batchID, RxnID);

                    if isempty(data) || ~isfield(data, 'CI')
                        % Clear the axes
                        cla(app.SubUIAxes);
                        return
                    end

                    % Clear the axes
                    cla(app.SubUIAxes);
                    drawCIReaction( ...
                        app.result, app.SubUIAxes, data ...
                    )

                case "Detailed"

                case "Comparison"

            end % switch type

        end % function updateBatchTable

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
            % Set the initial style for the batch table
            % depending on the status of the batch
            %
            % status: "ready", "finished", "warning", "error"

            numBatch = length(status);
            IDs = app.RunTable.Data.ID;

            for i = 1:numBatch

                ID = IDs(i);
                iStatus = status(i);

                idx = find(app.RunTable.Data.ID == ID, 1);

                switch iStatus

                    case "ready"
                        addStyle(app.RunTable, app.styleInfoIcon, 'cell', [idx 1]);

                    case "finished"
                        addStyle(app.RunTable, app.styleSuccessIcon, 'cell', [idx 1]);

                    case "warning"
                        addStyle(app.RunTable, app.styleWarningIcon, 'cell', [idx 1]);

                    case "error"
                        addStyle(app.RunTable, app.styleErrorIcon, 'cell', [idx 1]);

                    case "question"
                        addStyle(app.RunTable, app.styleQuestionIcon, 'cell', [idx 1]);
                    otherwise
                        error("Unknown status: " + iStatus);

                end

            end % for i

        end % function setBatchInitialStyle

        %% Status function
        function statusBatch(app, data)

            data = data.data;
            ID = data.id;
            status = data.status;
            rate = data.rate;
            msg = "Batch " + ID + " is completed.";
            idx = find(app.RunTable.Data.ID == ID, 1);

            switch status

                case "finished"
                    LogTextDate(app, msg, "Info");
                    addStyle(app.RunTable, app.styleSuccessIcon, 'cell', [idx 1]);

                case "warning"
                    LogTextDate(app, msg, "Warning");
                    addStyle(app.RunTable, app.styleWarningIcon, 'cell', [idx 1]);

                case "error"
                    LogTextDate(app, msg, "Error");
                    addStyle(app.RunTable, app.styleErrorIcon, 'cell', [idx 1]);

                case "question"
                    LogTextDate(app, msg, "Error");
                    addStyle(app.RunTable, app.styleQuestionIcon, 'cell', [idx 1]);

            end

            app.ProgressBar.setProgress(rate, msg);
            drawnow();

        end % function statusBatch

        function statusGeneralMsg(app, data)

            data = data.data;
            msg = data.msg;
            status = data.status;

            switch status

                case "info"
                    LogTextDate(app, msg, "Info");

                case "warning"
                    LogTextDate(app, msg, "Warning");

                case "error"
                    LogTextDate(app, msg, "Error");
            end

        end % function statusGeneralMsg

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

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, filepath)

            app.setLogFile();

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

            if ~isempty(filepath)

                filepath = fileparts(filepath);

                app.ProjectDirectoryDropDown.Value = filepath;
                ProjectLoadButtonPushed(app);

            end

        end

        % Close request function: OpenMebius2UIFigure
        function OpenMebius2UIFigureCloseRequest(app, event)

            saveHistory(app)
            delete(app)

        end

        % Button pushed function: ProjectBrowseButton
        function ProjectBrowseButtonPushed(app, event)

            % Open a dialog to select the project directory
            projectDirectory = uigetdir(app.ProjectDirectoryDropDown.Value, "Select Project Directory");

            if isequal(projectDirectory, 0)
                return; % User canceled the dialog
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
        function ProjectLoadButtonPushed(app, event)

            cleanupPresentation = app.beginPresentationOperation();

            % Update status
            updateStatus(app, "model", "running");

            projectDirectory = app.ProjectDirectoryDropDown.Value;
            objProjectDirectory = IO(projectDirectory);

            if objProjectDirectory.isError
                LogText(app, objProjectDirectory.statusMsg);
                app.updateStatus("model", "error");
                return
            end

            % If the project directory is not empty, load the project
            if objProjectDirectory.isEmpty
                msg = objProjectDirectory.returnDateMsg("Project directory is empty", "Info");
                app.LogText(msg);
                app.updateStatus("model", "error");
                return
            end

            % Load JSON file
            json = objProjectDirectory.importJSONFile(fullfile(projectDirectory, "setting.json"));

            if objProjectDirectory.isError
                app.LogText(objProjectDirectory.statusMsg);
                app.updateStatus("model", "error");
                return
            end

            try
                app.ProjectNameEditField.Value = json.Name;
                app.ProjectAuthorEditField.Value = json.Author;
                app.OrganismEditField.Value = json.Organism;
            catch
                msg = "Error loading project setting.json file. Please check the file format.";
                LogTextDate(app, msg, "Error");
                updateStatus(app, "model", "error");
                return
            end

            % Initialize the directory
            initDirectory(app, projectDirectory);

            LogText(app, objProjectDirectory.statusMsg);

            clear objProjectDirectory;

            app.model = EMUModel(app.directoryModel);

            if app.model.isError
                LogText(app, app.model.statusMsg);
                updateStatus(app, "model", "error");
                return
            else
                msg = "Model folder found in " + projectDirectory;
                LogTextDate(app, msg, "Info");
            end

            IOStatus = app.model.getIOStatus();

            if strcmp(IOStatus, "completed")
                msg = "Model loaded successfully.";
                LogTextDate(app, msg, "Info");
            else
                LogText(app, app.model.statusMsg);
                updateStatus(app, "model", "error");
                return
            end

            msg = "Constructing EMU network...";
            LogTextDate(app, msg, "Info");

            pause(0.5)

            loadEMUModel(app)

            if app.model.isError
                LogText(app, app.model.statusMsg);
                updateStatus(app, "model", "error");
                return
            end

            loadPathway(app)

            msg = "EMU network was successfully constructed.";
            LogTextDate(app, msg, "Info");
            updateStatus(app, "model", "finished");

            % Load experimental data
            updateStatus(app, "experiment", "running");

            app.exp = IOExps( ...
                app.directoryExp, ...
                app.directoryModel ...
            );

            if app.exp.isError
                LogText(app, app.exp.statusMsg);
                updateStatus(app, "experiment", "error");
                return
            end

            loadExpData(app)

            if app.exp.isError
                LogText(app, app.exp.statusMsg);
                updateStatus(app, "experiment", "error");
                return
            end

            updateStatus(app, "experiment", "finished");
            LogText(app, app.exp.statusMsg);

            % Load batch table
            loadBatchTable(app)

            % Load results if available
            loadResult(app)

        end

        % Button pushed function: ProjectSaveButton
        function ProjectSaveButtonPushed(app, event)

            % Export project setting to JSON file
            projectDirectory = app.ProjectDirectoryDropDown.Value;
            objProjectDirectory = IO(projectDirectory);

            if objProjectDirectory.isError
                app.LogText(objProjectDirectory.statusMsg);
                return
            end

            json.Name = app.ProjectNameEditField.Value;
            json.Author = app.ProjectAuthorEditField.Value;
            json.Organism = app.OrganismEditField.Value;

            objProjectDirectory.exportJSONFile(fullfile(projectDirectory, "setting.json"), json);

            if objProjectDirectory.isError
                app.LogText(objProjectDirectory.statusMsg);
                return
            end

            msg = objProjectDirectory.returnDateMsg("Project setting saved to setting.json", "Info");
            app.LogText(msg);

        end

        % Button pushed function: ProjectCreateButton
        function ProjectCreateButtonPushed(app, event)

            cleanupPresentation = app.beginPresentationOperation();

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
                msg = "Project directory name cannot be empty.";
                LogTextDate(app, msg, "Error");
                return
            end % if isempty(directoryName)

            % Create the project directory
            projectParentDirectory = app.uiGetDirWrap( ...
                StartPath = app.ProjectDirectoryDropDown.Value, ...
                Title = "Select Parent Directory for New Project" ...
            );

            if isequal(projectParentDirectory, 0) || ...
                    (isstring(projectParentDirectory) && strlength(projectParentDirectory) == 0)
                return;
            end

            projectParentDirectory = string(projectParentDirectory);

            % Check if the directory already exists
            newProjectDirectory = fullfile(projectParentDirectory, directoryName);

            if isfolder(newProjectDirectory)
                msg = "Project directory already exists: " + newProjectDirectory;
                LogTextDate(app, msg, "Error");
                return
            end % if isfolder(newProjectDirectory)

            % Create the new project directory
            try
                mkdir(newProjectDirectory);
            catch ME
                msg = "Failed to create project directory: " + newProjectDirectory + ". Error: " + ME.message;
                LogTextDate(app, msg, "Error");
                return
            end % try-catch

            % Update the dropdown value
            app.ProjectDirectoryDropDown.Value = newProjectDirectory;
            % Add the directory to the item
            items = string(app.ProjectDirectoryDropDown.Items);

            if ~any(items == string(newProjectDirectory))
                items(end + 1) = string(newProjectDirectory);
                app.ProjectDirectoryDropDown.Items = items;
            end

            % Update the status
            updateStatus(app, "model", "init");

            msg = "New project directory created: " + newProjectDirectory;
            LogTextDate(app, msg, "Info");

            % Save JSON file
            objProjectDirectory = IO(newProjectDirectory);

            if objProjectDirectory.isError
                LogText(app, objProjectDirectory.statusMsg);
                return
            end

            json.Name = app.ProjectNameEditField.Value;
            json.Author = app.ProjectAuthorEditField.Value;
            json.Organism = app.OrganismEditField.Value;

            objProjectDirectory.exportJSONFile(fullfile(newProjectDirectory, "setting.json"), json);

            if objProjectDirectory.isError
                LogText(app, objProjectDirectory.statusMsg);
                return
            end

            msg = "Project setting saved to " + fullfile(newProjectDirectory, "setting.json");
            LogTextDate(app, msg, "Info");

            % Initialize the directory
            initDirectory(app, newProjectDirectory);

            % Copy model template to the new project directory
            templateModelDirectory = app.TemplateModelDirectoryDropDown.Value;

            if ~isfolder(templateModelDirectory)
                msg = "Template model directory does not exist: " + templateModelDirectory;
                LogTextDate(app, msg, "Error");
                return
            end % if ~isfolder(templateModelDirectory)

            % Copy the template model directory to the new project directory
            try
                copyfile(templateModelDirectory, fullfile(newProjectDirectory, "model"), 'f');
                msg = "Template model copied to " + fullfile(newProjectDirectory, "model");
                LogTextDate(app, msg, "Info");
            catch ME
                msg = "Failed to copy template model: " + ME.message;
                LogTextDate(app, msg, "Error");
                return
            end % try-catch

            % Load the model
            app.model = EMUModel(fullfile(newProjectDirectory, "model"));

            msg = "Constructing EMU network...";
            LogTextDate(app, msg, "Info");

            pause(0.5)

            loadEMUModel(app);
            loadPathway(app);

            updateStatus(app, "model", "finished");

            msg = "New project created and model loaded successfully.";
            LogTextDate(app, msg, "Info");

            app.exp = IOExps( ...
                app.directoryExp, ...
                app.directoryModel ...
            );
            app.batch = Batch(app.exp);
            app.result = IOResult(app.directoryResult);

        end

        % Value changed function: ProjectDirectoryDropDown
        function ProjectDirectoryDropDownValueChanged(app, event)

            value = app.ProjectDirectoryDropDown.Value;

            % Check directory exists
            if ~isfolder(value)
                msg = "Selected directory does not exist: " + value;
                LogTextDate(app, msg, "Error");
                return
            end % if ~isfolder(value)

            % Add the directory to the item
            if ~any(strcmp(app.ProjectDirectoryDropDown.Items, value))
                app.ProjectDirectoryDropDown.Items{end + 1} = value;
            end % if exist

        end

        % Button pushed function: TemplateModelBrowseButton
        function TemplateModelBrowseButtonPushed(app, event)

            % Open a dialog to select the template model directory
            templateModelDirectory = uigetdir(app.TemplateModelDirectoryDropDown.Value, "Select Template Model Directory");

            if isequal(templateModelDirectory, 0)
                return; % User canceled the dialog
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
        function TemplateModelLoadButtonPushed(app, event)

            cleanupPresentation = app.beginPresentationOperation();

            % Update status
            updateStatus(app, "model", "running");

            projectDirectory = app.TemplateModelDirectoryDropDown.Value;
            objProjectDirectory = IO(projectDirectory);

            if objProjectDirectory.isError
                LogText(app, objProjectDirectory.statusMsg);
                updateStatus(app, "model", "error");
                return
            end

            % If the project directory is not empty, load the project
            if objProjectDirectory.isEmpty
                msg = objProjectDirectory.returnDateMsg("Project directory is empty", "Info");
                app.LogText(msg);
                app.updateStatus("model", "error");
                return
            end

            LogText(app, objProjectDirectory.statusMsg);

            clear objProjectDirectory;

            app.model = EMUModel(projectDirectory);

            if app.model.isError
                LogText(app, app.model.statusMsg);
                updateStatus(app, "model", "error");
                return
            else
                msg = "Model folder found in " + projectDirectory;
                LogTextDate(app, msg, "Info");
            end

            IOStatus = app.model.getIOStatus();

            if strcmp(IOStatus, "completed")
                msg = "Model loaded successfully.";
                LogTextDate(app, msg, "Info");
            else
                LogText(app, app.model.statusMsg);
                updateStatus(app, "model", "error");
                return
            end

            msg = "Constructing EMU network...";
            LogTextDate(app, msg, "Info");

            pause(0.5)

            loadEMUModel(app)

            if app.model.isError
                LogText(app, app.model.statusMsg);
                updateStatus(app, "model", "error");
                return
            end

            loadPathway(app)

            msg = "EMU network was successfully constructed.";
            LogTextDate(app, msg, "Info");
            updateStatus(app, "model", "finished");

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
        function ModelSaveButtonPushed(app, event)

            app.beginPresentationEditCommit();

            try
                app.updateStatus("model", "running");

                tableIn = app.ModelTable.Data;
                app.model.updateModelTableGUI(tableIn);

                errorRows = app.model.getInvalidModelRowIdx();

                resetModelTableColorFormat(app);

                if ~isempty(errorRows)
                    addStyle(app.ModelTable, app.styleError, 'row', errorRows);
                end

                if app.model.isError
                    app.LogTextDate(app.model.statusMsg, "Error");
                    app.updateStatus("model", "error");

                    app.finishPresentationEditCommit(false);
                    return
                end

                app.LogTextDate(app.model.statusMsg, "Info");
                app.updateStatus("model", "finished");

                app.finishPresentationEditCommit(true);

            catch ME
                app.finishPresentationEditCommit(false);
                rethrow(ME)
            end

        end

        % Cell selection callback: ModelTable
        function ModelTableCellSelection(app, event)

            indices = event.Indices;

            if isempty(indices)
                return
            end

            row = indices(1, 1);

            highlight = false(size(app.ModelTable.Data, 1), 1);
            highlight(row) = true;

            drawFluxLabel( ...
                app.model, ...
                app.MainUIAxes, ...
                [], ...
                highlight = highlight, ...
                darkmode = isDarkTheme(app) ...
            );

        end

        % Menu selected function: AddLabelMenu
        function AddLabelMenuSelected(app, event)

            % 座標を取得
            point = get(app.MainUIAxes, 'CurrentPoint');
            x = point(1, 1);
            y = point(1, 2);

            % Get the label name
            data = app.ModelTable.Data;
            idx = app.ModelTable.Selection;

            if isempty(idx)
                msg = app.model.returnDateMsg("Please select a reaction to add a label.", "Warning");
                app.LogText(msg);
                return
            end

            dataSelected = data(idx(1, 1), :);
            dataSelected.x = x;
            dataSelected.y = y;
            data(idx(1, 1), :) = dataSelected;
            app.ModelTable.Data = data;
            dataXY = app.model.tableXY;
            dataXY(dataSelected.Properties.RowNames, :) = dataSelected(:, {'x', 'y'});
            app.model.tableXY = dataXY;

            updateModel(app)
            loadPathway(app)

            rxnName = dataSelected.Properties.RowNames{1};
            msg = app.model.returnDateMsg("Label position added to " + rxnName + " x: " + string(x) + " y: " + string(y), "Info");
            app.LogText(msg);

        end

        % Menu selected function: RemoveLabelMenu
        function RemoveLabelMenuSelected(app, event)

        end

        % Button pushed function: MSReloadButton
        function MSReloadButtonPushed(app, event)

            if strcmp(app.MSEditButton.Enable, 'off')
                columnEditable = true;
                loadMSTable(app, isColumnEditable = columnEditable);
            else
                loadMSTable(app);
            end

            msg = app.model.returnDateMsg("MS table reloaded", "Info");
            app.LogText(msg);

        end

        % Button pushed function: MSEditButton
        function MSEditButtonPushed(app, event)

            import openmebius.presentation.main.EditTarget

            app.beginPresentationEdit(EditTarget.MassSpectrometry);

            app.LogTextDate("MS table is now editable", "Info");

        end

        % Button pushed function: MSSaveButton
        function MSSaveButtonPushed(app, event)

            app.beginPresentationEditCommit();

            try
                app.updateStatus("model", "running");

                tableMS = app.MSTable.Data;
                tableAtom = app.AtomTable.Data;

                app.model.updateMSTable(tableMS)
                resetMSTableColorFormat(app)

                errorRows = app.model.getInvalidMSRowIdx();

                if ~isempty(errorRows)
                    addStyle(app.MSTable, app.styleError, 'row', errorRows);
                end

                app.model.updateAtomTable(tableAtom)
                errorRows = app.model.getInvalidAtomRowIdx();

                if ~isempty(errorRows)
                    addStyle(app.AtomTable, app.styleError, 'row', errorRows);
                end

                if app.model.isError
                    app.LogText(app.model.statusMsg);
                    app.updateStatus("model", "error");

                    app.finishPresentationEditCommit(false);
                    return
                end

                app.LogText(app.model.statusMsg);
                app.updateStatus("model", "finished");

                app.LogTextDate("MS table saved", "Info");

                app.finishPresentationEditCommit(true);

            catch ME
                app.finishPresentationEditCommit(false);
                rethrow(ME)
            end

        end

        % Button pushed function: ExpImportButton
        function ExpImportButtonPushed(app, event)

            % Wrap
            [file, ~] = app.uiGetFileWrap( ...
                Filter = {'*.xlsx;*.xls', 'Excel Files (*.xlsx, *.xls)'}, ...
                Title = 'Select Experimental Data File', ...
                MultiSelect = "on" ...
            );

            if isequal(file, 0)
                % User canceled the dialog
                msg = "No file selected.";
                app.LogTextDate(msg, "Warning");
                return
            end

            if ischar(file)
                file = {file};
            end

            numFiles = length(file);
            msg = "Importing experimental data from " + string(numFiles) + " file(s): ";
            app.LogTextDate(msg, "Info");

            % Get files in directoryExp
            ToDirectory = app.directoryExp;

            % Get file list of the directory
            filesInDirectory = dir(fullfile(ToDirectory, '*.xlsx'));
            filesInDirectory = {filesInDirectory.name};

            for i = 1:numFiles

                filePath = fullfile(file{i});

                % Check if the file exists
                if ~isfile(filePath)
                    msg = "File does not exist: " + file{i};
                    app.LogTextDate(msg, "Error");
                    continue
                end

                % Check if the file is already in the directory
                if any(strcmp(filesInDirectory, file{i}))
                    msg = "File already exists in the directory: " + file{i};
                    app.LogTextDate(msg, "Warning");
                    continue
                end

                % Copy the file to the directoryExp
                try
                    copyfile(filePath, ToDirectory, 'f');
                    msg = "File imported successfully: " + file{i};
                    app.LogTextDate(msg, "Info");
                catch ME
                    msg = "Failed to import file: " + file{i} + ". Error: " + ME.message;
                    app.LogTextDate(msg, "Error");
                    continue
                end % try-catch

            end % i = 1:numFiles

            % Reload the experimental data
            updateStatus(app, "experiment", "running");

            app.exp.loadExpData();
            app.loadExpData();

            if app.exp.isError
                app.LogText(app.exp.statusMsg);
                updateStatus(app, "experiment", "error");
                return
            end

            updateStatus(app, "experiment", "finished");
            msg = "Experimental data imported successfully.";
            app.LogTextDate(msg, "Info");

        end

        % Button pushed function: ExpReloadButton
        function ExpReloadButtonPushed(app, event)

            app.exp.loadExpData(app.directoryModel);
            loadExpData(app)
            msg = app.model.returnDateMsg("Experimental data reloaded", "Info");
            app.LogText(msg);

        end

        % Button pushed function: ExpSaveButton
        function ExpSaveButtonPushed(app, event)

            cleanupPresentation = app.beginPresentationOperation();

            updateStatus(app, "experiment", "running");

            updateModel(app)

            tableExp = app.ExpTable.Data;
            tableBiomass = app.BiomassTable.Data;

            err = updateExpData(app.exp, tableExp, "Info");

            if err

                LogText(app, app.exp.statusMsg);
                updateStatus(app, "experiment", "error");

                return

            end

            LogTextDate(app, "Experimental data updated", "Info");

            % Save the experimental data
            saveExpData(app.exp);
            LogText(app, app.exp.statusMsg);

            updateStatus(app, "experiment", "finished");

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
                msg = app.model.returnDateMsg("Please select an experiment to view MS data.", "Warning");
                app.LogText(msg);
                return
            end

            if size(idx, 1) > 1
                msg = app.model.returnDateMsg("Please select only one experiment to view MS data.", "Warning");
                app.LogText(msg);
                return
            end

            idxRow = idx(1, 1);

            cleanupPresentation = app.beginPresentationOperation();

            app.MSViewApp = MSView(app, idxRow);

        end

        % Button pushed function: TracerConfigButton
        function LabelConfigButtonPushed(app, event)

            cleanupPresentation = app.beginPresentationOperation();
            app.LabelConfigApp = LabelConfig(app, app.model.tableLabelView, app.model.structLabelView);

        end

        % Button pushed function: TracerReloadButton
        function TracerReloadButtonPushed(app, event)

            app.loadTracerTable();
            msg = app.model.returnDateMsg("Tracer and uptake tables reloaded", "Info");
            app.LogText(msg);

        end

        % Button pushed function: TracerSaveButton
        function TracerSaveButtonPushed(app, event)

            cleanupPresentation = app.beginPresentationOperation();

            updateStatus(app, "experiment", "running");
            updateModel(app)

            tableUptake = app.UptakeTable.Data;
            tableLabel = app.LabelTable.Data;

            err = app.exp.updateExpData(tableUptake, "Uptake");

            if err

                app.LogText(app.exp.statusMsg);
                updateStatus(app, "experiment", "error");
                return

            end

            app.LogTextDate("Uptake table updated", "Info");

            err = app.exp.updateExpData(tableLabel, "Tracer");

            if err

                app.LogText(app.exp.statusMsg);
                updateStatus(app, "experiment", "error");
                return

            end

            app.LogTextDate("Tracer table updated", "Info");

            % Save the experimental data
            saveExpData(app.exp);
            LogText(app, app.exp.statusMsg);

            updateStatus(app, "experiment", "finished");

        end

        % Double-clicked callback: LabelTable
        function LabelTableDoubleClicked(app, event)

            tableOriginal = app.exp.tableTracersInfo;
            tableNow = app.LabelTable.Data;

            if ~isequaln(tableOriginal, tableNow)
                msg = app.model.returnDateMsg("Label table has been modified. Please save the table before editing.", "Warning");
                app.LogText(msg);
                return
            end

            displayRow = event.InteractionInformation.DisplayRow;
            displayColumn = event.InteractionInformation.DisplayColumn;

            if isempty(displayRow) || isempty(displayColumn)
                return
            end

            cleanupPresentation = app.beginPresentationOperation();

            app.TracerConfigApp = ...
                TracerConfig( ...
                app, ...
                [displayRow, displayColumn] ...
            );

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
        function RunAutoButtonPushed(app, event)

            app.batch.autoFillBatch();
            updateBatchTable(app);

            msg = app.model.returnDateMsg("Batch table has been automatically filled.", "Info");
            app.LogText(msg);

        end

        % Button pushed function: RunConfigButton
        function RunConfigButtonPushed(app, event)

            selection = app.RunTable.Selection;

            if isempty(selection)
                msg = app.model.returnDateMsg("Please select a batch to configure.", "Warning");
                app.LogText(msg);
                return
            end

            updateBatchTable(app);

            cleanupPresentation = app.beginPresentationOperation();

            app.RunConfigApp = RunConfig(app, selection);

        end

        % Button pushed function: RunReloadButton
        function RunReloadButtonPushed(app, event)

            updateBatchTable(app);
            msg = app.model.returnDateMsg("Batch table reloaded", "Info");
            app.LogText(msg);

        end

        % Button pushed function: RunSaveButton
        function RunSaveButtonPushed(app, event)

            app.batch.updateBatchFromGUI(app.RunTable.Data);
            updateBatchTable(app);

            app.batch.saveBatchFile()

            msg = app.model.returnDateMsg("Batch table has been saved.", "Info");
            app.LogText(msg);

        end

        % Button pushed function: RunRunButton
        function RunRunButtonPushed(app, event)

            if app.Presenter.isRunning()

                app.requestPresentationCancelRun();

                msg = "Canceling batch jobs. It may take several minutes...";
                app.LogTextDate(msg, "Info");

                cancelBatch(app.batch)

                return
            end

            app.beginPresentationRun();
            cleanupPresentation = onCleanup( ...
                @() app.finishPresentationRunSafely());

            try
                app.updateStatus("batch", "running");

                msg = "Batch jobs are running...";
                app.LogTextDate(msg, "Info");

                updateBatchTable(app);

                % updateBatchTable may reset RunTable.ColumnEditable.
                app.refreshPresentation();

                status = runBatch(app.batch, app.directoryResult);

                if strcmp(status, "canceled")
                    msg = "Batch jobs are canceled.";
                    app.LogTextDate(msg, "Info");
                    app.updateStatus("batch", "finished");
                    return
                end

                msg = "All batch jobs are completed.";
                app.LogTextDate(msg, "Info");
                app.updateStatus("batch", "finished");

            catch ME
                app.updateStatus("batch", "error");
                app.LogTextDate(string(ME.message), "Error");
                rethrow(ME)
            end

        end

        % Menu selected function: AddbatchMenu
        function RunAddbatchMenuSelected(app, event)

            app.RunAddBatchApp = RunAddBatch(app, 'parallel');

        end

        % Menu selected function: RemovethisbatchMenu
        function RunRemovethisbatchMenuSelected(app, event)

            selectedRows = app.RunTable.Selection;

            if isempty(selectedRows)
                msg = "Please select a batch to remove.";
                LogTextDate(app, msg, "Warning");
                return
            end % if

            selectedRows = selectedRows(:, 1); % Get the first column (row indices)
            selectedRows = unique(selectedRows); % Ensure unique selection
            batchIDs = app.RunTable.Data.ID(selectedRows);

            % Confirm deletion
            answer = uiconfirm(app.OpenMebius2UIFigure, ...
                "Are you sure you want to remove the selected batch?", ...
                "Remove Batch", ...
                'Options', {'Yes', 'No'}, ...
                'DefaultOption', 'No', ...
                'CancelOption', 'No');

            if strcmp(answer, 'Yes')

                for i = 1:length(batchIDs)
                    batchID = batchIDs(i);
                    app.batch.removeBatch(batchID);
                end % for i

                updateBatchTable(app);

                msg = "Selected batch has been removed.";
                LogTextDate(app, msg, "Info");

            end % if

        end

        % Menu selected function: ParallellabelingMenu
        function RunParallellabelingMenuSelected(app, event)

        end

        % Key press function: RunTable
        function RunKeyPress(app, event)

            key = event.Key;

            % If delete key is pressed
            isDelete = strcmp(key, 'delete');

            if isDelete

                % Get selected rows
                selectedRows = app.RunTable.Selection;

                if isempty(selectedRows)
                    return
                end % if

                selectedRows = selectedRows(:, 1); % Get the first column (row indices)
                selectedRows = unique(selectedRows); % Ensure unique selection
                batchIDs = app.RunTable.Data.ID(selectedRows);

                % Confirm deletion
                answer = uiconfirm(app.OpenMebius2UIFigure, ...
                    "Are you sure you want to delete the selected batch?", ...
                    "Delete Batch", ...
                    'Options', {'Yes', 'No'}, ...
                    'DefaultOption', 'No', ...
                    'CancelOption', 'No');

                if strcmp(answer, 'Yes')

                    for i = 1:length(batchIDs)
                        batchID = batchIDs(i);
                        app.batch.removeBatch(batchID);
                    end % for i

                    updateBatchTable(app);

                end % if

            end % if isDelete

        end

        % Value changed function: ResultDropDown
        function ResultDropDownValueChanged(app, event)

            updateResult(app);

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
        function ResultReportButtonPushed(app, event)

            % Exit if result data is not available
            if isempty(app.result) || app.result.isError
                msg = "Result data is not available.";
                app.LogTextDate(msg, "Error");
                return
            end

            if isdeployed
                msg = "Report generation is not available in the deployed version.";
                app.LogTextDate(msg, "Warning");
                return
            end

            app.report = ReportResult( ...
                app.directoryResult, ...
                app.model, ...
                app.exp, ...
                app.result ...
            );

        end

        % Button pushed function: ResultReloadButton
        function ResultReloadButtonPushed(app, event)

            app.updateResult();
            msg = app.model.returnDateMsg("Result data reloaded", "Info");
            app.LogText(msg);

        end

        % Button pushed function: ResultSaveButton
        function ResultSaveButtonPushed(app, event)

            % Directory dialog to save the result
            [folder, isOK] = app.uiGetDirWrap( ...
                StartPath = app.directoryResult, ...
                Title = "Select Directory to Save Result Files" ...
            );

            if ~isOK
                return; % User canceled the dialog
            end

            % Get selected results
            selected = app.ResultSubTable.Selection;

            if isempty(selected)
                msg = "Please select a result to save.";
                LogTextDate(app, msg, "Warning");
                return
            end % if

            batchIDs = app.ResultSubTable.Data.ID;
            selectedBatchIDs = batchIDs(selected);
            selectedBatchIDs = string(selectedBatchIDs);
            batchNames = app.ResultSubTable.Data.Name;
            selectedBatchNames = batchNames(selected);
            selectedBatchNames = string(selectedBatchNames);

            app.result.saveResult( ...
                selectedBatchIDs, ...
                selectedBatchNames, ...
                folder ...
            );

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

        % Menu selected function: RelativetoMenu
        function RelativetoMenuSelected(app, event)

            RowNames = app.ResultMainTable.RowName;
            selectedFlux = app.ResultMainTable.Selection;

            if isempty(selectedFlux)
                msg = "Please select a flux to set relative values.";
                LogTextDate(app, msg, "Warning");
                return
            end

            if isempty(RowNames)
                return
            end

            selectedFluxIdx = RowNames{selectedFlux(1)};

            loadMainResultTable(app, relative = true, relativeTo = selectedFluxIdx);

        end

        % Menu selected function: RangeplotMenu
        function RangeplotMenuSelected(app, event)

            % Selected rows
            selectedRows = app.ResultSubTable.Selection;

            disp(selectedRows)

            if isempty(selectedRows)
                msg = "Please select at least one flux to plot range plot.";
                LogTextDate(app, msg, "Warning");
                return
            end

        end

        % Menu selected function: ViewsuggestionMenu
        function ViewsuggestionMenuSelected(app, event)

            % Selected rows
            selectedRows = app.ResultSubTable.Selection;

            if isempty(selectedRows) || size(selectedRows, 1) > 1
                msg = "Please select one flux to view suggestions.";
                LogTextDate(app, msg, "Warning");
                return
            end

            [isExist, suggestion] = getNextLabelSuggestion( ...
                app.result, ...
                app.ResultSubTable.Data.ID{selectedRows(1)} ...
            );

            if ~isExist
                msg = "No labeling suggestion available for the selected flux.";
                LogTextDate(app, msg, "Warning");
                return
            end

            suggestion.sampleName = app.ResultSubTable.Data.Name{selectedRows(1)};
            suggestion.batchID = app.ResultSubTable.Data.ID{selectedRows(1)};

            app.ViewSuggestionApp = ViewSuggestion(suggestion);

        end

        % Menu selected function: CopythistracerforallentriesMenu
        function CopythistracerforallentriesMenuSelected(app, event)

            currentData = app.LabelTable.Data;
            selected = app.LabelTable.Selection;

            if isempty(selected)
                msg = "Please select a tracer to copy.";
                LogTextDate(app, msg, "Warning");
                return
            end

            selectedCell = currentData{selected(1, 1), selected(1, 2)};
            numRows = size(currentData, 1);

            for i = 1:numRows
                currentData{i, selected(1, 2)} = selectedCell;
            end

            app.LabelTable.Data = currentData;

            msg = "Selected tracer copied to all entries.";
            LogTextDate(app, msg, "Info");

            % Update the tracer table in exp
            app.exp.updateExpData(app.LabelTable.Data, "Tracer");

        end

        % Menu selected function: ImportMSdatafromtextfilesMenu
        function ImportMSdatafromtextfilesMenuSelected(app, event)

            importDirectory = uigetdir(app.directoryExp, "Select Directory Containing MS Data Text Files");

            if isequal(importDirectory, 0)
                return; % User canceled the dialog
            end

            % Check model is loaded
            if isempty(app.model) || app.model.isError
                msg = "Model is not loaded. Please load a model before importing MS data.";
                LogTextDate(app, msg, "Error");
                return
            end

            fragment = app.model.getAtomTable();
            fragment = fragment.Properties.RowNames;

            % Import MS data from text files
            io = IORawFile(importDirectory);
            io.readMSDataFromShimadzuASCII(app.directoryExp, fragment);

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

            % Show about dialog
            msg = "test";
            uialert(app.OpenMebius2UIFigure, msg, "About OpenMebius2", ...
                'Icon', 'info', ...
                'Interpreter', 'none' ...
            );

        end

        % Menu selected function: ClearcacheMenu
        function ClearcacheMenuSelected(app, event)

            % Clear cache directory
            app.clearHistory();

        end

        % Menu selected function: ExporttemplateExcelfileMenu
        function ExporttemplateExcelfileMenuSelected(app, event)

            if isempty(app.model) || app.model.isError
                msg = "Model is not loaded. Please load a model before exporting template Excel file.";
                LogTextDate(app, msg, "Error");
                return
            end

            cellData = getTemplateMSTable(app.model);

            msg = "Exporting template Excel file. Please select the location to save the file.";
            app.LogTextDate(msg, "Info");

            [file, isOK] = app.uiGetFileWrap( ...
                Filter = {'*.xlsx', 'Excel Files (*.xlsx)'}, ...
                Title = 'Save Template Excel File', ...
                MultiSelect = "off", ...
                DefaultName = "Template_MS_Table.xlsx", ...
                Save = true ...
            );

            if ~isOK
                return; % User canceled the dialog
            end

            % Write cell data to Excel file
            try
                writematrix(cellData, file, 'Sheet', 'MS');
                msg = "Template Excel file exported successfully: " + file;
                app.LogTextDate(msg, "Info");
            catch ME
                msg = "Failed to export template Excel file. Error: " + ME.message;
                app.LogTextDate(msg, "Error");
            end

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

            % Delete UIFigure when app is deleted
            delete(app.OpenMebius2UIFigure)
        end

    end

end
