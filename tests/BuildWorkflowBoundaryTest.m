classdef BuildWorkflowBoundaryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end

    end

    methods (Test)

        function validationPlanUsesRepositoryRelativePaths(testCase)
            root = string(fileparts(fileparts(mfilename("fullpath"))));

            result = BuildMyApp( ...
                ValidateOnly = true, ...
                RunFastTests = false, ...
                VerifySourceSync = false);
            plan = result.Plan;

            testCase.verifyEqual(plan.RepositoryRoot, root);
            testCase.verifyEqual( ...
                plan.AppFile, fullfile(root, "src", "OpenMebius2.mlapp"));
            testCase.verifyTrue(all(isfile(plan.AssetFiles)));
            testCase.verifyEqual( ...
                plan.OutputDirectory, ...
                fullfile(root, "build", "openmebius2"));
            testCase.verifyEqual( ...
                plan.InstallerDirectory, fullfile(root, "installer"));
            testCase.verifyNotEmpty(plan.Version);
            testCase.verifyTrue(startsWith( ...
                plan.InstallerName, "openmebius2-v" + plan.Version));
            testCase.verifyEmpty(result.BuildResults);
            testCase.verifyFalse(result.InstallerCreated);
        end

        function releaseDefaultsKeepVerificationEnabled(testCase)
            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread(fullfile(root, "src", "BuildMyApp.m")));

            testCase.verifyTrue(contains(source, ...
                "options.RunFastTests (1, 1) logical = true"));
            testCase.verifyTrue(contains(source, ...
                "options.VerifySourceSync (1, 1) logical = true"));
            testCase.verifyTrue(contains(source, "runFastTests()"));
            testCase.verifyTrue(contains(source, ...
                "OpenMebius2SourceSyncTest.m"));
        end

    end

end
