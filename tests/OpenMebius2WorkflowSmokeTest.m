classdef OpenMebius2WorkflowSmokeTest < matlab.uitest.TestCase

    properties
        App
        TemporaryRoot (1, 1) string
    end

    methods (TestMethodSetup)

        function launchApp(testCase)

            addpath(OpenMebius2WorkflowSmokeTest.sourcePath());
            testCase.TemporaryRoot = string(tempname);
            mkdir(testCase.TemporaryRoot);
            testCase.App = OpenMebius2TestMock();
            testCase.App.Test_Folder = testCase.TemporaryRoot;

        end

    end

    methods (TestMethodTeardown)

        function closeApp(testCase)

            if ~isempty(testCase.App) && isvalid(testCase.App)
                delete(testCase.App);
            end

            if isfolder(testCase.TemporaryRoot)
                rmdir(testCase.TemporaryRoot, "s");
            end

        end

    end

    methods (Test)

        function createsLoadsAndEditsProject(testCase)

            app = testCase.App;
            templateDirectory = fullfile( ...
                OpenMebius2WorkflowSmokeTest.repositoryRoot(), ...
                "tutorial", "ecoli", "model");
            app.TemplateModelDirectoryDropDown.Value = ...
                templateDirectory;
            app.Test_InputAnswer = "SmokeProject";
            app.ProjectNameEditField.Value = "Smoke project";
            app.ProjectAuthorEditField.Value = "UI test";
            app.OrganismEditField.Value = "Escherichia coli";

            testCase.press(app.TemplateModelLoadButton);
            testCase.press(app.ProjectCreateButton);

            createdProject = fullfile( ...
                testCase.TemporaryRoot, "SmokeProject");
            testCase.verifyTrue(isfolder(createdProject));
            testCase.verifyTrue(isfile(fullfile( ...
                createdProject, "setting.om2")));
            testCase.verifyNotEmpty(app.ModelTable.Data);

            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, createdProject);
            testCase.press(app.ProjectLoadButton);
            testCase.verifyEqual( ...
                string(app.ProjectNameEditField.Value), ...
            "Smoke project");

            testCase.press(app.ModelEditButton);
            testCase.verifyTrue(any(app.ModelTable.ColumnEditable));
            testCase.press(app.ModelSaveButton);
            testCase.verifyFalse(any(app.ModelTable.ColumnEditable));
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function runsCancelsAndReports(testCase)

            app = testCase.App;
            analysisProject = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, ...
            "ecoli_monte-carlo");
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, analysisProject);
            testCase.press(app.ProjectLoadButton);
            testCase.verifyEqual( ...
                string(app.ProjectDirectoryDropDown.Value), ...
                analysisProject);
            testCase.verifyGreaterThan(height(app.RunTable.Data), 0);

            testCase.choose(app.TabGroup, "Run");
            app.RunTable.Selection = [1, 1];
            app.Test_TriggerCancelDuringRun = true;
            testCase.press(app.RunRunButton);

            testCase.verifyTrue(app.Test_RunInvoked);
            testCase.verifyTrue(app.Test_CancelInvoked);
            testCase.verifyEqual(string(app.RunRunButton.Text), "Run");

            testCase.choose(app.TabGroup, "Result");
            testCase.press(app.ResultReportButton);

            testCase.verifyTrue(app.Test_ReportCreated);
            testCase.verifyTrue(app.Test_ReportViewed);
            testCase.verifyTrue(isfile(app.Test_ReportOutput));
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function reloadsWindowToInitialState(testCase)

            app = testCase.App;
            analysisProject = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, ...
            "ecoli_monte-carlo");
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, analysisProject);
            testCase.press(app.ProjectLoadButton);
            testCase.press(app.ModelEditButton);
            testCase.choose(app.TabGroup, "Result");
            app.ResultDropDown.Value = "Details";
            app.ModelTable.Selection = [1, 1];
            app.RunTable.Selection = [1, 1];
            plot(app.MainUIAxes, 1:3, 1:3);
            plot(app.SubUIAxes, 1:3, 3:-1:1);

            callback = app.ReloadWindowMenu.MenuSelectedFcn;
            callback(app.ReloadWindowMenu, []);

            testCase.verifyEqual( ...
                string(app.ProjectDirectoryDropDown.Value), "");
            testCase.verifyEqual( ...
                string(app.TemplateModelDirectoryDropDown.Value), "");
            testCase.verifyEqual(string(app.ProjectNameEditField.Value), "");
            testCase.verifyEqual(string(app.ProjectAuthorEditField.Value), "");
            testCase.verifyEqual(string(app.OrganismEditField.Value), "");
            testCase.verifyEmpty(app.ModelTable.Data);
            testCase.verifyEmpty(app.RunTable.Data);
            testCase.verifyEmpty(app.ResultSubTable.Data);
            testCase.verifyEmpty(app.ModelTable.Selection);
            testCase.verifyEmpty(app.RunTable.Selection);
            testCase.verifyEmpty(app.MainUIAxes.Children);
            testCase.verifyEmpty(app.SubUIAxes.Children);
            testCase.verifyEqual(string(app.ResultDropDown.Value), "Overview");
            testCase.verifySameHandle( ...
                app.TabGroup.SelectedTab, app.StoichiometryTab);
            testCase.verifyEqual(string(app.RunRunButton.Text), "Run");
            testCase.verifyEqual(string(app.ProjectLoadButton.Enable), "on");
            testCase.verifyEqual(string(app.ModelTable.Enable), "off");
            testCase.verifyEqual(string(app.ResultSubTable.Enable), "off");

            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, analysisProject);
            testCase.press(app.ProjectLoadButton);
            testCase.verifyNotEmpty(app.ModelTable.Data);
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function removesOnlyTheCellSelectedBatch(testCase)

            app = testCase.App;
            projectDirectory = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, "ecoli");
            experimentLocation = openmebius.domain.experiment ...
                .ExperimentLocation.fromDirectory( ...
                fullfile(projectDirectory, "experiments"));
            repository = ...
                openmebius.infrastructure.batch.BatchJsonRepository();
            [batchTable, isError, message] = repository.load( ...
                experimentLocation, "batch.json");
            testCase.assertFalse(isError, string(message));

            for batchIndex = 1:height(batchTable)
                batchTable.config(batchIndex).status = 'ready';
            end

            repository.save( ...
                experimentLocation, "batch.json", batchTable);
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, projectDirectory);
            testCase.press(app.ProjectLoadButton);
            rawDataBefore = app.RunTable.UserData.RawData;
            selectedId = rawDataBefore.ID(2);
            firstId = rawDataBefore.ID(1);
            app.RunTable.Selection = [2, 1];

            callback = app.RemovethisbatchMenu.MenuSelectedFcn;
            callback(app.RemovethisbatchMenu, []);

            rawDataAfter = app.RunTable.UserData.RawData;
            testCase.verifyEqual(height(rawDataAfter), 2);
            testCase.verifyTrue(any(rawDataAfter.ID == firstId));
            testCase.verifyFalse(any(rawDataAfter.ID == selectedId));
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function preservesDescriptionThroughConfigurationApply(testCase)

            app = testCase.App;
            projectDirectory = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, "ecoli");
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, projectDirectory);
            testCase.press(app.ProjectLoadButton);
            testCase.choose(app.TabGroup, "Run");
            expectedDescription = "Description edited before Config";
            app.RunTable.Data.Description(1) = expectedDescription;
            app.RunTable.Selection = [1, 1];

            testCase.press(app.RunConfigButton);
            testCase.verifyEqual( ...
                string(app.RunTable.Data.Description(1)), ...
                expectedDescription);

            app.RunConfigApp.IterationSpinner.Value = 31;
            testCase.press(app.RunConfigApp.GeneralApplyButton);

            testCase.verifyEqual( ...
                string(app.RunTable.Data.Description(1)), ...
                expectedDescription);
            testCase.verifyEmpty(app.Test_Alerts);
            delete(app.RunConfigApp);

        end

        function rendersGridSearchAxesAfterWindowReload(testCase)

            app = testCase.App;
            reloadCallback = app.ReloadWindowMenu.MenuSelectedFcn;
            reloadCallback(app.ReloadWindowMenu, []);
            gridSearchProject = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, "ecoli_grid_search");
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, gridSearchProject);
            testCase.press(app.ProjectLoadButton);
            testCase.choose(app.TabGroup, "Result");
            testCase.verifyNotEmpty(app.ResultSubTable.Data);

            app.ResultSubTable.Selection = [1, 1];
            app.testResultSubTableCellSelection();
            testCase.verifyNotEmpty(app.ResultMainTable.Data);
            gridSearchRow = find( ...
                string(app.ResultMainTable.RowName) == "r2", 1);
            testCase.assertNotEmpty(gridSearchRow);
            app.ResultMainTable.Selection = [gridSearchRow, 1];
            app.testResultMainTableCellSelection();

            testCase.verifyNotEmpty(app.SubUIAxes.Children);
            testCase.verifyEqual( ...
                string(app.SubUIAxes.XLabel.String), "Fixed flux");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.YLabel.String), "RSS");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.XLabel.Visible), "on");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.YLabel.Visible), "on");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.XColorMode), "auto");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.YColorMode), "auto");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.XTickMode), "auto");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.YTickMode), "auto");
            testCase.verifyEmpty(app.Test_Alerts);

        end

    end

    methods (Static, Access = private)

        function selectProject(app, projectDirectory)

            items = string(app.ProjectDirectoryDropDown.Items);

            if ~any(items == projectDirectory)
                app.ProjectDirectoryDropDown.Items{end + 1} = ...
                    char(projectDirectory);
            end

            app.ProjectDirectoryDropDown.Value = char(projectDirectory);

        end

        function target = copyTutorial(parentDirectory, name)

            source = fullfile( ...
                OpenMebius2WorkflowSmokeTest.repositoryRoot(), ...
                "tutorial", name);
            target = fullfile(parentDirectory, name);
            [ok, message] = copyfile(source, target);

            if ~ok
                error( ...
                    "OpenMebius2WorkflowSmokeTest:CopyFailed", ...
                    "Could not copy UI fixture: %s", string(message));
            end

        end

        function path = sourcePath()

            path = fullfile( ...
                OpenMebius2WorkflowSmokeTest.repositoryRoot(), "src");

        end

        function path = repositoryRoot()

            path = fileparts(fileparts(mfilename("fullpath")));

        end

    end

end
