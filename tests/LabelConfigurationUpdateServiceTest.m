classdef LabelConfigurationUpdateServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function appliesConfigurationAcrossSession(testCase)

            model = helpers.LabelConfigurationModelStub();
            experiments = helpers.LabelConfigurationExperimentStub();
            batch = helpers.LabelConfigurationBatchStub();
            service = openmebius.application.model ...
                .LabelConfigurationUpdateService();
            labelTable = table( ...
                {"Uniform"}, {1}, ...
                VariableNames = ["Name", "Num"]);
            ratioTables = struct( ...
                Uniform = table( ...
                {"#1"}, {1}, ...
                VariableNames = ["Label", "Ratio"]));

            result = service.apply( ...
                model, experiments, batch, ...
                labelTable, ratioTables);

            testCase.verifyTrue(model.Called);
            testCase.verifyEqual(model.LabelTable, labelTable);
            testCase.verifyEqual(model.RatioTables, ratioTables);
            testCase.verifyTrue(experiments.Called);
            testCase.verifyEqual(experiments.Model, model);
            testCase.verifyTrue(batch.Called);
            testCase.verifyEqual(batch.Experiments, experiments);
            testCase.verifyEqual( ...
                result.Messages, ...
                "Label configuration applied successfully.");

        end

        function rejectsMissingSessionObject(testCase)

            service = openmebius.application.model ...
                .LabelConfigurationUpdateService();
            experiments = helpers.LabelConfigurationExperimentStub();
            batch = helpers.LabelConfigurationBatchStub();

            testCase.verifyError( ...
                @() service.apply( ...
                [], experiments, batch, table(), struct()), ...
                "OpenMebius2:LabelConfiguration:InvalidObject");

        end

    end

end
