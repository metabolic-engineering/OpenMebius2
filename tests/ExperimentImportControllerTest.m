classdef ExperimentImportControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function importsExperimentFiles(testCase)

            importService = helpers.ExperimentImportServiceStub();
            importService.ImportResult = struct("Messages", "Imported.");
            controller = openmebius.application.experiment ...
                .ExperimentImportController( ...
                    ExperimentImportService = importService, ...
                    RawMSImportService = helpers.RawMSImportServiceStub());
            location = openmebius.domain.experiment ...
                .ExperimentLocation("experiment");
            files = ["first.xlsx"; "second.xlsx"];

            outcome = controller.importFiles( ...
                location, files, "model");

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(outcome.Result, importService.ImportResult);
            testCase.verifyEqual(importService.LastOperation, "importFiles");
            testCase.verifyEqual(importService.Inputs{2}, files);
            testCase.verifyEmpty(outcome.Exception);

        end

        function capturesReloadFailure(testCase)

            importService = helpers.ExperimentImportServiceStub();
            importService.Exception = MException( ...
                "OpenMebius2:Test:ReloadFailed", ...
                "Reload failed.");
            controller = openmebius.application.experiment ...
                .ExperimentImportController( ...
                    ExperimentImportService = importService, ...
                    RawMSImportService = helpers.RawMSImportServiceStub());
            location = openmebius.domain.experiment ...
                .ExperimentLocation("experiment");

            outcome = controller.reload(location, []);

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual(outcome.ErrorMessage, "Reload failed.");
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:ReloadFailed");

        end

        function importsRawMSData(testCase)

            rawService = helpers.RawMSImportServiceStub();
            rawService.Result = struct("Messages", "Raw data imported.");
            controller = openmebius.application.experiment ...
                .ExperimentImportController( ...
                    ExperimentImportService = ...
                        helpers.ExperimentImportServiceStub(), ...
                    RawMSImportService = rawService);
            location = openmebius.domain.experiment ...
                .ExperimentLocation("experiment");

            outcome = controller.importShimadzuASCII( ...
                "raw", location, "model");

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyTrue(rawService.Called);
            testCase.verifyEqual(rawService.Inputs{1}, "raw");
            testCase.verifyEqual(outcome.Result, rawService.Result);

        end

    end % methods (Test)

end % classdef
