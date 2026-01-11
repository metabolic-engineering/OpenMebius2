classdef ComparisonView_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ComparisonviewUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        GridLayout2 matlab.ui.container.GridLayout
        GridAxes matlab.ui.container.GridLayout
        GridLayout3 matlab.ui.container.GridLayout
        ConfigButton matlab.ui.control.Button
        ReloadButton matlab.ui.control.Button
        SaveButton matlab.ui.control.Button
        CloseButton matlab.ui.control.Button
        ExpListBox matlab.ui.control.ListBox
        DataListBox matlab.ui.control.ListBox
    end

    properties (Access = private)
        MainApp % Main application instance
        type % Type of data to be loaded (e.g.,'ms')
    end

    methods (Access = private)

        function loadMSData(app)

            listExp = app.MainApp.exp.getExpList();
            app.ExpListBox.Items = listExp;
            enrichment = app.MainApp.exp.getEnrichmentComparison();
            listData = enrichment.Properties.RowNames;

            app.ExpListBox.Items = listExp;
            app.DataListBox.Items = listData;

        end % loadMSData

        function updateData(app)

            pause(0.01)
            selectedExp = app.ExpListBox.Value;
            selectedData = app.DataListBox.Value;

            if isempty(selectedExp) || isempty(selectedData)
                return
            end

            switch app.type

                case 'ms'
                    enrichment = app.MainApp.exp.getEnrichmentComparison();
                    data = enrichment(selectedData, selectedExp);
                    updateMSData(app, data)
            end

        end % updateData

        function updateMSData(app, data)

            % Initialize progress bar
            progressDlg = app.createProgressDialog('Updating Data', 'Initializing...');

            numFragment = height(data);
            numPlotColumn = 3;
            numPlotRow = ceil(numFragment / numPlotColumn);

            frags = data.Properties.RowNames;
            exps = data.Properties.VariableNames;

            % Clear existing children in the GridLayout2
            delete(app.GridAxes.Children);

            % Create a new grid layout for subplots
            subplotGrid = uigridlayout(app.GridAxes);
            subplotGrid.RowHeight = repmat({'1x'}, 1, numPlotRow);
            subplotGrid.ColumnWidth = repmat({'1x'}, 1, numPlotColumn);
            subplotGrid.Layout.Row = 1;
            subplotGrid.Layout.Column = 1;

            % Disable visibility of the entire grid layout
            subplotGrid.Visible = 'off';

            % Pre-create axes and set them to invisible
            axesArray = gobjects(numFragment, 1);

            for i = 1:numFragment
                ax = uiaxes(subplotGrid);
                ax.Layout.Row = ceil(i / numPlotColumn);
                ax.Layout.Column = mod(i - 1, numPlotColumn) + 1;
                ax.Visible = 'off'; % Set axes to invisible initially
                axesArray(i) = ax;
            end

            for i = 1:numFragment

                % Update progress
                app.updateProgressDialog(progressDlg, i / numFragment, ...
                    sprintf('Processing fragment %d of %d...', i, numFragment));

                % Get data for the current fragment
                iFraName = frags{i};
                iData = app.MainApp.exp.getMDVBiomassComparison(iFraName);
                iData = iData(:, exps);
                iNumData = 1:width(iData);

                % color setting
                color = Color();
                colors = color.getColorPalette(height(iData), "hex", false);

                % Plot data in the pre-created UIAxes
                ax = axesArray(i);
                ax.ColorOrder = colors;
                bar(ax, iNumData, iData{:, :}, 'stacked');
                title(ax, iFraName);
                ylim(ax, [0, 1]);
                xticks(ax, iNumData);
                xlabel = iData.Properties.VariableNames;
                xticklabels(ax, xlabel);
                ax.TickLabelInterpreter = 'none';

            end % for i

            % Enable visibility of the grid layout and axes after processing
            subplotGrid.Visible = 'on';

            for i = 1:numFragment
                axesArray(i).Visible = 'on';
            end

            % Close the progress dialog
            close(progressDlg);

        end % updateMSData

        function saveMSData(app)

            % Prompt user to select a file location
            [file, path] = uiputfile({'*.png'; '*.jpg'; '*.pdf'}, 'Save As');

            if isequal(file, 0)
                return; % User canceled the save dialog
            end

            % Full file path
            fullFilePath = fullfile(path, file);

            % Export the GridAxes content to the selected file
            exportgraphics(app.GridAxes, fullFilePath, 'Resolution', 300);

            % Notify user of successful save
            uialert(app.ComparisonviewUIFigure, 'File saved successfully!', 'Success');

        end % saveMSData

        function progressDlg = createProgressDialog(app, title, message)
            % Create and return a progress dialog
            progressDlg = uiprogressdlg(app.ComparisonviewUIFigure, ...
                'Title', title, ...
                'Message', message, ...
                'Indeterminate', 'off');
        end

        function updateProgressDialog(~, progressDlg, value, message)
            % Update the progress dialog with new value and message
            progressDlg.Value = value;
            progressDlg.Message = message;
        end

    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, MainApp, type)

            app.MainApp = MainApp;
            app.type = type;

            switch type

                case 'ms'
                    loadMSData(app)

            end

        end

        % Clicked callback: ExpListBox
        function ExpListBoxClicked(app, event)

            updateData(app)

        end

        % Clicked callback: DataListBox
        function DataListBoxClicked(app, event)

            updateData(app)

        end

        % Button pushed function: ConfigButton
        function ConfigButtonPushed(app, event)

        end

        % Button pushed function: ReloadButton
        function ReloadButtonPushed(app, event)

        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)

            saveMSData(app)

        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)

            % Close the app when the button is pushed
            delete(app.ComparisonviewUIFigure);

        end

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create ComparisonviewUIFigure and hide until all components are created
            app.ComparisonviewUIFigure = uifigure('Visible', 'off');
            app.ComparisonviewUIFigure.Position = [100 100 1280 720];
            app.ComparisonviewUIFigure.Name = 'Comparison view';
            app.ComparisonviewUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');

            % Create GridLayout
            app.GridLayout = uigridlayout(app.ComparisonviewUIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '4x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create DataListBox
            app.DataListBox = uilistbox(app.GridLayout);
            app.DataListBox.Items = {};
            app.DataListBox.Multiselect = 'on';
            app.DataListBox.Layout.Row = 1;
            app.DataListBox.Layout.Column = 2;
            app.DataListBox.ClickedFcn = createCallbackFcn(app, @DataListBoxClicked, true);
            app.DataListBox.Value = {};

            % Create ExpListBox
            app.ExpListBox = uilistbox(app.GridLayout);
            app.ExpListBox.Items = {};
            app.ExpListBox.Multiselect = 'on';
            app.ExpListBox.Layout.Row = 1;
            app.ExpListBox.Layout.Column = 1;
            app.ExpListBox.ClickedFcn = createCallbackFcn(app, @ExpListBoxClicked, true);
            app.ExpListBox.Value = {};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'1x', 'fit'};
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 3;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout2);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 2;
            app.GridLayout3.Layout.Column = 1;

            % Create CloseButton
            app.CloseButton = uibutton(app.GridLayout3, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.Layout.Row = 1;
            app.CloseButton.Layout.Column = 7;
            app.CloseButton.Text = 'Close';

            % Create SaveButton
            app.SaveButton = uibutton(app.GridLayout3, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Layout.Row = 1;
            app.SaveButton.Layout.Column = 6;
            app.SaveButton.Text = 'Save';

            % Create ReloadButton
            app.ReloadButton = uibutton(app.GridLayout3, 'push');
            app.ReloadButton.ButtonPushedFcn = createCallbackFcn(app, @ReloadButtonPushed, true);
            app.ReloadButton.Layout.Row = 1;
            app.ReloadButton.Layout.Column = 5;
            app.ReloadButton.Text = 'Reload';

            % Create ConfigButton
            app.ConfigButton = uibutton(app.GridLayout3, 'push');
            app.ConfigButton.ButtonPushedFcn = createCallbackFcn(app, @ConfigButtonPushed, true);
            app.ConfigButton.Enable = 'off';
            app.ConfigButton.Layout.Row = 1;
            app.ConfigButton.Layout.Column = 4;
            app.ConfigButton.Text = 'Config';

            % Create GridAxes
            app.GridAxes = uigridlayout(app.GridLayout2);
            app.GridAxes.ColumnWidth = {'1x'};
            app.GridAxes.RowHeight = {'1x'};
            app.GridAxes.Padding = [0 0 0 0];
            app.GridAxes.Layout.Row = 1;
            app.GridAxes.Layout.Column = 1;

            % Show the figure after all components are created
            app.ComparisonviewUIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ComparisonView_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.ComparisonviewUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end

        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.ComparisonviewUIFigure)
        end

    end

end
