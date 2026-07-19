classdef ExperimentImportServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end % addSourcePath

    end % methods

    methods (Test)

        function importFilesBuildsExperimentsAndBatch(testCase)

            repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
            experimentDirectory = string(tempname);
            mkdir(experimentDirectory);
            cleanup = onCleanup(@() ExperimentImportServiceTest.removeDirectory(experimentDirectory));

            sourceFile = fullfile(repositoryRoot, 'dataset', 'WT_ecoli.xlsx');
            modelDirectory = fullfile(repositoryRoot, 'model', 'Escherichia coli');
            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                experimentDirectory);

            service = openmebius.application.experiment.ExperimentImportService();

            result = service.importFiles( ...
                experimentLocation, ...
                string(sourceFile), ...
                string(modelDirectory));

            testCase.verifyClass( ...
                result.Experiments, ...
                'openmebius.application.experiment.ExperimentWorkspace');
            testCase.verifyClass( ...
                result.Batch, ...
                'openmebius.application.batch.BatchSession');
            testCase.verifyEqual(result.Experiments.numFile, 1);
            testCase.verifyTrue(isfile(fullfile(experimentDirectory, 'WT_ecoli.xlsx')));
            testCase.verifyEqual(result.ImportedFiles, "WT_ecoli.xlsx");
            testCase.verifyEmpty(result.SkippedFiles);
            testCase.verifyTrue(any(contains(result.Messages, "Experimental data loaded successfully.")));

        end % importFilesBuildsExperimentsAndBatch

        function importFilesSkipsExistingWorkbook(testCase)

            repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
            experimentDirectory = string(tempname);
            mkdir(experimentDirectory);
            cleanup = onCleanup(@() ExperimentImportServiceTest.removeDirectory(experimentDirectory));

            sourceFile = fullfile(repositoryRoot, 'dataset', 'WT_ecoli.xlsx');
            copyfile(sourceFile, fullfile(experimentDirectory, 'WT_ecoli.xlsx'));

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                experimentDirectory);
            repository = openmebius.infrastructure.experiment.ExperimentRepository();

            report = repository.importFiles( ...
                experimentLocation, ...
                string(sourceFile));

            testCase.verifyEmpty(report.ImportedFiles);
            testCase.verifyEqual(report.SkippedFiles, "WT_ecoli.xlsx");
            testCase.verifyTrue(any(contains(report.Messages, "already exists")));

        end % importFilesSkipsExistingWorkbook

    end % methods

    methods (Static, Access = private)

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, 's');
            end

        end % removeDirectory

    end % methods

end % classdef
