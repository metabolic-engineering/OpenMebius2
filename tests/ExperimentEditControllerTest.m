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

            testCase.verifyEqual(outcome.Status, "finished");
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

            testCase.verifyEqual(outcome.Status, "finished");
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

            testCase.verifyEqual(outcome.Status, "finished");
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

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual(outcome.ErrorMessage, "Editing failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:EditFailed");

        end

    end % methods (Test)

end % classdef
