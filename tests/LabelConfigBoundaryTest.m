classdef LabelConfigBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function exportedChildAppDoesNotReferenceMainApp(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "LabelConfig_exported.m")));

            testCase.verifyFalse(contains(source, "MainApp"));
            testCase.verifyTrue(contains(source, "notify(app, ""Applied"""));
            testCase.verifyTrue( ...
                contains(source, "notify(app, ""Closed"""));
            testCase.verifyTrue( ...
                contains(source, "NotificationRequested"));
            testCase.verifyFalse( ...
                contains(source, "GeneralMessageEventData"));
            testCase.verifyTrue( ...
                contains(source, "startupFcn(app, context)"));
            testCase.verifyFalse( ...
                contains(source, ...
                    "startupFcn(app, tableLabelView, structLabelView)"));

        end

        function mainAppUsesTypedLaunchBoundary(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "OpenMebius2_exported.m")));

            testCase.verifyTrue(contains( ...
                source, "app.ApplicationController"));
            testCase.verifyTrue(contains( ...
                source, ".prepareLabelConfiguration()"));
            testCase.verifyTrue(contains( ...
                source, "LabelConfigPresenter"));
            testCase.verifyTrue(contains( ...
                source, "LabelConfigContext"));
            testCase.verifyTrue(contains( ...
                source, "closeLabelConfigApp"));
            testCase.verifyFalse(contains( ...
                source, "app.model.tableLabelView"));
            testCase.verifyFalse(contains( ...
                source, "app.model.structLabelView"));

        end

        function appliedEventCarriesEditedValues(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            labelTable = table( ...
                {"Uniform"}, {1}, ...
                VariableNames = ["Name", "Num"]);
            ratioTables = struct( ...
                Uniform = table( ...
                    {"#1"}, {1}, ...
                    VariableNames = ["Label", "Ratio"]));

            eventData = openmebius.presentation.model ...
                .LabelConfigurationAppliedEventData( ...
                    labelTable, ratioTables);

            testCase.verifyEqual(eventData.LabelTable, labelTable);
            testCase.verifyEqual(eventData.RatioTables, ratioTables);

        end

        function notificationEventCarriesTypedNotification(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            notification = openmebius.presentation.notification ...
                .Notification.info("Updated.");

            eventData = openmebius.presentation.notification ...
                .NotificationEventData(notification);

            testCase.verifyEqual(eventData.Notification, notification);

        end

    end

end
