classdef IdentifierFormatterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function keepsOnlyFirstTenCharacters(testCase)

            actual = openmebius.presentation.IdentifierFormatter.short( ...
                ["bat_dd0eff6798474f24b58b6657e5dd0354"; "short-id"]);

            testCase.verifyEqual(actual, ["bat_dd0eff"; "short-id"]);

        end

    end

end
