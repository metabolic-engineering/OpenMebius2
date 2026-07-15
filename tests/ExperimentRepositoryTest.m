classdef ExperimentRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(ExperimentRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function loadCreatesExperimentCollection(testCase)

            fixture = ExperimentRepositoryTest.createExperimentFixture();
            cleanup = onCleanup(@() ...
                ExperimentRepositoryTest.removeDirectory(fixture.Directory));

            repository = openmebius.infrastructure.experiment.ExperimentRepository();
            model = openmebius.infrastructure.model.ModelRepository().load( ...
                ExperimentRepositoryTest.templateModelLocation());

            experiments = repository.load(fixture.Location, model);

            testCase.verifyClass(experiments, "IOExps");
            testCase.verifyEqual(experiments.numFile, 1);
            testCase.verifyFalse(isprop(experiments, "isError"));
            testCase.verifyFalse(isprop(experiments, "statusMsg"));

            collection = experiments.getCollection();
            testCase.verifyClass( ...
                collection, ...
                "openmebius.domain.experiment.ExperimentCollection");
            testCase.verifyEqual( ...
                collection.FileNames, experiments.fileExpList);
            testCase.verifyEqual( ...
                collection.TracerTable, experiments.tableTracersInfo);

            invalidReport = experiments.updateExpData(table(), "Info");

            testCase.verifyClass( ...
                invalidReport, ...
                "openmebius.domain.experiment.ExperimentValidationReport");
            testCase.verifyFalse(invalidReport.IsValid);
            testCase.verifyNotEmpty(invalidReport.ErrorMessage);

            validReport = experiments.updateExpData( ...
                experiments.getInfoTable(), ...
                "Info");

            testCase.verifyTrue(validReport.IsValid);

            workbook = repository.loadWorkbook( ...
                fixture.Location.workbookFile("WT_ecoli.xlsx"));
            testCase.verifyClass( ...
                workbook, ...
                "openmebius.infrastructure.experiment." + ...
                "ExperimentWorkbookData");
            testCase.verifyGreaterThan(width(workbook.MS), 0);

            clear cleanup

        end

        function loadRejectsMissingExperimentDirectory(testCase)

            repository = ...
                openmebius.infrastructure.experiment.ExperimentRepository();
            location = openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory(fullfile( ...
                tempdir, ...
                "missing-openmebius-experiment-repository"));

            testCase.verifyError( ...
                @() repository.load(location, []), ...
                "OpenMebius2:ExperimentRepository:DirectoryNotFound");

        end

        function restoreDerivedDataMapsWorkbookTables(testCase)

            repository = openmebius.infrastructure.experiment ...
                .ExperimentRepository();
            workbook = openmebius.infrastructure.experiment ...
                .ExperimentWorkbookData( ...
                MSNormalized = array2table( ...
                [0.8; 0.2], VariableNames = "A"), ...
                MDVBiomass = array2table( ...
                [0.8; 0.2], VariableNames = "A"), ...
                Enrichment = table( ...
                0.2, VariableNames = "Enrichment", RowNames = "A"));
            model = helpers.StoredDerivedDataModelStub( ...
                table( ...
                true, ...
                VariableNames = "Used", ...
                RowNames = "A"), ...
                "A");

            result = repository.restoreDerivedData(workbook, model);

            testCase.verifyClass( ...
                result, ...
                "openmebius.domain.experiment." + ...
                "StoredExperimentDerivedData");
            testCase.verifyEqual( ...
                result.MSNormalized.A, ...
                [0.8; 0.2]);
            testCase.verifyEqual(result.Selection.Available, true);

        end

    end

    methods (Static, Access = private)

        function fixture = createExperimentFixture()

            experimentDirectory = string(tempname);
            mkdir(experimentDirectory);

            sourceFile = ExperimentRepositoryTest.datasetWorkbook();
            copyfile(sourceFile, fullfile(experimentDirectory, "WT_ecoli.xlsx"));

            fixture = struct( ...
                "Directory", experimentDirectory, ...
                "Location", ...
                openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory(experimentDirectory));

        end

        function path = datasetWorkbook()

            path = fullfile( ...
                ExperimentRepositoryTest.repositoryRoot(), ...
                "dataset", ...
                "WT_ecoli.xlsx");

        end

        function modelLocation = templateModelLocation()

            modelLocation = openmebius.domain.model.ModelLocation ...
                .fromDirectory( ...
                fullfile( ...
                ExperimentRepositoryTest.repositoryRoot(), ...
                "model", ...
                "Escherichia coli"));

        end

        function path = sourcePath()

            path = fullfile(ExperimentRepositoryTest.repositoryRoot(), "src");

        end

        function path = repositoryRoot()

            path = fileparts(fileparts(mfilename("fullpath")));

        end

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, "s");
            end

        end

    end

end
