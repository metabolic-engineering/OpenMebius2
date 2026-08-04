classdef TextFileSinkTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function appendsExplicitlyFormattedNotification(testCase)

            path = string(tempname) + ".log";
            cleanup = onCleanup(@() TextFileSinkTest.deleteIfExists(path));
            sink = openmebius.infrastructure.notification.TextFileSink( ...
                Path = path);
            message = openmebius.core.notification.Message( ...
                "hello", ...
                "warning", ...
                EventId = "file-event", ...
                Timestamp = datetime(2026, 7, 21, 1, 2, 3));

            sink.write(message);

            actual = string(fileread(path));
            testCase.verifyTrue(contains( ...
                actual, ...
                "[2026-07-21 01:02:03]" + char(9) + ...
                "[WARNING]" + char(9) + "hello"));

        end

        function rotatesOversizedLog(testCase)

            path = string(tempname) + ".log";
            cleanup = onCleanup(@() TextFileSinkTest.deleteIfExists(path));
            sink = openmebius.infrastructure.notification.TextFileSink( ...
                Path = path, ...
                MaxBytes = 1, ...
                BackupCount = 1);

            sink.write(openmebius.core.notification.Message( ...
                "first", "info", EventId = "rotation-first"));
            sink.write(openmebius.core.notification.Message( ...
                "second", "info", EventId = "rotation-second"));

            testCase.verifyTrue(isfile(path + ".1"));
            testCase.verifyTrue(contains( ...
                string(fileread(path + ".1")), "first"));
            testCase.verifyTrue(contains( ...
                string(fileread(path)), "second"));

        end

    end

    methods (Static, Access = private)

        function deleteIfExists(path)

            paths = [path; path + ".1"; path + ".2"; path + ".3"];

            for item = paths'
                if isfile(item)
                    delete(item);
                end
            end

        end

    end

end
