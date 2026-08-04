classdef OpenMebius2IntegratedTest < matlab.uitest.TestCase

    properties
        App
        RunConfigApp
    end

    methods (TestMethodSetup)

        function launchApp(testCase)
            testCase.App = OpenMebius2TestMock();
        end

    end

    methods (TestMethodTeardown)

        function closeApp(testCase)
            app = testCase.App;

            if isvalid(app)
                app.delete();
            end

        end

    end

    methods (Test)

        % 通常通りのプロジェクト作成からMFA実行まで
        function testRunMFAFromTemplateModel(testCase)

            app = testCase.App;

            tempname = "../model/Escherichia coli";

            app.TemplateModelDirectoryDropDown.Value = tempname;
            testCase.press(app.TemplateModelLoadButton);

            app.Test_InputAnswer = "TestProject_MFA";
            app.Test_Folder = "../tests";

            projfolder = fullfile(app.Test_Folder, "TestProject_MFA");
            testCase.verifyFalse(isfolder(projfolder));

            testCase.press(app.ProjectCreateButton);

            testCase.verifyTrue(isfolder(projfolder));

            app.Test_File = [
                             fullfile("../dataset/WT_ecoli.xlsx")
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
            testCase.verifyTrue(app.exp.hasCalculatedMDV());

            testCase.choose(app.TabGroup, "Run");
            testCase.press(app.RunAutoButton);
            testCase.press(app.RunRunButton);

            testCase.choose(app.TabGroup, "Result");
            testCase.press(app.ResultReloadButton);

            pause(3);

            delta = 0.3;
            rssValue = app.ResultSubTable.Data{1, "RSS"};
            testCase.verifyLessThanOrEqual(rssValue, 33.62715683 + delta);
            testCase.verifyGreaterThanOrEqual(rssValue, 33.62715683 - delta);

            pause(3);

        end % function testCreateProjectFromTemplateModel

        % 通常通りのプロジェクト作成からMFA実行まで（複数実験データ）
        function testRunMFAFromTemplateModelMultiExp(testCase)

            app = testCase.App;

            tempname = "../model/Escherichia coli";

            app.TemplateModelDirectoryDropDown.Value = tempname;
            testCase.press(app.TemplateModelLoadButton);

            app.Test_InputAnswer = "TestProject_MFA_MultiExp";
            app.Test_Folder = "../tests";

            projfolder = fullfile(app.Test_Folder, "TestProject_MFA_MultiExp");
            testCase.verifyFalse(isfolder(projfolder));

            testCase.press(app.ProjectCreateButton);

            testCase.verifyTrue(isfolder(projfolder));

            app.Test_File = [
                             fullfile("../dataset/WT_ecoli.xlsx")
                             fullfile("../dataset/Δpgi_ecoli.xlsx")
                             fullfile("../dataset/Δzwf_ecoli.xlsx")
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
            testCase.verifyTrue(app.exp.hasCalculatedMDV());

            testCase.choose(app.TabGroup, "Run");
            testCase.press(app.RunAutoButton);
            testCase.press(app.RunRunButton);

            testCase.choose(app.TabGroup, "Result");
            testCase.press(app.ResultReloadButton);

            pause(3);

            delta = 0.3;
            rssValue = app.ResultSubTable.Data{1, "RSS"};
            testCase.verifyLessThanOrEqual(rssValue, 33.62715683 + delta);
            testCase.verifyGreaterThanOrEqual(rssValue, 33.62715683 - delta);
            rssValue2 = app.ResultSubTable.Data{2, "RSS"};
            testCase.verifyLessThanOrEqual(rssValue2, 33.34891506 + delta);
            testCase.verifyGreaterThanOrEqual(rssValue2, 33.34891506 - delta);
            rssValue3 = app.ResultSubTable.Data{3, "RSS"};
            testCase.verifyLessThanOrEqual(rssValue3, 39.76656348 + delta);
            testCase.verifyGreaterThanOrEqual(rssValue3, 39.76656348 - delta);

            pause(3);

        end % function testCreateProjectFromTemplateModel

        % 通常通りのプロジェクト作成からMFA実行まで（複数実験データ、信頼区間計算）
        function testRunMFAFromTemplateModelMultiExpCI(testCase)

            app = testCase.App;

            tempname = "../model/Escherichia coli";

            app.TemplateModelDirectoryDropDown.Value = tempname;
            testCase.press(app.TemplateModelLoadButton);

            app.Test_InputAnswer = "TestProject_MFA_MultiExp_CI";
            app.Test_Folder = "../tests";

            projfolder = fullfile(app.Test_Folder, "TestProject_MFA_MultiExp_CI");
            testCase.verifyFalse(isfolder(projfolder));

            testCase.press(app.ProjectCreateButton);

            testCase.verifyTrue(isfolder(projfolder));

            app.Test_File = [
                             fullfile("../dataset/WT_ecoli.xlsx")
                             fullfile("../dataset/Δpgi_ecoli.xlsx")
                             fullfile("../dataset/Δzwf_ecoli.xlsx")
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
            testCase.verifyTrue(app.exp.hasCalculatedMDV());

            testCase.choose(app.TabGroup, "Run");
            testCase.press(app.RunAutoButton);

            % テーブルの全行を選択
            rowIdx = 1:size(app.RunTable.Data, 1);
            colIdx = ones(1, length(rowIdx));
            app.RunTable.Selection = [rowIdx', colIdx'];
            testCase.press(app.RunConfigButton);

            app.RunConfigApp.CalcCICheckBox.Value = true;

            testCase.press(app.RunConfigApp.GeneralApplyButton);
            testCase.press(app.RunConfigApp.GeneralCloseButton);

            testCase.press(app.RunConfigButton);
            testCase.verifyTrue(app.RunConfigApp.CalcCICheckBox.Value);
            testCase.press(app.RunConfigApp.GeneralCloseButton);

            testCase.press(app.RunRunButton);

            testCase.choose(app.TabGroup, "Result");
            testCase.press(app.ResultReloadButton);

            pause(3);

            deltaForFlux = 1;
            deltaForCI = 0.5;
            deltaForFVA = 0.1;

            correctData1 = readmatrix('../tests/assert_data/result_data1.csv');
            correctData2 = readmatrix('../tests/assert_data/result_data2.csv');
            correctData3 = readmatrix('../tests/assert_data/result_data3.csv');

            app.ResultSubTable.Selection = [1, 1];
            app.testResultSubTableCellSelection();
            pause(5);
            fluxData1 = app.ResultMainTable.Data;
            app.ResultSubTable.Selection = [2, 1];
            app.testResultSubTableCellSelection();
            pause(5);
            fluxData2 = app.ResultMainTable.Data;
            app.ResultSubTable.Selection = [3, 1];
            app.testResultSubTableCellSelection();
            pause(5);
            fluxData3 = app.ResultMainTable.Data;

            for i = 1:size(correctData1, 1)

                disp(fluxData1{i, 1})
                % フラックス値の確認
                correctBestfit = correctData1(i, 1);
                fluxBestfit = str2double(fluxData1{i, 2}{:});
                testCase.verifyLessThanOrEqual(fluxBestfit, correctBestfit + deltaForFlux);
                testCase.verifyGreaterThanOrEqual(fluxBestfit, correctBestfit - deltaForFlux);

                % 信頼区間の確認
                correctCI_Lower = correctData1(i, 2);
                correctCI_Upper = correctData1(i, 3);
                fluxCI_Lower = str2double(fluxData1{i, 3}{:});
                fluxCI_Upper = str2double(fluxData1{i, 4}{:});
                testCase.verifyLessThanOrEqual(fluxCI_Lower, correctCI_Lower + deltaForCI);
                testCase.verifyGreaterThanOrEqual(fluxCI_Lower, correctCI_Lower - deltaForCI);
                testCase.verifyLessThanOrEqual(fluxCI_Upper, correctCI_Upper + deltaForCI);
                testCase.verifyGreaterThanOrEqual(fluxCI_Upper, correctCI_Upper - deltaForCI);

                % FVAの確認
                correctFVA_Min = correctData1(i, 4);
                correctFVA_Max = correctData1(i, 5);
                fluxFVA_Min = str2double(fluxData1{i, 5}{:});
                fluxFVA_Max = str2double(fluxData1{i, 6}{:});
                testCase.verifyLessThanOrEqual(fluxFVA_Min, correctFVA_Min + deltaForFVA);
                testCase.verifyGreaterThanOrEqual(fluxFVA_Min, correctFVA_Min - deltaForFVA);
                testCase.verifyLessThanOrEqual(fluxFVA_Max, correctFVA_Max + deltaForFVA);
                testCase.verifyGreaterThanOrEqual(fluxFVA_Max, correctFVA_Max - deltaForFVA);
            end

            for i = 1:size(correctData2, 1)

                disp(fluxData2{i, 1})

                % フラックス値の確認
                correctBestfit = correctData2(i, 1);
                fluxBestfit = str2double(fluxData2{i, 2}{:});
                testCase.verifyLessThanOrEqual(fluxBestfit, correctBestfit + deltaForFlux);
                testCase.verifyGreaterThanOrEqual(fluxBestfit, correctBestfit - deltaForFlux);

                % 信頼区間の確認
                correctCI_Lower = correctData2(i, 2);
                correctCI_Upper = correctData2(i, 3);
                fluxCI_Lower = str2double(fluxData2{i, 3}{:});
                fluxCI_Upper = str2double(fluxData2{i, 4}{:});
                testCase.verifyLessThanOrEqual(fluxCI_Lower, correctCI_Lower + deltaForCI);
                testCase.verifyGreaterThanOrEqual(fluxCI_Lower, correctCI_Lower - deltaForCI);
                testCase.verifyLessThanOrEqual(fluxCI_Upper, correctCI_Upper + deltaForCI);
                testCase.verifyGreaterThanOrEqual(fluxCI_Upper, correctCI_Upper - deltaForCI);

                % FVAの確認
                correctFVA_Min = correctData2(i, 4);
                correctFVA_Max = correctData2(i, 5);
                fluxFVA_Min = str2double(fluxData2{i, 5}{:});
                fluxFVA_Max = str2double(fluxData2{i, 6}{:});
                testCase.verifyLessThanOrEqual(fluxFVA_Min, correctFVA_Min + deltaForFVA);
                testCase.verifyGreaterThanOrEqual(fluxFVA_Min, correctFVA_Min - deltaForFVA);
                testCase.verifyLessThanOrEqual(fluxFVA_Max, correctFVA_Max + deltaForFVA);
                testCase.verifyGreaterThanOrEqual(fluxFVA_Max, correctFVA_Max - deltaForFVA);
            end

            for i = 1:size(correctData3, 1)

                disp(fluxData3{i, 1})

                % フラックス値の確認
                correctBestfit = correctData3(i, 1);
                fluxBestfit = str2double(fluxData3{i, 2}{:});
                testCase.verifyLessThanOrEqual(fluxBestfit, correctBestfit + deltaForFlux);
                testCase.verifyGreaterThanOrEqual(fluxBestfit, correctBestfit - deltaForFlux);

                % 信頼区間の確認
                correctCI_Lower = correctData3(i, 2);
                correctCI_Upper = correctData3(i, 3);
                fluxCI_Lower = str2double(fluxData3{i, 3}{:});
                fluxCI_Upper = str2double(fluxData3{i, 4}{:});
                testCase.verifyLessThanOrEqual(fluxCI_Lower, correctCI_Lower + deltaForCI);
                testCase.verifyGreaterThanOrEqual(fluxCI_Lower, correctCI_Lower - deltaForCI);
                testCase.verifyLessThanOrEqual(fluxCI_Upper, correctCI_Upper + deltaForCI);
                testCase.verifyGreaterThanOrEqual(fluxCI_Upper, correctCI_Upper - deltaForCI);

                % FVAの確認
                correctFVA_Min = correctData3(i, 4);
                correctFVA_Max = correctData3(i, 5);
                fluxFVA_Min = str2double(fluxData3{i, 5}{:});
                fluxFVA_Max = str2double(fluxData3{i, 6}{:});
                testCase.verifyLessThanOrEqual(fluxFVA_Min, correctFVA_Min + deltaForFVA);
                testCase.verifyGreaterThanOrEqual(fluxFVA_Min, correctFVA_Min - deltaForFVA);
                testCase.verifyLessThanOrEqual(fluxFVA_Max, correctFVA_Max + deltaForFVA);
                testCase.verifyGreaterThanOrEqual(fluxFVA_Max, correctFVA_Max - deltaForFVA);
            end

        end % function testCreateProjectFromTemplateModel

    end % methods (Test)

end
