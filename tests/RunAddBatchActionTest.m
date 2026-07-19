classdef RunAddBatchActionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function addPublishesTypedSelection(testCase)

            context = RunAddBatchActionTest.context( ...
                ["exp-a"; "exp-b"], "inst-mfa", "batch-a");
            app = RunAddBatch_exported(context);
            appCleanup = onCleanup( ...
                @() RunAddBatchActionTest.deleteIfValid(app));
            recorder = helpers.BatchExperimentSelectionEventRecorder();
            listener = addlistener( ...
                app, "Applied", ...
                @(source, event) ...
                    recorder.recordApplied(source, event));
            listenerCleanup = onCleanup(@() delete(listener));
            tableData = app.UITable.Data;
            tableData.Add = [true; false];
            app.UITable.Data = tableData;

            callback = app.AddButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyTrue(recorder.Applied);
            testCase.verifyClass( ...
                recorder.Selection, ...
                'openmebius.domain.batch.BatchExperimentSelection');
            testCase.verifyEqual( ...
                recorder.Selection.Experiments, "exp-a");
            testCase.verifyEqual(recorder.Selection.Mode, "inst-mfa");
            testCase.verifyEqual(recorder.Selection.BatchId, "batch-a");

        end

        function closePublishesEvent(testCase)

            context = RunAddBatchActionTest.context( ...
                "exp-a", "parallel", "");
            app = RunAddBatch_exported(context);
            appCleanup = onCleanup( ...
                @() RunAddBatchActionTest.deleteIfValid(app));
            recorder = helpers.BatchExperimentSelectionEventRecorder();
            listener = addlistener( ...
                app, "Closed", ...
                @(source, event) ...
                    recorder.recordClosed(source, event));
            listenerCleanup = onCleanup(@() delete(listener));

            callback = app.CloseButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyTrue(recorder.Closed);
            testCase.verifyFalse(isvalid(app));

        end

    end % methods (Test)

    methods (Static, Access = private)

        function context = context(experimentNames, mode, batchId)

            editor = openmebius.presentation.batch ...
                .BatchExperimentSelectionEditorViewModel( ...
                    IsAvailable = true, ...
                    ExperimentNames = experimentNames(:), ...
                    Mode = mode, ...
                    BatchId = batchId);
            context = openmebius.presentation.batch ...
                .RunAddBatchContext(Editor = editor);

        end

        function deleteIfValid(app)

            if ~isempty(app) && isvalid(app)
                delete(app);
            end

        end

    end % methods (Static, Access = private)

end % classdef
