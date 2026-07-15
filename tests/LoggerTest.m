classdef LoggerTest < matlab.unittest.TestCase

    methods (Test)

        function normalizeLevelAcceptsAliases(testCase)

            testCase.verifyEqual( ...
                openmebius.infrastructure.logging.Logger.normalizeLevel("warn"), ...
                "Warning");
            testCase.verifyEqual( ...
                openmebius.infrastructure.logging.Logger.normalizeLevel("error"), ...
                "Error");
            testCase.verifyEqual( ...
                openmebius.infrastructure.logging.Logger.normalizeLevel("information"), ...
                "Info");
            testCase.verifyEqual( ...
                openmebius.infrastructure.logging.Logger.normalizeLevel("completed"), ...
                "Success");

        end

        function shouldLogUsesSeverityThreshold(testCase)

            testCase.verifyTrue( ...
                openmebius.infrastructure.logging.Logger.shouldLog( ...
                "Error", ...
                "Warning"));
            testCase.verifyFalse( ...
                openmebius.infrastructure.logging.Logger.shouldLog( ...
                "Info", ...
                "Warning"));

        end

        function formatDatedMessageUsesUnifiedColumns(testCase)

            timestamp = datetime(2026, 7, 12, 23, 10, 11);

            actual = openmebius.infrastructure.logging.Logger ...
                .formatDatedMessage( ...
                "hello", ...
                "Info", ...
                Timestamp = timestamp);

            testCase.verifyEqual( ...
                actual, ...
                "[2026-07-12 23:10:11]" + char(9) + ...
                "[INFO]" + char(9) + "hello");

        end

        function formatMessageOmitsTimestamp(testCase)

            actual = openmebius.infrastructure.logging.Logger ...
                .formatMessage("hello", "Warning");

            testCase.verifyEqual( ...
                actual, ...
                "[WARNING]" + char(9) + "hello");

        end

        function formatDatedLinesExpandsMultilineMessages(testCase)

            timestamp = datetime(2026, 7, 12, 23, 10, 11);

            actual = openmebius.infrastructure.logging.Logger ...
                .formatDatedLines( ...
                "hello" + newline + "world", ...
                "Error", ...
                Timestamp = timestamp);

            expectedPrefix = "[2026-07-12 23:10:11]" + char(9) + ...
                "[ERROR]" + char(9);

            testCase.verifyEqual( ...
                actual, ...
                [expectedPrefix + "hello"; expectedPrefix + "world"]);

        end

        function preformattedLogTextIsNotWrappedAgain(testCase)

            formatted = "[2026-07-12 23:10:11]" + char(9) + ...
                "[ERROR]" + char(9) + "hello";

            actual = openmebius.infrastructure.logging.Logger ...
                .formatDatedMessage(formatted, "Info");

            testCase.verifyEqual(actual, formatted);

        end

        function notificationAcceptsLoggerLevelAliases(testCase)

            import openmebius.presentation.notification.Notification

            notification = Notification("hello", "completed");

            testCase.verifyEqual(notification.Level, "success");

        end

        function notificationUsesLoggerFormat(testCase)

            import openmebius.presentation.notification.Notification

            timestamp = datetime(2026, 7, 12, 23, 10, 11);
            notification = Notification( ...
                "hello", ...
                "warning", ...
                Timestamp = timestamp);

            testCase.verifyEqual( ...
                notification.toLogText(), ...
                "[2026-07-12 23:10:11]" + char(9) + ...
                "[WARNING]" + char(9) + "hello");

        end

        function notificationFormatsEachMultilineLogRow(testCase)

            import openmebius.presentation.notification.Notification

            timestamp = datetime(2026, 7, 12, 23, 10, 11);
            notification = Notification( ...
                "hello" + newline + "world", ...
                "fatal", ...
                Timestamp = timestamp);

            expectedPrefix = "[2026-07-12 23:10:11]" + char(9) + ...
                "[FATAL]" + char(9);

            testCase.verifyEqual( ...
                notification.toLogText(), ...
                expectedPrefix + "hello" + newline + ...
                expectedPrefix + "world");

        end

        function readTailReturnsRequestedLastLines(testCase)

            pathFile = string(fullfile(tempdir, "openmebius2-logger-test.log"));
            testCase.addTeardown( ...
                @() LoggerTest.deleteIfExists(pathFile));

            fid = fopen(pathFile, "w");
            testCase.assertGreaterThan(fid, 0);
            fprintf(fid, "one\n");
            fprintf(fid, "two\n");
            fprintf(fid, "three\n");
            fclose(fid);

            lines = openmebius.infrastructure.logging.Logger ...
                .readTail(pathFile, MaxLines = 2);

            testCase.verifyEqual(lines, ["two"; "three"]);

        end

    end

    methods (Static, Access = private)

        function deleteIfExists(pathFile)

            if isfile(pathFile)
                delete(pathFile);
            end

        end

    end

end
