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

            testCase.verifyEmpty(app.ModelTable.ContextMenu);
            testCase.press(app.ModelEditButton);
            testCase.verifyTrue(any(app.ModelTable.ColumnEditable));
            testCase.assertNotEmpty(app.ModelTable.ContextMenu);
            menuItems = app.ModelTable.ContextMenu.Children;
            menuTexts = string({menuItems.Text});
            addMenu = menuItems(menuTexts == "Add reaction");
            removeMenu = menuItems(menuTexts == "Remove reaction");
            testCase.assertNotEmpty(addMenu);
            testCase.assertNotEmpty(removeMenu);
            originalRowCount = height(app.ModelTable.Data);
            app.Test_InputAnswer = "SmokeReaction";
            addCallback = addMenu.MenuSelectedFcn;
            addCallback(addMenu, []);
            testCase.verifyEqual( ...
                height(app.ModelTable.Data), originalRowCount + 1);
            testCase.verifyEqual( ...
                string(app.ModelTable.Data.Properties.RowNames(end)), ...
                "SmokeReaction");
            testCase.press(app.ModelSaveButton);
            testCase.verifyTrue(any(app.ModelTable.ColumnEditable));
            testCase.assertNotEmpty(app.ModelTable.ContextMenu);
            rowStyles = app.ModelTable.StyleConfigurations;
            rowStyles = rowStyles(string(rowStyles.Target) == "row", :);
            highlightedRows = unique(cell2mat(rowStyles.TargetIndex));
            testCase.verifyTrue(any( ...
                highlightedRows == originalRowCount + 1));
            removeCallback = removeMenu.MenuSelectedFcn;
            removeCallback(removeMenu, []);
            testCase.verifyEqual( ...
                height(app.ModelTable.Data), originalRowCount);
            updatedX = app.ModelTable.Data.x(1) + 1;
            app.ModelTable.Data.x(1) = updatedX;
            testCase.press(app.ModelSaveButton);
            testCase.verifyFalse(any(app.ModelTable.ColumnEditable));
            testCase.verifyEmpty(app.ModelTable.ContextMenu);
            savedPosition = readtable( ...
                fullfile( ...
                createdProject, "model", "metabolic_network.xlsx"), ...
                Sheet = "position", ...
                ReadRowNames = true);
            testCase.verifyEqual(savedPosition.x(1), updatedX);
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
            editableColumns = app.RunTable.ColumnEditable;
            columnNames = string(app.RunTable.ColumnName);
            nameColumn = find(columnNames == "Name", 1);
            descriptionColumn = find(columnNames == "Description", 1);
            testCase.assertNotEmpty(nameColumn);
            testCase.assertNotEmpty(descriptionColumn);
            testCase.assertTrue(editableColumns(nameColumn));
            testCase.assertTrue(editableColumns(descriptionColumn));
            expectedInfo = app.ExpTable.Data{1, 1} + 0.001;
            expectedUptake = app.UptakeTable.Data{1, 1} + 0.125;
            expectedTracer = "12C2~1";
            expectedDescription = "Saved automatically before Run";
            app.ExpTable.Data{1, 1} = expectedInfo;
            app.UptakeTable.Data{1, 1} = expectedUptake;
            app.LabelTable.Data{1, 1} = expectedTracer;
            app.RunTable.Data.Description(1) = expectedDescription;
            app.RunTable.Selection = [1, 1];
            app.Test_TriggerCancelDuringRun = true;
            testCase.press(app.RunRunButton);

            testCase.verifyTrue(app.Test_RunInvoked);
            testCase.verifyTrue(app.Test_CancelInvoked);
            testCase.verifyEqual(string(app.RunRunButton.Text), "Run");
            testCase.verifyEqual( ...
                app.RunTable.ColumnEditable, editableColumns);

            experimentLocation = openmebius.domain.experiment ...
                .ExperimentLocation.fromDirectory( ...
                fullfile(analysisProject, "experiments"));
            reloadedExperiments = openmebius.application.experiment ...
                .ExperimentSet( ...
                experimentLocation, ...
                app.Test_ApplicationController.model());
            experimentCleanup = onCleanup( ...
                @() delete(reloadedExperiments));
            savedInfo = reloadedExperiments.getInfoTable();
            savedUptake = reloadedExperiments.getUptakeTable();
            savedTracer = reloadedExperiments.getTracerTable();
            testCase.verifyEqual( ...
                savedInfo{1, 1}, expectedInfo, "AbsTol", 1e-12);
            testCase.verifyEqual( ...
                savedUptake{1, 1}, expectedUptake, "AbsTol", 1e-12);
            testCase.verifyEqual(savedTracer{1, 1}, expectedTracer);
            batchRepository = openmebius.infrastructure.batch ...
                .BatchJsonRepository();
            [savedBatch, isError, message] = batchRepository.load( ...
                experimentLocation, "batch.json");
            testCase.assertFalse(isError, string(message));
            testCase.verifyEqual( ...
                savedBatch.description(1), expectedDescription);

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
            app.ResultDropDown.Value = "MDV";
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
            testCase.verifyTrue(any( ...
                string(app.ProjectDirectoryDropDown.Items) == ...
                analysisProject));

            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, analysisProject);
            testCase.press(app.ProjectLoadButton);
            testCase.verifyNotEmpty(app.ModelTable.Data);
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function duplicatesCurrentProject(testCase)

            app = testCase.App;
            projectDirectory = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, "ecoli");
            testCase.verifyEqual( ...
                string(app.DuplicatecurrentprojectMenu.Enable), "off");
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, projectDirectory);
            testCase.press(app.ProjectLoadButton);
            testCase.verifyEqual( ...
                string(app.DuplicatecurrentprojectMenu.Enable), "on");
            expectedDefaultName = ...
                string(app.ProjectNameEditField.Value) + "_2";
            app.Test_InputAnswer = "ecoli_2";

            callback = app.DuplicatecurrentprojectMenu.MenuSelectedFcn;
            callback(app.DuplicatecurrentprojectMenu, []);

            duplicateDirectory = fullfile( ...
                testCase.TemporaryRoot, "ecoli_2");
            metadata = openmebius.infrastructure.project ...
                .FileProjectRepository.readMetadata( ...
                fullfile(duplicateDirectory, "setting.om2"));
            testCase.verifyTrue(isfolder(duplicateDirectory));
            testCase.verifyTrue(isfile(fullfile( ...
                duplicateDirectory, "model", ...
                "metabolic_network.xlsx")));
            testCase.verifyEqual(metadata.Name, "ecoli_2");
            testCase.verifyEqual( ...
                app.Test_LastInputDefault, expectedDefaultName);
            testCase.verifyEqual( ...
                string(app.ProjectDirectoryDropDown.Value), ...
                projectDirectory);
            testCase.verifyEqual( ...
                app.Test_ApplicationController.project() ...
                .Paths.RootDirectory, ...
                projectDirectory);
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
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(fullfile(projectDirectory, "results"));
            artifacts = resultLocation.resultArtifactFiles(selectedId);
            OpenMebius2WorkflowSmokeTest.writeText(artifacts(1));
            OpenMebius2WorkflowSmokeTest.writeText(artifacts(2));
            app.RunTable.Selection = [2, 1];
            app.Test_ConfirmAnswer = "Yes";

            callback = app.RemovethisbatchMenu.MenuSelectedFcn;
            callback(app.RemovethisbatchMenu, []);

            rawDataAfter = app.RunTable.UserData.RawData;
            testCase.verifyEqual(height(rawDataAfter), 2);
            testCase.verifyTrue(any(rawDataAfter.ID == firstId));
            testCase.verifyFalse(any(rawDataAfter.ID == selectedId));
            testCase.verifyFalse(any(isfile(artifacts)));
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function confirmsCompletedRemovalAndDeletesResultFiles(testCase)

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

            batchTable.config(2).status = 'finished';
            completedId = batchTable.id(2);
            repository.save( ...
                experimentLocation, "batch.json", batchTable);
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, projectDirectory);
            testCase.press(app.ProjectLoadButton);

            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(fullfile(projectDirectory, "results"));
            artifacts = resultLocation.resultArtifactFiles(completedId);
            OpenMebius2WorkflowSmokeTest.writeText(artifacts(1));
            OpenMebius2WorkflowSmokeTest.writeText(artifacts(2));
            app.RunTable.Selection = [2, 1];
            callback = app.RemovethisbatchMenu.MenuSelectedFcn;

            app.Test_ConfirmAnswer = "No";
            callback(app.RemovethisbatchMenu, []);
            testCase.verifyTrue(any( ...
                app.RunTable.UserData.RawData.ID == completedId));
            testCase.verifyTrue(all(isfile(artifacts)));

            app.Test_ConfirmAnswer = "Yes";
            callback(app.RemovethisbatchMenu, []);
            testCase.verifyFalse(any( ...
                app.RunTable.UserData.RawData.ID == completedId));
            testCase.verifyFalse(any(isfile(artifacts)));
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
            testCase.press(app.RunConfigApp.GeneralCloseButton);

            testCase.verifyEqual( ...
                string(app.RunTable.Data.Description(1)), ...
                expectedDescription);
            testCase.verifyEmpty(app.Test_Alerts);
        end

        function duplicatesSelectedBatchAsReady(testCase)

            app = testCase.App;
            projectDirectory = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, "ecoli");
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, projectDirectory);
            testCase.press(app.ProjectLoadButton);
            rawDataBefore = app.RunTable.UserData.RawData;
            expectedDescription = "Edited before duplicate";
            app.RunTable.Data.Description(2) = expectedDescription;
            source = app.RunTable.Data(2, :);
            app.RunTable.Selection = [2, 1];

            callback = app.DuplicatethisbatchMenu.MenuSelectedFcn;
            callback(app.DuplicatethisbatchMenu, []);

            rawDataAfter = app.RunTable.UserData.RawData;
            duplicate = rawDataAfter(end, :);
            testCase.verifyEqual( ...
                height(rawDataAfter), height(rawDataBefore) + 1);
            testCase.verifyNotEqual(duplicate.ID, source.ID);
            testCase.verifyEqual(duplicate.Name, source.Name);
            testCase.verifyEqual(duplicate.Experiment, source.Experiment);
            testCase.verifyEqual( ...
                duplicate.Description, expectedDescription);
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function tracerPatternsRemainReadOnlyAndOpenWithoutSaving(testCase)

            app = testCase.App;
            projectDirectory = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, "ecoli");
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, projectDirectory);
            testCase.press(app.ProjectLoadButton);
            testCase.choose(app.TabGroup, "Tracer");
            testCase.verifyFalse(any(app.LabelTable.ColumnEditable));
            testCase.verifyTrue(any(app.UptakeTable.ColumnEditable));
            interaction = struct( ...
                "InteractionInformation", struct( ...
                "DisplayRow", 1, "DisplayColumn", 1));
            openCallback = app.LabelTable.DoubleClickedFcn;

            openCallback(app.LabelTable, interaction);
            testCase.assertNotEmpty(app.TracerConfigApp);
            editorTable = app.TracerConfigApp.UITable.Data;
            testCase.assertGreaterThan(height(editorTable), 0);
            editorTable.Select(:) = false;
            editorTable.Select(end) = true;
            editorTable.Ratio(:) = 0;
            editorTable.Ratio(end) = 1;
            expectedPattern = editorTable.Label(end) + "~1";
            app.TracerConfigApp.UITable.Data = editorTable;
            saveCallback = app.TracerConfigApp.SaveButton.ButtonPushedFcn;
            saveCallback(app.TracerConfigApp.SaveButton, []);
            testCase.verifyEqual( ...
                string(app.LabelTable.Data{1, 1}), expectedPattern);
            testCase.verifyFalse(any(app.LabelTable.ColumnEditable));

            openCallback(app.LabelTable, interaction);
            testCase.assertNotEmpty(app.TracerConfigApp);
            testCase.verifyTrue(app.TracerConfigApp.UITable.Data.Select(end));
            close(app.TracerConfigApp.TracerselectionconfigUIFigure);

            testCase.press(app.TracerSaveButton);
            testCase.verifyFalse(any(app.LabelTable.ColumnEditable));
            openCallback(app.LabelTable, interaction);
            testCase.assertNotEmpty(app.TracerConfigApp);
            testCase.verifyTrue(app.TracerConfigApp.UITable.Data.Select(end));
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function movesBatchUpAndDownAndPersistsOrder(testCase)

            app = testCase.App;
            projectDirectory = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, "ecoli");
            experimentLocation = openmebius.domain.experiment ...
                .ExperimentLocation.fromDirectory( ...
                fullfile(projectDirectory, "experiments"));
            repository = ...
                openmebius.infrastructure.batch.BatchJsonRepository();
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, projectDirectory);
            testCase.press(app.ProjectLoadButton);
            originalIds = string(app.RunTable.UserData.RawData.ID);
            testCase.assertGreaterThanOrEqual(numel(originalIds), 3);
            moveUpMenu = findobj( ...
                app.ContextMenuRun, 'Text', 'Move up');
            moveDownMenu = findobj( ...
                app.ContextMenuRun, 'Text', 'Move down');
            testCase.assertNotEmpty(moveUpMenu);
            testCase.assertNotEmpty(moveDownMenu);

            app.RunTable.Selection = [2, 1];
            callback = moveUpMenu.MenuSelectedFcn;
            callback(moveUpMenu, []);

            movedIds = string(app.RunTable.UserData.RawData.ID);
            expectedMovedIds = originalIds;
            expectedMovedIds([1, 2]) = expectedMovedIds([2, 1]);
            testCase.verifyEqual(movedIds, expectedMovedIds);
            testCase.verifyEqual(app.RunTable.Selection, [1, 1]);
            [persisted, isError, message] = repository.load( ...
                experimentLocation, "batch.json");
            testCase.assertFalse(isError, string(message));
            testCase.verifyEqual(string(persisted.id), expectedMovedIds);

            callback = moveDownMenu.MenuSelectedFcn;
            callback(moveDownMenu, []);

            testCase.verifyEqual( ...
                string(app.RunTable.UserData.RawData.ID), originalIds);
            testCase.verifyEqual(app.RunTable.Selection, [2, 1]);
            [persisted, isError, message] = repository.load( ...
                experimentLocation, "batch.json");
            testCase.assertFalse(isError, string(message));
            testCase.verifyEqual(string(persisted.id), originalIds);
            testCase.verifyEmpty(app.Test_Alerts);

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

            testCase.choose(app.ResultSubTable, [1, 1]);
            testCase.verifyNotEmpty(app.ResultMainTable.Data);
            testCase.verifyNotEmpty(app.SubUIAxes.Children);
            testCase.verifyEqual( ...
                string(app.SubUIAxes.XLabel.String), "RSS");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.YLabel.String), "Frequency");
            rssHistogram = findobj( ...
                app.SubUIAxes, 'Type', 'histogram');
            testCase.verifyNotEmpty(rssHistogram);
            testCase.verifyEqual( ...
                string(rssHistogram.BinMethod), "fd");
            thresholdLine = findobj( ...
                app.SubUIAxes, ...
                'Type', 'constantline', ...
                'DisplayName', 'Threshold');
            testCase.verifyNotEmpty(thresholdLine);
            testCase.verifyEqual(string(thresholdLine.LineStyle), "-");
            maximumValue = max([ ...
                rssHistogram.Data(:); thresholdLine.Value]);
            alpha = 0.05 * maximumValue;

            if alpha == 0
                alpha = 0.05;
            end

            testCase.verifyEqual(app.SubUIAxes.XLim(1), 0);
            testCase.verifyEqual( ...
                app.SubUIAxes.XLim(2), maximumValue + alpha);
            testCase.verifyEqual( ...
                string(app.SubplottypeDropDown.Items), ...
                ["Histogram", "Exitflag"]);
            testCase.choose(app.SubplottypeDropDown, "Exitflag");
            testCase.verifyNotEmpty(findobj( ...
                app.SubUIAxes, ...
                'Type', 'patch', ...
                'Tag', 'ExitflagPieSlice'));
            testCase.verifyTrue(startsWith( ...
                string(app.SubUIAxes.Title.String), ...
                "Exitflag by iteration:"));
            testCase.choose(app.SubplottypeDropDown, "Histogram");
            testCase.verifyNotEmpty(findobj( ...
                app.SubUIAxes, 'Type', 'histogram'));

            testCase.choose(app.ResultDropDown, "MDV");
            app.ResultSubTable.Selection = [1, 1];
            app.testResultSubTableCellSelection();
            detailsHistogram = findobj( ...
                app.SubUIAxes, 'Type', 'histogram');
            testCase.verifyNotEmpty(detailsHistogram);
            testCase.verifyEqual( ...
                string(detailsHistogram.BinMethod), "fd");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.XLabel.String), "RSS");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.YLabel.String), "Frequency");

            testCase.choose(app.ResultDropDown, "MDV (Summary)");
            app.ResultSubTable.Selection = [1, 1];
            app.testResultSubTableCellSelection();
            testCase.verifyNotEmpty(app.ResultMainTable.Data);
            testCase.verifyEqual( ...
                string(app.ResultMainTable.Data.Properties.VariableNames), ...
                [ ...
                "Metabolite", ...
                "E[MDV_e] - E[MDV_s]", ...
                "W_1(MDV_e, MDV_s)", ...
                "χ^2"]);
            testCase.verifyNotEmpty(findobj( ...
                app.SubUIAxes, 'Type', 'histogram'));
            testCase.verifyEqual( ...
                string(app.SubplottypeDropDown.Items), ...
                ["Histogram", "Exitflag"]);

            testCase.choose(app.ResultDropDown, "Overview");
            gridSearchRow = find( ...
                string(app.ResultMainTable.RowName) == "r2", 1);
            testCase.assertNotEmpty(gridSearchRow);
            app.ResultMainTable.Selection = [gridSearchRow, 1];
            app.testResultMainTableCellSelection();

            testCase.verifyNotEmpty(app.SubUIAxes.Children);
            testCase.verifyEqual( ...
                string(app.SubplottypeDropDown.Items), ...
                ["Grid / MCMC", "Exitflag"]);
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
            fvaRegions = findobj( ...
                app.SubUIAxes, ...
                'Type', 'patch', ...
                'DisplayName', 'FVA range');
            testCase.verifyNumElements(fvaRegions, 1);
            testCase.verifyGreaterThanOrEqual( ...
                min(fvaRegions.XData), app.SubUIAxes.XLim(1));
            testCase.verifyLessThanOrEqual( ...
                max(fvaRegions.XData), app.SubUIAxes.XLim(2));
            testCase.verifyEmpty(findobj( ...
                app.SubUIAxes, ...
                'Type', 'patch', ...
                'DisplayName', 'Outside FVA'));
            testCase.choose(app.SubplottypeDropDown, "Exitflag");
            testCase.verifyNotEmpty(findobj( ...
                app.SubUIAxes, ...
                'Type', 'patch', ...
                'Tag', 'ExitflagPieSlice'));
            testCase.choose(app.SubplottypeDropDown, "Grid / MCMC");
            testCase.verifyNotEmpty(findobj( ...
                app.SubUIAxes, ...
                'Type', 'line', ...
                'DisplayName', 'Minimum RSS'));

            testCase.choose(app.ResultSubTable, [2, 1]);
            testCase.verifyEmpty(app.ResultMainTable.Selection);
            testCase.verifyNotEmpty(findobj( ...
                app.SubUIAxes, 'Type', 'histogram'));
            testCase.verifyEqual( ...
                string(app.SubUIAxes.XLabel.String), "RSS");
            testCase.verifyEqual( ...
                string(app.SubUIAxes.YLabel.String), "Frequency");

            unavailableRow = find( ...
                string(app.ResultMainTable.RowName) == "r1", 1);
            testCase.assertNotEmpty(unavailableRow);
            app.ResultMainTable.Selection = [unavailableRow, 1];
            app.testResultMainTableCellSelection();

            testCase.verifyEmpty(app.SubUIAxes.Children);
            testCase.verifyEqual(string(app.SubUIAxes.XGrid), "off");
            testCase.verifyEqual(string(app.SubUIAxes.YGrid), "off");
            testCase.verifyEqual(string(app.SubUIAxes.XLabel.String), "");
            testCase.verifyEqual(string(app.SubUIAxes.YLabel.String), "");
            testCase.verifyEqual(string(app.SubUIAxes.Title.String), "");
            testCase.verifyEqual(string(app.SubUIAxes.XLimMode), "auto");
            testCase.verifyEqual(string(app.SubUIAxes.YLimMode), "auto");
            testCase.verifyEqual(string(app.SubUIAxes.XScale), "linear");
            testCase.verifyEqual(string(app.SubUIAxes.YScale), "linear");
            testCase.verifyEmpty(app.Test_Alerts);

        end

        function showsDiffOnlyForTwoSelectedResults(testCase)

            app = testCase.App;
            projectDirectory = ...
                OpenMebius2WorkflowSmokeTest.copyTutorial( ...
                testCase.TemporaryRoot, "ecoli");
            OpenMebius2WorkflowSmokeTest.selectProject( ...
                app, projectDirectory);
            testCase.press(app.ProjectLoadButton);
            testCase.choose(app.TabGroup, "Result");
            testCase.assertGreaterThanOrEqual( ...
                height(app.ResultSubTable.Data), 3);
            diffMenu = findobj( ...
                app.ContextMenuResultSelect, 'Text', 'Diff');
            testCase.assertNumElements(diffMenu, 1);
            testCase.verifyEqual(string(diffMenu.Visible), "off");

            app.ResultSubTable.Selection = 1;
            app.testResultSubTableCellSelection();
            testCase.verifyEqual(string(diffMenu.Visible), "off");

            app.ResultSubTable.Selection = [1, 2];
            app.testResultSubTableCellSelection();
            testCase.verifyEqual(string(diffMenu.Visible), "on");
            callback = diffMenu.MenuSelectedFcn;
            callback(diffMenu, []);
            consoleText = join(string(app.LogTextArea.Value), newline);
            testCase.verifyThat( ...
                consoleText, ...
                matlab.unittest.constraints.ContainsSubstring( ...
                "Analysis condition diff"));
            testCase.verifyThat( ...
                consoleText, ...
                matlab.unittest.constraints.ContainsSubstring( ...
                "Differences:"));

            app.ResultSubTable.Selection = [1, 2, 3];
            app.testResultSubTableCellSelection();
            testCase.verifyEqual(string(diffMenu.Visible), "off");
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

        function writeText(path)

            fileId = fopen(path, 'w');
            assert(fileId >= 0, "Unable to create test file: " + path);
            cleanup = onCleanup(@() fclose(fileId));
            fprintf(fileId, 'test');
            clear cleanup

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
