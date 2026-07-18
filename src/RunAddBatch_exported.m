classdef RunAddBatch_exported < matlab.apps.AppBase

    events
        Applied
    end

    % Properties that correspond to app components
    properties (Access = public)
        AddbatchUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        AddAsParallel matlab.ui.control.CheckBox
        UITable matlab.ui.control.Table
        GridLayout2 matlab.ui.container.GridLayout
        AddButton matlab.ui.control.Button
        CloseButton matlab.ui.control.Button
    end

    properties (Access = private)

        ExperimentNames (:, 1) string
        type (1, 1) string
        batchID (1, 1) string = ""

    end % private properties

    methods (Access = private)

        %% Private initialization methods
        function initTable(app)
            % INITTABLE Initialize the UITable with default properties

            expList = app.ExperimentNames;

            dataTable = table( ...
                false(length(expList), 1), ... % Add column initialized to false
                expList, ... % Experiment names
                'VariableNames', {'Add', 'Experiment'} ...
            );

            app.UITable.Data = dataTable;
            app.UITable.ColumnWidth = {50, '1x'};
            app.UITable.ColumnEditable = [true, false]; % Make only the Add column editable

        end % method initTable

    end % private methods

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, experimentNames, type, batchID)

            if nargin < 4
                batchID = "";
            end

            app.ExperimentNames = string(experimentNames(:));
            app.type = string(type);
            app.batchID = string(batchID);

            if app.type == "inst-mfa"
                app.AddAsParallel.Visible = 'off';
            end

            initTable(app);

        end

        % Button pushed function: AddButton
        function AddButtonPushed(app, event)

            data = app.UITable.Data;
            % Get Add column
            addColumn = data{:, 1};
            expList = data{:, 2};

            % Get selected experiments
            selectedExps = expList(addColumn);

            if isempty(selectedExps)
                return;
            end

            selection = openmebius.domain.batch ...
                .BatchExperimentSelection( ...
                    Mode = app.type, ...
                    Experiments = string(selectedExps), ...
                    AddAsParallel = logical(app.AddAsParallel.Value), ...
                    BatchId = app.batchID);
            eventData = openmebius.presentation.batch ...
                .BatchExperimentSelectionEventData(selection);
            notify(app, "Applied", eventData);

            % Close the app after adding the batch items
            % close(app.AddbatchUIFigure);

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

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 3;
            app.GridLayout2.Layout.Column = 1;

            % Create CloseButton
            app.CloseButton = uibutton(app.GridLayout2, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.Layout.Row = 1;
            app.CloseButton.Layout.Column = 5;
            app.CloseButton.Text = 'Close';

            % Create AddButton
            app.AddButton = uibutton(app.GridLayout2, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPushed, true);
            app.AddButton.Layout.Row = 1;
            app.AddButton.Layout.Column = 4;
            app.AddButton.Text = 'Add';

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = '';
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.Layout.Row = 1;
            app.UITable.Layout.Column = 1;

            % Create AddAsParallel
            app.AddAsParallel = uicheckbox(app.GridLayout);
            app.AddAsParallel.Text = 'Add batch row as parallel labeling';
            app.AddAsParallel.Layout.Row = 2;
            app.AddAsParallel.Layout.Column = 1;
            app.AddAsParallel.Value = true;

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
