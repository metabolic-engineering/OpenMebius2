classdef BatchJsonRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end % addSourcePath

    end % methods

    methods (Test)

        function migratesLegacyArrayToCurrentSchema(testCase)

            legacyData = testCase.legacyBatchData();

            document = ...
                openmebius.infrastructure.batch.BatchJsonMigration.toCurrentDocument( ...
                legacyData);

            testCase.verifyEqual( ...
                document.schemaVersion, ...
                openmebius.infrastructure.batch.BatchJsonMigration.currentSchemaVersion());
            testCase.verifyTrue(isfield(document, 'batches'));
            testCase.verifyEqual(numel(document.batches), 1);
            testCase.verifyEqual(document.batches.id, "batch-id-1");
            testCase.verifyTrue(isfield(document.batches, 'contentHash'));
            testCase.verifyEqual(string(document.batches.contentHash), "");

            batchTable = ...
                openmebius.infrastructure.batch.BatchJsonMapper.toTable( ...
                legacyData);

            testCase.verifyTrue(istable(batchTable));
            testCase.verifyEqual(height(batchTable), 1);
            testCase.verifyEqual(batchTable.id, "batch-id-1");
            testCase.verifyEqual(batchTable.name, "Δ batch 1");
            testCase.verifyEqual(batchTable.contentHash, "");
            testCase.verifyEqual(batchTable.config.iteration, 7);
            testCase.verifyTrue(isfield(batchTable.config, 'fmincon'));
            testCase.verifyTrue(isfield(batchTable.config, 'INSTMFA'));
            testCase.verifyFalse(isfield(batchTable.config, 'random'));

        end % migratesLegacyArrayToCurrentSchema

        function rejectsUnsupportedSchemaVersion(testCase)

            unsupportedDocument = struct( ...
                'schemaVersion', ...
                openmebius.infrastructure.batch.BatchJsonMigration.currentSchemaVersion() + 1, ...
                'batches', ...
                []);

            testCase.verifyError( ...
                @() openmebius.infrastructure.batch.BatchJsonMapper.toTable( ...
                unsupportedDocument), ...
                'OpenMebius2:BatchJsonMigration:UnsupportedSchemaVersion');

        end % rejectsUnsupportedSchemaVersion

        function savesSchemaVersionedDocumentAtomically(testCase)

            [experimentLocation, cleanupGuard] = ...
                testCase.createExperimentLocation();
            testCase.verifyClass(cleanupGuard, 'onCleanup');

            repository = openmebius.infrastructure.batch.BatchJsonRepository();
            batchTable = ...
                openmebius.infrastructure.batch.BatchJsonMapper.toTable( ...
                testCase.legacyBatchData());
            batchTable.contentHash = "sha256:test-content";

            repository.save(experimentLocation, "batch.json", batchTable);

            batchFile = experimentLocation.batchFile("batch.json");
            savedDocument = jsondecode(fileread(batchFile));

            testCase.verifyTrue(isfield(savedDocument, 'schemaVersion'));
            testCase.verifyTrue(isfield(savedDocument, 'batches'));
            testCase.verifyTrue(isfield(savedDocument.batches, 'contentHash'));
            testCase.verifyEqual( ...
                savedDocument.schemaVersion, ...
                openmebius.infrastructure.batch.BatchJsonMigration.currentSchemaVersion());

            listing = dir(experimentLocation.Directory);
            fileNames = string({listing(~[listing.isdir]).name});
            testCase.verifyEqual(fileNames, "batch.json");

            [loadedTable, isError, msg] = repository.load( ...
                experimentLocation, ...
                "batch.json", ...
                batchTable.Properties.VariableNames);

            testCase.verifyFalse(isError, string(msg));
            testCase.verifyEqual(loadedTable.id, batchTable.id);
            testCase.verifyEqual(loadedTable.name, batchTable.name);
            testCase.verifyEqual( ...
                loadedTable.contentHash, ...
                batchTable.contentHash);
            testCase.verifyEqual( ...
                loadedTable.config.iteration, ...
                batchTable.config.iteration);
            testCase.verifyTrue(isfield(loadedTable.config, 'INSTMFA'));

        end % savesSchemaVersionedDocumentAtomically

        function preservesSingleMSExperimentAcrossJsonRoundTrip(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.isSelectMSFragment = true;
            config.MS.fragment = 'custom';
            config.MS.fragmentList = ["fragment-a"; "fragment-b"];
            config.MS.expList = "WT_ecoli";
            config.MS.customFragment = [true; false];
            batchData = struct( ...
                'id', "batch-id-1", ...
                'name', "batch-name-1", ...
                'exp', "WT_ecoli", ...
                'description', "MS JSON round-trip test", ...
                'config', config);
            decoded = jsondecode(jsonencode(batchData));

            batchTable = ...
                openmebius.infrastructure.batch.BatchJsonMapper.toTable( ...
                decoded);
            actual = batchTable.config.MS;

            testCase.verifyEqual(actual.expList, "WT_ecoli");
            testCase.verifyEqual( ...
                actual.fragmentList, ["fragment-a"; "fragment-b"]);
            testCase.verifyEqual(actual.customFragment, [true; false]);

        end % preservesSingleMSExperimentAcrossJsonRoundTrip

        function returnsEmptyTableWhenBatchFileIsMissing(testCase)

            [experimentLocation, cleanupGuard] = ...
                testCase.createExperimentLocation();
            testCase.verifyClass(cleanupGuard, 'onCleanup');

            repository = openmebius.infrastructure.batch.BatchJsonRepository();

            [batchTable, isError, msg] = repository.load( ...
                experimentLocation, ...
                "missing_batch.json");

            testCase.verifyTrue(isError);
            testCase.verifyTrue(contains(msg, "does not exist"));
            testCase.verifyTrue(istable(batchTable));
            testCase.verifyEqual(height(batchTable), 0);
            testCase.verifyEqual( ...
                batchTable.Properties.VariableNames, ...
                openmebius.infrastructure.batch.BatchJsonMapper.defaultVariableNames());

        end % returnsEmptyTableWhenBatchFileIsMissing

        function returnsEmptyTableWhenBatchFileIsInvalidJson(testCase)

            [experimentLocation, cleanupGuard] = ...
                testCase.createExperimentLocation();
            testCase.verifyClass(cleanupGuard, 'onCleanup');

            batchFile = experimentLocation.batchFile("batch.json");
            testCase.writeText(batchFile, "{ invalid json");

            repository = openmebius.infrastructure.batch.BatchJsonRepository();

            [batchTable, isError, msg] = repository.load( ...
                experimentLocation, ...
                "batch.json");

            testCase.verifyTrue(isError);
            testCase.verifyTrue(contains(msg, "not a valid JSON file"));
            testCase.verifyTrue(istable(batchTable));
            testCase.verifyEqual(height(batchTable), 0);

        end % returnsEmptyTableWhenBatchFileIsInvalidJson

    end % methods

    methods (Static, Access = private)

        function batchData = legacyBatchData()

            batchData = struct( ...
                'id', "batch-id-1", ...
                'name', "Δ batch 1", ...
                'exp', "Δ exp 1", ...
                'description', "migration test", ...
                'config', struct('iteration', 7, 'random', 0.1234));

        end % legacyBatchData

        function [experimentLocation, cleanup] = createExperimentLocation()

            tempDirectory = string(tempname);
            mkdir(tempDirectory);
            cleanup = onCleanup(@() rmdir(tempDirectory, 's'));

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation.fromInput( ...
                tempDirectory);

        end % createExperimentLocation

        function writeText(pathFile, text)

            fid = fopen(pathFile, 'w');

            if fid < 0
                error("BatchJsonRepositoryTest:OpenFailed", ...
                    "Failed to open test file: %s", pathFile);
            end

            cleanup = onCleanup(@() fclose(fid));
            fwrite(fid, char(text));
            clear cleanup

        end % writeText

    end % methods

end % classdef
