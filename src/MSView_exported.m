classdef MSView_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MSViewerUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        GridLayout3 matlab.ui.container.GridLayout
        TableTypeDropDown matlab.ui.control.DropDown
        ExpDropDown matlab.ui.control.DropDown
        GridLayout2 matlab.ui.container.GridLayout
        PlotButton matlab.ui.control.Button
        ReloadButton matlab.ui.control.Button
        SaveButton matlab.ui.control.Button
        MSTable matlab.ui.control.Table
    end

    properties (Access = private)
        MainApp % Description
        ComparisonApp
        color
    end

    methods (Access = private)

        function changeMSTable(app, expName, Type)

            % Get error columns
            [tableMS, err] = app.MainApp.exp.getMDVBiomassTable(expName);

            switch Type
                case 'MS raw data'
                    tableMS = app.MainApp.exp.getMSTable(expName);
                    app.ExpDropDown.Enable = "on";
                case 'MS normarized data'
                    tableMS = app.MainApp.exp.getMSNormalizedTable(expName);
                    app.ExpDropDown.Enable = "on";
                case 'MDV (Mass distribution vectors)'
                    tableMS = app.MainApp.exp.getMDVTable(expName);
                    app.ExpDropDown.Enable = "on";
                case 'Biomass corrected MDV'
                    app.ExpDropDown.Enable = "on";
                case 'Enrichment'
                    [tableMS, err] = app.MainApp.exp.getEnrichmentComparison();
                    app.ExpDropDown.Enable = "off";
            end

            app.MSTable.Data = tableMS;
            app.MSTable.ColumnName = tableMS.Properties.VariableNames;
            app.MSTable.RowName = tableMS.Properties.RowNames;

            isDark = isDarkTheme(app.MainApp);
            drawnow();

            if strcmp(Type, "Enrichment")

                removeStyle(app.MSTable);
                numRow = height(tableMS);
                numCol = width(tableMS);

                app.MSTable.ColumnWidth = repmat({100}, 1, numCol);

                data = tableMS{:, :};

                for i = 1:numCol

                    hex = app.color.getColorValue( ...
                        data(:, i), ...
                        "color", "cmthermallight", ...
                        "isDark", isDark ...
                    );

                    for j = 1:numRow

                        ui = uistyle('BackgroundColor', hex(j));
                        addStyle(app.MSTable, ui, 'cell', [j, i]);
                        clear ui;

                    end

                end

                clear data;

                % Change columns color if there are errors
                if ~isempty(err)

                    if isDark
                        addStyle(app.MSTable, app.MainApp.styleErrorDark, 'column', find(err));
                    else
                        addStyle(app.MSTable, app.MainApp.styleError, 'column', find(err));
                    end % if isDark

                end

            else

                app.MSTable.ColumnWidth = {'auto'};

                % Change columns color if there are errors
                if ~isempty(err)
                    removeStyle(app.MSTable);

                    if isDark
                        addStyle(app.MSTable, app.MainApp.styleErrorDark, 'column', find(err));
                    else
                        addStyle(app.MSTable, app.MainApp.styleError, 'column', find(err));
                    end % if isDark

                end % if isempty(err)

            end

        end % end changeMSTable

    end % end private methods

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, MainApp, idx)

            app.MainApp = MainApp;

            app.ExpDropDown.Items = MainApp.exp.getExpList();
            MainApp.exp.calculateMDV();

            expName = MainApp.exp.getExpName(idx);

            changeMSTable(app, expName, app.TableTypeDropDown.Value);

            app.ExpDropDown.Value = expName;

            app.color = Color();

        end

        % Value changed function: ExpDropDown
        function ExpDropDownValueChanged(app, event)

            value = app.ExpDropDown.Value;
            app.changeMSTable(value, app.TableTypeDropDown.Value);

        end

        % Value changed function: TableTypeDropDown
        function TableTypeDropDownValueChanged(app, event)

            value = app.TableTypeDropDown.Value;
            app.changeMSTable(app.ExpDropDown.Value, value);

        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)

            app.ComparisonApp = ComparisonView(app.MainApp, "ms");

        end

        % Button pushed function: ReloadButton
        function ReloadButtonPushed(app, event)

        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)

            [file, path] = uiputfile('MS_data.csv', 'Save MS data as');

            if isequal(file, 0) || isequal(path, 0)
                return;
            end

            filename = fullfile(path, file);
            tableOut = app.MSTable.Data;
            tableOut.Properties.VariableNames = app.MSTable.ColumnName;
            tableOut.Properties.RowNames = app.MSTable.RowName;

            try
                writetable(tableOut, filename, 'WriteRowNames', true);
            catch
                uialert(app.MSViewerUIFigure, "Failed to save the file.", "File Save Error");
            end

        end

        % Key press function: MSViewerUIFigure
        function MSViewerUIFigureKeyPress(app, event)

            key = event.Key;

            % Close the figure when the user presses the escape key
            if strcmp(key, 'escape')
                close(app.MSViewerUIFigure);
            end

        end

        % Close request function: MSViewerUIFigure
        function MSViewerUIFigureCloseRequest(app, event)

            delete(app)

        end

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create MSViewerUIFigure and hide until all components are created
            app.MSViewerUIFigure = uifigure('Visible', 'off');
            app.MSViewerUIFigure.Position = [100 100 1280 720];
            app.MSViewerUIFigure.Name = 'MS Viewer';
            app.MSViewerUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.MSViewerUIFigure.CloseRequestFcn = createCallbackFcn(app, @MSViewerUIFigureCloseRequest, true);
            app.MSViewerUIFigure.KeyPressFcn = createCallbackFcn(app, @MSViewerUIFigureKeyPress, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.MSViewerUIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'fit', '1x', 'fit'};

            % Create MSTable
            app.MSTable = uitable(app.GridLayout);
            app.MSTable.ColumnName = '';
            app.MSTable.RowName = {};
            app.MSTable.RowStriping = 'off';
            app.MSTable.Layout.Row = 2;
            app.MSTable.Layout.Column = 1;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 3;
            app.GridLayout2.Layout.Column = 1;

            % Create SaveButton
            app.SaveButton = uibutton(app.GridLayout2, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Layout.Row = 1;
            app.SaveButton.Layout.Column = 9;
            app.SaveButton.Text = 'Save';

            % Create ReloadButton
            app.ReloadButton = uibutton(app.GridLayout2, 'push');
            app.ReloadButton.ButtonPushedFcn = createCallbackFcn(app, @ReloadButtonPushed, true);
            app.ReloadButton.Layout.Row = 1;
            app.ReloadButton.Layout.Column = 8;
            app.ReloadButton.Text = 'Reload';

            % Create PlotButton
            app.PlotButton = uibutton(app.GridLayout2, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Layout.Row = 1;
            app.PlotButton.Layout.Column = 7;
            app.PlotButton.Text = 'Plot';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;

            % Create ExpDropDown
            app.ExpDropDown = uidropdown(app.GridLayout3);
            app.ExpDropDown.Items = {''};
            app.ExpDropDown.ValueChangedFcn = createCallbackFcn(app, @ExpDropDownValueChanged, true);
            app.ExpDropDown.Layout.Row = 1;
            app.ExpDropDown.Layout.Column = 1;
            app.ExpDropDown.Value = '';

            % Create TableTypeDropDown
            app.TableTypeDropDown = uidropdown(app.GridLayout3);
            app.TableTypeDropDown.Items = {'MS raw data', 'MS normarized data', 'MDV (Mass distribution vectors)', 'Biomass corrected MDV', 'Enrichment'};
            app.TableTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @TableTypeDropDownValueChanged, true);
            app.TableTypeDropDown.Layout.Row = 1;
            app.TableTypeDropDown.Layout.Column = 2;
            app.TableTypeDropDown.Value = 'MS raw data';

            % Show the figure after all components are created
            app.MSViewerUIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MSView_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.MSViewerUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end

        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MSViewerUIFigure)
        end

    end

end
