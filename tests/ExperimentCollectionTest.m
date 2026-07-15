classdef ExperimentCollectionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ExperimentCollectionTest.sourcePath());

        end

    end

    methods (Test)

        function ownsFileIdentityAndDerivedNames(testCase)

            location = openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory("experiment-root");
            collection = openmebius.domain.experiment ...
                .ExperimentCollection(location);

            collection.replaceFiles( ...
                ["WT ecoli.xlsx", "13C-test.xlsx"]);

            testCase.verifyEqual(collection.Location, location);
            testCase.verifyEqual( ...
                collection.FileNames, ...
                ["WT ecoli.xlsx", "13C-test.xlsx"]);
            testCase.verifyEqual(collection.Count, 2);
            testCase.verifyEqual( ...
                collection.FileBaseNames, ...
                ["WT ecoli", "13C-test"]);
            testCase.verifyEqual( ...
                collection.FieldNames, ...
                matlab.lang.makeValidName(collection.FileNames));

        end

        function ownsModelAndAggregateTables(testCase)

            collection = ExperimentCollectionTest.createCollection();
            atomTable = table( ...
                int8([1; 2]), ...
                VariableNames = "C", ...
                RowNames = ["A"; "B"]);
            model = struct("tableAtom", atomTable);
            infoTable = table( ...
                0.1, 0.2, 0.8, ...
                VariableNames = ["mu", "ODi", "ODf"]);
            tracerTable = table(1, VariableNames = "glc");
            fullTracerTable = table( ...
                [1; 0], VariableNames = "glc");

            collection.replaceModel(model, "model.xlsx");
            collection.replaceInfoTable(infoTable);
            collection.replaceTracerTables( ...
                tracerTable, fullTracerTable);

            testCase.verifyEqual(collection.Model, model);
            testCase.verifyEqual(collection.ModelPath, "model.xlsx");
            testCase.verifyEqual(collection.AtomTable, atomTable);
            testCase.verifyEqual(collection.InfoTable, infoTable);
            testCase.verifyEqual(collection.TracerTable, tracerTable);
            testCase.verifyEqual( ...
                collection.TracerTableFull, fullTracerTable);

        end

        function validatesDefaultSubstrateMetadata(testCase)

            collection = ExperimentCollectionTest.createCollection();

            collection.replaceDefaultSubstrateMetadata( ...
                ["Uptake", "Label"], ...
                ["double", "string"]);

            testCase.verifyEqual( ...
                collection.DefaultSubstrateVariableNames, ...
                ["Uptake", "Label"]);
            testCase.verifyError( ...
                @() collection.replaceDefaultSubstrateMetadata( ...
                ["Uptake", "Label"], "double"), ...
                "OpenMebius2:ExperimentCollection:" + ...
                "DefaultVariableCountMismatch");

        end

    end

    methods (Static, Access = private)

        function collection = createCollection()

            location = openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory("experiment-root");
            collection = openmebius.domain.experiment ...
                .ExperimentCollection(location);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename("fullpath"))), ...
                "src");

        end

    end

end % classdef
