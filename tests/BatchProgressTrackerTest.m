classdef BatchProgressTrackerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(BatchProgressTrackerTest.sourcePath());

        end

    end

    methods (Test)

        function excludesFinishedBatchesAndWeightsOptimization(testCase)

            tableValue = BatchProgressTrackerTest.batchTable( ...
                ["finished", "ready", "ready"]);
            tableValue.config(1).iteration = 100;
            tableValue.config(2).iteration = 2;
            tableValue.config(3).iteration = 6;
            recorder = helpers.BatchExecutionRecorder();
            tracker = openmebius.application.batch.BatchProgressTracker( ...
                tableValue, struct, ...
                @(progress) recorder.recordProgress(progress));

            tracker.reportAnalysisProgress(2, "optimization", 1, 2);
            tracker.reportStatus(2, "finished");
            tracker.reportAnalysisProgress(3, "optimization", 3, 6);

            rates = cellfun(@(value) value.rate, recorder.Progress);
            testCase.verifyEqual(rates, [1/8; 2/8; 5/8], ...
                AbsTol = eps);

        end

        function appliesMonteCarloRunWeight(testCase)

            tableValue = BatchProgressTrackerTest.batchTable("ready");
            config = tableValue.config;
            config.iteration = 2;
            config.isCalcCI = true;
            config.CIConf.algorithm = 'Monte Carlo';
            config.CIConf.MC.iteration = 3;
            config.CIConf.MC.theNumberOfRuns = 4;
            tableValue.config = config;
            recorder = helpers.BatchExecutionRecorder();
            tracker = openmebius.application.batch.BatchProgressTracker( ...
                tableValue, struct, ...
                @(progress) recorder.recordProgress(progress));

            tracker.reportAnalysisProgress(1, "optimization", 2, 2);
            tracker.reportAnalysisProgress(1, "monte-carlo", 1, 3);

            rates = cellfun(@(value) value.rate, recorder.Progress);
            testCase.verifyEqual(rates, [2/14; 6/14], AbsTol = eps);
            testCase.verifyEqual( ...
                string(recorder.Progress{2}.message), ...
                "Monte Carlo: 1/3");

        end

        function appliesGridSearchWeightAndRuntimeValidCount(testCase)

            tableValue = BatchProgressTrackerTest.batchTable("ready");
            config = tableValue.config;
            config.iteration = 2;
            config.isCalcCI = true;
            config.CIConf.algorithm = 'Grid Search';
            config.CIConf.grid.iteration = 2;
            config.CIConf.grid.points = 4;
            config.CIConf.grid.maximumTrial = 3;
            config.CIConf.grid.reactions.select = [true; true; true];
            config.CIConf.grid.reactions.id = ["r1"; "r2"; "r3"];
            config.CIConf.grid.reactions.reaction = ["a"; "b"; "c"];
            tableValue.config = config;
            recorder = helpers.BatchExecutionRecorder();
            tracker = openmebius.application.batch.BatchProgressTracker( ...
                tableValue, struct, ...
                @(progress) recorder.recordProgress(progress));

            tracker.reportAnalysisProgress(1, "optimization", 2, 2);
            % Runtime FVA identifies one of the three selected reactions
            % as constant, leaving two grid-search profiles.
            tracker.reportAnalysisProgress(1, "grid-search", 0, 2);
            tracker.reportAnalysisProgress(1, "grid-search", 1, 2);

            rates = cellfun(@(value) value.rate, recorder.Progress);
            perReaction = 2 * (4 + 2 * 3);
            total = 2 + perReaction * 2;
            testCase.verifyEqual( ...
                rates, [2/62; 2/total; (2 + perReaction)/total], ...
                AbsTol = eps);
            testCase.verifyEqual( ...
                string(recorder.Progress{3}.message), ...
                "Grid search: 1/2 reactions");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function batchTable = batchTable(statuses)

            statuses = string(statuses(:));
            count = numel(statuses);
            configs = repmat( ...
                openmebius.domain.batch.BatchConfig.defaultConfig(), ...
                count, 1);

            for index = 1:count
                configs(index).status = char(statuses(index));
            end

            batchTable = table( ...
                "bat_" + string((1:count)'), ...
                "Batch " + string((1:count)'), ...
                repmat({"experiment-a"}, count, 1), ...
                strings(count, 1), ...
                configs, ...
                strings(count, 1), ...
                'VariableNames', ...
                openmebius.infrastructure.batch.BatchJsonMapper ...
                .defaultVariableNames());

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
