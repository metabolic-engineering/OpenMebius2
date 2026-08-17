classdef ExperimentComparisonServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function loadsComparisonCatalog(testCase)

            experiments = helpers.ExperimentComparisonWorkspaceStub( ...
                ExperimentComparisonServiceTest.collection());
            service = openmebius.application.experiment ...
                .ExperimentComparisonService();

            catalog = service.loadCatalog(experiments);

            testCase.verifyEqual( ...
                catalog.ExperimentNames, ["ExpA", "ExpB"]);
            testCase.verifyEqual(catalog.DataNames, ["A", "B"]);

        end

        function loadsSelectedBiomassComparison(testCase)

            experiments = helpers.ExperimentComparisonWorkspaceStub( ...
                ExperimentComparisonServiceTest.collection());
            service = openmebius.application.experiment ...
                .ExperimentComparisonService();

            selection = service.loadSelection( ...
                experiments, "ExpB", "Frag");

            testCase.verifyEqual(selection.ExperimentNames, "ExpB");
            testCase.verifyEqual(selection.DataNames, "Frag");
            testCase.verifyEqual( ...
                selection.Tables{1}{:, :}, [0.7; 0.3], ...
                AbsTol = 1e-12);
            testCase.verifyEqual( ...
                string(selection.Tables{1}.Properties.RowNames), ...
                ["M0"; "M1"]);

        end

        function rejectsUnknownExperiment(testCase)

            experiments = helpers.ExperimentComparisonWorkspaceStub( ...
                ExperimentComparisonServiceTest.collection());
            service = openmebius.application.experiment ...
                .ExperimentComparisonService();

            testCase.verifyError( ...
                @() service.loadSelection( ...
                experiments, "missing", "Frag"), ...
                "OpenMebius2:ExperimentComparison:UnknownExperiment");

        end

    end

    methods (Static, Access = private)

        function collection = collection()

            location = openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory("experiment-root");
            collection = openmebius.domain.experiment ...
                .ExperimentCollection(location);
            collection.replaceFiles(["ExpA.xlsx", "ExpB.xlsx"]);
            collection.replaceData(struct( ...
                "ExpA_xlsx", ...
                ExperimentComparisonServiceTest.experimentA(), ...
                "ExpB_xlsx", ...
                ExperimentComparisonServiceTest.experimentB()));

        end

        function data = experimentA()

            data = ExperimentComparisonServiceTest.experiment( ...
                [0.8; 0.2], [0.2; 0.4]);

        end

        function data = experimentB()

            data = ExperimentComparisonServiceTest.experiment( ...
                [0.7; 0.3], [0.3; 0.5]);

        end

        function data = experiment(fragmentValues, enrichmentValues)

            fragment = table( ...
                fragmentValues, ...
                VariableNames = "Frag", ...
                RowNames = ["M0"; "M1"]);
            enrichment = table( ...
                enrichmentValues, ...
                VariableNames = "Enrichment", ...
                RowNames = ["A"; "B"]);
            data = struct( ...
                "tableMDVBiomass", fragment, ...
                "tableEnrichment", enrichment);

        end

    end

end
