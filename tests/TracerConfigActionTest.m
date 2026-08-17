classdef TracerConfigActionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function reloadRestoresInitialEditorTable(testCase)

            editorTable = TracerConfigActionTest.editorTable();
            context = TracerConfigActionTest.context(editorTable, [2, 3]);
            app = TracerConfig_exported(context);
            cleanup = onCleanup( ...
                @() TracerConfigActionTest.deleteIfValid(app));
            changed = editorTable;
            changed.Select(:) = false;
            app.UITable.Data = changed;

            callback = app.ReloadButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual(app.UITable.Data, editorTable);

        end

        function savePublishesValuesAndCloses(testCase)

            editorTable = TracerConfigActionTest.editorTable();
            context = TracerConfigActionTest.context(editorTable, [2, 3]);
            app = TracerConfig_exported(context);
            appCleanup = onCleanup( ...
                @() TracerConfigActionTest.deleteIfValid(app));
            recorder = helpers.TracerConfigurationEventRecorder();
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
            testCase.verifyEqual(recorder.EventData.Position, [2, 3]);
            testCase.verifyEqual( ...
                recorder.EventData.EditorTable, editorTable);
            testCase.verifyFalse(isvalid(app));

        end

    end

    methods (Static, Access = private)

        function value = editorTable()

            value = table( ...
                [true; false], ...
                ["U-13C"; "1-13C"], ...
                [1; 0], ...
                VariableNames = ["Select", "Label", "Ratio"]);

        end

        function context = context(editorTable, position)

            context = openmebius.presentation.experiment ...
                .TracerConfigContext( ...
                EditorTable = editorTable, ...
                Position = position);

        end

        function deleteIfValid(app)

            if ~isempty(app) && isvalid(app)
                delete(app);
            end

        end

    end

end
