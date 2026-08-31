classdef ResultDiffServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function comparesSavedAnalysisSettings(testCase)

            firstConfig = openmebius.domain.batch.BatchConfig ...
                .defaultConfig();
            firstConfig.iteration = 12;
            firstConfig.optimizationMethod = 'hybrid-ga-gradient';
            firstConfig.MS.fragment = 'custom';
            firstConfig.MS.fragmentList = ["frag-a"; "frag-b"];
            firstConfig.isSelectMSFragment = true;
            secondConfig = firstConfig;
            secondConfig.iteration = 30;
            secondConfig.optimizationMethod = 'gradient-only';
            secondConfig.MS.fragmentList = "frag-b";
            workspace = helpers.ResultDiffWorkspaceStub();
            workspace.Snapshots = { ...
                ResultDiffServiceTest.snapshot(firstConfig); ...
                ResultDiffServiceTest.snapshot(secondConfig)};
            service = openmebius.application.result.ResultDiffService();

            comparison = service.compare( ...
                workspace, ...
                ["batch-1"; "batch-2"], ...
                ["First"; "Second"]);

            testCase.verifyEqual( ...
                workspace.RequestedIDs, ["batch-1"; "batch-2"]);
            testCase.verifyEqual( ...
                comparison.BatchNames, ["First"; "Second"]);
            testCase.verifyTrue(any( ...
                comparison.Differences == "iteration: 12 -> 30"));
            testCase.verifyTrue(any( ...
                comparison.Differences == ...
                "optimizationMethod: ""hybrid-ga-gradient"" -> " + ...
                """gradient-only"""));
            testCase.verifyTrue(any( ...
                comparison.Differences == ...
                "MS.fragmentList: [""frag-a"", ""frag-b""] -> " + ...
                """frag-b"""));

        end

        function reportsNoDifferencesForEquivalentSettings(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            workspace = helpers.ResultDiffWorkspaceStub();
            workspace.Snapshots = { ...
                ResultDiffServiceTest.snapshot(config); ...
                ResultDiffServiceTest.snapshot(config)};
            service = openmebius.application.result.ResultDiffService();

            comparison = service.compare( ...
                workspace, ...
                ["batch-1"; "batch-2"], ...
                ["First"; "Second"]);

            testCase.verifyEmpty(comparison.Differences);

        end

        function requiresExactlyTwoResults(testCase)

            service = openmebius.application.result.ResultDiffService();
            workspace = helpers.ResultDiffWorkspaceStub();

            testCase.verifyError( ...
                @() service.compare( ...
                workspace, "batch-1", "First"), ...
                "OpenMebius2:ResultDiff:SelectionRequired");
            testCase.verifyError( ...
                @() service.compare( ...
                workspace, ...
                ["batch-1"; "batch-2"; "batch-3"], ...
                ["First"; "Second"; "Third"]), ...
                "OpenMebius2:ResultDiff:SelectionRequired");

        end

        function rejectsUnavailableMetadata(testCase)

            service = openmebius.application.result.ResultDiffService();
            workspace = helpers.ResultDiffWorkspaceStub();
            workspace.Snapshots = {struct(); struct()};

            testCase.verifyError( ...
                @() service.compare( ...
                workspace, ...
                ["batch-1"; "batch-2"], ...
                ["First"; "Second"]), ...
                "OpenMebius2:ResultDiff:DataUnavailable");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function snapshot = snapshot(config)

            semanticConfig = openmebius.domain.batch.BatchIdentity ...
                .semanticConfig(config);
            snapshot = struct( ...
                ConfigJson = string(jsonencode(semanticConfig)));

        end

    end % methods (Static, Access = private)

end % classdef
