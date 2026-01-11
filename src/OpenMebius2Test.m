classdef OpenMebius2Test < matlab.uitest.TestCase

    properties
        App
        RunConfigApp
    end

    methods (TestMethodSetup)

        function launchApp(testCase)
            testCase.App = OpenMebius2();
        end

    end

    methods (TestMethodTeardown)

        function closeApp(testCase)
            app = testCase.App;

            if isempty(app) || ~isvalid(app)
                return;
            end

            if isprop(app, "RunConfigApp") && ~isempty(app.RunConfigApp) && isvalid(app.RunConfigApp)
                app.RunConfigApp.delete();
                app.RunConfigApp = [];
            end

            if isprop(app, "MSViewApp") && ~isempty(app.MSViewApp) && isvalid(app.MSViewApp)
                app.MSViewApp.delete();
                app.MSViewApp = [];
            end

            app.delete();

        end

    end

    methods (Test)

        function testLoadProject(testCase)

            app = testCase.App;

            app.ProjectDirectoryDropDown.Value = '../tutorial/ecoli';
            testCase.press(app.ProjectLoadButton);

            % Check if the project is loaded correctly
            testCase.verifyEqual(app.ProjectDirectoryDropDown.Value, '../tutorial/ecoli');

        end

        function testMSView(testCase)

            app = testCase.App;

            app.ProjectDirectoryDropDown.Value = '../tutorial/ecoli';
            testCase.press(app.ProjectLoadButton);
            app.TabGroup.SelectedTab = app.ExperimentTab;

            testCase.verifyEqual(app.TabGroup.SelectedTab, app.ExperimentTab);

            app.ExpTable.Selection = [1, 1];
            chooseContextMenu(testCase, app.ExpTable, app.ViewMStableMenu, [1, 1]);

            testCase.verifyNotEmpty(app.MSViewApp);
            testCase.verifyTrue(isvalid(app.MSViewApp));

            msViewApp = app.MSViewApp;
            expItems = msViewApp.ExpDropDown.Items;
            tableTypeItems = msViewApp.TableTypeDropDown.Items;

            for j = 1:length(tableTypeItems)
                testCase.choose(msViewApp.TableTypeDropDown, tableTypeItems{j});

                for i = 1:length(expItems)

                    if j == 5
                        pause(1);
                        break;
                    end

                    testCase.choose(msViewApp.ExpDropDown, expItems{i});
                    pause(1);
                end

            end

            app.MSViewApp.delete();

        end

        function testConfigApp(testCase)

            app = testCase.App;

            app.ProjectDirectoryDropDown.Value = '../tutorial/ecoli';
            testCase.press(app.ProjectLoadButton);
            app.TabGroup.SelectedTab = app.RunTab;

            [nRows, nCols] = size(app.RunTable.Data);
            [rowIdx, colIdx] = ndgrid(1:nRows, 1:nCols);
            selection = [rowIdx(:), colIdx(:)];
            app.RunTable.Selection = selection;

            testCase.press(app.RunAutoButton);
            testCase.press(app.RunConfigButton);

            pause(1)

            testCase.verifyNotEmpty(app.RunConfigApp);
            testCase.verifyTrue(isvalid(app.RunConfigApp));

            pause(1)

            % Check close button
            testCase.press(app.RunConfigApp.GeneralCloseButton);
            testCase.verifyFalse(isvalid(app.RunConfigApp));

            pause(1)

            testCase.press(app.RunConfigButton);
            testCase.verifyNotEmpty(app.RunConfigApp);
            testCase.verifyTrue(isvalid(app.RunConfigApp));

            pause(1)

            % Check close button
            app.RunConfigApp.TabGroup.SelectedTab = app.RunConfigApp.MSfragmentTab;
            testCase.press(app.RunConfigApp.MSCloseButton);
            testCase.verifyFalse(isvalid(app.RunConfigApp));

            testCase.press(app.RunConfigButton);
            testCase.verifyNotEmpty(app.RunConfigApp);
            testCase.verifyTrue(isvalid(app.RunConfigApp));

            tabs = app.RunConfigApp.TabGroup.Children;
            % Move to each tab and pause for 1 second
            for i = 1:length(tabs)
                % Use numeric index to select the tab
                testCase.choose(app.RunConfigApp.TabGroup, i);
                pause(1); % Pause for 1 second
            end

            % Check if the selected tab is the last one
            testCase.verifyEqual(app.RunConfigApp.TabGroup.SelectedTab, tabs(end));

            % close the RunConfigApp
            app.RunConfigApp.delete();

        end % testConfigApp

        function testConfigApp2(testCase)

            app = testCase.App;

            app.ProjectDirectoryDropDown.Value = '../tutorial/ecoli';
            testCase.press(app.ProjectLoadButton);
            app.TabGroup.SelectedTab = app.RunTab;

            [nRows, nCols] = size(app.RunTable.Data);
            [rowIdx, colIdx] = ndgrid(1:nRows, 1:nCols);
            selection = [rowIdx(1), colIdx(1)];
            app.RunTable.Selection = selection;

            testCase.press(app.RunConfigButton);
            testCase.choose(app.RunConfigApp.TabGroup, 'MS fragment');

            numRow = size(app.RunConfigApp.MSTable.Data, 1);
            numCol = size(app.RunConfigApp.MSTable.Data, 2);

            for i = 1:numRow

                for j = 1:numCol
                    isPress = rand(1) > 0.2;
                    app.RunConfigApp.MSTable.Data{i, j} = isPress;
                end

            end

            data = app.RunConfigApp.MSTable.Data;

            press(testCase, app.RunConfigApp.MSApplyButton);
            testCase.press(app.RunConfigApp.MSCloseButton);
            testCase.press(app.RunConfigButton);
            testCase.verifyEqual(app.RunConfigApp.MSTable.Data, data);

            app.RunConfigApp.delete();

        end % testConfigApp2

        function testConfigApp3(testCase)

            app = testCase.App;

            app.ProjectDirectoryDropDown.Value = '../tutorial/ecoli';
            testCase.press(app.ProjectLoadButton);
            app.TabGroup.SelectedTab = app.RunTab;

            [nRows, nCols] = size(app.RunTable.Data);
            [rowIdx, colIdx] = ndgrid(1:nRows, 1:nCols);
            selection = [rowIdx(1), colIdx(1)];
            app.RunTable.Selection = selection;

            testCase.press(app.RunConfigButton);
            testCase.choose(app.RunConfigApp.TabGroup, 'General');

            % IterationSpinner type
            testCase.type(app.RunConfigApp.IterationSpinner, 20);
            testCase.verifyEqual(app.RunConfigApp.IterationSpinner.Value, 20);

            iterBefore = app.RunConfigApp.IterationSpinner.Value;

            press(testCase, app.RunConfigApp.GeneralApplyButton);
            testCase.press(app.RunConfigApp.GeneralCloseButton);
            testCase.press(app.RunConfigButton);
            testCase.verifyEqual(app.RunConfigApp.IterationSpinner.Value, iterBefore);

        end % testConfigApp3

        function testRun1(testCase)
            % Check flux calculation process with a short iteration

            app = testCase.App;

            % Load the project
            app.ProjectDirectoryDropDown.Value = '../tutorial/ecoli';
            testCase.press(app.ProjectLoadButton);

            % Select the Run tab
            app.TabGroup.SelectedTab = app.RunTab;

            % Select all rows and columns in the RunTable
            [nRows, nCols] = size(app.RunTable.Data);
            [rowIdx, colIdx] = ndgrid(1:nRows, 1:nCols);
            selection = [rowIdx(:), colIdx(:)];
            app.RunTable.Selection = selection;

            % Modify the iteration spinner value
            press(testCase, app.RunConfigButton);
            choose(testCase, app.RunConfigApp.TabGroup, 'General');
            type(testCase, app.RunConfigApp.IterationSpinner, 1);
            verifyEqual(testCase, app.RunConfigApp.IterationSpinner.Value, 1);
            press(testCase, app.RunConfigApp.GeneralApplyButton);
            press(testCase, app.RunConfigApp.GeneralCloseButton);

            % Select the Run tab again
            press(testCase, app.RunRunButton);

        end % testConfigApp3

        function testResultView(testCase)

            app = testCase.App;

            app.ProjectDirectoryDropDown.Value = '../tutorial/ecoli_monte-carlo';
            press(testCase, app.ProjectLoadButton);
            choose(testCase, app.TabGroup, 'Result');

            resultSub = app.ResultSubTable;
            dropdown = app.ResultDropDown.Items;

            numTest = 20;
            numDropdown = length(dropdown);

            for i = 1:numTest

                % Select a random row and column
                rowIdx = randi(size(resultSub.Data, 1));
                colIdx = randi(size(resultSub.Data, 2));
                dropdownIdx = randi(numDropdown);

                disp(['Iteration: ', num2str(i), ...
                          ', Row: ', num2str(rowIdx), ...
                          ', Column: ', num2str(colIdx), ...
                          ', Dropdown: ', dropdown{dropdownIdx}]);

                % Select a random dropdown item
                testCase.choose(app.ResultDropDown, dropdown{dropdownIdx});

                % Select the cell
                resultSub.Selection = [rowIdx, colIdx];
                testResultSubTableCellSelection(app);

                dataMain = app.ResultMainTable.Data;

                if isempty(dataMain)
                    continue; % Skip if the main table is empty
                end

                rowIdxMain = randi(size(dataMain, 1));
                colIdxMain = randi(size(dataMain, 2));

                app.ResultMainTable.Selection = [rowIdxMain, colIdxMain];
                testResultMainTableCellSelection(app);

            end % for

        end % function testResultView

    end % methods (Test)

end % classdef OpenMebius2Test
