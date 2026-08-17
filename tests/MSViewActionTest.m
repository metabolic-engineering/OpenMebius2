classdef MSViewActionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function contextSelectsInitialExperiment(testCase)

            experiments = helpers.MSViewExperimentsStub();
            context = MSViewActionTest.context(experiments, 2);
            app = MSView_exported(context);
            cleanup = onCleanup( ...
                @() MSViewActionTest.deleteIfValid(app));

            testCase.verifyEqual( ...
                string(app.ExpDropDown.Value), "Experiment B");
            testCase.verifyEqual(app.MSTable.Data, experiments.Raw);

        end

        function plotPublishesComparisonRequest(testCase)

            context = MSViewActionTest.context( ...
                helpers.MSViewExperimentsStub(), 1);
            app = MSView_exported(context);
            cleanup = onCleanup( ...
                @() MSViewActionTest.deleteIfValid(app));
            recorder = helpers.MSViewEventRecorder();
            listener = addlistener( ...
                app, "ComparisonRequested", ...
                @(source, event) ...
                recorder.recordComparisonRequested(source, event));
            listenerCleanup = onCleanup(@() delete(listener));

            callback = app.PlotButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyTrue(recorder.ComparisonRequested);

        end

        function closePublishesEvent(testCase)

            context = MSViewActionTest.context( ...
                helpers.MSViewExperimentsStub(), 1);
            app = MSView_exported(context);
            cleanup = onCleanup( ...
                @() MSViewActionTest.deleteIfValid(app));
            recorder = helpers.MSViewEventRecorder();
            listener = addlistener( ...
                app, "Closed", ...
                @(source, event) ...
                recorder.recordClosed(source, event));
            listenerCleanup = onCleanup(@() delete(listener));

            close(app.MSViewerUIFigure);

            testCase.verifyTrue(recorder.Closed);
            testCase.verifyFalse(isvalid(app));

        end

    end % methods (Test)

    methods (Static, Access = private)

        function context = context(experiments, initialIndex)

            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(experiments);
            context = openmebius.presentation.experiment ...
                .MSViewContext( ...
                Presenter = presenter, ...
                InitialExperimentIndex = initialIndex);

        end

        function deleteIfValid(app)

            if ~isempty(app) && isvalid(app)
                delete(app);
            end

        end

    end % methods (Static, Access = private)

end % classdef
