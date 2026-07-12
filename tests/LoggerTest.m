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

        function formatDatedMessageMatchesLegacyShape(testCase)

            timestamp = datetime(2026, 7, 12, 23, 10, 11);

            actual = openmebius.infrastructure.logging.Logger ...
                .formatDatedMessage( ...
                "hello", ...
                "Info", ...
                Timestamp = timestamp);

            testCase.verifyEqual( ...
                actual, ...
                "2026-07-12 23:10:11 Info: hello");

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
