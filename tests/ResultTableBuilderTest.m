classdef ResultTableBuilderTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)
            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
        end

    end

    methods (Test)

        function buildsOverviewAndRelativeValues(testCase)
            builder = openmebius.application.result.ResultTableBuilder();
            data = ResultTableBuilderTest.resultData([10; 20]);

            [value, message] = builder.fluxOverview(data);
            [relative, relativeMessage] = builder.fluxOverview( ...
                data, Relative = true, RelativeTo = "R1");

            testCase.verifyEqual(message, "");
            testCase.verifyEqual(relativeMessage, "");
            testCase.verifyEqual(value.Properties.RowNames, {'R1'; 'biomass'});
            testCase.verifyEqual(value.Flux, [10; 20]);
            testCase.verifyEqual(value.LB, [8; 18]);
            testCase.verifyEqual(value.UB, [12; 22]);
            testCase.verifyEqual(relative.Flux, [100; 200]);
        end

        function buildsDetailedMdvTable(testCase)
            builder = openmebius.application.result.ResultTableBuilder();
            data = ResultTableBuilderTest.resultData([10; 20]);
            data.MDVExp = [0.25; 0.75];
            data.MDVExpName = ["fragment-a"; "fragment-a"];
            data.MDVFragMask = [true; true];
            data.fluxResult0001.MDV = [0.2; 0.8];

            [value, message] = builder.fluxDetailed(data);

            testCase.verifyEqual(message, "");
            testCase.verifyEqual(value.Fragment, ["fragment-a"; ""]);
            testCase.verifyEqual(value.("M+i"), ["M + 0"; "M + 1"]);
            testCase.verifyEqual(value.Measured, [0.25; 0.75]);
            testCase.verifyEqual(value.Estimated, [0.2; 0.8]);
            testCase.verifyEqual(value.("Chi^2"), [25; 25], ...
                AbsTol = 1e-12);
        end

        function acceptsNumericFragmentMaskFromHdf5(testCase)

            builder = openmebius.application.result.ResultTableBuilder();
            data = ResultTableBuilderTest.resultData([10; 20]);
            data.MDVExp = [0.25; 0.75];
            data.MDVExpName = ["fragment-a"; "fragment-a"];
            data.MDVFragMask = [1; 0];
            data.fluxResult0001.MDV = [0.2; 0.8];

            [value, message] = builder.fluxDetailed(data);

            testCase.verifyEqual(message, "");
            testCase.verifyEqual(value.("Chi^2")(1), 25, ...
                AbsTol = 1e-12);
            testCase.verifyTrue(isnan(value.("Chi^2")(2)));

        end

        function buildsComparisonWithUniqueSeriesNames(testCase)
            builder = openmebius.application.result.ResultTableBuilder();
            first = ResultTableBuilderTest.resultData([10; 20]);
            second = ResultTableBuilderTest.resultData([30; 40]);

            [value, message] = builder.fluxComparison( ...
                {first, second}, ["sample", "sample"]);

            testCase.verifyEqual(message, "");
            testCase.verifyEqual( ...
                string(value.Properties.VariableNames), ...
                ["Reaction", "sample_1", "sample_2"]);
            testCase.verifyEqual(value.sample_1, [10; 20]);
            testCase.verifyEqual(value.sample_2, [30; 40]);
        end

        function buildsGridSearchLongTable(testCase)

            builder = openmebius.application.result.ResultTableBuilder();
            data = ResultTableBuilderTest.resultData([10; 20]);
            data.CI.algorithm = "Grid search";
            data.CI.gridSearch = struct( ...
                fluxIndices = 1, ...
                reactionIDs = "R1", ...
                fixedFlux = [0.5, 1.0], ...
                RSS = cat(3, [6, 4], [5, 3]), ...
                minimumRSS = [5, 3], ...
                bestObjective = 2, ...
                objectiveThreshold = 5.5);

            [value, message] = builder.gridSearch(data);

            testCase.verifyEqual(message, "");
            testCase.verifyEqual(height(value), 4);
            testCase.verifyEqual(value.ReactionID, repmat("R1", 4, 1));
            testCase.verifyEqual(value.GridPoint, [1; 1; 2; 2]);
            testCase.verifyEqual(value.Trial, [1; 2; 1; 2]);
            testCase.verifyEqual(value.FixedFlux, [0.5; 0.5; 1; 1]);
            testCase.verifyEqual(value.RSS, [6; 5; 4; 3]);
            testCase.verifyEqual(value.MinimumRSS, [5; 5; 3; 3]);
            testCase.verifyEqual(value.BestObjective, 2 * ones(4, 1));
            testCase.verifyEqual( ...
                value.ObjectiveThreshold, 5.5 * ones(4, 1));

            profiles = builder.gridSearchProfiles(value);
            testCase.verifyNumElements(profiles, 1);
            testCase.verifyEqual(profiles.ReactionID, "R1");
            testCase.verifyEqual(profiles.FluxIndex, 1);
            testCase.verifyEqual( ...
                string(profiles.Data.Properties.VariableNames), ...
                ["FixedFlux", "RSS"]);
            testCase.verifyEqual(profiles.Data.FixedFlux, [0.5; 1]);
            testCase.verifyEqual(profiles.Data.RSS, [5; 3]);

        end

        function gridSearchProfilesCollapseDuplicateFixedFlux(testCase)

            builder = openmebius.application.result.ResultTableBuilder();
            data = ResultTableBuilderTest.resultData([10; 20]);
            data.CI.algorithm = "Grid search";
            data.CI.gridSearch = struct( ...
                fluxIndices = 1, ...
                reactionIDs = "R1", ...
                fixedFlux = [0.5, 1.0, 1.0], ...
                RSS = cat(3, [6, 5, 4], [5, 4, 3]), ...
                minimumRSS = [5, 4, 3], ...
                bestObjective = 2, ...
                objectiveThreshold = 5.5);

            [longTable, message] = builder.gridSearch(data);
            profiles = builder.gridSearchProfiles(longTable);

            testCase.verifyEqual(message, "");
            testCase.verifyNumElements(profiles, 1);
            testCase.verifyEqual( ...
                profiles.Data.FixedFlux, [0.5; 1]);
            testCase.verifyEqual(profiles.Data.RSS, [5; 3]);

        end

    end

    methods (Static, Access = private)

        function data = resultData(flux)
            data = struct();
            data.status = [true, true, true, false];
            data.fluxVariability = struct( ...
                'fluxUBFwd', [15; 25], ...
                'fluxLBFwd', [5; 15]);
            data.model = struct( ...
                'modelID', "R1", ...
                'modelReaction', "A -> B");
            data.RSSIdx = 1;
            data.fluxResult0001 = struct('fluxFwd', flux);
            data.fluxLB = [8; 18];
            data.fluxUB = [12; 22];
        end

    end

end
