classdef BatchCollectionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(BatchCollectionTest.sourcePath());

        end

    end

    methods (Test)

        function addsNormalizesAndReadsEntries(testCase)

            collection = BatchCollectionTest.emptyCollection();
            firstId = collection.add( ...
                "Batch A", ...
                {["exp-a"; "exp-b"]}, ...
                "first", ...
                struct('iteration', 7));
            secondId = collection.add( ...
                "Batch B", ...
                {"exp-c"}, ...
                "second", ...
                openmebius.domain.batch.BatchConfig.defaultConfig());

            batchTable = collection.toTable();
            testCase.verifyMatches(firstId, "^bat_[0-9a-f]{32}$");
            testCase.verifyNotEqual(firstId, secondId);
            testCase.verifyEqual(height(batchTable), 2);
            testCase.verifyEqual(collection.configFor(firstId).iteration, 7);
            testCase.verifyEqual( ...
                collection.experimentsFor([firstId; secondId]), ...
                ["exp-a"; "exp-b"; "exp-c"]);
            testCase.verifyTrue( ...
                isfield(collection.configFor(firstId), 'INSTMFA'));

        end

        function editsConfigAndStatusesByStableId(testCase)

            collection = BatchCollectionTest.emptyCollection();
            id = collection.add( ...
                "Before", ...
                {"exp-a"}, ...
                "before", ...
                openmebius.domain.batch.BatchConfig.defaultConfig());
            config = collection.configFor(id);
            config.iteration = 12;

            collection.edit( ...
                id, "After", {"exp-b"}, "after", config);
            collection.setStatus(id, "finished");

            batchTable = collection.toTable();
            testCase.verifyEqual(batchTable.name, "After");
            testCase.verifyEqual(batchTable.exp{1}, "exp-b");
            testCase.verifyEqual(batchTable.description, "after");
            testCase.verifyEqual(collection.configFor(id).iteration, 12);
            testCase.verifyEqual(collection.statusesFor(id), "finished");
            testCase.verifyEqual(collection.finishedIds(), id);

        end

        function replacesConfigForMultipleEntries(testCase)

            collection = BatchCollectionTest.emptyCollection();
            firstId = BatchCollectionTest.addDefault(collection, "A");
            secondId = BatchCollectionTest.addDefault(collection, "B");

            collection.replaceConfigs( ...
                [firstId; secondId], struct('iteration', 9));

            testCase.verifyEqual( ...
                collection.configFor(firstId).iteration, 9);
            testCase.verifyEqual( ...
                collection.configFor(secondId).iteration, 9);

        end

        function replacesSingleConfigByStableId(testCase)

            collection = BatchCollectionTest.emptyCollection();
            id = BatchCollectionTest.addDefault(collection, "A");

            collection.replaceConfig(id, struct('iteration', 11));

            testCase.verifyEqual(collection.configFor(id).iteration, 11);

        end

        function configReplacementPreservesTerminalStatuses(testCase)

            collection = BatchCollectionTest.emptyCollection();
            finishedId = BatchCollectionTest.addDefault(collection, "Done");
            failedId = BatchCollectionTest.addDefault(collection, "Failed");
            readyId = BatchCollectionTest.addDefault(collection, "Ready");
            collection.setStatus(finishedId, "finished");
            collection.setStatus(failedId, "error");
            replacement = ...
                openmebius.domain.batch.BatchConfig.defaultConfig();
            replacement.iteration = 99;

            collection.replaceConfigs( ...
                [finishedId; failedId; readyId], replacement);

            testCase.verifyEqual( ...
                collection.statusesFor( ...
                [finishedId; failedId; readyId]), ...
                ["finished"; "error"; "ready"]);
            testCase.verifyEqual( ...
                collection.configFor(finishedId).iteration, 99);
            testCase.verifyEqual( ...
                collection.configFor(failedId).iteration, 99);

        end

        function removeAndClearPreserveTerminalEntries(testCase)

            collection = BatchCollectionTest.emptyCollection();
            finishedId = BatchCollectionTest.addDefault(collection, "Done");
            failedId = BatchCollectionTest.addDefault(collection, "Failed");
            readyId = BatchCollectionTest.addDefault(collection, "Ready");
            collection.setStatus(finishedId, "finished");
            collection.setStatus(failedId, "error");

            [removedFinished, finishedReason] = ...
                collection.remove(finishedId);
            [removedReady, readyReason] = collection.remove(readyId);

            testCase.verifyFalse(removedFinished);
            testCase.verifyEqual(finishedReason, "finished");
            testCase.verifyTrue(removedReady);
            testCase.verifyEqual(readyReason, "");
            BatchCollectionTest.addDefault(collection, "Another ready");
            collection.clearUnfinished();
            testCase.verifyEqual( ...
                collection.toTable().id, [finishedId; failedId]);

        end

        function unknownStatusLookupRemainsNonThrowing(testCase)

            collection = BatchCollectionTest.emptyCollection();

            testCase.verifyEqual( ...
                collection.statusesFor("missing"), "unknown");
            testCase.verifyError( ...
                @() collection.configFor("missing"), ...
            "OpenMebius2:BatchCollection:BatchNotFound");
            testCase.verifyError( ...
                @() collection.experimentsFor("missing"), ...
            "OpenMebius2:BatchCollection:BatchNotFound");

        end

        function rejectsInvalidTableSchema(testCase)

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchCollection(table), ...
            "OpenMebius2:BatchCollection:InvalidSchema");

        end

    end

    methods (Static, Access = private)

        function collection = emptyCollection()

            collection = openmebius.domain.batch.BatchCollection( ...
                openmebius.infrastructure.batch.BatchJsonMapper.emptyTable());

        end

        function id = addDefault(collection, name)

            id = collection.add( ...
                string(name), ...
                {"exp-a"}, ...
                "", ...
                openmebius.domain.batch.BatchConfig.defaultConfig());

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
            'src');

        end

    end

end
