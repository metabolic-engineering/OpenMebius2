classdef ReactionExpressionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function reversesReversibleExpressions(testCase)

            [reversed, isReversible] = openmebius.domain.model ...
                .ReactionExpression.reverseReversible( ...
                    ["A <=> B"; "  C + D <=> E  "]);

            testCase.verifyEqual( ...
                reversed, ...
                ["B <=> A"; "E <=> C + D"]);
            testCase.verifyEqual(isReversible, [true; true]);

        end

        function preservesNonReversibleExpressions(testCase)

            reactions = ["A --> B", "no arrow"];

            [reversed, isReversible] = openmebius.domain.model ...
                .ReactionExpression.reverseReversible(reactions);

            testCase.verifyEqual(reversed, reactions);
            testCase.verifyEqual(isReversible, [false, false]);

        end

        function preservesInputShape(testCase)

            reactions = ["A <=> B", "C <=> D"];

            [reversed, isReversible] = openmebius.domain.model ...
                .ReactionExpression.reverseReversible(reactions);

            testCase.verifySize(reversed, size(reactions));
            testCase.verifySize(isReversible, size(reactions));

        end

    end % methods (Test)

end % classdef
