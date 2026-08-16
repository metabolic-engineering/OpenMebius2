classdef ComparisonViewActionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function displaysAndReloadsCatalog(testCase)

            [presenter, service, catalog] = ...
                ComparisonViewActionTest.presenter();
            context = ComparisonViewActionTest.context( ...
                presenter, catalog);
            app = ComparisonView_exported(context);
            cleanup = onCleanup( ...
                @() ComparisonViewActionTest.deleteIfValid(app));

            testCase.verifyEqual( ...
                string(app.ExpListBox.Items), ["ExpA", "ExpB"]);
            testCase.verifyEqual( ...
                string(app.DataListBox.Items), "FragA");

            service.Catalog = openmebius.application.experiment ...
                .ExperimentComparisonCatalog( ...
                ExperimentNames = "ExpC", ...
                DataNames = ["FragB", "FragC"]);
            callback = app.ReloadButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual( ...
                string(app.ExpListBox.Items), "ExpC");
            testCase.verifyEqual( ...
                string(app.DataListBox.Items), ["FragB", "FragC"]);

        end

        function closePublishesEvent(testCase)

            [presenter, ~, catalog] = ...
                ComparisonViewActionTest.presenter();
            context = ComparisonViewActionTest.context( ...
                presenter, catalog);
            app = ComparisonView_exported(context);
            appCleanup = onCleanup( ...
                @() ComparisonViewActionTest.deleteIfValid(app));
            recorder = helpers.ComparisonViewEventRecorder();
            listener = addlistener( ...
                app, "Closed", ...
                @(source, event) ...
                recorder.recordClosed(source, event));
            listenerCleanup = onCleanup(@() delete(listener));

            callback = app.CloseButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyTrue(recorder.Closed);
            testCase.verifyFalse(isvalid(app));

        end

        function plotsExperimentRowsWithMdvStacks(testCase)

            [presenter, service, catalog] = ...
                ComparisonViewActionTest.presenter();
            comparison = array2table( ...
                [0.8, 0.7; 0.15, 0.2; 0.05, 0.1], ...
                VariableNames = ["ExpA", "ExpB"], ...
                RowNames = ["M0"; "M1"; "M2"]);
            service.Selection = openmebius.application.experiment ...
                .ExperimentComparisonSelection( ...
                ExperimentNames = ["ExpA", "ExpB"], ...
                DataNames = "FragA", ...
                Tables = {comparison});
            context = ComparisonViewActionTest.context( ...
                presenter, catalog);
            app = ComparisonView_exported(context);
            cleanup = onCleanup( ...
                @() ComparisonViewActionTest.deleteIfValid(app));
            app.ExpListBox.Value = {'ExpA', 'ExpB'};
            app.DataListBox.Value = {'FragA'};

            callback = app.DataListBox.ClickedFcn;
            callback([], []);

            testCase.assertNumElements(app.GridAxes.Children, 1);
            subplotGrid = app.GridAxes.Children(1);
            axesObjects = subplotGrid.Children;
            testCase.assertNumElements(axesObjects, 1);
            barObjects = axesObjects(1).Children;
            testCase.verifyNumElements(barObjects, 3);

        end

    end

    methods (Static, Access = private)

        function [presenter, service, catalogViewModel] = presenter()

            service = helpers.ExperimentComparisonServiceStub();
            service.Catalog = openmebius.application.experiment ...
                .ExperimentComparisonCatalog( ...
                ExperimentNames = ["ExpA", "ExpB"], ...
                DataNames = "FragA");
            experiments = helpers.ExperimentComparisonWorkspaceStub([]);
            presenter = openmebius.presentation.experiment ...
                .ComparisonViewPresenter( ...
                experiments, Service = service);
            catalogViewModel = presenter.presentCatalog();

        end

        function context = context(presenter, catalogViewModel)

            context = openmebius.presentation.experiment ...
                .ComparisonViewContext( ...
                Presenter = presenter, ...
                InitialCatalog = catalogViewModel);

        end

        function deleteIfValid(app)

            if ~isempty(app) && isvalid(app)
                delete(app);
            end

        end

    end

end
