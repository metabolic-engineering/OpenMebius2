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
            batch = openmebius.application.batch.BatchSession(experiments);
            observer = helpers.AnalysisNotificationObserverStub();
            result = batch.runBatch( ...
                resultDirectory, ...
                NotificationReporter = ...
                @(notification) observer.publish(notification));

            testCase.verifyTrue(result.isFailure());
            testCase.verifyEqual(observer.EventCount, 1);
            testCase.verifyClass( ...
                observer.LastEvent, ...
                'openmebius.core.notification.Message');
            testCase.verifyEqual( ...
                observer.LastEvent.Level, "error");
            testCase.verifyTrue(contains( ...
                observer.LastEvent.Text, ...
                "MDV data has not been calculated"));

        end

        function resultWorkspacePublishesTypedLoadError(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                GeneralMessageIntegrationTest.removeDirectories( ...
                resultDirectory));
            observer = helpers.AnalysisNotificationObserverStub();
            result = openmebius.application.result.ResultCatalog( ...
                resultDirectory, ...
                NotificationReporter = ...
                @(notification) observer.publish(notification));
            rmdir(resultDirectory, 's');

            result.loadResultFile("missing");

            testCase.verifyEqual(observer.EventCount, 2);
            testCase.verifyClass( ...
                observer.LastEvent, ...
                'openmebius.core.notification.Message');
            testCase.verifyEqual( ...
                observer.LastEvent.Level, "error");
            testCase.verifyEqual( ...
                observer.LastEvent.Text, ...
                "Result directory does not exist: " + resultDirectory);

        end

        function resultWorkspaceConstructorRejectsMissingDirectory(testCase)

            resultDirectory = string(tempname);

            testCase.verifyError( ...
                @() openmebius.application.result.ResultCatalog( ...
                resultDirectory), ...
                "OpenMebius2:ResultRepository:DirectoryNotFound");

        end

        function comparisonExceptionIsPublishedAsPassiveError(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                GeneralMessageIntegrationTest.removeDirectories( ...
                resultDirectory));
            observer = helpers.AnalysisNotificationObserverStub();
            queryService = helpers.ResultComparisonQueryServiceStub();
            result = openmebius.application.result.ResultCatalog( ...
                resultDirectory, ...
                NotificationReporter = ...
                @(notification) observer.publish(notification), ...
                QueryService = queryService, ...
                TableBuilder = helpers.FailingResultTableBuilderStub());

            comparison = result.getFluxComparison( ...
                ["first", "second"], ["First", "Second"]);

            testCase.verifyEmpty(comparison);
            testCase.verifyEqual(observer.LastEvent.Level, "error");
            testCase.verifyEqual( ...
                observer.LastEvent.Code, "result.comparison.failed");
            testCase.verifyEqual( ...
                observer.LastEvent.Attention, "passive");
            testCase.verifyTrue(contains( ...
                observer.LastEvent.Text, "synthetic comparison failure"));

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
