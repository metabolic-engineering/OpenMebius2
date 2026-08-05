classdef OpenMebius2IntegratedTest < matlab.uitest.TestCase

    properties
        App
        RunConfigApp
        TemporaryRoot (1, 1) string = ""
    end

    methods (TestMethodSetup)

        function launchApp(testCase)

            testCase.TemporaryRoot = string(tempname);
            mkdir(testCase.TemporaryRoot);
            testCase.App = OpenMebius2TestMock();

        end

    end

    methods (TestMethodTeardown)

        function closeApp(testCase)
            app = testCase.App;

            if isvalid(app)
                app.delete();
            end

            OpenMebius2IntegratedTest.removeDirectory( ...
                testCase.TemporaryRoot);

        end

    end

    methods (Test)

        % 通常通りのプロジェクト作成からMFA実行まで
        function testRunMFAFromTemplateModel(testCase)

            app = testCase.App;

            templateDirectory = testCase.repositoryPath( ...
                "model", "Escherichia coli");

            app.TemplateModelDirectoryDropDown.Value = templateDirectory;
            testCase.press(app.TemplateModelLoadButton);

            app.Test_InputAnswer = "TestProject_MFA";
            app.Test_Folder = testCase.TemporaryRoot;

            projfolder = fullfile(app.Test_Folder, "TestProject_MFA");
            testCase.verifyFalse(isfolder(projfolder));

            testCase.press(app.ProjectCreateButton);

            testCase.verifyTrue(isfolder(projfolder));

            app.Test_File = [
                             testCase.repositoryPath( ...
                                 "dataset", "WT_ecoli.xlsx")
                             ];
            app.Test_Files = app.Test_File;

            testCase.verifyTrue(app.ExpImportButton.Enable);

            testCase.choose(app.TabGroup, "Experiment");
            testCase.press(app.ExpImportButton);
            testCase.verifyEqual(size(app.ExpTable.Data, 1), 1);

            app.ExpTable.Data{1, 1} = 0.634525729817483;
            app.ExpTable.Data{1, 2} = 0;
            app.ExpTable.Data{1, 3} = 1;
            testCase.press(app.ExpSaveButton);

            testCase.choose(app.TabGroup, "Tracer");
            % Acetate uptake
            app.UptakeTable.Data{1, 1} = 3.6405030802424;
            app.UptakeTable.Data{1, 3} = 8.206603261;
            app.LabelTable.Data{1, 1} = "12C2~1";
            app.LabelTable.Data{1, 2} = "12C1~1";
            app.LabelTable.Data{1, 3} = "[1]Glc~1";
            app.LabelTable.Data{1, 4} = "12C1~1";
            testCase.press(app.TracerSaveButton);

            testCase.choose(app.TabGroup, "Experiment");
            testCase.press(app.ExpCalculationButton);
            testCase.verifyTrue(app.testHasCalculatedMDV());

            testCase.choose(app.TabGroup, "Run");
            testCase.press(app.RunAutoButton);
            testCase.press(app.RunRunButton);
            testCase.verifyTrue(app.Test_RunInvoked);
            testCase.verifyEqual(string(app.RunRunButton.Text), "Run");

        end % function testCreateProjectFromTemplateModel

        % 通常通りのプロジェクト作成からMFA実行まで（複数実験データ）
        function testRunMFAFromTemplateModelMultiExp(testCase)

            app = testCase.App;

            templateDirectory = testCase.repositoryPath( ...
                "model", "Escherichia coli");

            app.TemplateModelDirectoryDropDown.Value = templateDirectory;
            testCase.press(app.TemplateModelLoadButton);

            app.Test_InputAnswer = "TestProject_MFA_MultiExp";
            app.Test_Folder = testCase.TemporaryRoot;

            projfolder = fullfile(app.Test_Folder, "TestProject_MFA_MultiExp");
            testCase.verifyFalse(isfolder(projfolder));

            testCase.press(app.ProjectCreateButton);

            testCase.verifyTrue(isfolder(projfolder));

            app.Test_File = [
                             testCase.repositoryPath( ...
                                 "dataset", "WT_ecoli.xlsx")
                             testCase.repositoryPath( ...
                                 "dataset", "Δpgi_ecoli.xlsx")
                             testCase.repositoryPath( ...
                                 "dataset", "Δzwf_ecoli.xlsx")
                             ];
            app.Test_Files = app.Test_File;

            testCase.verifyTrue(app.ExpImportButton.Enable);

            testCase.choose(app.TabGroup, "Experiment");
            testCase.press(app.ExpImportButton);
            testCase.verifyEqual(size(app.ExpTable.Data, 1), 3);

            pause(3);

            app.ExpTable.Data{1, 1} = 0.634525729817483;
            app.ExpTable.Data{1, 2} = 0;
            app.ExpTable.Data{1, 3} = 1;
            app.ExpTable.Data{2, 1} = 0.208360256266272;
            app.ExpTable.Data{2, 2} = 0;
            app.ExpTable.Data{2, 3} = 1;
            app.ExpTable.Data{3, 1} = 0.574057910603119;
            app.ExpTable.Data{3, 2} = 0;
            app.ExpTable.Data{3, 3} = 1;

            pause(3);

            testCase.press(app.ExpSaveButton);

            pause(3);

            testCase.choose(app.TabGroup, "Tracer");
            app.UptakeTable.Data{1, 1} = 3.6405030802424;
            app.UptakeTable.Data{1, 3} = 8.206603261;
            app.UptakeTable.Data{2, 1} = 0;
            app.UptakeTable.Data{2, 3} = 2.60955389134703;
            app.UptakeTable.Data{3, 1} = 6.21886800278605;
            app.UptakeTable.Data{3, 3} = 8.00820811543245;
            app.LabelTable.Data{1, 1} = "12C2~1";
            app.LabelTable.Data{1, 2} = "12C1~1";
            app.LabelTable.Data{1, 3} = "[1]Glc~1";
            app.LabelTable.Data{1, 4} = "12C1~1";
            app.LabelTable.Data{2, 1} = "12C2~1";
            app.LabelTable.Data{2, 2} = "12C1~1";
            app.LabelTable.Data{2, 3} = "[1]Glc~1";
            app.LabelTable.Data{2, 4} = "12C1~1";
            app.LabelTable.Data{3, 1} = "12C2~1";
            app.LabelTable.Data{3, 2} = "12C1~1";
            app.LabelTable.Data{3, 3} = "[1]Glc~1";
            app.LabelTable.Data{3, 4} = "12C1~1";
            testCase.press(app.TracerSaveButton);

            pause(3);

            testCase.choose(app.TabGroup, "Experiment");
            testCase.press(app.ExpCalculationButton);
            testCase.verifyTrue(app.testHasCalculatedMDV());

            testCase.choose(app.TabGroup, "Run");
            testCase.press(app.RunAutoButton);
            testCase.press(app.RunRunButton);
            testCase.verifyTrue(app.Test_RunInvoked);
            testCase.verifyEqual(string(app.RunRunButton.Text), "Run");

        end % function testCreateProjectFromTemplateModel

        % 通常通りのプロジェクト作成からMFA実行まで（複数実験データ、信頼区間計算）
        function testRunMFAFromTemplateModelMultiExpCI(testCase)

            app = testCase.App;

            templateDirectory = testCase.repositoryPath( ...
                "model", "Escherichia coli");

            app.TemplateModelDirectoryDropDown.Value = templateDirectory;
            testCase.press(app.TemplateModelLoadButton);

            app.Test_InputAnswer = "TestProject_MFA_MultiExp_CI";
            app.Test_Folder = testCase.TemporaryRoot;

            projfolder = fullfile(app.Test_Folder, "TestProject_MFA_MultiExp_CI");
            testCase.verifyFalse(isfolder(projfolder));

            testCase.press(app.ProjectCreateButton);

            testCase.verifyTrue(isfolder(projfolder));

            app.Test_File = [
                             testCase.repositoryPath( ...
                                 "dataset", "WT_ecoli.xlsx")
                             testCase.repositoryPath( ...
                                 "dataset", "Δpgi_ecoli.xlsx")
                             testCase.repositoryPath( ...
                                 "dataset", "Δzwf_ecoli.xlsx")
                             ];
            app.Test_Files = app.Test_File;

            testCase.verifyTrue(app.ExpImportButton.Enable);

            testCase.choose(app.TabGroup, "Experiment");
            testCase.press(app.ExpImportButton);
            testCase.verifyEqual(size(app.ExpTable.Data, 1), 3);

            pause(3);

            app.ExpTable.Data{1, 1} = 0.634525729817483;
            app.ExpTable.Data{1, 2} = 0;
            app.ExpTable.Data{1, 3} = 1;
            app.ExpTable.Data{2, 1} = 0.208360256266272;
            app.ExpTable.Data{2, 2} = 0;
            app.ExpTable.Data{2, 3} = 1;
            app.ExpTable.Data{3, 1} = 0.574057910603119;
            app.ExpTable.Data{3, 2} = 0;
            app.ExpTable.Data{3, 3} = 1;

            pause(3);

            testCase.press(app.ExpSaveButton);

            pause(3);

            testCase.choose(app.TabGroup, "Tracer");
            app.UptakeTable.Data{1, 1} = 3.6405030802424;
            app.UptakeTable.Data{1, 3} = 8.206603261;
            app.UptakeTable.Data{2, 1} = 0;
            app.UptakeTable.Data{2, 3} = 2.60955389134703;
            app.UptakeTable.Data{3, 1} = 6.21886800278605;
            app.UptakeTable.Data{3, 3} = 8.00820811543245;
            app.LabelTable.Data{1, 1} = "12C2~1";
            app.LabelTable.Data{1, 2} = "12C1~1";
            app.LabelTable.Data{1, 3} = "[1]Glc~1";
            app.LabelTable.Data{1, 4} = "12C1~1";
            app.LabelTable.Data{2, 1} = "12C2~1";
            app.LabelTable.Data{2, 2} = "12C1~1";
            app.LabelTable.Data{2, 3} = "[1]Glc~1";
            app.LabelTable.Data{2, 4} = "12C1~1";
            app.LabelTable.Data{3, 1} = "12C2~1";
            app.LabelTable.Data{3, 2} = "12C1~1";
            app.LabelTable.Data{3, 3} = "[1]Glc~1";
            app.LabelTable.Data{3, 4} = "12C1~1";
            testCase.press(app.TracerSaveButton);

            pause(3);

            testCase.choose(app.TabGroup, "Experiment");
            testCase.press(app.ExpCalculationButton);
            testCase.verifyTrue(app.testHasCalculatedMDV());

            testCase.choose(app.TabGroup, "Run");
            testCase.press(app.RunAutoButton);

            % テーブルの全行を選択
            rowIdx = 1:size(app.RunTable.Data, 1);
            colIdx = ones(1, length(rowIdx));
            app.RunTable.Selection = [rowIdx', colIdx'];
            testCase.press(app.RunConfigButton);

            app.RunConfigApp.CalcCICheckBox.Value = true;

            testCase.press(app.RunConfigApp.GeneralApplyButton);
            testCase.press(app.RunConfigApp.GeneralCancelButton);

            testCase.press(app.RunConfigButton);
            testCase.verifyTrue(app.RunConfigApp.CalcCICheckBox.Value);
            testCase.press(app.RunConfigApp.GeneralCancelButton);

            testCase.press(app.RunRunButton);
            testCase.verifyTrue(app.Test_RunInvoked);
            testCase.verifyEqual(string(app.RunRunButton.Text), "Run");

        end % function testCreateProjectFromTemplateModel

    end % methods (Test)

    methods (Access = private)

        function path = repositoryPath(~, varargin)

            root = fileparts(fileparts(mfilename("fullpath")));
            path = fullfile(root, varargin{:});

        end

    end

    methods (Static, Access = private)

        function removeDirectory(directory)

            if strlength(directory) > 0 && isfolder(directory)
                rmdir(directory, "s");
            end

        end

    end

end
