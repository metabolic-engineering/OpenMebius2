classdef RunAddBatch_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        AddbatchUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        GridLayout2 matlab.ui.container.GridLayout
        CloseButton matlab.ui.control.Button
        AddButton matlab.ui.control.Button
        UITable matlab.ui.control.Table
        AddAsParallel matlab.ui.control.CheckBox
    end

    properties (Access = private)

        Action openmebius.presentation.batch.RunAddBatchAction

    end % private properties

    events

        Applied
        Closed

    end % events

    methods (Access = private)

        %% Private initialization methods
        function initTable(app)
            % INITTABLE Initialize the UITable with default properties

            app.UITable.Data = app.Action.initialTable();
            app.UITable.ColumnWidth = {50, '1x'};
            app.UITable.ColumnEditable = [true, false]; % Make only the Add column editable

        end % method initTable

        function applySelection(app)

            selection = app.Action.createSelection( ...
                app.UITable.Data, ...
                logical(app.AddAsParallel.Value));

            if isempty(selection)
                return
            end

            eventData = openmebius.presentation.batch ...
                .BatchExperimentSelectionEventData(selection);
            notify(app, "Applied", eventData);

        end % applySelection

    end % private methods

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, context)

            editor = context.Editor;
            app.Action = context.Action;

            if editor.Mode == "inst-mfa"
                app.AddAsParallel.Visible = 'off';
            end

            initTable(app);
        end

        % Button pushed function: AddButton
        function AddButtonPushed(app, event)

            app.applySelection();
        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)

            % Close the app when the Close button is pressed
            close(app.AddbatchUIFigure);
        end

        % Key press function: AddbatchUIFigure
        function AddbatchUIFigureKeyPress(app, event)

            key = event.Key;

            if strcmp(key, 'escape')
                % Close the app if the Escape key is pressed
                close(app.AddbatchUIFigure);

            end

        end

        % Close request function: AddbatchUIFigure
        function AddbatchUIFigureCloseRequest(app, event)
            uiresume(app.AddbatchUIFigure);
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

            % Create AddbatchUIFigure and hide until all components are created
            app.AddbatchUIFigure = uifigure('Visible', 'off');
            app.AddbatchUIFigure.Position = [100 100 480 640];
            app.AddbatchUIFigure.Name = 'Add batch';
            app.AddbatchUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.AddbatchUIFigure.CloseRequestFcn = createCallbackFcn(app, @AddbatchUIFigureCloseRequest, true);
            app.AddbatchUIFigure.KeyPressFcn = createCallbackFcn(app, @AddbatchUIFigureKeyPress, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.AddbatchUIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x', 'fit', 'fit'};

            % Create AddAsParallel
            app.AddAsParallel = uicheckbox(app.GridLayout);
            app.AddAsParallel.Text = 'Add batch row as parallel labeling';
            app.AddAsParallel.Layout.Row = 2;
            app.AddAsParallel.Layout.Column = 1;
            app.AddAsParallel.Value = true;

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = '';
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.Layout.Row = 1;
            app.UITable.Layout.Column = 1;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 3;
            app.GridLayout2.Layout.Column = 1;

            % Create AddButton
            app.AddButton = uibutton(app.GridLayout2, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPushed, true);
            app.AddButton.Layout.Row = 1;
            app.AddButton.Layout.Column = 4;
            app.AddButton.Text = 'Add';

            % Create CloseButton
            app.CloseButton = uibutton(app.GridLayout2, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.Layout.Row = 1;
            app.CloseButton.Layout.Column = 5;
            app.CloseButton.Text = 'Close';

            % Show the figure after all components are created
            app.AddbatchUIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = RunAddBatch_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.AddbatchUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end

        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.AddbatchUIFigure)
        end

    end

end
