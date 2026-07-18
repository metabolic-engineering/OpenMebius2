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
            app = RunConfig_exported(session);
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
            testCase.verifyEqual(app.EffluxUITable.Enable, 'off');
            testCase.verifyTrue(all(app.MSTable.Data{:, :}, "all"));
            testCase.verifyEqual(batch.ConfigUpdateCount, 0);
            testCase.verifyEqual(recorder.AppliedCount, 0);

        end

        function appliesAllSettingsFromEveryTab(testCase)

            batch = helpers.RunConfigBatchStub();
            session = RunConfigActionTest.createSession(batch);
            app = RunConfig_exported(session);
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
            app = RunConfig_exported(session);
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
            app = RunConfig_exported(session);
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
            app = RunConfig_exported(session);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));

            testCase.verifyEqual(app.MCLmaxEditField.Value, 222);
            testCase.verifyEqual( ...
                app.ThenumberofgridpointsEditField.Value, 17);

            app.MCLmaxEditField.Value = 333;
            app.ThenumberofgridpointsEditField.Value = 29;
            callback = app.GeneralApplyButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual( ...
                batch.Config.CIConf.MC.iteration, 333);
            testCase.verifyEqual( ...
                batch.Config.CIConf.grid.points, 29);

        end

    end % methods (Test)

    methods (Static, Access = private)

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
