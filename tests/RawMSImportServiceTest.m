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
            testCase.verifyClass(result.Experiments, 'IOExps');
            testCase.verifyClass(result.Batch, 'Batch');
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

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, 's');
            end

        end % removeDirectory

    end % methods

end % classdef
