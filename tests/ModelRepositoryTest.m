classdef ModelRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(ModelRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function loadCreatesMetabolicModel(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();
            modelLocation = ModelRepositoryTest.templateModelLocation();

            model = repository.load(modelLocation);

            testCase.verifyClass( ...
                model, ...
                "openmebius.application.model.MetabolicModel");
            testCase.verifyEqual( ...
                model.getModelLocation().Directory, ...
                modelLocation.Directory);

        end

        function loadedModelExposesEmuNetworkSnapshot(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();
            model = repository.load( ...
                ModelRepositoryTest.templateModelLocation());

            snapshot = model.getEMUNetworkSnapshot();

            testCase.verifyClass( ...
                snapshot, ...
                "openmebius.domain.model.EMUNetworkSnapshot");
            testCase.verifyNotEmpty(snapshot.TableEMU);
            testCase.verifyNotEmpty(snapshot.TableEMUReaction);

        end

        function loadedModelExposesPathwayData(testCase)

            repository = openmebius.infrastructure.model.ModelRepository();
            model = repository.load( ...
                ModelRepositoryTest.templateModelLocation());

            pathway = model.getPathwayData();

            testCase.verifyClass( ...
                pathway, ...
                "openmebius.application.model.ModelPathwayData");
            testCase.verifyNotEmpty(pathway.Image);
            testCase.verifyNotEmpty(pathway.ReactionIDs);
            testCase.verifyEqual( ...
                numel(pathway.ReactionIDs), numel(pathway.X));
            testCase.verifyEqual( ...
                numel(pathway.ReactionIDs), numel(pathway.Y));

            reactionID = pathway.ReactionIDs(1);
            model.updatePathwayLabelPosition( ...
                reactionID, [12.5 4.25]);
            updated = model.getPathwayData();
            updatedRow = find(updated.ReactionIDs == reactionID, 1);

            testCase.verifyEqual(updated.X(updatedRow), 12.5);
            testCase.verifyEqual(updated.Y(updatedRow), 4.25);

            model.updatePathwayLabelPosition( ...
                reactionID, [nan nan]);
            removed = model.getPathwayData();
            removedRow = find(removed.ReactionIDs == reactionID, 1);

            testCase.verifyTrue(isnan(removed.X(removedRow)));
            testCase.verifyTrue(isnan(removed.Y(removedRow)));

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

            temporaryRoot = string(tempname);
            mkdir(temporaryRoot);
            cleanup = onCleanup(@() ...
                ModelRepositoryTest.removeDirectory(temporaryRoot));
            modelDirectory = fullfile(temporaryRoot, "model");
            [wasCopied, copyMessage] = copyfile( ...
                ModelRepositoryTest.templateModelDirectory(), ...
                modelDirectory);
            testCase.assertTrue(wasCopied, copyMessage);
            repository = openmebius.infrastructure.model.ModelRepository();
            model = repository.load( ...
                openmebius.domain.model.ModelLocation ...
                .fromDirectory(modelDirectory));

            testCase.verifyFalse(isprop(model, "isError"));
            testCase.verifyFalse(isprop(model, "statusMsg"));

            invalidReport = model.updateModelTableGUI(table());

            testCase.verifyClass( ...
                invalidReport, ...
                "openmebius.domain.model.ModelValidationReport");
            testCase.verifyFalse(invalidReport.IsValid);
            testCase.verifyNotEmpty(invalidReport.ErrorMessage);
            testCase.verifyEmpty(invalidReport.InvalidRows);

            validTable = model.getModelTableGUI();
            validReport = model.updateModelTableGUI(validTable);

            testCase.verifyTrue(validReport.IsValid);
            testCase.verifyNotEmpty(validReport.Messages);

            clear cleanup

        end

        function validModelEditPersistsWorkbook(testCase)

            temporaryRoot = string(tempname);
            mkdir(temporaryRoot);
            cleanup = onCleanup(@() ...
                ModelRepositoryTest.removeDirectory(temporaryRoot));
            modelDirectory = fullfile(temporaryRoot, "model");
            [wasCopied, copyMessage] = copyfile( ...
                ModelRepositoryTest.templateModelDirectory(), ...
                modelDirectory);
            testCase.assertTrue(wasCopied, copyMessage);
            location = openmebius.domain.model.ModelLocation ...
                .fromDirectory(modelDirectory);
            repository = openmebius.infrastructure.model.ModelRepository();
            model = repository.load(location);
            editedTable = model.getModelTableGUI();
            expectedX = editedTable.x(1) + 1;
            editedTable.x(1) = expectedX;

            report = model.updateModelTableGUI(editedTable);

            testCase.assertTrue(report.IsValid, report.ErrorMessage);
            savedPosition = repository.readModelSheet( ...
                location, ...
                "metabolic_network", ...
                "xlsx", ...
                "position", ...
                RefVariableNames = ["x", "y"], ...
                RefTypes = ["double", "double"]);
            testCase.verifyEqual(savedPosition.x(1), expectedX);

            clear cleanup

        end


        function modelSaveReportsAllReactionValidationCategories(testCase)

            temporaryRoot = string(tempname);
            mkdir(temporaryRoot);
            cleanup = onCleanup(@() ...
                ModelRepositoryTest.removeDirectory(temporaryRoot));
            modelDirectory = fullfile(temporaryRoot, "model");
            [wasCopied, copyMessage] = copyfile( ...
                ModelRepositoryTest.templateModelDirectory(), ...
                modelDirectory);
            testCase.assertTrue(wasCopied, copyMessage);
            repository = openmebius.infrastructure.model.ModelRepository();
            model = repository.load( ...
                openmebius.domain.model.ModelLocation ...
                .fromDirectory(modelDirectory));
            validTable = model.getModelTableGUI();

            malformed = validTable;
            malformed.Reaction{1} = 'not a reaction';
            malformedReport = model.updateModelTableGUI(malformed);
            testCase.verifyFalse(malformedReport.IsValid);
            testCase.verifyTrue(any(malformedReport.InvalidRows == 1));
            testCase.verifySubstring( ...
                malformedReport.ErrorMessage, "Reaction format mismatch");

            componentMismatch = validTable;
            componentMismatch.Transition{1} = ...
                'ABCDEF --> ABCDEF + A';
            componentReport = model.updateModelTableGUI(componentMismatch);
            testCase.verifyFalse(componentReport.IsValid);
            testCase.verifyTrue(any(componentReport.InvalidRows == 1));
            testCase.verifySubstring( ...
                componentReport.ErrorMessage, ...
                "Reaction and Transition mismatch");

            carbonMismatch = validTable;
            carbonMismatch.Transition{2} = 'ABCDE <=> ABCDEF';
            carbonReport = model.updateModelTableGUI(carbonMismatch);
            testCase.verifyFalse(carbonReport.IsValid);
            testCase.verifyTrue(all(ismember([1; 2], ...
                carbonReport.InvalidRows)));
            testCase.verifySubstring( ...
                carbonReport.ErrorMessage, "Carbon count mismatch");

            reversibilityMismatch = validTable;
            reversibilityMismatch.Transition{2} = 'ABCDEF --> ABCDEF';
            reversibilityReport = ...
                model.updateModelTableGUI(reversibilityMismatch);
            testCase.verifyFalse(reversibilityReport.IsValid);
            testCase.verifyTrue(any( ...
                reversibilityReport.InvalidRows == 2));
            testCase.verifySubstring( ...
                reversibilityReport.ErrorMessage, ...
                "Reversibility mismatch");

            clear cleanup

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
