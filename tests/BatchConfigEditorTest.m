classdef BatchConfigEditorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(BatchConfigEditorTest.sourcePath());

        end

    end

    methods (Test)

        function appliesDefaultAndCustomMSFragmentSelections(testCase)

            collection = BatchConfigEditorTest.emptyCollection();
            defaultId = BatchConfigEditorTest.addDefault( ...
                collection, "Default");
            customId = BatchConfigEditorTest.addDefault( ...
                collection, "Custom");
            editor = openmebius.domain.batch.BatchConfigEditor(collection);
            selections = [ ...
                BatchConfigEditorTest.msSelection( ...
                defaultId, [true; false]), ...
                BatchConfigEditorTest.msSelection( ...
                customId, [false; true])];

            ids = editor.applyMSFragmentSelections( ...
                selections, ["M+0"; "M+1"], [true; false]);

            defaultConfig = collection.configFor(defaultId);
            customConfig = collection.configFor(customId);
            testCase.verifyEqual(ids, [defaultId, customId]);
            testCase.verifyFalse(defaultConfig.isSelectMSFragment);
            testCase.verifyEqual(defaultConfig.MS.fragment, 'all');
            testCase.verifyTrue(customConfig.isSelectMSFragment);
            testCase.verifyEqual(customConfig.MS.fragment, 'custom');
            testCase.verifyEqual( ...
                customConfig.MS.customFragment, [false; true]);
            testCase.verifyEqual( ...
                customConfig.MS.fragmentList, ["M+0"; "M+1"]);
            testCase.verifyEqual(customConfig.MS.expList, "exp-a");

        end

        function rejectsInvalidMSFragmentDimensions(testCase)

            collection = BatchConfigEditorTest.emptyCollection();
            id = BatchConfigEditorTest.addDefault(collection, "Batch");
            editor = openmebius.domain.batch.BatchConfigEditor(collection);
            selection = BatchConfigEditorTest.msSelection( ...
                id, [true, false]);

            testCase.verifyError( ...
                @() editor.applyMSFragmentSelections( ...
                selection, ["M+0"; "M+1"], [true; false]), ...
                ['OpenMebius2:BatchConfigEditor:' ...
                'InvalidMSFragmentSelection']);

        end

        function mergesAndSortsEffluxConfiguration(testCase)

            collection = BatchConfigEditorTest.emptyCollection();
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.efflux.selection = [true; false];
            config.efflux.substrate = ["B"; "A"];
            config.efflux.substrateSD = [2; NaN];
            id = collection.add( ...
                "Batch", {"exp-a"}, "", config);
            editor = openmebius.domain.batch.BatchConfigEditor(collection);

            editor.applyEfflux( ...
                id, [false; true], ["B"; "C"], [20; NaN]);

            updated = collection.configFor(id).efflux;
            testCase.verifyEqual(updated.substrate, ["A"; "B"; "C"]);
            testCase.verifyEqual( ...
                updated.selection, [false; false; true]);
            testCase.verifyEqual( ...
                updated.substrateSD, [NaN; 20; NaN]);

        end

        function appliesSuggestionValuesAndLabels(testCase)

            collection = BatchConfigEditorTest.emptyCollection();
            id = BatchConfigEditorTest.addDefault(collection, "Batch");
            editor = openmebius.domain.batch.BatchConfigEditor(collection);
            values = ["A", "B"; "C", "D"];

            editor.applySuggestion( ...
                id, values, ["first"; "second"], ["T1", "T2"]);

            config = collection.configFor(id);
            testCase.verifyEqual(config.suggestionTable, values);
            testCase.verifyEqual( ...
                config.suggestionTableRowNames, ["first"; "second"]);
            testCase.verifyEqual( ...
                config.suggestionTableVarNames, ["T1", "T2"]);

        end

    end

    methods (Static, Access = private)

        function selection = msSelection(id, values)

            selection = struct( ...
                'BatchID', id, ...
                'ExperimentNames', "exp-a", ...
                'FragmentNames', ["M+0"; "M+1"], ...
                'Selection', values);

        end

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
