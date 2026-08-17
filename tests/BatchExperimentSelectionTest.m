classdef BatchExperimentSelectionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function normalizesExperiments(testCase)

            selection = openmebius.domain.batch ...
                .BatchExperimentSelection( ...
                Mode = "parallel", ...
                Experiments = [" exp-a "; "exp-a"; "exp-b"]);

            testCase.verifyEqual( ...
                selection.Experiments, ["exp-a"; "exp-b"]);

        end

        function requiresExperiments(testCase)

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchExperimentSelection( ...
                Mode = "parallel", Experiments = strings(0, 1)), ...
                "OpenMebius2:BatchExperimentSelection:" + ...
                "InvalidExperiments");

        end

        function requiresBatchIdForInstationaryMode(testCase)

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchExperimentSelection( ...
                Mode = "inst-mfa", Experiments = "exp-a"), ...
                "OpenMebius2:BatchExperimentSelection:MissingBatchId");

        end

    end % methods (Test)

end % classdef
