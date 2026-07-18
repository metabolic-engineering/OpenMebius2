classdef ComparisonView_exported < matlab.apps.AppBase

    events
        NotificationRequested
        Closed
    end

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
        Presenter openmebius.presentation.experiment.ComparisonViewPresenter
        type (1, 1) string
    end

    methods (Access = private)

        function applyCatalog(app, viewModel)

            app.requestNotifications(viewModel.Notifications);

            if ~viewModel.IsAvailable
                app.ExpListBox.Items = {};
                app.DataListBox.Items = {};
                app.ExpListBox.Value = {};
                app.DataListBox.Value = {};
                return
            end

            app.ExpListBox.Items = viewModel.ExperimentItems;
            app.DataListBox.Items = viewModel.DataItems;

        end % applyCatalog

        function updateData(app)

            pause(0.01)
            selectedExp = app.ExpListBox.Value;
            selectedData = app.DataListBox.Value;

            if isempty(selectedExp) || isempty(selectedData)
                return
            end

            viewModel = app.Presenter.presentSelection( ...
                selectedExp, selectedData);
            app.requestNotifications(viewModel.Notifications);

            if viewModel.IsAvailable
                app.updateMSData(viewModel);
            end

        end % updateData

        function updateMSData(app, viewModel)

            % Initialize progress bar
            progressDlg = app.createProgressDialog('Updating Data', 'Initializing...');
            progressCleanup = onCleanup( ...
                @() app.closeProgressDialog(progressDlg));

            numFragment = numel(viewModel.DataNames);

            if numFragment == 0
                return
            end

            numPlotColumn = 3;
            numPlotRow = ceil(numFragment / numPlotColumn);

            frags = viewModel.DataNames;
            exps = viewModel.ExperimentNames;

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
                iFraName = frags(i);
                values = viewModel.Values{i};
                iNumData = 1:numel(exps);

                % color setting
                color = Color();
                colors = color.getColorPalette( ...
                    size(values, 2), "hex", false);

                % Plot data in the pre-created UIAxes
                ax = axesArray(i);
                ax.ColorOrder = colors;
                bar(ax, iNumData, values, 'stacked');
                title(ax, iFraName);
                ylim(ax, [0, 1]);
                xticks(ax, iNumData);
                xticklabels(ax, exps);
                ax.TickLabelInterpreter = 'none';

            end % for i

            % Enable visibility of the grid layout and axes after processing
            subplotGrid.Visible = 'on';

            for i = 1:numFragment
                axesArray(i).Visible = 'on';
            end

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

            notification = openmebius.presentation.notification ...
                .Notification.success( ...
                    "Comparison image saved to " + ...
                    string(fullFilePath) + ".");
            eventData = openmebius.presentation.notification ...
                .NotificationEventData(notification);
            notify(app, "NotificationRequested", eventData);

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

        function closeProgressDialog(~, progressDlg)

            try
                if ~isempty(progressDlg) && isvalid(progressDlg)
                    close(progressDlg);
                end
            catch
            end

        end % closeProgressDialog

        function requestNotifications(app, notifications)

            for notificationIndex = 1:numel(notifications)
                eventData = openmebius.presentation.notification ...
                    .NotificationEventData( ...
                        notifications{notificationIndex});
                notify(app, "NotificationRequested", eventData);
            end

        end % requestNotifications

    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, presenter, catalogViewModel, type)

            app.Presenter = presenter;
            app.type = string(type);

            switch app.type

                case "ms"
                    app.applyCatalog(catalogViewModel);

                otherwise
                    error( ...
                        "OpenMebius2:ComparisonView:UnknownType", ...
                        "Unknown comparison view type: %s", ...
                        app.type);

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

            app.applyCatalog(app.Presenter.presentCatalog());

        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)

            saveMSData(app)

        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)

            close(app.ComparisonviewUIFigure);

        end

        % Close request function: ComparisonviewUIFigure
        function ComparisonviewUIFigureCloseRequest(app, event)

            notify(app, "Closed");
            delete(app);

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
            app.ComparisonviewUIFigure.CloseRequestFcn = createCallbackFcn(app, @ComparisonviewUIFigureCloseRequest, true);

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
