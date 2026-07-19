classdef ExperimentCalculationControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function returnsFinishedOutcome(testCase)

            service = helpers.ExperimentCalculationServiceStub();
            service.Result = struct("Messages", "Calculated.");
            controller = openmebius.application.experiment ...
                .ExperimentCalculationController(Service = service);
            tables = ExperimentCalculationControllerTest.tables();

            outcome = controller.calculate( ...
                "model", "experiments", "batch", ...
                tables{1}, tables{2}, tables{3});

            testCase.verifyTrue(service.Called);
            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(outcome.Result, service.Result);
            testCase.verifyEmpty(outcome.Exception);
            testCase.verifyEqual(service.Inputs{1}, "model");

        end

        function capturesCalculationFailure(testCase)

            service = helpers.ExperimentCalculationServiceStub();
            service.Exception = MException( ...
                "OpenMebius2:Test:CalculationFailed", ...
                "Calculation failed.");
            controller = openmebius.application.experiment ...
                .ExperimentCalculationController(Service = service);
            tables = ExperimentCalculationControllerTest.tables();

            outcome = controller.calculate( ...
                [], [], [], tables{1}, tables{2}, tables{3});

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual( ...
                outcome.ErrorMessage, "Calculation failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:CalculationFailed");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function values = tables()

            values = {table(), table(), table()};

        end

    end % methods (Static, Access = private)

end % classdef
