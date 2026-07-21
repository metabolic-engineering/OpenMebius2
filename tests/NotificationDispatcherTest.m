classdef NotificationDispatcherTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function routesOnceByCentralPolicy(testCase)

            policy = openmebius.infrastructure.notification ...
                .RoutingPolicy(Mode = "desktop");
            dispatcher = openmebius.infrastructure.notification ...
                .NotificationDispatcher(Policy = policy);
            names = ["file", "console", "ui-log", "ui-alert", "slack"];
            sinks = cell(size(names));

            for sinkIndex = 1:numel(names)
                sinks{sinkIndex} = helpers.NotificationSinkSpy( ...
                    names(sinkIndex));
                dispatcher.addSink(sinks{sinkIndex});
            end

            message = openmebius.core.notification.Message( ...
                "Batch failed.", ...
                "error", ...
                EventId = "event-1", ...
                Code = "batch.failed", ...
                Attention = "action-required");
            dispatcher.publish(message);
            dispatcher.publish(message);

            for sinkIndex = 1:numel(sinks)
                testCase.verifyEqual(sinks{sinkIndex}.count(), 1, ...
                    names(sinkIndex));
            end

        end

        function passiveInfoAvoidsAlertConsoleAndSlack(testCase)

            dispatcher = openmebius.infrastructure.notification ...
                .NotificationDispatcher();
            fileSink = helpers.NotificationSinkSpy("file");
            logSink = helpers.NotificationSinkSpy("ui-log");
            alertSink = helpers.NotificationSinkSpy("ui-alert");
            consoleSink = helpers.NotificationSinkSpy("console");
            slackSink = helpers.NotificationSinkSpy("slack");
            dispatcher.addSink(fileSink);
            dispatcher.addSink(logSink);
            dispatcher.addSink(alertSink);
            dispatcher.addSink(consoleSink);
            dispatcher.addSink(slackSink);

            dispatcher.publish(openmebius.core.notification.Message( ...
                "Loaded.", "info", EventId = "event-2"));

            testCase.verifyEqual(fileSink.count(), 1);
            testCase.verifyEqual(logSink.count(), 1);
            testCase.verifyEqual(alertSink.count(), 0);
            testCase.verifyEqual(consoleSink.count(), 0);
            testCase.verifyEqual(slackSink.count(), 0);

        end

        function sinkFailureIsIsolated(testCase)

            emergency = strings(0, 1);
            dispatcher = openmebius.infrastructure.notification ...
                .NotificationDispatcher( ...
                    EmergencyWriter = @recordEmergency);
            failing = helpers.NotificationSinkSpy( ...
                "file", ThrowOnWrite = true);
            surviving = helpers.NotificationSinkSpy("ui-log");
            dispatcher.addSink(failing);
            dispatcher.addSink(surviving);

            dispatcher.publish(openmebius.core.notification.Message( ...
                "Message", "info", EventId = "event-3"));
            dispatcher.publish(openmebius.core.notification.Message( ...
                "Second message", "info", EventId = "event-4"));

            testCase.verifyEqual(failing.attemptCount(), 1);
            testCase.verifyEqual(surviving.count(), 2);
            testCase.verifyNumElements(emergency, 1);
            testCase.verifyTrue(contains(emergency, "sink failed"));

            function recordEmergency(text)
                emergency(end + 1, 1) = string(text);
            end

        end

        function emitterCreatesEnrichedTypedMessage(testCase)

            received = [];
            timestamp = datetime(2026, 7, 21, 10, 11, 12);
            emitter = openmebius.application.notification ...
                .NotificationEmitter( ...
                    Publisher = @record, ...
                    Clock = @() timestamp, ...
                    Source = "UnitTest");

            message = emitter.report( ...
                "warn", ...
                "Check input.", ...
                Code = "input.invalid", ...
                Attention = "action-required", ...
                CorrelationId = "run-1");

            testCase.verifyClass( ...
                received, "openmebius.core.notification.Message");
            testCase.verifyEqual(received, message);
            testCase.verifyEqual(message.Level, "warning");
            testCase.verifyEqual(message.Code, "input.invalid");
            testCase.verifyEqual(message.Source, "UnitTest");
            testCase.verifyEqual(message.CorrelationId, "run-1");
            testCase.verifyEqual(message.Timestamp, timestamp);

            function record(value)
                received = value;
            end

        end

    end

end
