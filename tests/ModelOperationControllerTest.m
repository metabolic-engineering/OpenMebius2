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

        function savesModelTable(testCase)

            model = helpers.ModelEditWorkspaceStub();
            model.ModelReport = ...
                openmebius.domain.model.ModelValidationReport.success( ...
                    "Model saved.");
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    TemplateModelLoadService = ...
                        helpers.TemplateModelLoadServiceStub());
            modelTable = table((1:2)', VariableNames = "Value");

            outcome = controller.saveModelTable(model, modelTable);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyTrue(model.ModelCalled);
            testCase.verifyEqual(model.ModelTable, modelTable);
            testCase.verifyEqual( ...
                outcome.Result.ModelReport, model.ModelReport);

        end

        function savesMassSpectrometryTables(testCase)

            model = helpers.ModelEditWorkspaceStub();
            model.MSReport = ...
                openmebius.domain.model.ModelValidationReport.success( ...
                    "MS saved.");
            model.AtomReport = ...
                openmebius.domain.model.ModelValidationReport.success( ...
                    "Atom saved.");
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    TemplateModelLoadService = ...
                        helpers.TemplateModelLoadServiceStub());
            msTable = table(1, VariableNames = "MS");
            atomTable = table(2, VariableNames = "Atom");

            outcome = controller.saveMassSpectrometry( ...
                model, msTable, atomTable);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyTrue(model.MSCalled);
            testCase.verifyTrue(model.AtomCalled);
            testCase.verifyEqual(outcome.Result.MSReport, model.MSReport);
            testCase.verifyEqual( ...
                outcome.Result.AtomReport, model.AtomReport);

        end

        function capturesModelEditFailure(testCase)

            model = helpers.ModelEditWorkspaceStub();
            model.Exception = MException( ...
                "OpenMebius2:Test:ModelEditFailed", ...
                "Model edit failed.");
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    TemplateModelLoadService = ...
                        helpers.TemplateModelLoadServiceStub());

            outcome = controller.saveModelTable(model, table());

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                outcome.ErrorMessage, "Model edit failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:ModelEditFailed");

        end

        function exportsMassSpectrometryTemplate(testCase)

            service = helpers.MassSpectrometryTemplateExportServiceStub();
            service.Result = openmebius.application.model ...
                .MassSpectrometryTemplateExportResult( ...
                    OutputPath = "template.xlsx");
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    TemplateModelLoadService = ...
                        helpers.TemplateModelLoadServiceStub(), ...
                    TemplateExportService = service);
            model = helpers.MassSpectrometryTemplateModelStub();

            outcome = controller.exportMassSpectrometryTemplate( ...
                model, "template.xlsx");

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyTrue(service.Called);
            testCase.verifyEqual(service.Model, model);
            testCase.verifyEqual(service.OutputPath, "template.xlsx");
            testCase.verifyEqual(outcome.Result, service.Result);

        end

        function capturesTemplateExportFailure(testCase)

            service = helpers.MassSpectrometryTemplateExportServiceStub();
            service.Exception = MException( ...
                "OpenMebius2:Test:TemplateExportFailed", ...
                "Template export failed.");
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    TemplateModelLoadService = ...
                        helpers.TemplateModelLoadServiceStub(), ...
                    TemplateExportService = service);

            outcome = controller.exportMassSpectrometryTemplate( ...
                helpers.MassSpectrometryTemplateModelStub(), ...
                "template.xlsx");

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                outcome.ErrorMessage, "Template export failed.");

        end

        function setsPathwayLabelPosition(testCase)

            service = helpers.PathwayLabelServiceStub();
            service.Result = "updated";
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    PathwayLabelService = service);
            model = helpers.PathwayLabelModelStub();

            outcome = controller.setPathwayLabelPosition( ...
                model, "R1", [2.5 4.5]);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyTrue(service.SetCalled);
            testCase.verifyEqual(service.Model, model);
            testCase.verifyEqual(service.ReactionID, "R1");
            testCase.verifyEqual(service.Position, [2.5 4.5]);
            testCase.verifyEqual(outcome.Result, "updated");

        end

        function removesPathwayLabelPosition(testCase)

            service = helpers.PathwayLabelServiceStub();
            service.Result = "removed";
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    PathwayLabelService = service);

            outcome = controller.removePathwayLabelPosition( ...
                helpers.PathwayLabelModelStub(), "R1");

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyTrue(service.RemoveCalled);
            testCase.verifyEqual(outcome.Result, "removed");

        end

        function capturesPathwayLabelFailure(testCase)

            service = helpers.PathwayLabelServiceStub();
            service.Exception = MException( ...
                "OpenMebius2:PathwayLabel:ReactionRequired", ...
                "Please select a reaction.");
            controller = openmebius.application.model ...
                .ModelOperationController( ...
                    PathwayLabelService = service);

            outcome = controller.setPathwayLabelPosition( ...
                [], "", [1 2]);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:PathwayLabel:ReactionRequired");

        end

    end % methods (Test)

end % classdef
