classdef LabelConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        LabelconfigUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        GridLayout3 matlab.ui.container.GridLayout
        GridLayout7 matlab.ui.container.GridLayout
        SaveButton matlab.ui.control.Button
        LoadButton matlab.ui.control.Button
        GridLayout5 matlab.ui.container.GridLayout
        RemoveRatioButton matlab.ui.control.Button
        AddRatioButton matlab.ui.control.Button
        RatioTable matlab.ui.control.Table
        GridLayout2 matlab.ui.container.GridLayout
        LabelTable matlab.ui.control.Table
        GridLayout4 matlab.ui.container.GridLayout
        GridLayout6 matlab.ui.container.GridLayout
        RemoveLabelButton matlab.ui.control.Button
        AddLabelButton matlab.ui.control.Button
    end

    properties (Access = private)

        Action openmebius.presentation.model.LabelConfigAction
        idxLabel double

    end

    methods (Access = private)

        function initLabelTable(app)

            app.Action.restore();
            app.LabelTable.Data = app.Action.LabelTable;
            app.lockRatioTable();

        end

        function selectLabel(app, indices)

            if isempty(indices)
                app.lockRatioTable();
                return
            end

            app.idxLabel = indices(1, 1);
            app.RatioTable.Data = ...
                app.Action.selectLabel(app.idxLabel);
            app.unlockRatioTable();

        end % selectLabel

        function removeSelectedRatio(app)

            ratioSelection = app.RatioTable.Selection;
            labelSelection = app.LabelTable.Selection;

            if isempty(ratioSelection) || isempty(labelSelection)
                return
            end

            [app.RatioTable.Data, message] = app.Action.removeRatio( ...
                labelSelection(1, 1), ratioSelection(1, 1));
            app.requestInfo(message);

        end % removeSelectedRatio

        function removeSelectedLabels(app)

            selection = app.LabelTable.Selection;

            if isempty(selection)
                return
            end

            message = app.Action.removeLabels(selection(:, 1));
            app.LabelTable.Data = app.Action.LabelTable;
            app.lockRatioTable();
            app.requestInfo(message);

        end % removeSelectedLabels

        function updateRatioTable(app)

            idx = app.idxLabel;
            app.Action.updateRatioTable(idx, app.RatioTable.Data);

        end

        function updateLabelTable(app)

            app.Action.updateLabelTable(app.LabelTable.Data);

        end

        function lockRatioTable(app)

            app.RatioTable.Enable = 'off';
            app.RatioTable.Data = {};

            app.AddRatioButton.Enable = 'off';
            app.RemoveRatioButton.Enable = 'off';

        end

        function unlockRatioTable(app)

            app.RatioTable.Enable = 'on';

            app.AddRatioButton.Enable = 'on';
            app.RemoveRatioButton.Enable = 'on';

        end

        function requestInfo(app, message)

            notification = openmebius.presentation.notification ...
                .Notification.info(string(message));
            eventData = openmebius.presentation.notification ...
                .NotificationEventData(notification);
            notify(app, "NotificationRequested", eventData);

        end % requestInfo

    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, context)

            app.Action = context.Action;
            app.LabelTable.Data = app.Action.LabelTable;
            app.LabelTable.ColumnName = ...
                app.Action.LabelTable.Properties.VariableNames;
        end

        % Cell selection callback: LabelTable
        function LabelTableCellSelection(app, event)

            app.selectLabel(event.Indices);
        end

        % Button pushed function: AddLabelButton
        function AddLabelButtonPushed(app, event)

            message = app.Action.addLabel();
            app.LabelTable.Data = app.Action.LabelTable;
            app.requestInfo(message);
        end

        % Button pushed function: RemoveLabelButton
        function RemoveLabelButtonPushed(app, event)

            app.removeSelectedLabels();
        end

        % Button pushed function: AddRatioButton
        function AddRatioButtonPushed(app, event)

            % Add new ratio pattern to the end of the seleceted row
            indices = app.LabelTable.Selection;
            idx = indices(1, 1);
            [app.RatioTable.Data, message] = app.Action.addRatio(idx);
            app.requestInfo(message);
        end

        % Button pushed function: RemoveRatioButton
        function RemoveRatioButtonPushed(app, event)

            app.removeSelectedRatio();
        end

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)

            lockRatioTable(app);

            app.initLabelTable();
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)

            app.updateLabelTable();
            eventData = openmebius.presentation.model ...
                .LabelConfigurationAppliedEventData( ...
                app.Action.LabelTable, app.Action.RatioTables);
            notify(app, "Applied", eventData);
            close(app.LabelconfigUIFigure);
        end

        % Display data changed function: RatioTable
        function RatioTableDisplayDataChanged(app, event)

            updateRatioTable(app);
        end

        % Cell edit callback: RatioTable
        function RatioTableCellEdit(app, event)

            updateRatioTable(app);
        end

        % Close request function: LabelconfigUIFigure
        function LabelconfigUIFigureCloseRequest(app, event)

            notify(app, "Closed");
            delete(app);
        end

        % Key press function: LabelconfigUIFigure
        function LabelconfigUIFigureKeyPress(app, event)

            if strcmp(event.Key, 'escape')

                close(app.LabelconfigUIFigure);

            end

        end

    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create LabelconfigUIFigure and hide until all components are created
            app.LabelconfigUIFigure = uifigure('Visible', 'off');
            app.LabelconfigUIFigure.Position = [100 100 640 480];
            app.LabelconfigUIFigure.Name = 'Label config';
            app.LabelconfigUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.LabelconfigUIFigure.CloseRequestFcn = createCallbackFcn(app, @LabelconfigUIFigureCloseRequest, true);
            app.LabelconfigUIFigure.KeyPressFcn = createCallbackFcn(app, @LabelconfigUIFigureKeyPress, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.LabelconfigUIFigure);
            app.GridLayout.RowHeight = {'1x'};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'8x', 'fit'};
            app.GridLayout2.Padding = [0 0 0 0];
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 1;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout2);
            app.GridLayout4.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Padding = [0 0 0 0];
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout4);
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.Padding = [0 0 0 0];
            app.GridLayout6.Layout.Row = 1;
            app.GridLayout6.Layout.Column = 3;

            % Create AddLabelButton
            app.AddLabelButton = uibutton(app.GridLayout6, 'push');
            app.AddLabelButton.ButtonPushedFcn = createCallbackFcn(app, @AddLabelButtonPushed, true);
            app.AddLabelButton.Layout.Row = 1;
            app.AddLabelButton.Layout.Column = 1;
            app.AddLabelButton.Text = '+';

            % Create RemoveLabelButton
            app.RemoveLabelButton = uibutton(app.GridLayout6, 'push');
            app.RemoveLabelButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveLabelButtonPushed, true);
            app.RemoveLabelButton.Layout.Row = 1;
            app.RemoveLabelButton.Layout.Column = 2;
            app.RemoveLabelButton.Text = '-';

            % Create LabelTable
            app.LabelTable = uitable(app.GridLayout2);
            app.LabelTable.ColumnName = {'Label'; 'C'};
            app.LabelTable.ColumnWidth = {'8x', '2x'};
            app.LabelTable.RowName = {};
            app.LabelTable.ColumnEditable = true;
            app.LabelTable.CellSelectionCallback = createCallbackFcn(app, @LabelTableCellSelection, true);
            app.LabelTable.Layout.Row = 1;
            app.LabelTable.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'1x'};
            app.GridLayout3.RowHeight = {'1x', 'fit', 'fit'};
            app.GridLayout3.Padding = [0 0 0 0];
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 2;

            % Create RatioTable
            app.RatioTable = uitable(app.GridLayout3);
            app.RatioTable.ColumnName = {'Label'; 'Ratio'};
            app.RatioTable.RowName = {};
            app.RatioTable.ColumnEditable = true;
            app.RatioTable.CellEditCallback = createCallbackFcn(app, @RatioTableCellEdit, true);
            app.RatioTable.DisplayDataChangedFcn = createCallbackFcn(app, @RatioTableDisplayDataChanged, true);
            app.RatioTable.Enable = 'off';
            app.RatioTable.Layout.Row = 1;
            app.RatioTable.Layout.Column = 1;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout3);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Padding = [0 0 0 0];
            app.GridLayout5.Layout.Row = 2;
            app.GridLayout5.Layout.Column = 1;

            % Create AddRatioButton
            app.AddRatioButton = uibutton(app.GridLayout5, 'push');
            app.AddRatioButton.ButtonPushedFcn = createCallbackFcn(app, @AddRatioButtonPushed, true);
            app.AddRatioButton.Enable = 'off';
            app.AddRatioButton.Layout.Row = 1;
            app.AddRatioButton.Layout.Column = 5;
            app.AddRatioButton.Text = '+';

            % Create RemoveRatioButton
            app.RemoveRatioButton = uibutton(app.GridLayout5, 'push');
            app.RemoveRatioButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveRatioButtonPushed, true);
            app.RemoveRatioButton.Enable = 'off';
            app.RemoveRatioButton.Layout.Row = 1;
            app.RemoveRatioButton.Layout.Column = 6;
            app.RemoveRatioButton.Text = '-';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout3);
            app.GridLayout7.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout7.RowHeight = {'1x'};
            app.GridLayout7.Padding = [0 0 0 0];
            app.GridLayout7.Layout.Row = 3;
            app.GridLayout7.Layout.Column = 1;

            % Create LoadButton
            app.LoadButton = uibutton(app.GridLayout7, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Layout.Row = 1;
            app.LoadButton.Layout.Column = 3;
            app.LoadButton.Text = 'Load';

            % Create SaveButton
            app.SaveButton = uibutton(app.GridLayout7, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Layout.Row = 1;
            app.SaveButton.Layout.Column = 4;
            app.SaveButton.Text = 'Save';

            % Show the figure after all components are created
            app.LabelconfigUIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = LabelConfig_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.LabelconfigUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end

        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.LabelconfigUIFigure)
        end

    end

end
