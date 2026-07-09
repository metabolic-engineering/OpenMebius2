classdef Preferences_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        PreferencesUIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        TabGroup matlab.ui.container.TabGroup
        NotificationTab matlab.ui.container.Tab
        GridLayout2 matlab.ui.container.GridLayout
        GridLayout3 matlab.ui.container.GridLayout
        SlackWebhookEditField matlab.ui.control.EditField
        WebhookEditFieldLabel matlab.ui.control.Label
        SlacknotificationCheckBox matlab.ui.control.CheckBox
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create PreferencesUIFigure and hide until all components are created
            app.PreferencesUIFigure = uifigure('Visible', 'off');
            app.PreferencesUIFigure.Position = [100 100 640 480];
            app.PreferencesUIFigure.Name = 'Preferences';
            app.PreferencesUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');

            % Create GridLayout
            app.GridLayout = uigridlayout(app.PreferencesUIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = 1;

            % Create NotificationTab
            app.NotificationTab = uitab(app.TabGroup);
            app.NotificationTab.Title = 'Notification';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.NotificationTab);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'fit', 'fit', '1x'};

            % Create SlacknotificationCheckBox
            app.SlacknotificationCheckBox = uicheckbox(app.GridLayout2);
            app.SlacknotificationCheckBox.Text = 'Slack notification';
            app.SlacknotificationCheckBox.Layout.Row = 1;
            app.SlacknotificationCheckBox.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout2);
            app.GridLayout3.ColumnWidth = {'1x', '6x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Padding = [0 0 0 0];
            app.GridLayout3.Layout.Row = 2;
            app.GridLayout3.Layout.Column = 1;

            % Create WebhookEditFieldLabel
            app.WebhookEditFieldLabel = uilabel(app.GridLayout3);
            app.WebhookEditFieldLabel.Layout.Row = 1;
            app.WebhookEditFieldLabel.Layout.Column = 1;
            app.WebhookEditFieldLabel.Text = 'Webhook';

            % Create SlackWebhookEditField
            app.SlackWebhookEditField = uieditfield(app.GridLayout3, 'text');
            app.SlackWebhookEditField.Layout.Row = 1;
            app.SlackWebhookEditField.Layout.Column = 2;

            % Show the figure after all components are created
            app.PreferencesUIFigure.Visible = 'on';
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Preferences_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.PreferencesUIFigure)

            if nargout == 0
                clear app
            end

        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.PreferencesUIFigure)
        end

    end

end
