classdef BatchLoadServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end % addSourcePath

    end % methods

    methods (Test)

        function loadForExperimentBuildsBatch(testCase)

            fixture = BatchLoadServiceTest.importFixture();
            cleanup = onCleanup( ...
                @() BatchLoadServiceTest.removeDirectory(fixture.Directory));

            service = openmebius.application.batch.BatchLoadService();

            result = service.loadForExperiment( ...
                fixture.ExperimentLocation, ...
                fixture.ImportResult.Experiments);

            testCase.verifyClass( ...
                result, ...
                'openmebius.application.batch.BatchLoadResult');
            testCase.verifyClass(result.Batch, 'Batch');
            testCase.verifyTrue(any(contains( ...
                result.Messages, ...
                "Batch object created successfully.")));

        end % loadForExperimentBuildsBatch

        function loadForExperimentRejectsLocationMismatch(testCase)

            fixture = BatchLoadServiceTest.importFixture();
            cleanup = onCleanup( ...
                @() BatchLoadServiceTest.removeDirectory(fixture.Directory));

            otherDirectory = string(tempname);
            mkdir(otherDirectory);
            cleanupOther = onCleanup( ...
                @() BatchLoadServiceTest.removeDirectory(otherDirectory));

            otherLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                otherDirectory);

            service = openmebius.application.batch.BatchLoadService();

            testCase.verifyError( ...
                @() service.loadForExperiment( ...
                otherLocation, ...
                fixture.ImportResult.Experiments), ...
                "OpenMebius2:LegacyProject:ExperimentLocationMismatch");

        end % loadForExperimentRejectsLocationMismatch

    end % methods

    methods (Static, Access = private)

        function fixture = importFixture()

            repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
            experimentDirectory = string(tempname);
            mkdir(experimentDirectory);

            sourceFile = fullfile(repositoryRoot, 'dataset', 'WT_ecoli.xlsx');
            modelDirectory = fullfile(repositoryRoot, 'model', 'Escherichia coli');
            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                experimentDirectory);

            importService = ...
                openmebius.application.experiment.ExperimentImportService();

            fixture = struct( ...
                "Directory", experimentDirectory, ...
                "ExperimentLocation", experimentLocation, ...
                "ImportResult", importService.importFiles( ...
                experimentLocation, ...
                string(sourceFile), ...
                string(modelDirectory)));

        end % importFixture

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, 's');
            end

        end % removeDirectory

    end % methods

end % classdef
