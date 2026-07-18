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

        end

        function parentConstructsComparisonPresenter(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "OpenMebius2_exported.m")));

            testCase.verifyTrue( ...
                contains(source, "ComparisonViewPresenter(app.exp)"));
            testCase.verifyFalse( ...
                contains(source, "ComparisonView(app, ""ms"")"));

        end

    end

end
