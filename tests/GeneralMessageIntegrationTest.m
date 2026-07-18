classdef GeneralMessageIntegrationTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(GeneralMessageIntegrationTest.sourcePath());

        end

    end

    methods (Test)

        function batchPublishesTypedInputError(testCase)

            experimentDirectory = string(tempname);
            resultDirectory = string(tempname);
            mkdir(experimentDirectory);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                GeneralMessageIntegrationTest.removeDirectories( ...
                [experimentDirectory; resultDirectory]));
            experiments = helpers.BatchExperimentNotificationStub( ...
                experimentDirectory);
            batch = Batch(experiments);
            observer = helpers.AnalysisNotificationObserverStub();
            status = batch.runBatch( ...
                resultDirectory, ...
                NotificationReporter = ...
                    @(notification) observer.publish(notification));

            testCase.verifyEqual(status, "error");
            testCase.verifyEqual(observer.EventCount, 1);
            testCase.verifyClass( ...
                observer.LastEvent, ...
                'openmebius.presentation.notification.Notification');
            testCase.verifyEqual( ...
                observer.LastEvent.Level, "error");
            testCase.verifyTrue(contains( ...
                observer.LastEvent.Message, ...
                "MDV data has not been calculated"));

        end

        function resultWorkspacePublishesTypedLoadError(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                GeneralMessageIntegrationTest.removeDirectories( ...
                resultDirectory));
            observer = helpers.AnalysisNotificationObserverStub();
            result = openmebius.application.result.ResultWorkspace( ...
                resultDirectory, ...
                NotificationReporter = ...
                    @(notification) observer.publish(notification));
            rmdir(resultDirectory, 's');

            result.loadResultFile("missing");

            testCase.verifyEqual(observer.EventCount, 1);
            testCase.verifyClass( ...
                observer.LastEvent, ...
                'openmebius.presentation.notification.Notification');
            testCase.verifyEqual( ...
                observer.LastEvent.Level, "error");
            testCase.verifyEqual( ...
                observer.LastEvent.Message, ...
                "Result directory does not exist: " + resultDirectory);

        end

        function resultWorkspaceConstructorRejectsMissingDirectory(testCase)

            resultDirectory = string(tempname);

            testCase.verifyError( ...
                @() openmebius.application.result.ResultWorkspace( ...
                resultDirectory), ...
                "OpenMebius2:ResultRepository:DirectoryNotFound");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

        function removeDirectories(directories)

            for directory = string(directories(:))'
                if isfolder(directory)
                    rmdir(directory, 's');
                end
            end

        end

    end

end
