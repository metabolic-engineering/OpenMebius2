classdef MainAppDomainBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function mainAppDoesNotInvokeDomainMembersDirectly(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "OpenMebius2_exported.m")));
            directReferences = regexp( ...
                source, ...
                "app\.(model|exp|batch)\.[A-Za-z_]\w*", ...
                "match");

            testCase.verifyEmpty(unique(directReferences));
            testCase.verifyFalse(contains( ...
                source, "function updateModel(app)"));

        end

    end % methods (Test)

end % classdef
