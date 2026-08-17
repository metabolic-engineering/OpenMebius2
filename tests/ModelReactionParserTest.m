classdef ModelReactionParserTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end

    end

    methods (Test)

        function parsesIrreversibleAndReversibleExpressions(testCase)

            parser = openmebius.application.model.ModelReactionParser();
            result = parser.parse({'A + B --> C'; 'C <=> D'});

            testCase.verifyEmpty(result.Errors);
            testCase.verifyEqual(result.Reactants{1}, {'A', 'B'});
            testCase.verifyEqual(result.Products{1}, {'C'});
            testCase.verifyEqual(result.Reversible, [false; true]);

        end

        function reportsMalformedRowsAndPreservesValidRows(testCase)

            parser = openmebius.application.model.ModelReactionParser();
            result = parser.parse({ ...
                'A --> B'; ...
                ''; ...
                'A --> B <=> C'; ...
                'A + --> B'});

            testCase.verifyEqual(result.ErrorRows, [2, 3, 4]);
            testCase.verifyNumElements(result.Errors, 3);
            testCase.verifyEqual(result.Reactants{1}, {'A'});
            testCase.verifyEqual(result.Products{1}, {'B'});
            testCase.verifyEmpty(result.Reactants{2});
            testCase.verifyTrue(all(contains( ...
                result.Errors, "Reaction format mismatch")));

        end

        function reportsNonTextValuesAsFormatErrors(testCase)

            parser = openmebius.application.model.ModelReactionParser();
            result = parser.parse({'A --> B'; 42});

            testCase.verifyEqual(result.ErrorRows, 2);
            testCase.verifyEqual(result.Reversible, [false; false]);

        end

    end

end
