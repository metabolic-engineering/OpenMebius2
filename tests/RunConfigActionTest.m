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
            mainApp = helpers.RunConfigMainAppStub(batch);
            app = RunConfig_exported(mainApp, [1, 1]);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));
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
            testCase.verifyEqual(mainApp.UpdateCount, 0);

        end

        function appliesAllSettingsFromEveryTab(testCase)

            batch = helpers.RunConfigBatchStub();
            mainApp = helpers.RunConfigMainAppStub(batch);
            app = RunConfig_exported(mainApp, [1, 1]);
            cleanup = onCleanup(@() RunConfigActionTest.deleteIfValid(app));
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
            testCase.verifyEqual(mainApp.UpdateCount, 5);

        end

        function cancelClosesWithoutSaving(testCase)

            batch = helpers.RunConfigBatchStub();
            mainApp = helpers.RunConfigMainAppStub(batch);
            app = RunConfig_exported(mainApp, [1, 1]);

            callback = app.MSCancelButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyFalse(isvalid(app));
            testCase.verifyEqual(batch.ConfigUpdateCount, 0);
            testCase.verifyEqual(mainApp.UpdateCount, 0);

        end

    end % methods (Test)

    methods (Static, Access = private)

        function deleteIfValid(app)

            if ~isempty(app) && isvalid(app)
                delete(app);
            end

        end

    end % methods (Static, Access = private)

end % classdef
