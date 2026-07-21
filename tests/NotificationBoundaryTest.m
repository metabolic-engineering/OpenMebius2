classdef NotificationBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function coreLayersDoNotWriteNotificationDestinations(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            directories = [ ...
                string(fullfile(root, "src", "+openmebius", "+application")); ...
                string(fullfile(root, "src", "+openmebius", "+domain")); ...
                string(fullfile(root, "src", "+openmebius", "+mfa"))];
            forbidden = [ ...
                "openmebius.infrastructure.logging"; ...
                "SlackWebhookNotifier"; ...
                "configureDefaultDiary"];

            for directory = directories'
                files = dir(fullfile(directory, "**", "*.m"));

                for fileIndex = 1:numel(files)
                    path = fullfile(files(fileIndex).folder, ...
                        files(fileIndex).name);
                    source = string(fileread(path));

                    for token = forbidden'
                        testCase.verifyFalse(contains(source, token), ...
                            path + " contains " + token);
                    end

                    directOutput = regexp( ...
                        source, ...
                        '(?m)^\s*(disp|warning|uialert)\s*\(', ...
                        'match');
                    testCase.verifyEmpty(directOutput, path);
                end
            end

        end

        function mainAppUsesDispatcherInsteadOfDiary(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread(fullfile( ...
                root, "src", "OpenMebius2_exported.m")));

            testCase.verifyTrue(contains( ...
                source, "NotificationDispatcher.publish(message)"));
            testCase.verifyTrue(contains( ...
                source, "configureNotificationSinks"));
            testCase.verifyFalse(contains(source, "configureDefaultDiary"));
            testCase.verifyFalse(contains(source, "notifySlackBatchCompleted"));

        end

    end

end
