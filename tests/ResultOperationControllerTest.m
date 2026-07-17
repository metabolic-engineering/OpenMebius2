classdef ResultOperationControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function generatesReport(testCase)

            reportService = helpers.ReportGenerationServiceStub();
            reportService.Result = struct("Messages", "Generated.");
            controller = openmebius.application.result ...
                .ResultOperationController( ...
                    ResultExportService = ...
                        helpers.ResultExportServiceStub(), ...
                    ReportGenerationService = reportService);
            location = openmebius.domain.result ...
                .ResultLocation.fromDirectory(tempdir);

            outcome = controller.generateReport( ...
                location, "model", "experiments", "result", ...
                IsDeployed = false);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyEqual(outcome.Result, reportService.Result);
            testCase.verifyTrue(reportService.Called);
            testCase.verifyEqual(reportService.Inputs{1}, location);
            testCase.verifyEmpty(outcome.Exception);

        end

        function exportsSelectedResults(testCase)

            exportService = helpers.ResultExportServiceStub();
            exportService.Result = struct("Messages", "Exported.");
            controller = openmebius.application.result ...
                .ResultOperationController( ...
                    ResultExportService = exportService, ...
                    ReportGenerationService = ...
                        helpers.ReportGenerationServiceStub());
            location = openmebius.domain.result ...
                .ResultLocation.fromDirectory(tempdir);

            outcome = controller.exportResults( ...
                "result", ["batch-1"; "batch-2"], ...
                ["First"; "Second"], location);

            testCase.verifyEqual(outcome.Status, "finished");
            testCase.verifyTrue(exportService.Called);
            testCase.verifyEqual( ...
                exportService.Inputs{2}, ["batch-1"; "batch-2"]);
            testCase.verifyEqual( ...
                exportService.Inputs{3}, ["First"; "Second"]);

        end

        function capturesOperationFailure(testCase)

            exportService = helpers.ResultExportServiceStub();
            exportService.Exception = MException( ...
                "OpenMebius2:ResultExport:ResultUnavailable", ...
                "Result data is not available.");
            controller = openmebius.application.result ...
                .ResultOperationController( ...
                    ResultExportService = exportService, ...
                    ReportGenerationService = ...
                        helpers.ReportGenerationServiceStub());
            location = openmebius.domain.result ...
                .ResultLocation.fromDirectory(tempdir);

            outcome = controller.exportResults( ...
                [], "batch-1", "First", location);

            testCase.verifyEqual(outcome.Status, "error");
            testCase.verifyEqual( ...
                outcome.ErrorMessage, ...
                "Result data is not available.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:ResultExport:ResultUnavailable");

        end

    end % methods (Test)

end % classdef
