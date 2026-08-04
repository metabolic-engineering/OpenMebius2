classdef ExperimentValidationReportTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(ExperimentValidationReportTest.sourcePath());

        end

    end

    methods (Test)

        function successCarriesMessagesAndWarnings(testCase)

            report = openmebius.domain.experiment ...
                .ExperimentValidationReport.success( ...
                "Experiment data updated.", ...
                Warnings = "A default value was applied.");

            testCase.verifyTrue(report.IsValid);
            testCase.verifyEqual( ...
                report.Messages, ...
                "Experiment data updated.");
            testCase.verifyEqual( ...
                report.Warnings, ...
                "A default value was applied.");

        end

        function failureRequiresErrorMessage(testCase)

            testCase.verifyError( ...
                @() openmebius.domain.experiment ...
                .ExperimentValidationReport(IsValid = false), ...
                "OpenMebius2:ExperimentValidationReport:" + ...
                "MissingErrorMessage");

        end

        function failureCarriesErrorMessage(testCase)

            report = openmebius.domain.experiment ...
                .ExperimentValidationReport.failure( ...
                "Experiment data is invalid.");

            testCase.verifyFalse(report.IsValid);
            testCase.verifyEqual( ...
                report.ErrorMessage, ...
                "Experiment data is invalid.");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename("fullpath"))), ...
                "src");

        end

    end

end % classdef
