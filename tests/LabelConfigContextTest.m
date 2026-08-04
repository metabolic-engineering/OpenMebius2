classdef LabelConfigContextTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function storesInitialEditorState(testCase)

            labelTable = table( ...
                {"Uniform"}, {1}, ...
                VariableNames = ["Name", "Num"]);
            ratioTables = struct(Uniform = table());

            context = openmebius.presentation.model ...
                .LabelConfigContext( ...
                    LabelTable = labelTable, ...
                    RatioTables = ratioTables);

            testCase.verifyEqual(context.LabelTable, labelTable);
            testCase.verifyEqual(context.RatioTables, ratioTables);

        end

    end % methods (Test)

end % classdef
