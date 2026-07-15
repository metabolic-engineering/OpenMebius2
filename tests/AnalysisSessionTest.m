classdef AnalysisSessionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(AnalysisSessionTest.sourcePath());

        end

    end

    methods (Test)

        function resultSessionOwnsResultAndStatus(testCase)

            coordinator = openmebius.infrastructure.result ...
                .MFAResultCoordinator(IsExport = false);
            session = openmebius.application.analysis ...
                .MFAResultSession(Coordinator = coordinator);
            session.writeGeneral( ...
                "batch-1", [0.2; 0.8], ["M0"; "M1"], [true; true]);
            session.writeInitialFlux( ...
                [1; 2], [3; 4], 5, zeros(0, 2));
            session.writeSummary(5, 1, 7);

            testCase.verifyEqual(session.Status, [1, 1, 0, 0]);
            testCase.verifyEqual(session.Result.ID, "batch-1");
            testCase.verifyEqual(session.Result.initialFlux.RSS, 5);
            testCase.verifyEqual(session.Result.threshold, 7);

        end

        function resultSessionReportsCoordinatorFailure(testCase)

            observer = helpers.FailureObserverStub();
            session = openmebius.application.analysis ...
                .MFAResultSession( ...
                Coordinator = ...
                helpers.MFAResultCoordinatorFailureStub(), ...
                FailureReporter = ...
                @(message) observer.report(message));
            session.writeGeneral("id", 1, "M0", true);

            testCase.verifyEqual( ...
                observer.Messages, "checkpoint failed");

        end

        function runScopeStartsAndRefreshesMetadata(testCase)

            lifecycle = helpers.AnalysisRunLifecycleStub();
            observer = helpers.FailureObserverStub();
            startedAt = "2026-07-15T00:00:00.000Z";
            randomState = rng;
            scope = openmebius.application.analysis.AnalysisRunScope( ...
                lifecycle, ...
                struct, ...
                "batch-1", ...
                [], ...
                "exp-1", ...
                struct, ...
                [], ...
                "result.h5", ...
                StartedAtUtc = startedAt, ...
                RandomState = randomState, ...
                FailureReporter = ...
                @(message) observer.report(message));

            scope.finish(false, false);
            scope.finish(true, false);

            testCase.verifyTrue(scope.StartSucceeded);
            testCase.verifyTrue(scope.IsStarted);
            testCase.verifyEqual(scope.StartedAtUtc, startedAt);
            testCase.verifyEqual(lifecycle.StartCallCount, 1);
            testCase.verifyEqual(lifecycle.FinishCallCount, 2);
            testCase.verifyEqual(scope.FinishCount, 2);
            testCase.verifyEmpty(observer.Messages);

        end

        function runScopeReportsStartFailure(testCase)

            lifecycle = helpers.AnalysisRunLifecycleStub();
            lifecycle.StartSucceeded = false;
            lifecycle.StartMessage = "start failed";
            observer = helpers.FailureObserverStub();
            scope = openmebius.application.analysis.AnalysisRunScope( ...
                lifecycle, struct, "id", [], [], struct, [], "result.h5", ...
                FailureReporter = ...
                @(message) observer.report(message));

            scope.finish(false, false);

            testCase.verifyFalse(scope.StartSucceeded);
            testCase.verifyFalse(scope.IsStarted);
            testCase.verifyEqual(observer.Messages, "start failed");
            testCase.verifyEqual(lifecycle.FinishCallCount, 0);

        end

        function runScopeReportsEveryFinishFailure(testCase)

            lifecycle = helpers.AnalysisRunLifecycleStub();
            lifecycle.FinishErrors = ["manifest failed"; "metadata failed"];
            observer = helpers.FailureObserverStub();
            scope = openmebius.application.analysis.AnalysisRunScope( ...
                lifecycle, struct, "id", [], [], struct, [], "result.h5", ...
                FailureReporter = ...
                @(message) observer.report(message));

            scope.finish(false, false);

            testCase.verifyEqual( ...
                observer.Messages, lifecycle.FinishErrors);
            testCase.verifyEqual(lifecycle.FinishCallCount, 1);

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
