classdef TracerConfigurationServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function loadsEditorTable(testCase)

            experiments = helpers.TracerConfigurationExperimentStub();
            experiments.EditorTable = table( ...
                true, "U-13C", 1, ...
                VariableNames = ["Select", "Label", "Ratio"]);
            service = openmebius.application.experiment ...
                .TracerConfigurationService();

            result = service.load(experiments, [2, 3]);

            testCase.verifyTrue(experiments.Called);
            testCase.verifyEqual(experiments.Position, [2, 3]);
            testCase.verifyEqual(result.Position, [2, 3]);
            testCase.verifyEqual( ...
                result.EditorTable, experiments.EditorTable);

        end

        function appliesEditorTable(testCase)

            editorTable = table( ...
                true, "U-13C", 0.5, ...
                VariableNames = ["Select", "Label", "Ratio"]);
            service = openmebius.application.experiment ...
                .TracerConfigurationService();

            result = service.apply([1, 2], editorTable);

            testCase.verifyEqual(result.Position, [1, 2]);
            testCase.verifyEqual(result.EditorTable, editorTable);
            testCase.verifyEqual(result.Pattern, "U-13C~1");

        end

        function rejectsInvalidExperiments(testCase)

            service = openmebius.application.experiment ...
                .TracerConfigurationService();

            testCase.verifyError( ...
                @() service.load([], [1, 1]), ...
                "OpenMebius2:TracerConfiguration:InvalidExperiments");

        end

    end

end
