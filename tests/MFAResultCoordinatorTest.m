classdef MFAResultCoordinatorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAResultCoordinatorTest.sourcePath());

        end

    end

    methods (Test)

        function accumulatesGeneralAndFluxVariabilityState(testCase)

            coordinator = MFAResultCoordinatorTest.coordinator();
            status = zeros(1, 4);
            [result, status, isSuccess] = coordinator.writeGeneral( ...
                struct, status, "run-1", [0.2; 0.8], ...
                ["A"; "A"], [true; true]);
            [result, status, fvaSuccess] = ...
                coordinator.writeFluxVariability( ...
                result, status, [0; 1], [2; 3], zeros(0, 2));

            testCase.verifyTrue(isSuccess);
            testCase.verifyTrue(fvaSuccess);
            testCase.verifyEqual(result.ID, "run-1");
            testCase.verifyEqual(result.MDVExp, [0.2; 0.8]);
            testCase.verifyEqual( ...
                result.fluxVariability.fluxLB, [0; 1]);
            testCase.verifyEqual(status, zeros(1, 4));

        end

        function advancesInitialAndSummaryStatus(testCase)

            coordinator = MFAResultCoordinatorTest.coordinator();
            [result, status] = coordinator.writeInitialFlux( ...
                struct, zeros(1, 4), [1; 2], [3; 4], 5, zeros(0, 2));
            [result, status] = coordinator.writeSummary( ...
                result, status, [1, 2], [2, 1], 3.84);

            testCase.verifyEqual(status, [1, 1, 0, 0]);
            testCase.verifyEqual(result.status, status);
            testCase.verifyEqual(result.initialFlux.RSS, 5);
            testCase.verifyEqual(result.RSSIdx, [2, 1]);
            testCase.verifyEqual(result.threshold, 3.84);

        end

        function accumulatesIterationCheckpoint(testCase)

            coordinator = MFAResultCoordinatorTest.coordinator();
            iterationResult = openmebius.mfa.MFAIterationResult( ...
                IndependentValues = [1; 2], ...
                Flux = [1; 2], ...
                MDV = [0.3; 0.7], ...
                ObjectiveValue = 4, ...
                ExitFlag = 1);

            [result, status, isSuccess] = coordinator.writeIteration( ...
                struct, zeros(1, 4), 1, iterationResult, zeros(0, 2));

            testCase.verifyTrue(isSuccess);
            testCase.verifyTrue(isfield(result, 'fluxResult0001'));
            testCase.verifyEqual(result.fluxResult0001.RSS, 4);
            testCase.verifyEqual(status, zeros(1, 4));

        end

        function leavesExportOnlyStateUntouchedWhenDisabled(testCase)

            coordinator = MFAResultCoordinatorTest.coordinator();
            result = struct(existing = 1);
            status = zeros(1, 4);

            [result, status, isSuccess] = ...
                coordinator.writeMonteCarloConfidenceInterval( ...
                result, status, [0; 0], [1; 1], ...
                openmebius.mfa.ConfidenceIntervalSettings(), ...
                struct);

            testCase.verifyTrue(isSuccess);
            testCase.verifyEqual(result, struct(existing = 1));
            testCase.verifyEqual(status, zeros(1, 4));

        end

    end

    methods (Static, Access = private)

        function value = coordinator()

            value = openmebius.infrastructure.result ...
                .MFAResultCoordinator(IsExport = false);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
