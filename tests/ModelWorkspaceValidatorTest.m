classdef ModelWorkspaceValidatorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end

    end

    methods (Test)

        function acceptsCustomLabelMatchingCarbonCount(~)

            validator = openmebius.application.model.ModelWorkspaceValidator();
            labels = table({'Custom'}, {6}, VariableNames = {'Name', 'Num'});
            ratios = struct(Custom = table( ...
                {'#111111'; '#000000'}, [0.8; 0.2], ...
                VariableNames = {'Label', 'Ratio'}));

            validator.validateLabelConfiguration(labels, ratios);

        end

        function rejectsPatternsThatWouldProduceWrongSizedSubstrateEMUs(testCase)

            validator = openmebius.application.model.ModelWorkspaceValidator();
            labels = table({'Custom'}, {6}, VariableNames = {'Name', 'Num'});
            invalidPatterns = {{'#1'}, {'#'}, {'pattern'}, ...
                {'#000002'}, cell(0, 1), {'#111111'; '#0'}};
            for index = 1:numel(invalidPatterns)
                patterns = invalidPatterns{index};
                ratios = struct(Custom = table(patterns, ones(numel(patterns), 1), ...
                    VariableNames = {'Label', 'Ratio'}));
                testCase.verifyError( ...
                    @() validator.validateLabelConfiguration(labels, ratios), ...
                    "OpenMebius2:LabelConfiguration:InvalidLabelPattern");
            end

        end

        function rejectsInvalidLabelCarbonCount(testCase)

            validator = openmebius.application.model.ModelWorkspaceValidator();
            ratios = struct(Custom = table({'#1'}, 1, ...
                VariableNames = {'Label', 'Ratio'}));
            for count = [0, -1, 1.5, nan, inf]
                labels = table({'Custom'}, {count}, VariableNames = {'Name', 'Num'});
                testCase.verifyError( ...
                    @() validator.validateLabelConfiguration(labels, ratios), ...
                    "OpenMebius2:LabelConfiguration:InvalidCarbonCount");
            end

        end

        function acceptsMatchingReactionAndTransition(testCase)

            validator = openmebius.application.model ...
                .ModelWorkspaceValidator();
            [reaction, transition] = ...
                ModelWorkspaceValidatorTest.matchingTables();

            [errors, rows] = validator.validateReactionTransition( ...
                reaction, transition);

            testCase.verifyEmpty(errors);
            testCase.verifyEmpty(rows);

        end

        function reportsComponentCountAndReversibilityRows(testCase)

            validator = openmebius.application.model ...
                .ModelWorkspaceValidator();
            [reaction, transition] = ...
                ModelWorkspaceValidatorTest.matchingTables();
            transition.Products{1} = {'A', 'B'};
            transition.Reversible(2) = false;

            [errors, rows] = validator.validateReactionTransition( ...
                reaction, transition);

            testCase.verifyEqual(rows, [1, 2]);
            testCase.verifyTrue(any(contains( ...
                errors, "Reaction and Transition mismatch")));
            testCase.verifyTrue(any(contains( ...
                errors, "Reversibility mismatch")));

        end

        function reportsAllRowsWithInconsistentCarbonCounts(testCase)

            validator = openmebius.application.model ...
                .ModelWorkspaceValidator();
            [reaction, transition] = ...
                ModelWorkspaceValidatorTest.matchingTables();
            reaction.Reactants = {{'A'}; {'A'}};
            transition.Reactants = {{'ab'}; {'abc'}};

            [errors, rows] = validator.validateReactionTransition( ...
                reaction, transition);

            testCase.verifyEqual(rows, [1, 2]);
            testCase.verifyTrue(any(contains( ...
                errors, "Carbon count mismatch")));

        end

    end

    methods (Static, Access = private)

        function [reaction, transition] = matchingTables()

            reaction = table( ...
                {{'A', 'B'}; {'C', 'D'}}, ...
                {{'E'}; {'F'}}, ...
                [false; true], ...
                VariableNames = ["Reactants", "Products", "Reversible"]);
            transition = table( ...
                {{'a', 'b'}; {'c', 'd'}}, ...
                {{'e'}; {'f'}}, ...
                [false; true], ...
                VariableNames = ["Reactants", "Products", "Reversible"]);

        end

    end

end
