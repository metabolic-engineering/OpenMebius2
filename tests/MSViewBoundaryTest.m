classdef MSViewBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function childAppUsesContextAndEvents(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "MSView_exported.m")));

            testCase.verifyFalse(contains(source, "MainApp"));
            testCase.verifyTrue(contains(source, "ComparisonRequested"));
            testCase.verifyTrue(contains(source, "notify(app, ""Closed"")"));
            testCase.verifyTrue(contains( ...
                source, "startupFcn(app, context)"));
            testCase.verifyFalse(contains( ...
                source, ...
                "startupFcn(app, Presenter, idx, isDarkTheme)"));

        end

        function mainAppOwnsMSViewLifecycle(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "OpenMebius2_exported.m")));

            testCase.verifyTrue(contains(source, ".MSViewContext("));
            testCase.verifyTrue(contains(source, "MSView(context)"));
            testCase.verifyTrue(contains(source, "attachMSViewListeners"));
            testCase.verifyTrue(contains(source, "detachMSViewListeners"));
            testCase.verifyTrue(contains(source, "closeMSViewApp"));
            testCase.verifyTrue(contains(source, "onMSViewClosed"));
            testCase.verifyFalse(contains( ...
                source, "app.MSViewListeners = addlistener("));

        end

    end % methods (Test)

end % classdef
