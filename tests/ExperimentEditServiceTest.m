classdef ExperimentEditServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end % addSourcePath

    end % methods

    methods (Test)

        function saveInfoPersistsInfoTable(testCase)

            fixture = ExperimentEditServiceTest.importFixture();
            cleanup = onCleanup(@() ExperimentEditServiceTest.removeDirectory(fixture.Directory));

            [infoTable, ~, ~] = ...
                ExperimentEditServiceTest.validExperimentTables( ...
                fixture.ImportResult.Experiments);

            service = openmebius.application.experiment.ExperimentEditService();

            result = service.saveInfo( ...
                fixture.ImportResult.Experiments.getModel(), ...
                fixture.ImportResult.Experiments, ...
                fixture.ImportResult.Batch, ...
                infoTable);

            testCase.verifyClass( ...
                result.Experiments, ...
                'openmebius.application.experiment.ExperimentSet');
            testCase.verifyClass( ...
                result.Batch, ...
                'openmebius.application.batch.BatchSession');
            testCase.verifyTrue(any(contains(result.Messages, "saved successfully")));

            reloaded = openmebius.application.experiment ...
                .ExperimentSet( ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                fixture.Directory), ...
                fixture.ImportResult.Experiments.getModel());
            cleanupReloaded = onCleanup(@() delete(reloaded));

            savedInfo = reloaded.getInfoTable();
            testCase.verifyEqual(savedInfo{1, "mu"}, 0.634525729817483, ...
                "AbsTol", 1e-12);

        end % saveInfoPersistsInfoTable

        function saveTracerPersistsTracerTables(testCase)

            fixture = ExperimentEditServiceTest.importFixture();
            cleanup = onCleanup(@() ExperimentEditServiceTest.removeDirectory(fixture.Directory));

            [~, uptakeTable, tracerTable] = ...
                ExperimentEditServiceTest.validExperimentTables( ...
                fixture.ImportResult.Experiments);

            service = openmebius.application.experiment.ExperimentEditService();

            result = service.saveTracer( ...
                fixture.ImportResult.Experiments.getModel(), ...
                fixture.ImportResult.Experiments, ...
                fixture.ImportResult.Batch, ...
                uptakeTable, ...
                tracerTable);

            testCase.verifyClass( ...
                result.Experiments, ...
                'openmebius.application.experiment.ExperimentSet');
            testCase.verifyClass( ...
                result.Batch, ...
                'openmebius.application.batch.BatchSession');
            testCase.verifyTrue(any(contains(result.Messages, "Tracer table updated.")));

            reloaded = openmebius.application.experiment ...
                .ExperimentSet( ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                fixture.Directory), ...
                fixture.ImportResult.Experiments.getModel());
            cleanupReloaded = onCleanup(@() delete(reloaded));

            savedTracer = reloaded.getTracerTable();
            savedUptake = reloaded.getUptakeTable();

            testCase.verifyEqual(savedTracer{1, 1}, "12C2~1");
            testCase.verifyEqual(savedUptake{1, 1}, 3.6405030802424, ...
                "AbsTol", 1e-12);

        end % saveTracerPersistsTracerTables

        function invalidInfoTableRaisesUpdateError(testCase)

            fixture = ExperimentEditServiceTest.importFixture();
            cleanup = onCleanup(@() ExperimentEditServiceTest.removeDirectory(fixture.Directory));

            service = openmebius.application.experiment.ExperimentEditService();

            testCase.verifyError( ...
                @() service.saveInfo( ...
                fixture.ImportResult.Experiments.getModel(), ...
                fixture.ImportResult.Experiments, ...
                fixture.ImportResult.Batch, ...
                table()), ...
                "OpenMebius2:ExperimentEdit:UpdateFailed");

        end % invalidInfoTableRaisesUpdateError

        function copyTracerToAllEntriesUpdatesTracerTable(testCase)

            fixture = ExperimentEditServiceTest.importFixture();
            cleanup = onCleanup(@() ExperimentEditServiceTest.removeDirectory(fixture.Directory));

            [~, ~, tracerTable] = ...
                ExperimentEditServiceTest.validExperimentTables( ...
                fixture.ImportResult.Experiments);
            tracerTable{1, 2} = "12C1~0.5;13C1~0.5";

            service = openmebius.application.experiment.ExperimentEditService();

            result = service.copyTracerToAllEntries( ...
                fixture.ImportResult.Experiments.getModel(), ...
                fixture.ImportResult.Experiments, ...
                fixture.ImportResult.Batch, ...
                tracerTable, ...
                [1, 2]);

            testCase.verifyEqual( ...
                result.UpdatedTable{1, 2}, ...
                "12C1~0.5;13C1~0.5");
            updatedTracer = result.Experiments.getTracerTable();
            testCase.verifyEqual( ...
                updatedTracer{1, 2}, ...
                "12C1~0.5;13C1~0.5");
            testCase.verifyTrue(any(contains( ...
                result.Messages, ...
                "Selected tracer copied to all entries.")));

        end % copyTracerToAllEntriesUpdatesTracerTable

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
