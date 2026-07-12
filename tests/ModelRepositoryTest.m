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
