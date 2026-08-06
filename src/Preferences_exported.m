classdef Preferences_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        PreferencesUIFigure         matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        GridLayout4                 matlab.ui.container.GridLayout
        CancelButton                matlab.ui.control.Button
        CloseButton                 matlab.ui.control.Button
        TabGroup                    matlab.ui.container.TabGroup
        NotificationTab             matlab.ui.container.Tab
        GridLayout2                 matlab.ui.container.GridLayout
        GridLayout3                 matlab.ui.container.GridLayout
        SlackWebhookEditField       matlab.ui.control.EditField
        WebhookEditFieldLabel       matlab.ui.control.Label
        SlacknotificationCheckBox   matlab.ui.control.CheckBox
        CalculationTab              matlab.ui.container.Tab
        GridLayout2_2               matlab.ui.container.GridLayout
        GridLayout5                 matlab.ui.container.GridLayout
        GridLayout6                 matlab.ui.container.GridLayout
        MDVcorrectionDropDown       matlab.ui.control.DropDown
        MDVcorrectionDropDownLabel  matlab.ui.control.Label
    end


    properties (Access = private)
        SlackNotifier openmebius.infrastructure.notification.SlackWebhookNotifier
        MDVCorrectionPreference openmebius.infrastructure.preferences ...
            .MDVCorrectionPreference
        PreferencesClosedNotified (1, 1) logical = false
        NotificationPublisher (1, 1) function_handle = @(~) []
    end

    events
        PreferencesClosed
    end

    methods (Access = private)

        function loadSlackPreferences(app)

            if isempty(app.SlackNotifier)
                app.SlackNotifier = ...
                    openmebius.infrastructure.notification.SlackWebhookNotifier();
            end

            enabled = app.SlackNotifier.isEnabled();
            webhook = app.SlackNotifier.getWebhook();

            app.SlacknotificationCheckBox.Value = enabled;
            app.SlackWebhookEditField.Enable = app.onOff(enabled);

            if webhook == ""
                app.SlackWebhookEditField.Value = "";
            else
                app.SlackWebhookEditField.Value = ...
                    app.SlackNotifier.maskWebhook(webhook);
            end

        end % method loadSlackPreferences

        function saveSlackPreferences(app)

            if isempty(app.SlackNotifier)
                app.SlackNotifier = ...
                    openmebius.infrastructure.notification.SlackWebhookNotifier();
            end

            enabled = logical(app.SlacknotificationCheckBox.Value);
            app.SlackNotifier.setEnabled(enabled);

            value = strtrim(string(app.SlackWebhookEditField.Value));

            if isempty(value) || value == ""
                app.SlackNotifier.clearWebhook();
                return
            end

            if app.SlackNotifier.isMaskedWebhook(value)
                return
            end

            app.SlackNotifier.setWebhook(value);

            app.SlackWebhookEditField.Value = ...
                app.SlackNotifier.maskWebhook(value);

        end % method saveSlackPreferences

        function loadMDVCorrectionPreference(app)

            if isempty(app.MDVCorrectionPreference)
                app.MDVCorrectionPreference = openmebius.infrastructure ...
                    .preferences.MDVCorrectionPreference();
            end

            app.MDVcorrectionDropDown.ItemsData = ...
                cellstr(app.MDVCorrectionPreference.SupportedMethods);
            app.MDVcorrectionDropDown.Value = char( ...
                app.MDVCorrectionPreference.getMethod());

        end % loadMDVCorrectionPreference

        function saveMDVCorrectionPreference(app)

            if isempty(app.MDVCorrectionPreference)
                app.MDVCorrectionPreference = openmebius.infrastructure ...
                    .preferences.MDVCorrectionPreference();
            end

            app.MDVCorrectionPreference.setMethod( ...
                string(app.MDVcorrectionDropDown.Value));

        end % saveMDVCorrectionPreference

        function value = onOff(~, enabled)

            if enabled
                value = 'on';
            else
                value = 'off';
            end

        end % method onOff

        function showPreferenceNotification(app, notification)

            if isempty(notification)
                return
            end

            if ~isa(notification, ...
                "openmebius.presentation.notification.Notification")

                notification = ...
                    openmebius.presentation.notification.Notification.info( ...
                    string(notification));
            end

            app.NotificationPublisher( ...
                notification.toMessage( ...
                Code = "preferences.operation", ...
                Source = "Preferences"));

        end % method showPreferenceNotification

        function renderLocalNotification(app, message)

            notification = openmebius.presentation.notification ...
                .Notification.fromMessage( ...
                message, ...
                Title = message.Title, ...
                ShowAlert = true);
            uialert( ...
                app.PreferencesUIFigure, ...
                char(notification.Message), ...
                char(notification.Title), ...
                "Icon", char(notification.alertIcon()), ...
                "Interpreter", "none");

        end % method renderLocalNotification

        function showLocalWarning(app, ME)

            notification = ...
                openmebius.presentation.notification.Notification.fromException( ...
                ME, ...
                Title = "Preferences", ...
                ShowAlert = true);

            app.showPreferenceNotification(notification);

        end % method showLocalWarning

        function notifyPreferencesClosed(app)

            if app.PreferencesClosedNotified
                return
            end

            app.PreferencesClosedNotified = true;

            try
                notify(app, 'PreferencesClosed');
            catch
                % Main app may have already been deleted.
            end

        end % method notifyPreferencesClosed

        function closePreferences(app)

            app.notifyPreferencesClosed();
            delete(app);

        end % closePreferences

    end % methods (Access = private)


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, slackNotifier, notificationPublisher, ...
                mdvCorrectionPreference)

            if nargin < 2 || isempty(slackNotifier)
                slackNotifier = ...
                    openmebius.infrastructure.notification.SlackWebhookNotifier();
            end

            app.SlackNotifier = slackNotifier;

            if nargin >= 3 && ~isempty(notificationPublisher)
                app.NotificationPublisher = notificationPublisher;
            else
                app.NotificationPublisher = ...
                    @(message) app.renderLocalNotification(message);
            end

            if nargin < 4 || isempty(mdvCorrectionPreference)
                mdvCorrectionPreference = openmebius.infrastructure ...
                    .preferences.MDVCorrectionPreference();
            end

            app.MDVCorrectionPreference = mdvCorrectionPreference;

            app.loadSlackPreferences();
            app.loadMDVCorrectionPreference();
        end

        % Value changed function: SlacknotificationCheckBox
        function SlacknotificationCheckBoxValueChanged(app, event)

            enabled = logical(app.SlacknotificationCheckBox.Value);

            app.SlackWebhookEditField.Enable = app.onOff(enabled);
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)

            app.closePreferences();
        end

        % Button pushed function: CloseButton
        function CloseButtonPushed(app, event)

            try
                app.saveSlackPreferences();
                app.saveMDVCorrectionPreference();
                app.closePreferences();

            catch ME
                app.showPreferenceNotification( ...
                    openmebius.presentation.notification.Notification.fromException( ...
                    ME, ...
                    Title = "Preferences", ...
                    ShowAlert = true));
            end
        end

        % Close request function: PreferencesUIFigure
        function PreferencesUIFigureCloseRequest(app, event)

            app.closePreferences();
        end
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
            app.PreferencesUIFigure.CloseRequestFcn = createCallbackFcn(app, @PreferencesUIFigureCloseRequest, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.PreferencesUIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x', 'fit'};

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
            app.GridLayout2.RowHeight = {'fit', 'fit', '1x', 'fit'};

            % Create SlacknotificationCheckBox
            app.SlacknotificationCheckBox = uicheckbox(app.GridLayout2);
            app.SlacknotificationCheckBox.ValueChangedFcn = createCallbackFcn(app, @SlacknotificationCheckBoxValueChanged, true);
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

            % Create CalculationTab
            app.CalculationTab = uitab(app.TabGroup);
            app.CalculationTab.Title = 'Calculation';

            % Create GridLayout2_2
            app.GridLayout2_2 = uigridlayout(app.CalculationTab);
            app.GridLayout2_2.RowHeight = {'1x'};

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout2_2);
            app.GridLayout5.ColumnWidth = {'1x'};
            app.GridLayout5.RowHeight = {'fit', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout5.Padding = [0 0 0 0];
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 1;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout5);
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.Padding = [0 0 0 0];
            app.GridLayout6.Layout.Row = 1;
            app.GridLayout6.Layout.Column = 1;

            % Create MDVcorrectionDropDownLabel
            app.MDVcorrectionDropDownLabel = uilabel(app.GridLayout6);
            app.MDVcorrectionDropDownLabel.Layout.Row = 1;
            app.MDVcorrectionDropDownLabel.Layout.Column = 1;
            app.MDVcorrectionDropDownLabel.Text = 'MDV correction';

            % Create MDVcorrectionDropDown
            app.MDVcorrectionDropDown = uidropdown(app.GridLayout6);
            app.MDVcorrectionDropDown.Items = {'Classical', 'Skew method', 'Skew LSQ'};
            app.MDVcorrectionDropDown.Layout.Row = 1;
            app.MDVcorrectionDropDown.Layout.Column = 2;
            app.MDVcorrectionDropDown.Value = 'Skew method';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;

            % Create CloseButton
            app.CloseButton = uibutton(app.GridLayout4, 'push');
            app.CloseButton.ButtonPushedFcn = createCallbackFcn(app, @CloseButtonPushed, true);
            app.CloseButton.Layout.Row = 1;
            app.CloseButton.Layout.Column = 6;
            app.CloseButton.Text = 'Close';

            % Create CancelButton
            app.CancelButton = uibutton(app.GridLayout4, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.Layout.Row = 1;
            app.CancelButton.Layout.Column = 5;
            app.CancelButton.Text = 'Cancel';

            % Show the figure after all components are created
            app.PreferencesUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Preferences_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.PreferencesUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

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
