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
