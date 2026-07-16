classdef ModelRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(ModelRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function loadCreatesEmuModel(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();
            modelLocation = ModelRepositoryTest.templateModelLocation();

            model = repository.load(modelLocation);

            testCase.verifyClass(model, "EMUModel");
            testCase.verifyTrue(isa( ...
                model, ...
                "openmebius.application.model.ModelWorkspace"));
            testCase.verifyEqual( ...
                model.getModelLocation().Directory, ...
                modelLocation.Directory);

        end

        function readModelSheetReturnsValidatedTable(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();

            tableInfo = repository.readModelSheet( ...
                ModelRepositoryTest.templateModelLocation(), ...
                "metabolic_network", ...
                "xlsx", ...
                "info", ...
                ReadRowNames = false, ...
                RefVariableNames = ["Information", "Value"], ...
                RefTypes = ["cell", "cell"]);

            testCase.verifyEqual( ...
                string(tableInfo.Properties.VariableNames), ...
                ["Information", "Value"]);
            testCase.verifyGreaterThan(height(tableInfo), 0);

        end

        function loadedModelExposesAlignedConstraintTypes(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();
            model = repository.load( ...
                ModelRepositoryTest.templateModelLocation());
            constraintTypes = string(model.getConstraintTypes());
            systemTypes = string(model.getSType());

            testCase.verifyEqual( ...
                numel(constraintTypes), height(model.getSBefore()));
            testCase.verifyEqual( ...
                numel(systemTypes), height(model.getS()));
            testCase.verifyEqual( ...
                constraintTypes(:), ...
                systemTypes(1:numel(constraintTypes)));

        end

        function loadRejectsMissingModelDirectory(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();
            modelLocation = openmebius.domain.model.ModelLocation ...
                .fromDirectory(fullfile(tempdir, "missing-openmebius-model-repo"));

            testCase.verifyError( ...
                @() repository.load(modelLocation), ...
                "OpenMebius2:ModelRepository:DirectoryNotFound");

        end

        function loadPreservesTypedWorkbookFailure(testCase)

            modelDirectory = string(tempname);
            mkdir(modelDirectory);
            cleanup = onCleanup(@() ...
                ModelRepositoryTest.removeDirectory(modelDirectory));
            repository = openmebius.infrastructure.model.ModelRepository();
            modelLocation = openmebius.domain.model.ModelLocation ...
                .fromDirectory(modelDirectory);

            testCase.verifyError( ...
                @() repository.load(modelLocation), ...
                "OpenMebius2:ModelRepository:ModelFileNotFound");

            clear cleanup

        end

        function labelRoundTripUsesRepositoryJsonStore(testCase)

            modelDirectory = string(tempname);
            mkdir(modelDirectory);
            cleanup = onCleanup(@() ...
                ModelRepositoryTest.removeDirectory(modelDirectory));

            repository = openmebius.infrastructure.model.ModelRepository();
            modelLocation = ...
                openmebius.domain.model.ModelLocation.fromDirectory( ...
                modelDirectory);
            label = struct( ...
                "Glucose", ...
                struct("name", "Glucose", "num", 6));

            repository.writeLabel(modelLocation, "label", "json", label);
            loaded = repository.readLabel(modelLocation, "label", "json");

            testCase.verifyEqual(string(loaded.Glucose.name), "Glucose");
            testCase.verifyEqual(loaded.Glucose.num, 6);

        end

        function hashModelFileMatchesGenericHash(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();
            modelLocation = ModelRepositoryTest.templateModelLocation();
            modelFile = modelLocation.modelFile("metabolic_network", "xlsx");

            modelHash = repository.hashModelFile( ...
                modelLocation, ...
                "metabolic_network", ...
                "xlsx");
            genericHash = repository.hashFile(modelFile);

            testCase.verifyNotEmpty(modelHash);
            testCase.verifyEqual(modelHash, genericHash);

        end

        function readModelSheetRejectsUnsupportedFileType(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();

            testCase.verifyError( ...
                @() repository.readModelSheet( ...
                ModelRepositoryTest.templateModelLocation(), ...
                "metabolic_network", ...
                "csv", ...
                "info"), ...
                "OpenMebius2:ModelRepository:UnsupportedModelFileType");

        end

        function modelEditingUsesValidationReport(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();
            model = repository.load( ...
                ModelRepositoryTest.templateModelLocation());

            testCase.verifyFalse(isprop(model, "isError"));
            testCase.verifyFalse(isprop(model, "statusMsg"));

            invalidReport = model.updateModelTableGUI(table());

            testCase.verifyClass( ...
                invalidReport, ...
                "openmebius.domain.model.ModelValidationReport");
            testCase.verifyFalse(invalidReport.IsValid);
            testCase.verifyNotEmpty(invalidReport.ErrorMessage);
            testCase.verifyEmpty(invalidReport.InvalidRows);

            validReport = model.updateModelTableGUI( ...
                model.getModelTableGUI());

            testCase.verifyTrue(validReport.IsValid);
            testCase.verifyNotEmpty(validReport.Messages);

        end

    end

    methods (Static, Access = private)

        function modelLocation = templateModelLocation()

            modelLocation = openmebius.domain.model.ModelLocation ...
                .fromDirectory(ModelRepositoryTest.templateModelDirectory());

        end

        function path = templateModelDirectory()

            path = fullfile( ...
                ModelRepositoryTest.repositoryRoot(), ...
                "tutorial", ...
                "ecoli", ...
                "model");

        end

        function path = sourcePath()

            path = fullfile(ModelRepositoryTest.repositoryRoot(), "src");

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
