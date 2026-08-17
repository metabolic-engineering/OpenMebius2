classdef ModelWorkspaceValidatorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end

    end

    methods (Test)

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
