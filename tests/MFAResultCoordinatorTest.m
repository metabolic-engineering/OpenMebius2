classdef MFAResultCoordinatorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAResultCoordinatorTest.sourcePath());

        end

    end

    methods (Test)

        function accumulatesGeneralAndFluxVariabilityState(testCase)

            coordinator = MFAResultCoordinatorTest.coordinator();
            progress = MFAResultCoordinatorTest.progress();
            [result, progress, isSuccess] = coordinator.writeGeneral( ...
                struct, progress, "run-1", [0.2; 0.8], ...
                ["A"; "A"], [true; true]);
            [result, progress, fvaSuccess] = ...
                coordinator.writeFluxVariability( ...
                result, progress, [0; 1], [2; 3], zeros(0, 2));

            testCase.verifyTrue(isSuccess);
            testCase.verifyTrue(fvaSuccess);
            testCase.verifyEqual(result.ID, "run-1");
            testCase.verifyEqual(result.MDVExp, [0.2; 0.8]);
            testCase.verifyEqual( ...
                result.fluxVariability.fluxLB, [0; 1]);
            testCase.verifyEqual( ...
                progress.toStorageVector(), zeros(1, 4));

        end

        function advancesInitialAndSummaryStatus(testCase)

            coordinator = MFAResultCoordinatorTest.coordinator();
            progress = MFAResultCoordinatorTest.progress();
            [result, progress] = coordinator.writeInitialFlux( ...
                struct, progress, [1; 2], [3; 4], 5, zeros(0, 2));
            [result, progress] = coordinator.writeSummary( ...
                result, progress, [1, 2], [2, 1], 3.84);

            status = progress.toStorageVector();
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

            progress = MFAResultCoordinatorTest.progress();
            [result, progress, isSuccess] = coordinator.writeIteration( ...
                struct, progress, 1, iterationResult, zeros(0, 2));

            testCase.verifyTrue(isSuccess);
            testCase.verifyTrue(isfield(result, 'fluxResult0001'));
            testCase.verifyEqual(result.fluxResult0001.RSS, 4);
            testCase.verifyEqual( ...
                progress.toStorageVector(), zeros(1, 4));

        end

        function leavesExportOnlyStateUntouchedWhenDisabled(testCase)

            coordinator = MFAResultCoordinatorTest.coordinator();
            result = struct(existing = 1);
            progress = MFAResultCoordinatorTest.progress();

            [result, progress, isSuccess] = ...
                coordinator.writeMonteCarloConfidenceInterval( ...
                result, progress, [0; 0], [1; 1], ...
                openmebius.mfa.ConfidenceIntervalSettings(), ...
                struct);

            testCase.verifyTrue(isSuccess);
            testCase.verifyEqual(result, struct(existing = 1));
            testCase.verifyEqual( ...
                progress.toStorageVector(), [0, 0, 1, 0]);

        end

    end

    methods (Static, Access = private)

        function value = coordinator()

            value = openmebius.infrastructure.result ...
                .MFAResultCoordinator(IsExport = false);

        end

        function value = progress()

            value = openmebius.application.analysis.AnalysisProgress();

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
