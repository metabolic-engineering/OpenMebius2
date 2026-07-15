classdef ModelValidationReportTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ModelValidationReportTest.sourcePath());

        end

    end

    methods (Test)

        function successNormalizesMessagesAndWarnings(testCase)

            report = openmebius.domain.model.ModelValidationReport.success( ...
                "Model updated.", ...
                Warnings = "Default value applied.", ...
                InvalidRows = [3; 1; 3]);

            testCase.verifyTrue(report.IsValid);
            testCase.verifyEqual(report.Messages, "Model updated.");
            testCase.verifyEqual(report.Warnings, "Default value applied.");
            testCase.verifyEqual(report.InvalidRows, [3; 1]);

        end

        function failureRequiresErrorMessage(testCase)

            testCase.verifyError( ...
                @() openmebius.domain.model.ModelValidationReport( ...
                IsValid = false), ...
                "OpenMebius2:ModelValidationReport:MissingErrorMessage");

        end

        function failureCarriesInvalidRows(testCase)

            report = openmebius.domain.model.ModelValidationReport.failure( ...
                "Invalid reaction.", ...
                InvalidRows = [2; 4]);

            testCase.verifyFalse(report.IsValid);
            testCase.verifyEqual(report.ErrorMessage, "Invalid reaction.");
            testCase.verifyEqual(report.InvalidRows, [2; 4]);

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename("fullpath"))), ...
                "src");

        end

    end

end
