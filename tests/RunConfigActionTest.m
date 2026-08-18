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
            suggestion = table("pattern-a", ...
                VariableNames = "exp-a");
            app.EffluxUITable.Data = efflux;
            app.LabelTable.Data = suggestion;
            app.INSTMFAPoolUITable.Data = pool;
            app.INSTMFATimeCourseUITable.Data = timeCourse;
            app.MSTable.Data{1, 1} = false;
            app.GridReactionUITable.Data.Select(2) = false;
            expectedMS = app.MSTable.Data;
            expectedGrid = app.GridReactionUITable.Data;
            app.IterationSpinner.Value = 7;
            app.CalcCICheckBox.Value = true;
            app.MaxIterationsEditField.Value = 99;
            app.EnforceFluxBoundsCheckBox.Value = true;
            app.MCLmaxEditField_2.Value = 9;

            callback = app.GeneralRestoreDefaultButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual(app.IterationSpinner.Value, 30);
            testCase.verifyFalse(app.CalcCICheckBox.Value);
            testCase.verifyEqual( ...
                app.MaxIterationsEditField.Value, 2000);
            testCase.verifyFalse( ...
                app.EnforceFluxBoundsCheckBox.Value);
            testCase.verifyEqual(app.MCLmaxEditField_2.Value, 3);
            testCase.verifyEqual(app.EffluxUITable.Data, efflux);
            testCase.verifyEqual(app.LabelTable.Data, suggestion);
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
            testCase.verifyEqual( ...
                app.GridReactionUITable.Data, expectedGrid);
            testCase.verifyEqual( ...
                app.GridReactionUITable.ColumnEditable, ...
                [true, false, false]);
            testCase.verifyEqual(app.EffluxUITable.Enable, 'off');
            testCase.verifyEqual(app.MSTable.Data, expectedMS);
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
            app.AlgorithmDropDown.Value = 'IPMs';
            app.FluxLBEditField.Value = -200;
            app.FluxUBEditField.Value = 300;
            app.MaxFunctionEvaluationsEditField.Value = 4321;
            app.MaxIterationsEditField.Value = 876;
            app.FunctionToleranceEditField.Value = 2e-6;
            app.StepToleranceEditField.Value = 3e-10;
            app.OptimalityToleranceEditField.Value = 4e-8;
            app.ConstraintToleranceEditField.Value = 5e-8;
            app.FiniteDifferenceTypeDropDown.Value = 'Forward';
            app.FiniteDifferenceStepSizeEditField.Value = 6e-6;
            app.SearchOptimalFiniteDifferenceStepSizeCheckBox.Value = ...
                false;
            app.EnforceFluxBoundsCheckBox.Value = true;
            app.MCLmaxEditField_2.Value = 4.5;

            callback = app.OptimizationCloseButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual(batch.Config.iteration, 42);
            testCase.verifyEqual(batch.Config.algorithm, 'interior-point');
            testCase.verifyEqual(batch.Config.fluxLB, -200);
            testCase.verifyEqual(batch.Config.fluxUB, 300);
            testCase.verifyEqual( ...
                batch.Config.fmincon.maxFunctionEvaluations, 4321);
            testCase.verifyEqual( ...
                batch.Config.fmincon.maxIterations, 876);
            testCase.verifyEqual( ...
                batch.Config.fmincon.functionTolerance, 2e-6);
            testCase.verifyEqual( ...
                batch.Config.fmincon.stepTolerance, 3e-10);
            testCase.verifyEqual( ...
                batch.Config.fmincon.optimalityTolerance, 4e-8);
            testCase.verifyEqual( ...
                batch.Config.fmincon.constraintTolerance, 5e-8);
            testCase.verifyEqual( ...
                batch.Config.fmincon.finiteDifferenceType, 'forward');
            testCase.verifyEqual( ...
                batch.Config.fmincon.finiteDifferenceStepSize, 6e-6);
            testCase.verifyFalse( ...
                batch.Config.fmincon ...
                .finiteDifferenceStepSizeSearch.enabled);
            testCase.verifyTrue( ...
                batch.Config.fmincon.enforceFluxBounds);
            testCase.verifyEqual( ...
                batch.Config.initialFlux ...
                .freeEffluxSeedSigmaMultiplier, 4.5);
            testCase.verifyEqual(batch.ConfigUpdateCount, 1);
            testCase.verifyEqual(batch.FragmentUpdateCount, 1);
            testCase.verifyTrue( ...
                batch.LastFragmentSelections(1).Selection(1));
            testCase.verifyEqual(recorder.AppliedCount, 1);
            testCase.verifyEqual(recorder.ClosedCount, 1);
            testCase.verifyEmpty(recorder.Notifications);
            testCase.verifyFalse(isvalid(app));

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

        function terminalConfigurationDisablesEditingAndClosesWithoutSaving( ...
                testCase)

            batch = helpers.RunConfigBatchStub();
            batch.Config.status = 'finished';
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));
            recorder = helpers.RunConfigEventRecorder();
            recorder.attach(app);

            testCase.verifyEqual(string(app.IterationSpinner.Enable), "off");
            testCase.verifyEqual(string(app.CalcCICheckBox.Enable), "off");
            testCase.verifyEqual(string(app.MSTable.Enable), "off");
            testCase.verifyFalse(any(app.MSTable.ColumnEditable));
            testCase.verifyEqual( ...
                string(app.GeneralRestoreDefaultButton.Enable), "off");
            testCase.verifyEqual( ...
                string(app.GeneralCloseButton.Enable), "on");
            testCase.verifyEqual( ...
                string(app.GeneralCancelButton.Enable), "on");

            callback = app.GeneralCloseButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyFalse(isvalid(app));
            testCase.verifyEqual(batch.ConfigUpdateCount, 0);
            testCase.verifyEqual(batch.FragmentUpdateCount, 0);
            testCase.verifyEqual(recorder.AppliedCount, 0);
            testCase.verifyEqual(recorder.ClosedCount, 1);

        end

        function escapeClosesWithoutSaving(testCase)

            batch = helpers.RunConfigBatchStub();
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            recorder = helpers.RunConfigEventRecorder();
            recorder.attach(app);
            app.IterationSpinner.Value = 91;

            callback = app.BatchconfigUIFigure.KeyPressFcn;
            callback([], struct(Key = 'escape'));

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

            callback = app.GeneralCloseButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual(batch.Config.iteration, originalIteration);
            testCase.verifyEqual(recorder.AppliedCount, 0);
            testCase.verifyNumElements(recorder.Notifications, 1);
            testCase.verifyEqual( ...
                recorder.Notifications{1}.Level, "error");
            testCase.verifyTrue( ...
                recorder.Notifications{1}.ShowAlert);
            testCase.verifyTrue(isvalid(app));

        end

        function retainsBothConfidenceIntervalModes(testCase)

            batch = helpers.RunConfigBatchStub();
            batch.Config.CIConf.algorithm = 'Grid search';
            batch.Config.CIConf.MC.iteration = 222;
            batch.Config.CIConf.grid.points = 18;
            batch.Config.CIConf.grid.workerCount = 12;
            batch.Config.CIConf.grid.minimumFluxRange = 2e-5;
            batch.Config.CIConf.grid.intervalMode = 'automatic';
            batch.Config.CIConf.grid.executionMode = 'parallel';
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));

            testCase.verifyEqual(app.MCLmaxEditField.Value, 222);
            testCase.verifyEqual( ...
                app.ThenumberofgridpointsEditField.Value, 18);
            testCase.verifyEqual( ...
                app.MinimumFLuxRangeEditField.Value, 2e-5);
            testCase.verifyEqual(app.ParallelworkersEditField.Value, 12);
            testCase.verifyEqual( ...
                app.GridLayout12_6.Parent, app.GridLayout8);
            testCase.verifyTrue( ...
                app.DeterminegridintervalautomaticallyCheckBox.Value);
            testCase.verifyTrue(app.CheckBox.Value);

            app.MCLmaxEditField.Value = 333;
            app.ThenumberofgridpointsEditField.Value = 29;
            app.MinimumFLuxRangeEditField.Value = 3e-4;
            app.ParallelworkersEditField.Value = 16;
            app.DeterminegridintervalautomaticallyCheckBox.Value = false;
            app.CheckBox.Value = false;
            app.GridReactionUITable.Data.Select(2) = false;
            callback = app.GeneralCloseButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual( ...
                batch.Config.CIConf.MC.iteration, 333);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.points, 29);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.minimumFluxRange, 3e-4);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.workerCount, 16);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.intervalMode, ...
                'fixed-delta');
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.executionMode, ...
                'serial');
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.reactions.select, ...
                [true; false]);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.reactions.id, ...
                ["R1"; "R2"]);

        end

        function conditionallyShowsTabsAndPreservesTableValues(testCase)

            batch = helpers.RunConfigBatchStub();
            session = RunConfigActionTest.createSession(batch);
            app = RunConfigActionTest.createApp(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));

            testCase.verifyEmpty(app.EffluxperturbationTab.Parent);
            testCase.verifyEmpty(app.TracersuggestionTab.Parent);
            testCase.verifyEmpty(app.INSTMFATab.Parent);

            efflux = table( ...
                true, 0.25, ...
                VariableNames = ["Selection", "SD"], ...
                RowNames = "substrate-a");
            app.EffluxUITable.Data = efflux;
            app.PerturbateEffluxCheckBox.Value = true;
            callback = app.PerturbateEffluxCheckBox.ValueChangedFcn;
            callback([], []);
            testCase.verifyEqual( ...
                app.EffluxperturbationTab.Parent, app.TabGroup);

            app.PerturbateEffluxCheckBox.Value = false;
            callback([], []);
            testCase.verifyEmpty(app.EffluxperturbationTab.Parent);
            testCase.verifyEqual(app.EffluxUITable.Data, efflux);

            suggestion = table("pattern-a", ...
                VariableNames = "exp-a");
            app.LabelTable.Data = suggestion;
            app.SuggestionCheckBox.Value = true;
            callback = app.SuggestionCheckBox.ValueChangedFcn;
            callback([], []);
            testCase.verifyEqual( ...
                app.TracersuggestionTab.Parent, app.TabGroup);
            app.SuggestionCheckBox.Value = false;
            callback([], []);
            testCase.verifyEmpty(app.TracersuggestionTab.Parent);
            testCase.verifyEqual(app.LabelTable.Data, suggestion);

            pool = table( ...
                "metabolite-a", 2.5, ...
                VariableNames = ["Metabolite", "PoolSize"]);
            timeCourse = table( ...
                "exp-a", 3, ...
                VariableNames = ["TimePointExpName", "TimePoint"]);
            app.INSTMFAPoolUITable.Data = pool;
            app.INSTMFATimeCourseUITable.Data = timeCourse;
            app.INSTMFACheckBox.Value = true;
            callback = app.INSTMFACheckBox.ValueChangedFcn;
            callback([], struct(Source = app.INSTMFACheckBox));
            testCase.verifyEqual(app.INSTMFATab.Parent, app.TabGroup);
            app.INSTMFACheckBox.Value = false;
            callback([], struct(Source = app.INSTMFACheckBox));
            testCase.verifyEmpty(app.INSTMFATab.Parent);
            testCase.verifyEqual(app.INSTMFAPoolUITable.Data, pool);
            testCase.verifyEqual( ...
                app.INSTMFATimeCourseUITable.Data, timeCourse);

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
            testCase.verifyEqual(string(app.CheckBox.Enable), "off");
            testCase.verifyEqual( ...
                string(app.ParallelworkersEditField.Enable), "on");
            testCase.verifyEmpty(app.GridreactionTab.Parent);

            app.AlgorithmCIDropDown.Value = 'Grid search';
            callback = app.AlgorithmCIDropDown.ValueChangedFcn;
            callback([], []);

            testCase.verifyEqual( ...
                string(app.MCLmaxEditField.Enable), "off");
            testCase.verifyEqual( ...
                string(app.DeterminegridintervalautomaticallyCheckBox.Enable), ...
                "on");
            testCase.verifyEqual(string(app.CheckBox.Enable), "on");
            testCase.verifyEqual( ...
                string(app.ParallelworkersEditField.Enable), "on");
            app.CheckBox.Value = false;
            callback = app.CheckBox.ValueChangedFcn;
            callback([], []);
            testCase.verifyEqual( ...
                string(app.ParallelworkersEditField.Enable), "on");
            app.CheckBox.Value = true;
            callback([], []);
            testCase.verifyEqual( ...
                string(app.ParallelworkersEditField.Enable), "on");
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
            testCase.verifyEqual(string(app.CheckBox.Enable), "off");
            testCase.verifyEqual( ...
                string(app.ParallelworkersEditField.Enable), "on");

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
