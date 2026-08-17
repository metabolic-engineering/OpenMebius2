classdef TracerConfigContextTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function storesInitialEditorState(testCase)

            editorTable = table( ...
                true, "U-13C", 1, ...
                VariableNames = ["Select", "Label", "Ratio"]);

            context = openmebius.presentation.experiment ...
                .TracerConfigContext( ...
                EditorTable = editorTable, ...
                Position = [2, 3]);

            testCase.verifyEqual(context.EditorTable, editorTable);
            testCase.verifyEqual(context.Position, [2, 3]);

        end

        function rejectsInvalidPosition(testCase)

            testCase.verifyError( ...
                @() openmebius.presentation.experiment ...
                .TracerConfigContext( ...
                EditorTable = table(), ...
                Position = [0, 1]), ...
                "MATLAB:validators:mustBePositive");

        end

    end % methods (Test)

end % classdef
