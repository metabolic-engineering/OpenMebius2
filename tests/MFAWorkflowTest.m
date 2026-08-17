classdef MFAWorkflowTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAWorkflowTest.sourcePath());

        end

    end

    methods (Test)

        function aggregatesAndSortsCompletedIterations(testCase)

            observer = helpers.MFAWorkflowObserverStub();
            workflow = openmebius.mfa.MFAWorkflow();
            rightHandSides = [3, 1, 2; 30, 10, 20];

            result = workflow.run( ...
                rightHandSides, ...
                @(rhs) MFAWorkflowTest.createIterationResult(rhs), ...
                ProgressReporter = ...
                @(index, total) ...
                observer.reportProgress(index, total), ...
                IterationCompleted = ...
                @(index, iterationResult) ...
                observer.complete(index, iterationResult), ...
                MDVMapper = @(mdv) [mdv, mdv + 100]);

            testCase.verifyFalse(result.IsCanceled);
            testCase.verifyEqual(result.CompletedCount, 3);
            testCase.verifyEqual(result.ObjectiveValues, [1, 2, 3]);
            testCase.verifyEqual(result.Order, [2, 3, 1]);
            testCase.verifyEqual( ...
                result.Fluxes, [1, 2, 3; 10, 20, 30]);
            testCase.verifyEqual( ...
                result.MDVs(:, :, 1), [1, 101; 10, 110]);
            testCase.verifyEqual(observer.ProgressIndices, [1, 2, 3]);
            testCase.verifyEqual(observer.ProgressTotals, [3, 3, 3]);
            testCase.verifyEqual(observer.CompletedIndices, [1, 2, 3]);
            testCase.verifyEqual( ...
                result.IterationResults{1}.Flux, [3; 30]);

        end

        function preservesExecutionOrderWhenCanceled(testCase)

            observer = helpers.MFAWorkflowObserverStub();
            observer.CancelAfter = 2;
            workflow = openmebius.mfa.MFAWorkflow();

            result = workflow.run( ...
                [3, 1, 2; 30, 10, 20], ...
                @(rhs) MFAWorkflowTest.createIterationResult(rhs), ...
                IterationCompleted = ...
                @(index, iterationResult) ...
                observer.complete(index, iterationResult), ...
                CancellationRequested = ...
                @() observer.cancellationRequested());

            testCase.verifyTrue(result.IsCanceled);
            testCase.verifyEqual(result.CompletedCount, 2);
            testCase.verifyEqual(result.ObjectiveValues, [3, 1]);
            testCase.verifyEqual(result.Order, [1, 2]);
            testCase.verifyEqual(result.Fluxes, [3, 1; 30, 10]);

        end

        function limitsOptimizationsToRequestedIterationCount(testCase)

            observer = helpers.MFAWorkflowObserverStub();
            workflow = openmebius.mfa.MFAWorkflow();

            result = workflow.run( ...
                [3, 1, 2; 30, 10, 20], ...
                @(rhs) MFAWorkflowTest.createIterationResult(rhs), ...
                IterationCount = 2, ...
                ProgressReporter = ...
                @(index, total) ...
                observer.reportProgress(index, total));

            testCase.verifyEqual(result.CompletedCount, 2);
            testCase.verifyEqual(observer.ProgressIndices, [1, 2]);
            testCase.verifyEqual(observer.ProgressTotals, [2, 2]);
            testCase.verifyEqual(result.ObjectiveValues, [1, 3]);
            testCase.verifyEqual(result.Fluxes, [1, 3; 10, 30]);

        end

        function rejectsIterationCountAboveAvailableInitialValues(testCase)

            workflow = openmebius.mfa.MFAWorkflow();

            testCase.verifyError( ...
                @() workflow.run( ...
                zeros(2, 2), ...
                @(rhs) MFAWorkflowTest.createIterationResult(rhs), ...
                IterationCount = 3), ...
                "OpenMebius2:MFAWorkflow:InsufficientInitialValues");

        end

        function rejectsInvalidIterationResult(testCase)

            workflow = openmebius.mfa.MFAWorkflow();

            testCase.verifyError( ...
                @() workflow.run(zeros(2, 1), @(~) struct), ...
                "OpenMebius2:MFAWorkflow:InvalidIterationResult");

        end

        function supportsCancellationBeforeFirstIteration(testCase)

            workflow = openmebius.mfa.MFAWorkflow();

            result = workflow.run( ...
                zeros(2, 1), ...
                @(rhs) MFAWorkflowTest.createIterationResult(rhs), ...
                CancellationRequested = @() true);

            testCase.verifyTrue(result.IsCanceled);
            testCase.verifyEqual(result.CompletedCount, 0);
            testCase.verifyEmpty(result.ObjectiveValues);
            testCase.verifyEmpty(result.Fluxes);
            testCase.verifyEmpty(result.MDVs);

        end

        function reportsConfiguredSerialResources(testCase)

            observer = helpers.AnalysisMessageObserverStub();
            workflow = openmebius.mfa.MFAWorkflow();

            workflow.run( ...
                [2, 1; 20, 10], ...
                @(rhs) MFAWorkflowTest.createIterationResult(rhs), ...
                IterationCount = 2, ...
                WorkerCount = 12, ...
                MessageReporter = @(level, message) ...
                observer.report(level, message));

            resourceMessage = observer.Messages(contains( ...
                observer.Messages, "Optimization resources:"));
            testCase.verifyNumElements(resourceMessage, 1);
            testCase.verifyTrue(contains( ...
                resourceMessage, "configuredWorkers=12"));
            testCase.verifyTrue(contains(resourceMessage, "workers=1"));
            testCase.verifyTrue(contains(resourceMessage, "iterations=2"));

        end

    end

    methods (Static, Access = private)

        function result = createIterationResult(rightHandSide)

            result = openmebius.mfa.MFAIterationResult( ...
                IndependentValues = rightHandSide, ...
                Flux = rightHandSide, ...
                MDV = rightHandSide, ...
                ObjectiveValue = rightHandSide(1), ...
                ExitFlag = 1);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
