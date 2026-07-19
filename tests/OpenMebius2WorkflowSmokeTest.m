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
