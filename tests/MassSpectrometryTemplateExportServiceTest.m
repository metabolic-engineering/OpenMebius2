classdef MassSpectrometryTemplateExportServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function exportsTemplateData(testCase)

            repository = ...
                helpers.MassSpectrometryTemplateRepositoryStub();
            service = openmebius.application.model ...
                .MassSpectrometryTemplateExportService( ...
                Repository = repository);
            model = helpers.MassSpectrometryTemplateModelStub();
            outputPath = string(fullfile(tempdir, "template.xlsx"));

            result = service.export(model, outputPath);

            testCase.verifyTrue(model.Called);
            testCase.verifyTrue(repository.Called);
            testCase.verifyEqual(repository.OutputPath, outputPath);
            testCase.verifyEqual( ...
                repository.TemplateData, model.TemplateData);
            testCase.verifyEqual(repository.SheetName, "MS");
            testCase.verifyEqual(result.OutputPath, outputPath);
            testCase.verifyEqual(result.SheetName, "MS");

        end

        function rejectsMissingModel(testCase)

            service = openmebius.application.model ...
                .MassSpectrometryTemplateExportService( ...
                Repository = ...
                helpers.MassSpectrometryTemplateRepositoryStub());

            testCase.verifyError( ...
                @() service.export([], "template.xlsx"), ...
                "OpenMebius2:MSTemplate:ModelUnavailable");

        end

        function rejectsNonExcelOutput(testCase)

            service = openmebius.application.model ...
                .MassSpectrometryTemplateExportService( ...
                Repository = ...
                helpers.MassSpectrometryTemplateRepositoryStub());
            model = helpers.MassSpectrometryTemplateModelStub();

            testCase.verifyError( ...
                @() service.export(model, "template.csv"), ...
                "OpenMebius2:MSTemplate:InvalidExtension");

        end

    end % methods (Test)

end % classdef
