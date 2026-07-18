classdef LabelConfigurationLaunchControllerTest < ...
        matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function preparesEditorState(testCase)

            labelTable = table( ...
                {"Uniform"}, {1}, ...
                VariableNames = ["Name", "Num"]);
            ratioTables = struct( ...
                Uniform = table( ...
                    {"#1"}, {1}, ...
                    VariableNames = ["Label", "Ratio"]));
            model = helpers.LabelConfigurationModelStub();
            model.LabelTable = labelTable;
            model.RatioTables = ratioTables;
            controller = openmebius.application.model ...
                .LabelConfigurationLaunchController();

            outcome = controller.prepare(model);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyClass( ...
                outcome.State, ...
                ['openmebius.application.model.' ...
                 'LabelConfigurationEditorState']);
            testCase.verifyEqual(outcome.State.LabelTable, labelTable);
            testCase.verifyEqual(outcome.State.RatioTables, ratioTables);

        end

        function rejectsMissingModel(testCase)

            controller = openmebius.application.model ...
                .LabelConfigurationLaunchController();

            outcome = controller.prepare([]);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:" + ...
                "LabelConfigurationLaunchController:InvalidModel");

        end

        function capturesModelReadFailure(testCase)

            model = helpers.LabelConfigurationModelStub();
            model.ThrowOnRead = true;
            controller = openmebius.application.model ...
                .LabelConfigurationLaunchController();

            outcome = controller.prepare(model);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:LabelConfigurationReadFailed");

        end

        function rejectsInconsistentEditorData(testCase)

            model = helpers.LabelConfigurationModelStub();
            model.LabelTable = table( ...
                {"Uniform"}, {1}, ...
                VariableNames = ["Name", "Num"]);
            controller = openmebius.application.model ...
                .LabelConfigurationLaunchController();

            outcome = controller.prepare(model);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:" + ...
                "LabelConfigurationEditorState:InconsistentData");

        end

    end % methods (Test)

end % classdef
