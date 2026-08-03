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
