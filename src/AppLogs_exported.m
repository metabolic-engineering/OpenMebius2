classdef AppLogs_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        LogsUIFigure     matlab.ui.Figure
        FilesMenu        matlab.ui.container.Menu
        SaveAsCtrlSMenu  matlab.ui.container.Menu
        GridLayout       matlab.ui.container.GridLayout
        TextArea         matlab.ui.control.TextArea
    end


    properties (Access = private)
        NotificationPublisher (1, 1) function_handle = @(~) []
    end

    methods (Access = protected)

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

    end % methods (Access = protected)

    methods (Access = private)

        function loadLogs(app)

            filename = openmebius.infrastructure.logging.Logger ...
                .defaultLogFile();
            logLines = openmebius.infrastructure.logging.Logger ...
                .readTail(filename, MaxLines = 5000);

            app.TextArea.Value = cellstr(logLines);

        end % function loadLogs

        function publishNotification(app, level, text)

            emitter = openmebius.application.notification ...
                .NotificationEmitter( ...
                Publisher = app.NotificationPublisher, ...
                Source = "AppLogs");
            emitter.report( ...
                level, ...
                text, ...
                Code = "log.export");

        end % publishNotification

    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, notificationPublisher)

            if nargin >= 2 && ~isempty(notificationPublisher)
                app.NotificationPublisher = notificationPublisher;
            else
                consoleSink = openmebius.infrastructure.notification ...
                    .ConsoleSink();
                app.NotificationPublisher = ...
                    @(message) consoleSink.write(message);
            end

            app.loadLogs();
        end

        % Menu selected function: SaveAsCtrlSMenu
        function SaveAsCtrlSMenuSelected(app, event)

            [folder, isOK] = app.uiGetDirWrap();

            if ~isOK
                return;
            end

            try
                openmebius.infrastructure.logging.Logger ...
                    .copyDefaultLogTo(folder);
                msg = "Log file saved to: " + ...
                    fullfile(folder, "openmebius2.log");
                app.publishNotification("success", msg);
            catch ME
                msg = "Failed to save log file: " + ME.message;
                app.publishNotification("error", msg);
            end
        end

        % Key press function: LogsUIFigure
        function LogsUIFigureKeyPress(app, event)

            key = event.Key;

            if strcmp(key, "s") && ismember("control", event.Modifier)
                app.SaveAsCtrlSMenuSelected();
            elseif strcmp(key, "escape")
                delete(app);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create LogsUIFigure and hide until all components are created
            app.LogsUIFigure = uifigure('Visible', 'off');
            app.LogsUIFigure.Position = [100 100 1280 720];
            app.LogsUIFigure.Name = 'Logs';
            app.LogsUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.LogsUIFigure.KeyPressFcn = createCallbackFcn(app, @LogsUIFigureKeyPress, true);

            % Create FilesMenu
            app.FilesMenu = uimenu(app.LogsUIFigure);
            app.FilesMenu.Text = 'Files';

            % Create SaveAsCtrlSMenu
            app.SaveAsCtrlSMenu = uimenu(app.FilesMenu);
            app.SaveAsCtrlSMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveAsCtrlSMenuSelected, true);
            app.SaveAsCtrlSMenu.Text = 'Save As (Ctrl + S)';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.LogsUIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create TextArea
            app.TextArea = uitextarea(app.GridLayout);
            app.TextArea.Layout.Row = 1;
            app.TextArea.Layout.Column = 1;

            % Show the figure after all components are created
            app.LogsUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AppLogs_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.LogsUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.LogsUIFigure)
        end
    end
end