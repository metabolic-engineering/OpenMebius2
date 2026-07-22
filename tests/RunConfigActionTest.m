classdef RunConfigActionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function restoresDefaultsWithoutSavingPreservedTables(testCase)

            batch = helpers.RunConfigBatchStub();
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));
            recorder = helpers.RunConfigEventRecorder();
            recorder.attach(app);
            efflux = table( ...
                true, 0.25, ...
                VariableNames = ["Selection", "SD"], ...
                RowNames = "substrate-a");
            pool = table( ...
                "metabolite-a", 2.5, ...
                VariableNames = ["Metabolite", "PoolSize"]);
            timeCourse = table( ...
                "exp-a", 3, ...
                VariableNames = ["TimePointExpName", "TimePoint"]);
            app.EffluxUITable.Data = efflux;
            app.INSTMFAPoolUITable.Data = pool;
            app.INSTMFATimeCourseUITable.Data = timeCourse;
            app.IterationSpinner.Value = 7;
            app.CalcCICheckBox.Value = true;

            callback = app.GeneralRestoreDefaultButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual(app.IterationSpinner.Value, 30);
            testCase.verifyFalse(app.CalcCICheckBox.Value);
            testCase.verifyEqual(app.EffluxUITable.Data, efflux);
            testCase.verifyEqual(app.INSTMFAPoolUITable.Data, pool);
            testCase.verifyEqual( ...
                app.INSTMFATimeCourseUITable.Data, timeCourse);
            testCase.verifyEqual( ...
                app.EffluxUITable.ColumnEditable, [false, false]);
            testCase.verifyEqual( ...
                app.INSTMFAPoolUITable.ColumnEditable, [false, false]);
            testCase.verifyEqual( ...
                app.INSTMFATimeCourseUITable.ColumnEditable, ...
                [false, false]);
            testCase.verifyTrue( ...
                all(app.GridReactionUITable.Data.Select));
            testCase.verifyEqual( ...
                app.GridReactionUITable.ColumnEditable, ...
                [true, false, false]);
            testCase.verifyEqual(app.EffluxUITable.Enable, 'off');
            testCase.verifyTrue(all(app.MSTable.Data{:, :}, "all"));
            testCase.verifyEqual(batch.ConfigUpdateCount, 0);
            testCase.verifyEqual(recorder.AppliedCount, 0);

        end

        function appliesAllSettingsFromEveryTab(testCase)

            batch = helpers.RunConfigBatchStub();
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));
            recorder = helpers.RunConfigEventRecorder();
            recorder.attach(app);
            app.IterationSpinner.Value = 42;
            app.MSTable.Data{1, 1} = true;

            applyButtons = [ ...
                                app.GeneralApplyButton
                            app.MSApplyAllButton
                            app.EffluxApplyButton
                            app.SuggestionApplyButton
                            app.INSTMFAApplyButton];

            for buttonIndex = 1:numel(applyButtons)
                callback = applyButtons(buttonIndex).ButtonPushedFcn;
                callback([], []);
            end

            testCase.verifyEqual(batch.Config.iteration, 42);
            testCase.verifyEqual(batch.ConfigUpdateCount, 5);
            testCase.verifyEqual(batch.FragmentUpdateCount, 5);
            testCase.verifyTrue( ...
                batch.LastFragmentSelections(1).Selection(1));
            testCase.verifyEqual(recorder.AppliedCount, 5);
            testCase.verifyEmpty(recorder.Notifications);

        end

        function cancelClosesWithoutSaving(testCase)

            batch = helpers.RunConfigBatchStub();
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            recorder = helpers.RunConfigEventRecorder();
            recorder.attach(app);

            callback = app.MSCancelButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyFalse(isvalid(app));
            testCase.verifyEqual(batch.ConfigUpdateCount, 0);
            testCase.verifyEqual(recorder.ClosedCount, 1);

        end

        function reportsApplyFailureAndKeepsOriginalConfig(testCase)

            batch = helpers.RunConfigBatchStub();
            batch.FailFragmentUpdate = true;
            originalIteration = batch.Config.iteration;
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));
            recorder = helpers.RunConfigEventRecorder();
            recorder.attach(app);
            app.IterationSpinner.Value = 55;

            callback = app.GeneralApplyButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual(batch.Config.iteration, originalIteration);
            testCase.verifyEqual(recorder.AppliedCount, 0);
            testCase.verifyNumElements(recorder.Notifications, 1);
            testCase.verifyEqual( ...
                recorder.Notifications{1}.Level, "error");
            testCase.verifyTrue( ...
                recorder.Notifications{1}.ShowAlert);

        end

        function retainsBothConfidenceIntervalModes(testCase)

            batch = helpers.RunConfigBatchStub();
            batch.Config.CIConf.algorithm = 'Grid search';
            batch.Config.CIConf.MC.iteration = 222;
            batch.Config.CIConf.grid.points = 17;
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));

            testCase.verifyEqual(app.MCLmaxEditField.Value, 222);
            testCase.verifyEqual( ...
                app.ThenumberofgridpointsEditField.Value, 17);

            app.MCLmaxEditField.Value = 333;
            app.ThenumberofgridpointsEditField.Value = 29;
            app.GridReactionUITable.Data.Select(2) = false;
            callback = app.GeneralApplyButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual( ...
                batch.Config.CIConf.MC.iteration, 333);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.points, 29);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.reactions.select, ...
                [true; false]);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.reactions.id, ...
                ["R1"; "R2"]);

        end

        function rendersConfidenceIntervalControlState(testCase)

            batch = helpers.RunConfigBatchStub();
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));

            app.CalcCICheckBox.Value = true;
            callback = app.CalcCICheckBox.ValueChangedFcn;
            callback([], []);

            testCase.verifyEqual( ...
                string(app.AlgorithmCIDropDown.Enable), "on");
            testCase.verifyEqual( ...
                string(app.MCLmaxEditField.Enable), "on");
            testCase.verifyEqual( ...
                string(app.DeterminegridintervalautomaticallyCheckBox.Enable), ...
            "off");
            testCase.verifyEmpty(app.GridreactionTab.Parent);

            app.AlgorithmCIDropDown.Value = 'Grid search';
            callback = app.AlgorithmCIDropDown.ValueChangedFcn;
            callback([], []);

            testCase.verifyEqual( ...
                string(app.MCLmaxEditField.Enable), "off");
            testCase.verifyEqual( ...
                string(app.DeterminegridintervalautomaticallyCheckBox.Enable), ...
            "on");
            testCase.verifyEqual( ...
                string(app.ThenumberofgridpointsEditField.Enable), "on");
            testCase.verifyEqual( ...
                string(app.GridintervalDeltaixiEditField.Enable), "off");
            testCase.verifyEqual( ...
                app.GridreactionTab.Parent, app.TabGroup2);

            app.CalcCICheckBox.Value = false;
            callback = app.CalcCICheckBox.ValueChangedFcn;
            callback([], []);
            testCase.verifyEmpty(app.GridreactionTab.Parent);

            app.CalcCICheckBox.Value = true;
            callback([], []);

            app.DeterminegridintervalautomaticallyCheckBox.Value = false;
            callback = app.DeterminegridintervalautomaticallyCheckBox ...
                .ValueChangedFcn;
            callback([], []);

            testCase.verifyEqual( ...
                string(app.ThenumberofgridpointsEditField.Enable), "off");
            testCase.verifyEqual( ...
                string(app.GridintervalDeltaixiEditField.Enable), "on");

        end

        function reportsINSTMFARestrictionThroughNotification(testCase)

            batch = helpers.RunConfigBatchStub();
            session = openmebius.application.batch ...
                .BatchConfigurationSession( ...
                batch, [], ["batch-a"; "batch-b"]);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));
            recorder = helpers.RunConfigEventRecorder();
            recorder.attach(app);
            app.INSTMFACheckBox.Value = true;

            callback = app.INSTMFACheckBox.ValueChangedFcn;
            callback([], struct(Source = app.INSTMFACheckBox));

            testCase.verifyFalse(app.INSTMFACheckBox.Value);
            testCase.verifyNumElements(recorder.Notifications, 1);
            testCase.verifyEqual( ...
                recorder.Notifications{1}.Level, "error");
            testCase.verifyTrue(recorder.Notifications{1}.ShowAlert);

        end

    end % methods (Test)

    methods (Static, Access = private)

        function app = createApp(session)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            editor = presenter.presentEditor(session);
            controller = openmebius.application.batch ...
                .BatchConfigurationController();
            experimentController = openmebius.application.experiment ...
                .ExperimentEditController();
            experimentPresenter = openmebius.presentation.experiment ...
                .ExperimentPresenter();
            selectionController = openmebius.application.batch ...
                .BatchExperimentSelectionEditorController();
            selectionPresenter = openmebius.presentation.batch ...
                .BatchExperimentSelectionEditorPresenter();
            context = openmebius.presentation.batch ...
                .RunConfigContext( ...
                Session = session, ...
                Presenter = presenter, ...
                Editor = editor, ...
                ConfigurationController = controller, ...
                ExperimentEditController = experimentController, ...
                ExperimentPresenter = experimentPresenter, ...
                ExperimentSelectionController = ...
                selectionController, ...
                ExperimentSelectionPresenter = ...
                selectionPresenter);
            app = RunConfig_exported(context);

        end % createApp

        function session = createSession(batch)

            session = openmebius.application.batch ...
                .BatchConfigurationSession( ...
                batch, [], "batch-a");

        end % createSession

        function deleteIfValid(app)

            if ~isempty(app) && isvalid(app)
                delete(app);
            end

        end

    end % methods (Static, Access = private)

end % classdef
