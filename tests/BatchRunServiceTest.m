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

            status = service.run( ...
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

            testCase.verifyEqual(status, "finished");
            testCase.verifyEqual(analysis.Calls, "flux");
            testCase.verifyEqual(analysis.FinalizeCount, 1);
            testCase.verifyEqual(recorder.MessageCount, 1);
            testCase.verifyEqual(recorder.ResultCount, 1);

        end

        function runsConfidenceIntervalAfterFlux(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.isCalcCI = true;
            [service, analysis] = BatchRunServiceTest.createService(config);

            status = BatchRunServiceTest.runService(service, analysis.Config);

            testCase.verifyEqual(status, "finished");
            testCase.verifyEqual(analysis.Calls, ["flux", "ci"]);

        end

        function suggestionSuppressesConfidenceInterval(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.suggestNextFlux = true;
            config.isCalcCI = true;
            [service, analysis] = BatchRunServiceTest.createService(config);

            status = BatchRunServiceTest.runService(service, analysis.Config);

            testCase.verifyEqual(status, "finished");
            testCase.verifyEqual(analysis.Calls, ["flux", "suggest"]);

        end

        function stopsAfterAnalysisError(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.suggestNextFlux = true;
            [service, analysis] = BatchRunServiceTest.createService( ...
                config, "error-suggest");

            status = BatchRunServiceTest.runService(service, analysis.Config);

            testCase.verifyEqual(status, "error");
            testCase.verifyEqual(analysis.Calls, ["flux", "suggest"]);
            testCase.verifyEqual(analysis.FinalizeCount, 1);

        end

        function stopsAfterCancellation(testCase)

            [service, analysis] = BatchRunServiceTest.createService( ...
                [], "cancel-flux");

            status = BatchRunServiceTest.runService(service, analysis.Config);

            testCase.verifyEqual(status, "canceled");
            testCase.verifyEqual(analysis.Calls, "flux");
            testCase.verifyEqual(analysis.FinalizeCount, 1);

        end

        function passesProvenanceToFactory(testCase)

            analysis = helpers.BatchAnalysisStub( ...
                openmebius.domain.batch.BatchConfig.defaultConfig());
            factory = helpers.FluxAnalysisFactoryStub(analysis);
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
            factory = helpers.FluxAnalysisFactoryStub(analysis);
            service = openmebius.application.batch.BatchRunService( ...
                AnalysisFactory = factory);

        end

        function status = runService(service, config)

            status = service.run( ...
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
