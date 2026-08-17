classdef ModelTableEditorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end

    end

    methods (Test)

        function addsBlankReactionAfterSelectedRow(testCase)

            modelTable = ModelTableEditorTest.modelTable();
            [actual, insertedRow] = openmebius.presentation.model ...
                .ModelTableEditor.addReaction(modelTable, "Rnew", 1);

            testCase.verifyEqual(insertedRow, 2);
            testCase.verifyEqual( ...
                string(actual.Properties.RowNames), ["R1"; "Rnew"; "R2"]);
            testCase.verifyEqual(actual.Reaction{2}, '');
            testCase.verifyEqual(actual.Transition{2}, '');
            testCase.verifyFalse(actual.Independent(2));
            testCase.verifyTrue(isnan(actual.x(2)) && isnan(actual.y(2)));

        end

        function rejectsDuplicateReactionID(testCase)

            modelTable = ModelTableEditorTest.modelTable();

            testCase.verifyError( ...
                @() openmebius.presentation.model.ModelTableEditor ...
                .addReaction(modelTable, "R1"), ...
                "OpenMebius2:ModelTableEditor:DuplicateReactionID");

        end

        function removesSelectedReactionAndChoosesNeighbor(testCase)

            modelTable = ModelTableEditorTest.modelTable();
            [actual, selectedRow] = openmebius.presentation.model ...
                .ModelTableEditor.removeReactions(modelTable, 2);

            testCase.verifyEqual(selectedRow, 1);
            testCase.verifyEqual(string(actual.Properties.RowNames), "R1");

        end

        function createsUniqueDefaultReactionID(testCase)

            modelTable = ModelTableEditorTest.modelTable();
            modelTable.Properties.RowNames = {'new_reaction'; 'new_reaction_2'};

            actual = openmebius.presentation.model.ModelTableEditor ...
                .nextReactionID(modelTable);

            testCase.verifyEqual(actual, "new_reaction_3");

        end

    end

    methods (Static, Access = private)

        function value = modelTable()

            value = table( ...
                {'A --> B'; 'B <=> C'}, ...
                {'a --> b'; 'b <=> c'}, ...
                [false; true], ...
                [1; 2], ...
                [3; 4], ...
                VariableNames = [ ...
                "Reaction", "Transition", "Independent", "x", "y"], ...
                RowNames = {'R1'; 'R2'});

        end

    end

end
