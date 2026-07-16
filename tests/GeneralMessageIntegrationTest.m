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
            listener = addlistener( ...
                batch, ...
                'GeneralMsg', ...
                @(~, eventData) observer.publish(eventData));
            listenerCleanup = onCleanup(@() delete(listener));

            status = batch.runBatch(resultDirectory);

            testCase.verifyEqual(status, "error");
            testCase.verifyEqual(observer.EventCount, 1);
            testCase.verifyClass( ...
                observer.LastEvent, ...
                ['openmebius.presentation.notification.' ...
                'GeneralMessageEventData']);
            testCase.verifyEqual( ...
                observer.LastEvent.data.status, "error");
            testCase.verifyTrue(contains( ...
                observer.LastEvent.data.msg, ...
                "MDV data has not been calculated"));

        end

        function ioResultPublishesTypedLoadError(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                GeneralMessageIntegrationTest.removeDirectories( ...
                resultDirectory));
            result = IOResult(resultDirectory);
            observer = helpers.AnalysisNotificationObserverStub();
            listener = addlistener( ...
                result, ...
                'GeneralMsg', ...
                @(~, eventData) observer.publish(eventData));
            listenerCleanup = onCleanup(@() delete(listener));
            rmdir(resultDirectory, 's');

            result.loadResultFile("missing");

            testCase.verifyEqual(observer.EventCount, 1);
            testCase.verifyClass( ...
                observer.LastEvent, ...
                ['openmebius.presentation.notification.' ...
                'GeneralMessageEventData']);
            testCase.verifyEqual( ...
                observer.LastEvent.data.status, "error");
            testCase.verifyEqual( ...
                observer.LastEvent.data.msg, ...
                "Result directory does not exist: " + resultDirectory);

        end

        function ioResultConstructorRejectsMissingDirectory(testCase)

            resultDirectory = string(tempname);

            testCase.verifyError( ...
                @() IOResult(resultDirectory), ...
                "OpenMebius2:ResultRepository:DirectoryNotFound");

        end

        function batchProgressEventRejectsGeneralMessages(testCase)

            progress = struct( ...
                id = "batch-1", ...
                status = "finished", ...
                rate = 1);
            eventData = BatchProgressEventData( ...
                "BatchIteration", progress);

            testCase.verifyEqual(eventData.data, progress);
            testCase.verifyError( ...
                @() BatchProgressEventData("GeneralMsg", struct), ...
                "OpenMebius2:BatchProgressEventData:" + ...
                "UnsupportedType");

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
