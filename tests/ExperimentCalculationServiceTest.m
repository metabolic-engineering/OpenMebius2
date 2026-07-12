classdef ExperimentCalculationServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end % addSourcePath

    end % methods

    methods (Test)

        function calculateMDVUpdatesExperimentAndBatch(testCase)

            fixture = ExperimentCalculationServiceTest.importFixture();
            cleanup = onCleanup(@() ExperimentCalculationServiceTest.removeDirectory(fixture.Directory)); %#ok<NASGU>

            [infoTable, uptakeTable, tracerTable] = ...
                ExperimentCalculationServiceTest.validExperimentTables( ...
                fixture.ImportResult.Experiments);

            service = ...
                openmebius.application.experiment.ExperimentCalculationService();

            result = service.calculateMDV( ...
                fixture.ImportResult.Experiments.getModel(), ...
                fixture.ImportResult.Experiments, ...
                fixture.ImportResult.Batch, ...
                infoTable, ...
                uptakeTable, ...
                tracerTable);

            testCase.verifyClass(result.Experiments, 'IOExps');
            testCase.verifyClass(result.Batch, 'Batch');
            testCase.verifyTrue(result.HasCalculatedMDV);
            testCase.verifyTrue(result.Experiments.hasCalculatedMDV());
            testCase.verifyTrue(any(contains( ...
                result.Messages, ...
                "MDV-derived tables have been updated successfully.")));

        end % calculateMDVUpdatesExperimentAndBatch

        function invalidInfoTableRaisesUpdateError(testCase)

            fixture = ExperimentCalculationServiceTest.importFixture();
            cleanup = onCleanup(@() ExperimentCalculationServiceTest.removeDirectory(fixture.Directory)); %#ok<NASGU>

            [~, uptakeTable, tracerTable] = ...
                ExperimentCalculationServiceTest.validExperimentTables( ...
                fixture.ImportResult.Experiments);

            service = ...
                openmebius.application.experiment.ExperimentCalculationService();

            testCase.verifyError( ...
                @() service.calculateMDV( ...
                fixture.ImportResult.Experiments.getModel(), ...
                fixture.ImportResult.Experiments, ...
                fixture.ImportResult.Batch, ...
                table(), ...
                uptakeTable, ...
                tracerTable), ...
                "OpenMebius2:ExperimentCalculation:UpdateFailed");

        end % invalidInfoTableRaisesUpdateError

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

        function [infoTable, uptakeTable, tracerTable] = validExperimentTables(experiments)

            infoTable = experiments.getInfoTable();
            uptakeTable = experiments.getUptakeTable();
            tracerTable = experiments.getTracerTable();

            infoTable{1, 1} = 0.634525729817483;
            infoTable{1, 2} = 0;
            infoTable{1, 3} = 1;

            uptakeTable{1, 1} = 3.6405030802424;
            uptakeTable{1, 3} = 8.206603261;

            tracerTable{1, 1} = "12C2~1";
            tracerTable{1, 2} = "12C1~1";
            tracerTable{1, 3} = "[1]Glc~1";
            tracerTable{1, 4} = "12C1~1";

        end % validExperimentTables

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, 's');
            end

        end % removeDirectory

    end % methods

end % classdef
