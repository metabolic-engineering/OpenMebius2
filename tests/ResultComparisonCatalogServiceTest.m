classdef ResultComparisonCatalogServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function listsOnlyFinishedAnalyzedBatches(testCase)

            batch = helpers.ResultComparisonBatchStub();
            batch.Data = table( ...
                ["batch-a"; "batch-b"; "batch-c"], ...
                ["A"; "B"; "C"], ...
                ["exp-a"; "exp-b"; "exp-c"], ...
                strings(3, 1), ...
                'VariableNames', ...
                {'ID', 'Name', 'Experiment', 'Description'});
            batch.Statuses = ["finished"; "finished"; "ready"];
            result = helpers.ResultComparisonCatalogWorkspaceStub();
            result.Data = { ...
                struct('status', logical([1 1 0 0])), ...
                struct('status', logical([1 1 1 0]))};
            result.Mask = [true true];
            service = openmebius.application.result ...
                .ResultComparisonCatalogService();

            catalog = service.load(batch, result);

            testCase.verifyEqual(catalog.BatchIDs, ...
                ["batch-a"; "batch-b"]);
            testCase.verifyEqual(catalog.BatchNames, ["A"; "B"]);
            testCase.verifyEqual(catalog.ExperimentNames, ...
                ["exp-a"; "exp-b"]);
            testCase.verifyEqual(catalog.Contents, ["FVA"; "CI"]);
            testCase.verifyEqual(result.RequestedIDs, ...
                ["batch-a", "batch-b"]);
            testCase.verifyEqual(result.ReadStatus, false(1, 4));

        end

        function omitsMissingAndUnanalyzedResults(testCase)

            batch = helpers.ResultComparisonBatchStub();
            batch.Data = table( ...
                ["batch-a"; "batch-b"], ...
                ["A"; "B"], ...
                ["exp-a"; "exp-b"], ...
                strings(2, 1), ...
                'VariableNames', ...
                {'ID', 'Name', 'Experiment', 'Description'});
            batch.Statuses = repmat("finished", 2, 1);
            result = helpers.ResultComparisonCatalogWorkspaceStub();
            result.Data = {struct('status', false(1, 4)), struct()};
            result.Mask = [true false];
            service = openmebius.application.result ...
                .ResultComparisonCatalogService();

            catalog = service.load(batch, result);

            testCase.verifyEqual(catalog.count(), 0);

        end

    end

end
