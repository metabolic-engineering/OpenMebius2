classdef BatchRunServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(BatchRunServiceTest.sourcePath());

        end

    end

    methods (Test)

        function runsFluxAndForwardsEvents(testCase)

            [service, analysis] = BatchRunServiceTest.createService();
            recorder = helpers.BatchRunCallbackRecorder();

            result = service.run( ...
                struct, ...
                struct, ...
                "experiment-a", ...
                analysis.Config, ...
                "result-directory", ...
                "bat_test", ...
                MessageReporter = ...
                @(eventData) recorder.recordMessage(eventData), ...
                ResultReporter = ...
                @(eventData) recorder.recordResult(eventData));

            testCase.verifyTrue(result.isSuccess());
            testCase.verifyEqual(analysis.Calls, "flux");
            testCase.verifyEqual(analysis.FinalizeCount, 1);
            testCase.verifyEqual(recorder.MessageCount, 1);
            testCase.verifyEqual(recorder.ResultCount, 1);

        end

        function runsConfidenceIntervalAfterFlux(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.isCalcCI = true;
            [service, analysis] = BatchRunServiceTest.createService(config);

            result = BatchRunServiceTest.runService(service, analysis.Config);

            testCase.verifyTrue(result.isSuccess());
            testCase.verifyEqual(analysis.Calls, ["flux", "ci"]);

        end

        function forwardsConfidenceIntervalProgress(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.isCalcCI = true;
            [service, analysis] = BatchRunServiceTest.createService(config);
            progress = helpers.AnalysisProgressRecorder();

            service.run( ...
                struct, ...
                struct, ...
                "experiment-a", ...
                analysis.Config, ...
                "result-directory", ...
                "bat_test", ...
                ProgressReporter = @(completed, total) ...
                progress.record(completed, total));

            testCase.verifyEqual(progress.Completed, 1);
            testCase.verifyEqual(progress.Total, 4);

        end

        function suggestionSuppressesConfidenceInterval(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.suggestNextFlux = true;
            config.isCalcCI = true;
            [service, analysis] = BatchRunServiceTest.createService(config);

            result = BatchRunServiceTest.runService(service, analysis.Config);

            testCase.verifyTrue(result.isSuccess());
            testCase.verifyEqual(analysis.Calls, ["flux", "suggest"]);

        end

        function stopsAfterAnalysisError(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.suggestNextFlux = true;
            [service, analysis] = BatchRunServiceTest.createService( ...
                config, "error-suggest");

            result = BatchRunServiceTest.runService(service, analysis.Config);

            testCase.verifyTrue(result.isFailure());
            testCase.verifyEqual(analysis.Calls, ["flux", "suggest"]);
            testCase.verifyEqual(analysis.FinalizeCount, 1);

        end

        function stopsAfterCancellation(testCase)

            [service, analysis] = BatchRunServiceTest.createService( ...
                [], "cancel-flux");

            result = BatchRunServiceTest.runService(service, analysis.Config);

            testCase.verifyTrue(result.isCanceled());
            testCase.verifyEqual(analysis.Calls, "flux");
            testCase.verifyEqual(analysis.FinalizeCount, 1);

        end

        function passesProvenanceToFactory(testCase)

            analysis = helpers.BatchAnalysisStub( ...
                openmebius.domain.batch.BatchConfig.defaultConfig());
            factory = helpers.MFAAnalysisRunFactoryStub(analysis);
            service = openmebius.application.batch.BatchRunService( ...
                AnalysisFactory = factory);
            provenance = struct('contentHash', "sha256:test");

            service.run( ...
                struct, ...
                struct, ...
                "experiment-a", ...
                analysis.Config, ...
                "result-directory", ...
                "bat_test", ...
                Provenance = provenance);

            testCase.verifyEqual(factory.CreateArguments{8}, "Provenance");
            testCase.verifyEqual(factory.CreateArguments{9}, provenance);

        end

    end

    methods (Static, Access = private)

        function [service, analysis] = createService(config, failurePhase)

            if nargin < 1 || isempty(config)
                config = openmebius.domain.batch.BatchConfig.defaultConfig();
            end

            if nargin < 2
                failurePhase = "";
            end

            analysis = helpers.BatchAnalysisStub(config, failurePhase);
            factory = helpers.MFAAnalysisRunFactoryStub(analysis);
            service = openmebius.application.batch.BatchRunService( ...
                AnalysisFactory = factory);

        end

        function result = runService(service, config)

            result = service.run( ...
                struct, ...
                struct, ...
                "experiment-a", ...
                config, ...
                "result-directory", ...
                "bat_test");

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
