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

            experiment = IOExp( ...
                fixture.Location.workbookFile("WT_ecoli.xlsx"), ...
                ExperimentRepository = repository);
            testCase.verifyFalse(isprop(experiment, "isError"));
            testCase.verifyFalse(isprop(experiment, "statusMsg"));

            clear cleanup

        end

        function readWorkbookSheetReturnsTable(testCase)

            repository = openmebius.infrastructure.experiment.ExperimentRepository();

            msTable = repository.readWorkbookSheet( ...
                ExperimentRepositoryTest.datasetWorkbook(), ...
                "MS", ...
                CheckVariable = false);

            testCase.verifyTrue(istable(msTable));
            testCase.verifyGreaterThan(width(msTable), 0);

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

        function writeWorkbookSheetCanBeReadBack(testCase)

            experimentDirectory = string(tempname);
            mkdir(experimentDirectory);
            cleanup = onCleanup(@() ...
                ExperimentRepositoryTest.removeDirectory(experimentDirectory));

            repository = openmebius.infrastructure.experiment.ExperimentRepository();
            pathFile = fullfile(experimentDirectory, "saved.xlsx");
            sourceTable = table( ...
                [0.5; 1.0], ...
                ["A"; "B"], ...
                VariableNames = ["Uptake", "Label"]);

            [isSuccess, msg] = repository.writeWorkbookSheet( ...
                pathFile, ...
                sourceTable, ...
                "substrate", ...
                WriteRowNames = false);
            testCase.verifyTrue(isSuccess, msg);

            loaded = repository.readWorkbookSheet( ...
                pathFile, ...
                "substrate", ...
                ReadRowNames = false, ...
                RefVariableNames = ["Uptake", "Label"], ...
                RefTypes = ["double", "string"]);

            testCase.verifyEqual(loaded.Uptake, sourceTable.Uptake);
            testCase.verifyEqual(string(loaded.Label), sourceTable.Label);

            clear cleanup

        end

        function readOptionalWorkbookSheetUsesAliases(testCase)

            experimentDirectory = string(tempname);
            mkdir(experimentDirectory);
            cleanup = onCleanup(@() ...
                ExperimentRepositoryTest.removeDirectory(experimentDirectory));

            repository = openmebius.infrastructure.experiment.ExperimentRepository();
            pathFile = fullfile(experimentDirectory, "optional.xlsx");
            sourceTable = table( ...
                [0.1; 0.9], ...
                VariableNames = "M0");

            repository.writeWorkbookSheet( ...
                pathFile, ...
                sourceTable, ...
                "MS normalized data", ...
                WriteRowNames = false);

            loaded = repository.readOptionalWorkbookSheet( ...
                pathFile, ...
                "MS (Normalized)", ...
                ["MS normalized data", "MS normarized data"], ...
                ReadRowNames = false);

            testCase.verifyEqual(loaded.M0, sourceTable.M0);

            clear cleanup

        end

        function readWorkbookSheetRejectsMissingWorkbook(testCase)

            repository = openmebius.infrastructure.experiment.ExperimentRepository();

            testCase.verifyError( ...
                @() repository.readWorkbookSheet( ...
                fullfile(tempdir, "missing-openmebius-exp.xlsx"), ...
                "MS"), ...
                "OpenMebius2:ExperimentRepository:WorkbookNotFound");

        end

        function restoreDerivedDataMapsWorkbookTables(testCase)

            repository = openmebius.infrastructure.experiment ...
                .ExperimentRepository();
            workbook = struct( ...
                "tableMSNormalized", array2table( ...
                [0.8; 0.2], VariableNames = "A"), ...
                "tableMDV", table(), ...
                "tableMDVBiomass", array2table( ...
                [0.8; 0.2], VariableNames = "A"), ...
                "tableEnrichment", table( ...
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
