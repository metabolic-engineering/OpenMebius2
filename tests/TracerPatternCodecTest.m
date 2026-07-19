classdef TracerPatternCodecTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function encodesSelectedTracerRatios(testCase)

            editorTable = table( ...
                [true; true; false], ...
                ["U-13C"; "1-13C"; "2-13C"], ...
                [0.25; 0.75; 0.50], ...
                VariableNames = ["Select", "Label", "Ratio"]);

            pattern = openmebius.domain.experiment ...
                .TracerPatternCodec.encode(editorTable);

            testCase.verifyEqual(pattern, "U-13C~0.25;1-13C~0.75");

        end

        function normalizesSingleSelectionRatio(testCase)

            editorTable = table( ...
                true, "U-13C", 0.25, ...
                VariableNames = ["Select", "Label", "Ratio"]);

            pattern = openmebius.domain.experiment ...
                .TracerPatternCodec.encode(editorTable);

            testCase.verifyEqual(pattern, "U-13C~1");

        end

        function returnsEmptyPatternWithoutSelection(testCase)

            editorTable = table( ...
                false, "U-13C", 1, ...
                VariableNames = ["Select", "Label", "Ratio"]);

            pattern = openmebius.domain.experiment ...
                .TracerPatternCodec.encode(editorTable);

            testCase.verifyEqual(pattern, "");

        end

        function rejectsInvalidEditorTable(testCase)

            testCase.verifyError( ...
                @() openmebius.domain.experiment ...
                    .TracerPatternCodec.encode(table()), ...
                "OpenMebius2:TracerConfiguration:InvalidTable");

        end

    end

end
