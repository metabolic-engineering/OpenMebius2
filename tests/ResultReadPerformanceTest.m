classdef ResultReadPerformanceTest < matlab.unittest.TestCase
    properties
        Location
        Reader
    end
    methods (TestMethodSetup)
        function setup(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(root, 'src'), fullfile(root, 'tests'));
            folder = tempname;
            mkdir(folder);
            testCase.addTeardown(@() rmdir(folder, 's'));
            testCase.Location = openmebius.domain.result.ResultLocation(folder);
            testCase.Reader = helpers.CountingResultReader();
        end
    end
    methods (Test)
        function summaryDoesNotRequireIterationPayloads(testCase)
            testCase.summaryFixture("a");
            data = testCase.Reader.readResultSummary(testCase.Location, "a");
            testCase.verifyEqual(data.RSS, 1);
            testCase.verifyEqual(data.threshold, 2.5);
            testCase.verifyEqual(sort(string(fieldnames(data))), sort(["ID"; "status"; "RSS"; "threshold"]));
            data = testCase.Reader.readOptimizationState(testCase.Location, "a", IncludeExitFlags = false);
            testCase.verifyEqual(data.RSS, [3; 1; 2]);
            testCase.verifyFalse(isfield(data, 'ExitFlags'));
        end

        function bestFitIgnoresOtherIterationsAndInitialPoints(testCase)
            testCase.bestFitFixture("a");
            data = testCase.Reader.readBestFit(testCase.Location, "a");
            testCase.verifyEqual(data.RSSIdx, int32(2));
            testCase.verifyEqual(data.fluxResult0002.fluxFwd, [10; 20; 30]);
            testCase.verifyFalse(isfield(data.fluxResult0002, 'MDV'));
            testCase.verifyFalse(isfield(data, 'initialFlux'));
            testCase.put("a", "/MDVExp", [0.2; 0.8]);
            testCase.put("a", "/MDVFragList", ["F"; "F"]);
            testCase.put("a", "/MDVFragMask", [1; 1]);
            testCase.put("a", "/fluxResult/0002/MDV", [0.3; 0.7]);
            data = testCase.Reader.readBestFit(testCase.Location, "a", IncludeMDV = true);
            testCase.verifyEqual(data.fluxResult0002.MDV, [0.3; 0.7]);
        end

        function monteCarloReadsOnlySelectedReactionWithoutFluxSamples(testCase)
            testCase.bestFitFixture("a");
            testCase.put("a", "/status", int8([1; 1; 1; 0]));
            testCase.put("a", "/fluxLB", [1; 2; 3]);
            testCase.put("a", "/fluxUB", [4; 5; 6]);
            testCase.put("a", "/CI/algorithm", "Monte Carlo");
            lower = reshape(1:12, 3, 4);
            testCase.put("a", "/CI/fluxLB", lower);
            testCase.put("a", "/CI/fluxUB", lower + 10);
            data = testCase.Reader.readConfidenceInterval(testCase.Location, "a", "R2");
            testCase.verifyEqual(data.CI.reactionIndex, 2);
            testCase.verifyEqual(data.CI.fluxLB, lower(2, :));
            testCase.verifyEqual(data.CI.fluxUB, lower(2, :) + 10);
            testCase.verifyFalse(isfield(data.CI, 'flux'));
            data = testCase.Reader.readConfidenceInterval(testCase.Location, "a", "biomass");
            testCase.verifyEqual(data.CI.fluxLB, lower(3, :));
            testCase.verifyEmpty(testCase.Reader.readConfidenceInterval(testCase.Location, "a", "missing"));
        end

        function gridSearchMatchesSelectedSliceOfLegacyFile(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            location = openmebius.domain.result.ResultLocation(fullfile(root, 'tutorial', 'ecoli_grid_search', 'results'));
            id = "bat_dd0eff6798474f24b58b6657e5dd0354";
            full = testCase.Reader.readResultData(location, id, ReadStatus = [false, false, true, false]);
            reaction = full.CI.gridSearch.reactionIDs(2);
            selected = testCase.Reader.readConfidenceInterval(location, id, reaction);
            testCase.verifyEqual(selected.CI.gridSearch.RSS, full.CI.gridSearch.RSS(2, :, :));
            testCase.verifyEqual(selected.CI.gridSearch.fixedFlux, full.CI.gridSearch.fixedFlux(2, :));
            testCase.verifyEqual(selected.CI.gridSearch.fluxIndices, full.CI.gridSearch.fluxIndices(2));
        end

        function cacheReusesReadsAndInvalidatesOnlyChangedBatch(testCase)
            testCase.bestFitFixture("a"); testCase.bestFitFixture("b");
            query = testCase.query();
            query.readSummaries(["a", "b"]);
            query.readSummaries(["b", "a"]);
            query.readBestFit("a"); query.readBestFit("a");
            testCase.verifyEqual(testCase.Reader.SummaryReads, 2);
            testCase.verifyEqual(testCase.Reader.BestFitReads, 1);
            query.invalidate("a");
            query.readSummaries(["a", "b"]);
            query.readBestFit("a");
            testCase.verifyEqual(testCase.Reader.SummaryReads, 3);
            testCase.verifyEqual(testCase.Reader.BestFitReads, 2);
            query.invalidate();
            query.readSummaries(["a", "b"]);
            testCase.verifyEqual(testCase.Reader.SummaryReads, 5);
        end

        function changedDeletedAndCorruptFilesDoNotLeaveStaleRows(testCase)
            testCase.summaryFixture("a"); testCase.summaryFixture("b");
            query = testCase.query();
            query.readSummaries(["a", "b"]);
            testCase.put("a", "/extra", zeros(100, 1));
            h5write(testCase.Location.resultFile("a"), "/RSS", [5; 6; 7]);
            delete(testCase.Location.resultFile("b"));
            testCase.put("bad", "/ID", "bad");
            [data, mask] = query.readSummaries(["a", "b", "bad"]);
            testCase.verifyEqual(mask, [true, false, false]);
            testCase.verifyEqual(data{1}.RSS, 5);
            testCase.summaryFixture("b");
            [~, mask] = query.readSummaries("b");
            testCase.verifyTrue(mask);
        end

        function explicitInvalidationWorksWithUnchangedFileSignature(testCase)
            testCase.summaryFixture("a");
            query = testCase.query();
            query.readSummaries("a");
            file = java.io.File(char(testCase.Location.resultFile("a")));
            modified = file.lastModified();
            before = dir(testCase.Location.resultFile("a"));
            h5write(testCase.Location.resultFile("a"), "/RSS", [7; 8; 9]);
            testCase.assertTrue(file.setLastModified(modified));
            after = dir(testCase.Location.resultFile("a"));
            testCase.assertEqual([before.bytes, before.datenum], [after.bytes, after.datenum]);
            query.invalidate("a");
            data = query.readSummaries("a");
            testCase.verifyEqual(data{1}.RSS, 7);
        end

        function zeroBudgetDoesNotRetainDetailedData(testCase)
            testCase.bestFitFixture("a");
            query = openmebius.application.result.ResultQueryService(testCase.Location, ...
                Hdf5ResultRepository = testCase.Reader, MaxCacheBytes = 0);
            query.readBestFit("a"); query.readBestFit("a");
            testCase.verifyEqual(testCase.Reader.BestFitReads, 2);
        end
    end
    methods (Access = private)
        function query = query(testCase)
            query = openmebius.application.result.ResultQueryService(testCase.Location, ...
                Hdf5ResultRepository = testCase.Reader);
        end
        function summaryFixture(testCase, id)
            testCase.put(id, "/ID", id);
            testCase.put(id, "/status", int8([1; 1; 0; 0]));
            testCase.put(id, "/RSS", [3; 1; 2]);
            testCase.put(id, "/threshold", 2.5);
        end
        function bestFitFixture(testCase, id)
            testCase.summaryFixture(id);
            testCase.put(id, "/model/modelID", ["R1"; "R2"]);
            testCase.put(id, "/model/modelReaction", ["First"; "Second"]);
            testCase.put(id, "/fluxVariability/fluxLBFwd", [0; 0; 0]);
            testCase.put(id, "/fluxVariability/fluxUBFwd", [100; 100; 100]);
            testCase.put(id, "/RSSIndex", int32([2; 1; 3]));
            testCase.put(id, "/fluxResult/0002/fluxFwd", [10; 20; 30]);
        end
        function put(testCase, id, path, value)
            type = string(class(value));
            [ok, message] = testCase.Reader.writeDataset(testCase.Location.resultFile(id), path, value, DataType = type);
            testCase.assertTrue(ok, message);
        end
    end
end
