classdef LabelConfigActionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function addingLabelPreservesEditedNamesAndCarbonCounts(testCase)

            [context, ~, ~] = LabelConfigActionTest.context();
            app = LabelConfig_exported(context);
            cleanup = onCleanup( ...
                @() LabelConfigActionTest.deleteIfValid(app));
            addCallback = app.AddLabelButton.ButtonPushedFcn;
            addCallback([], []);
            edited = app.LabelTable.Data;
            edited.Name{end} = 'Custom glucose';
            edited.Num{end} = 6;
            app.LabelTable.Data = edited;

            addCallback([], []);

            testCase.verifyEqual(app.LabelTable.Data(1:end - 1, :), edited);
            testCase.verifyEqual(context.Action.LabelTable, app.LabelTable.Data);

        end

        function removingLabelPreservesOtherEditedRows(testCase)

            [context, ~, ~] = LabelConfigActionTest.context();
            app = LabelConfig_exported(context);
            cleanup = onCleanup( ...
                @() LabelConfigActionTest.deleteIfValid(app));
            addCallback = app.AddLabelButton.ButtonPushedFcn;
            addCallback([], []);
            edited = app.LabelTable.Data;
            edited.Name{end} = 'Custom glucose';
            edited.Num{end} = 6;
            app.LabelTable.Data = edited;
            app.LabelTable.Selection = [1, 1];

            removeCallback = app.RemoveLabelButton.ButtonPushedFcn;
            removeCallback([], []);

            testCase.verifyEqual(app.LabelTable.Data, edited(2, :));
            testCase.verifyEqual(context.Action.LabelTable, edited(2, :));

        end

        function clearingRatioDisplayDoesNotEraseSelectedPattern(testCase)

            [context, ~, ratioTables] = LabelConfigActionTest.context();
            app = LabelConfig_exported(context);
            cleanup = onCleanup( ...
                @() LabelConfigActionTest.deleteIfValid(app));
            selectCallback = app.LabelTable.CellSelectionCallback;
            selectCallback([], struct('Indices', [1, 1]));
            app.RatioTable.Data = {};

            displayCallback = app.RatioTable.DisplayDataChangedFcn;
            displayCallback([], []);

            testCase.verifyEqual(context.Action.RatioTables, ratioTables);

        end

        function contextProvidesInitialEditorState(testCase)

            [context, labelTable, ~] = ...
                LabelConfigActionTest.context();
            app = LabelConfig_exported(context);
            cleanup = onCleanup( ...
                @() LabelConfigActionTest.deleteIfValid(app));

            testCase.verifyEqual(app.LabelTable.Data, labelTable);
            testCase.verifyEqual( ...
                string(app.LabelTable.ColumnName(:)), ...
                string(labelTable.Properties.VariableNames(:)));

        end

        function loadRestoresInitialLabelTable(testCase)

            [context, labelTable, ~] = ...
                LabelConfigActionTest.context();
            app = LabelConfig_exported(context);
            cleanup = onCleanup( ...
                @() LabelConfigActionTest.deleteIfValid(app));
            changed = labelTable;
            changed.Name{1} = "Changed";
            app.LabelTable.Data = changed;

            callback = app.LoadButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual(app.LabelTable.Data, labelTable);

        end

        function savePublishesValuesAndCloses(testCase)

            [context, labelTable, ratioTables] = ...
                LabelConfigActionTest.context();
            app = LabelConfig_exported(context);
            appCleanup = onCleanup( ...
                @() LabelConfigActionTest.deleteIfValid(app));
            recorder = helpers.LabelConfigurationEventRecorder();
            listeners = [ ...
                addlistener(app, "Applied", ...
                @(source, event) ...
                recorder.recordApplied(source, event)); ...
                addlistener(app, "Closed", ...
                @(source, event) ...
                recorder.recordClosed(source, event))];
            listenerCleanup = onCleanup(@() delete(listeners));

            callback = app.SaveButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyTrue(recorder.Applied);
            testCase.verifyTrue(recorder.Closed);
            testCase.verifyEqual( ...
                recorder.EventData.LabelTable, labelTable);
            testCase.verifyEqual( ...
                recorder.EventData.RatioTables, ratioTables);
            testCase.verifyFalse(isvalid(app));

        end

    end % methods (Test)

    methods (Static, Access = private)

        function [context, labelTable, ratioTables] = context()

            labelTable = table( ...
                {"Uniform"}, {1}, ...
                VariableNames = ["Name", "Num"]);
            ratioTables = struct( ...
                Uniform = table( ...
                {"#1"}, {1}, ...
                VariableNames = ["Label", "Ratio"]));
            context = openmebius.presentation.model ...
                .LabelConfigContext( ...
                LabelTable = labelTable, ...
                RatioTables = ratioTables);

        end

        function deleteIfValid(app)

            if ~isempty(app) && isvalid(app)
                delete(app);
            end

        end

    end % methods (Static, Access = private)

end % classdef
