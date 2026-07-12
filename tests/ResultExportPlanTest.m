classdef ResultExportPlanTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ResultExportPlanTest.sourcePath());

        end

    end

    methods (Test)

        function buildCreatesDeterministicDirectoriesWithoutDatetime(testCase)

            outputDirectory = fullfile(tempdir, "openmebius-export-plan");
            outputLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(outputDirectory);

            plan = openmebius.application.result.ResultExportPlan.build( ...
                ["batch-1"; "batch-2"], ...
                ["Batch 1"; "Batch 2"], ...
                outputLocation, ...
                AddDatetime = false);

            testCase.verifyEqual(plan.count(), 2);
            testCase.verifyEqual(plan.OutputLocation.Directory, outputDirectory);
            testCase.verifyEqual( ...
                plan.ExportDirectories, ...
                [
                 fullfile(outputDirectory, "Batch 1_batch-1")
                 fullfile(outputDirectory, "Batch 2_batch-2")
                ]);

        end

        function exportLocationReturnsResultLocation(testCase)

            outputDirectory = fullfile(tempdir, "openmebius-export-plan");
            outputLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(outputDirectory);

            plan = openmebius.application.result.ResultExportPlan.build( ...
                "batch-1", ...
                "Batch 1", ...
                outputLocation, ...
                AddDatetime = false);

            exportLocation = plan.exportLocation(1);

            testCase.verifyClass( ...
                exportLocation, ...
                "openmebius.domain.result.ResultLocation");
            testCase.verifyEqual( ...
                exportLocation.Directory, ...
                fullfile(outputDirectory, "Batch 1_batch-1"));

        end

        function buildAppendsTimestampWhenRequested(testCase)

            outputDirectory = fullfile(tempdir, "openmebius-export-plan");
            outputLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(outputDirectory);

            plan = openmebius.application.result.ResultExportPlan.build( ...
                "batch-1", ...
                "Batch 1", ...
                outputLocation, ...
                AddDatetime = true);

            [~, directoryName] = fileparts(plan.ExportDirectories(1));

            testCase.verifyMatches( ...
                directoryName, ...
                "^Batch 1_batch-1_\d{8}-\d{6}$");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                ResultExportPlanTest.repositoryRoot(), ...
                "src");

        end

        function path = repositoryRoot()

            path = fileparts(fileparts(mfilename("fullpath")));

        end

    end

end
