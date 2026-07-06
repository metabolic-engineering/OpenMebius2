classdef TracerConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        TracerselectionconfigUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        AllowmultipletracerpatternforonesubstrateCheckBox matlab.ui.control.CheckBox
        GridLayout2 matlab.ui.container.GridLayout
        SaveButton matlab.ui.control.Button
        ReloadButton matlab.ui.control.Button
        UITable matlab.ui.control.Table
    end

    properties (Access = private)
        MainApp
        xy
        tableSubstrate
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, MainApp, xy)

            app.MainApp = MainApp;
            app.xy = xy;

            ReloadButtonPushed(app)

        end

        % Button pushed function: ReloadButton
        function ReloadButtonPushed(app, event)

            app.tableSubstrate = ...
                app.MainApp.exp.createTableTracerConfig(app.xy);

            app.UITable.Data = app.tableSubstrate;
            app.UITable.ColumnName = app.tableSubstrate.Properties.VariableNames;
            app.UITable.ColumnEditable = [true, false, true];

        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)

            text = app.MainApp.exp.disparseLabelPattern(app.UITable.Data);
            app.MainApp.LabelTable.Data{app.xy(1), app.xy(2)} = {text};

            delete(app)

        end

        % Close request function: TracerselectionconfigUIFigure
        function TracerselectionconfigUIFigureCloseRequest(app, event)

            delete(app)

        end

        % Key press function: TracerselectionconfigUIFigure
        function TracerselectionconfigUIFigureKeyPress(app, event)

            % Set escape key to close the app
            key = event.Key;

            if strcmp(key, 'escape')
                TracerselectionconfigUIFigureCloseRequest(app, [])
            end

        end

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create TracerselectionconfigUIFigure and hide until all components are created
            app.TracerselectionconfigUIFigure = uifigure('Visible', 'off');
            app.TracerselectionconfigUIFigure.Position = [100 100 320 480];
            app.TracerselectionconfigUIFigure.Name = 'Tracer selection config';
            app.TracerselectionconfigUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.TracerselectionconfigUIFigure.CloseRequestFcn = createCallbackFcn(app, @TracerselectionconfigUIFigureCloseRequest, true);
            app.TracerselectionconfigUIFigure.KeyPressFcn = createCallbackFcn(app, @TracerselectionconfigUIFigureKeyPress, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.TracerselectionconfigUIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x', 'fit', 'fit'};

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = '';
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.Layout.Row = 1;
            app.UITable.Layout.Column = 1;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = 3;
            app.GridLayout2.Layout.Column = 1;

            % Create ReloadButton
            app.ReloadButton = uibutton(app.GridLayout2, 'push');
            app.ReloadButton.ButtonPushedFcn = createCallbackFcn(app, @ReloadButtonPushed, true);
            app.ReloadButton.Layout.Row = 1;
            app.ReloadButton.Layout.Column = 2;
            app.ReloadButton.Text = 'Reload';

            % Create SaveButton
            app.SaveButton = uibutton(app.GridLayout2, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Layout.Row = 1;
            app.SaveButton.Layout.Column = 3;
            app.SaveButton.Text = 'Save';

            % Create AllowmultipletracerpatternforonesubstrateCheckBox
            app.AllowmultipletracerpatternforonesubstrateCheckBox = uicheckbox(app.GridLayout);
            app.AllowmultipletracerpatternforonesubstrateCheckBox.Text = 'Allow multiple tracer pattern for one substrate.';
            app.AllowmultipletracerpatternforonesubstrateCheckBox.Layout.Row = 2;
            app.AllowmultipletracerpatternforonesubstrateCheckBox.Layout.Column = 1;

            % Show the figure after all components are created
            app.TracerselectionconfigUIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = TracerConfig_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.TracerselectionconfigUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end

        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.TracerselectionconfigUIFigure)
        end

    end

end
