classdef TracerConfigBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function childAppDoesNotReferenceParentApps(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "TracerConfig_exported.m")));

            testCase.verifyFalse(contains(source, "MainApp"));
            testCase.verifyTrue(contains(source, "notify(app, ""Applied"""));
            testCase.verifyTrue(contains(source, "notify(app, ""Closed"""));

        end

        function appliedEventCarriesEditorValues(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            editorTable = table( ...
                true, "U-13C", 1, ...
                VariableNames = ["Select", "Label", "Ratio"]);

            eventData = openmebius.presentation.experiment ...
                .TracerConfigurationAppliedEventData( ...
                    [2, 3], editorTable);

            testCase.verifyEqual(eventData.Position, [2, 3]);
            testCase.verifyEqual(eventData.EditorTable, editorTable);

        end

        function runConfigDoesNotExposeChildThroughMainApp(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "RunConfig_exported.m")));

            testCase.verifyFalse( ...
                contains(source, "MainApp.TracerConfigApp"));

        end

        function mainAppUsesTracerPreparationBoundary(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "OpenMebius2_exported.m")));

            testCase.verifyTrue(contains( ...
                source, ".prepareTracerConfiguration("));
            testCase.verifyTrue(contains( ...
                source, ...
                ".presentTracerConfigurationPreparationOutcome("));
            testCase.verifyTrue(contains( ...
                source, "renderTracerConfigurationViewModel"));
            testCase.verifyTrue(contains( ...
                source, "closeTracerConfigApp"));
            testCase.verifyFalse(contains( ...
                source, "app.exp.tableTracersInfo"));
            testCase.verifyFalse(contains( ...
                source, "function openTracerConfiguration(app"));

        end

    end

end
