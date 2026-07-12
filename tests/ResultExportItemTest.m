classdef ResultExportItemTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ResultExportItemTest.sourcePath());

        end

    end

    methods (Test)

        function constructorStoresBatchAndLocation(testCase)

            exportDirectory = fullfile(tempdir, "openmebius-export-item");
            exportLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(exportDirectory);

            item = openmebius.application.result.ResultExportItem( ...
                BatchID = "batch-1", ...
                BatchName = "Batch 1", ...
                ExportLocation = exportLocation);

            testCase.verifyEqual(item.BatchID, "batch-1");
            testCase.verifyEqual(item.BatchName, "Batch 1");
            testCase.verifyEqual(item.ExportLocation.Directory, exportDirectory);
            testCase.verifyEqual(item.ExportDirectory, exportDirectory);

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                ResultExportItemTest.repositoryRoot(), ...
                "src");

        end

        function path = repositoryRoot()

            path = fileparts(fileparts(mfilename("fullpath")));

        end

    end

end
