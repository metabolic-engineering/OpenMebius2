classdef RawMSImportServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end % addSourcePath

    end % methods

    methods (Test)

        function importShimadzuASCIIWritesWorkbookAndReloadsExperiment(testCase)

            fixture = RawMSImportServiceTest.importFixture();
            cleanupExperiment = onCleanup( ...
                @() RawMSImportServiceTest.removeDirectory(fixture.Directory));

            rawDirectory = string(tempname);
            mkdir(rawDirectory);
            cleanupRaw = onCleanup( ...
                @() RawMSImportServiceTest.removeDirectory(rawDirectory));

            model = fixture.ImportResult.Experiments.getModel();
            atomTable = model.getAtomTable();
            fragmentName = string(atomTable.Properties.RowNames{1});

            rawFile = fullfile(rawDirectory, "raw_sample.txt");
            RawMSImportServiceTest.writeShimadzuText(rawFile, fragmentName);

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                fixture.Directory);

            service = openmebius.application.experiment.RawMSImportService();

            result = service.importShimadzuASCII( ...
                rawDirectory, ...
                experimentLocation, ...
                model);

            workbookPath = fullfile(fixture.Directory, "raw_sample.xlsx");
            testCase.verifyTrue(isfile(workbookPath));
            testCase.verifyClass( ...
                result.Experiments, ...
                'openmebius.application.experiment.ExperimentSet');
            testCase.verifyClass( ...
                result.Batch, ...
                'openmebius.application.batch.BatchSession');
            testCase.verifyEqual(result.ImportedFiles, "raw_sample.xlsx");
            testCase.verifyTrue(any(contains( ...
                result.Messages, ...
                "Raw MS data imported successfully: raw_sample.xlsx")));

            msTable = readtable( ...
                workbookPath, ...
                'Sheet', 'MS', ...
                'ReadRowNames', true, ...
                'VariableNamingRule', 'preserve');

            testCase.verifyEqual(height(msTable), 2);
            testCase.verifyEqual(msTable.Properties.RowNames, {'M+0'; 'M+1'});
            testCase.verifyEqual(msTable{:, fragmentName}, [10; 20]);

        end % importShimadzuASCIIWritesWorkbookAndReloadsExperiment

        function importShimadzuASCIIRequiresLoadedModel(testCase)

            rawDirectory = string(tempname);
            mkdir(rawDirectory);
            cleanupRaw = onCleanup( ...
                @() RawMSImportServiceTest.removeDirectory(rawDirectory));

            experimentDirectory = string(tempname);
            mkdir(experimentDirectory);
            cleanupExperiment = onCleanup( ...
                @() RawMSImportServiceTest.removeDirectory(experimentDirectory));

            service = openmebius.application.experiment.RawMSImportService();
            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                experimentDirectory);

            testCase.verifyError( ...
                @() service.importShimadzuASCII( ...
                rawDirectory, ...
                experimentLocation, ...
                []), ...
                "OpenMebius2:RawMSImportService:ModelNotLoaded");

        end % importShimadzuASCIIRequiresLoadedModel

        function importShimadzuASCIIFailsWhenAnyRawFileFails(testCase)

            fixture = RawMSImportServiceTest.importFixture();
            cleanupExperiment = onCleanup( ...
                @() RawMSImportServiceTest.removeDirectory(fixture.Directory));

            rawDirectory = string(tempname);
            mkdir(rawDirectory);
            cleanupRaw = onCleanup( ...
                @() RawMSImportServiceTest.removeDirectory(rawDirectory));

            model = fixture.ImportResult.Experiments.getModel();
            atomTable = model.getAtomTable();
            fragmentName = string(atomTable.Properties.RowNames{1});

            validRawFile = fullfile(rawDirectory, "valid_sample.txt");
            invalidRawFile = fullfile(rawDirectory, "invalid_sample.txt");
            RawMSImportServiceTest.writeShimadzuText( ...
                validRawFile, ...
                fragmentName);
            RawMSImportServiceTest.writeInvalidShimadzuText(invalidRawFile);

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                fixture.Directory);

            service = openmebius.application.experiment.RawMSImportService();

            try
                service.importShimadzuASCII( ...
                    rawDirectory, ...
                    experimentLocation, ...
                    model);
                testCase.verifyTrue( ...
                    false, ...
                    "Expected raw MS import to fail when any source file fails.");
            catch ME
                testCase.verifyEqual( ...
                    string(ME.identifier), ...
                    "OpenMebius2:RawMSDataRepository:ImportFailed");
                testCase.verifyTrue(contains(string(ME.message), "invalid_sample.txt"));
                testCase.verifyTrue(contains(string(ME.message), "Tag not found"));
            end

            testCase.verifyTrue(isfile(fullfile(fixture.Directory, "valid_sample.xlsx")));

        end % importShimadzuASCIIFailsWhenAnyRawFileFails

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
                "ImportResult", importService.importFiles( ...
                experimentLocation, ...
                string(sourceFile), ...
                string(modelDirectory)));

        end % importFixture

        function writeShimadzuText(filename, fragmentName)

            fragmentName = char(fragmentName);

            fileID = fopen(filename, 'w');

            if fileID == -1
                error("RawMSImportServiceTest:FileOpenFailed", ...
                    "Failed to create test raw MS file: %s", filename);
            end

            cleanup = onCleanup(@() fclose(fileID));

            fprintf(fileID, "[MS Quantitative Results]\n");
            fprintf(fileID, "Generated by test fixture\n");
            fprintf(fileID, "Name\tArea\tHeight\n");
            fprintf(fileID, "%s M+0\t10\t1\n", fragmentName);
            fprintf(fileID, "%s M+1\t20\t1\n", fragmentName);
            fprintf(fileID, "\n");

        end % writeShimadzuText

        function writeInvalidShimadzuText(filename)

            fileID = fopen(filename, 'w');

            if fileID == -1
                error("RawMSImportServiceTest:FileOpenFailed", ...
                    "Failed to create test raw MS file: %s", filename);
            end

            cleanup = onCleanup(@() fclose(fileID));

            fprintf(fileID, "Name\tArea\tHeight\n");
            fprintf(fileID, "Unknown M+0\t10\t1\n");

        end % writeInvalidShimadzuText

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, 's');
            end

        end % removeDirectory

    end % methods

end % classdef
