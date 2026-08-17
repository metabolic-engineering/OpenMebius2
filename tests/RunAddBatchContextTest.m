classdef RunAddBatchContextTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function storesAvailableEditor(testCase)

            editor = openmebius.presentation.batch ...
                .BatchExperimentSelectionEditorViewModel( ...
                IsAvailable = true, ...
                ExperimentNames = "exp-a", ...
                Mode = "parallel");

            context = openmebius.presentation.batch ...
                .RunAddBatchContext(Editor = editor);

            testCase.verifyEqual(context.Editor, editor);

        end

        function rejectsUnavailableEditor(testCase)

            editor = openmebius.presentation.batch ...
                .BatchExperimentSelectionEditorViewModel();

            testCase.verifyError( ...
                @() openmebius.presentation.batch ...
                .RunAddBatchContext(Editor = editor), ...
                "OpenMebius2:RunAddBatchContext:UnavailableEditor");

        end

    end % methods (Test)

end % classdef
