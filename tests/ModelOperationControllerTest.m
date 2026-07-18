classdef ModelOperationControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function loadsTemplateModel(testCase)

            service = helpers.TemplateModelLoadServiceStub();
            service.Result = struct("Messages", "Loaded.");
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    TemplateModelLoadService = service);
            location = openmebius.domain.model.ModelLocation ...
                .fromDirectory("model");

            outcome = controller.loadTemplate(location);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyEqual(outcome.Result, service.Result);
            testCase.verifyTrue(service.Called);
            testCase.verifyEqual(service.ModelLocation, location);
            testCase.verifyEmpty(outcome.Exception);

        end

        function capturesTemplateLoadFailure(testCase)

            service = helpers.TemplateModelLoadServiceStub();
            service.Exception = MException( ...
                "OpenMebius2:Test:TemplateLoadFailed", ...
                "Template load failed.");
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    TemplateModelLoadService = service);
            location = openmebius.domain.model.ModelLocation ...
                .fromDirectory("model");

            outcome = controller.loadTemplate(location);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                outcome.ErrorMessage, "Template load failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:TemplateLoadFailed");

        end

    end % methods (Test)

end % classdef
