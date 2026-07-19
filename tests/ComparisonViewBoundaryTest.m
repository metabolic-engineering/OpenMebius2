classdef ComparisonViewBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function childAppDoesNotReferenceMainApp(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "ComparisonView_exported.m")));

            testCase.verifyFalse(contains(source, "MainApp"));
            testCase.verifyTrue(contains(source, "ComparisonViewPresenter"));
            testCase.verifyTrue( ...
                contains(source, "NotificationRequested"));
            testCase.verifyTrue(contains(source, "notify(app, ""Closed"""));
            testCase.verifyTrue(contains( ...
                source, "startupFcn(app, context)"));
            testCase.verifyFalse(contains( ...
                source, ...
                "startupFcn(app, presenter, catalogViewModel, type)"));

        end

        function parentConstructsComparisonPresenter(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "OpenMebius2_exported.m")));

            testCase.verifyTrue( ...
                contains(source, ...
                    "ComparisonViewPresenter("));
            testCase.verifyTrue(contains( ...
                source, "app.ApplicationController.experiments()"));
            testCase.verifyTrue(contains(source, ".ComparisonViewContext("));
            testCase.verifyTrue(contains(source, "ComparisonView(context)"));
            testCase.verifyTrue(contains( ...
                source, "closeComparisonViewApp"));
            testCase.verifyFalse( ...
                contains(source, "ComparisonView(app, ""ms"")"));
            testCase.verifyFalse(contains( ...
                source, ...
                "presenter, catalogViewModel, ""ms"""));

        end

    end

end
