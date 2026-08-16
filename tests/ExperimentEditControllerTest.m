classdef ExperimentEditControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function savesExperimentInfo(testCase)

            service = helpers.ExperimentEditServiceStub();
            service.Result = struct("Messages", "Saved.");
            controller = openmebius.application.experiment ...
                .ExperimentEditController(Service = service);
            infoTable = table(1, VariableNames = "Growth");

            outcome = controller.saveInfo( ...
                "model", "experiments", "batch", infoTable);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(outcome.Result, service.Result);
            testCase.verifyEqual(service.LastOperation, "saveInfo");
            testCase.verifyEqual(service.Inputs{4}, infoTable);
            testCase.verifyEmpty(outcome.Exception);

        end

        function savesTracerTables(testCase)

            service = helpers.ExperimentEditServiceStub();
            service.Result = struct("Messages", "Tracer saved.");
            controller = openmebius.application.experiment ...
                .ExperimentEditController(Service = service);
            uptakeTable = table(1, VariableNames = "Uptake");
            tracerTable = table("12C1~1", VariableNames = "Tracer");

            outcome = controller.saveTracer( ...
                [], [], [], uptakeTable, tracerTable);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(service.LastOperation, "saveTracer");
            testCase.verifyEqual(service.Inputs{4}, uptakeTable);
            testCase.verifyEqual(service.Inputs{5}, tracerTable);

        end

        function copiesTracerToAllEntries(testCase)

            service = helpers.ExperimentEditServiceStub();
            service.Result = struct("UpdatedTable", table( ...
                ["12C1~1"; "12C1~1"], VariableNames = "Tracer"));
            controller = openmebius.application.experiment ...
                .ExperimentEditController(Service = service);
            tracerTable = table( ...
                ["12C1~1"; "13C1~1"], VariableNames = "Tracer");

            outcome = controller.copyTracerToAllEntries( ...
                [], [], [], tracerTable, [1, 1]);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual( ...
                service.LastOperation, "copyTracerToAllEntries");
            testCase.verifyEqual(service.Inputs{4}, tracerTable);
            testCase.verifyEqual(service.Inputs{5}, [1, 1]);

        end

        function capturesEditingFailure(testCase)

            service = helpers.ExperimentEditServiceStub();
            service.Exception = MException( ...
                "OpenMebius2:Test:EditFailed", ...
                "Editing failed.");
            controller = openmebius.application.experiment ...
                .ExperimentEditController(Service = service);

            outcome = controller.saveInfo([], [], [], table());

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual(outcome.ErrorMessage, "Editing failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:EditFailed");

        end

        function loadsTracerConfiguration(testCase)

            service = helpers.TracerConfigurationServiceStub();
            editorTable = table( ...
                true, "U-13C", 1, ...
                VariableNames = ["Select", "Label", "Ratio"]);
            service.Result = openmebius.application.experiment ...
                .TracerConfigurationResult( ...
                Position = [2, 3], ...
                EditorTable = editorTable);
            controller = openmebius.application.experiment ...
                .ExperimentEditController( ...
                TracerConfigurationService = service);
            experiments = helpers.TracerConfigurationExperimentStub();

            outcome = controller.loadTracerConfiguration( ...
                experiments, [2, 3]);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(service.LastOperation, "load");
            testCase.verifyEqual(service.Experiments, experiments);
            testCase.verifyEqual(service.Position, [2, 3]);
            testCase.verifyEqual(outcome.Result, service.Result);

        end

        function preparesTracerConfiguration(testCase)

            service = helpers.TracerConfigurationServiceStub();
            tracerTable = table( ...
                "12C1~1", VariableNames = "Tracer");
            service.Result = openmebius.application.experiment ...
                .TracerConfigurationLaunchDecision( ...
                IsAllowed = true, ...
                Position = [2, 3], ...
                EditorTable = table());
            controller = openmebius.application.experiment ...
                .ExperimentEditController( ...
                TracerConfigurationService = service);
            experiments = helpers.TracerConfigurationExperimentStub();

            outcome = controller.prepareTracerConfiguration( ...
                experiments, tracerTable, [2, 3]);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(service.LastOperation, "prepare");
            testCase.verifyEqual(service.Experiments, experiments);
            testCase.verifyEqual( ...
                service.CurrentTracerTable, tracerTable);
            testCase.verifyEqual(service.Position, [2, 3]);
            testCase.verifyEqual(outcome.Result, service.Result);

        end

        function appliesTracerConfiguration(testCase)

            service = helpers.TracerConfigurationServiceStub();
            editorTable = table( ...
                true, "U-13C", 1, ...
                VariableNames = ["Select", "Label", "Ratio"]);
            service.Result = openmebius.application.experiment ...
                .TracerConfigurationResult( ...
                Position = [1, 2], Pattern = "U-13C~1");
            controller = openmebius.application.experiment ...
                .ExperimentEditController( ...
                TracerConfigurationService = service);

            outcome = controller.applyTracerConfiguration( ...
                [1, 2], editorTable);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(service.LastOperation, "apply");
            testCase.verifyEqual(service.Position, [1, 2]);
            testCase.verifyEqual(service.EditorTable, editorTable);

        end

        function capturesTracerConfigurationFailure(testCase)

            service = helpers.TracerConfigurationServiceStub();
            service.Exception = MException( ...
                "OpenMebius2:Test:TracerConfigurationFailed", ...
                "Tracer configuration failed.");
            controller = openmebius.application.experiment ...
                .ExperimentEditController( ...
                TracerConfigurationService = service);

            outcome = controller.applyTracerConfiguration( ...
                [1, 1], table());

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual( ...
                outcome.ErrorMessage, "Tracer configuration failed.");

        end

    end % methods (Test)

end % classdef
