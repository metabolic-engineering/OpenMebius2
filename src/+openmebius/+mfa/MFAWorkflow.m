classdef MFAWorkflow
    % MFAWORKFLOW
    % Executes, reports, aggregates, and orders MFA iterations.

    properties (SetAccess = private)
        ParallelPoolManager
    end

    methods

        function obj = MFAWorkflow(options)

            arguments
                options.ParallelPoolManager = openmebius.mfa ...
                    .GridSearchParallelPoolManager()
            end

            obj.ParallelPoolManager = options.ParallelPoolManager;

        end % constructor

        function workflowResult = run( ...
                obj, rightHandSides, iterationFunction, options)

            arguments
                obj (1, 1) openmebius.mfa.MFAWorkflow
                rightHandSides (:, :) double
                iterationFunction (1, 1) function_handle
                options.UseParallel (1, 1) logical = false
                options.WorkerCount (1, 1) double ...
                    {mustBeInteger, mustBePositive} = 8
                options.MessageReporter (1, 1) function_handle = ...
                    @(~, ~) []
                options.ProgressReporter (1, 1) function_handle = ...
                    @(~, ~) []
                options.IterationCompleted (1, 1) function_handle = ...
                    @(~, ~) []
                options.CancellationRequested (1, 1) function_handle = ...
                    @() false
                options.MDVMapper (1, 1) function_handle = @(mdv) mdv
                options.IterationCount (1, 1) double = NaN
            end

            availableCount = size(rightHandSides, 2);
            iterationCount = options.IterationCount;

            if isnan(iterationCount)
                iterationCount = availableCount;
            elseif ~isfinite(iterationCount) || iterationCount <= 0 || ...
                    fix(iterationCount) ~= iterationCount
                error( ...
                    "OpenMebius2:MFAWorkflow:InvalidIterationCount", ...
                    "The MFA iteration count must be a positive integer.");
            end

            if iterationCount == 0
                error( ...
                    "OpenMebius2:MFAWorkflow:MissingIterations", ...
                    "At least one MFA iteration is required.");
            end

            if availableCount < iterationCount
                error( ...
                    "OpenMebius2:MFAWorkflow:InsufficientInitialValues", ...
                    "The requested MFA iteration count exceeds the " + ...
                    "number of available initial values.");
            end

            [physicalCoreCount, logicalProcessorCount] = ...
                obj.ParallelPoolManager.processorCounts();
            workerCount = 1;
            pool = [];

            if options.UseParallel
                requestedWorkerCount = obj.ParallelPoolManager ...
                    .requestedWorkerCount( ...
                    logicalProcessorCount, ...
                    options.WorkerCount, ...
                    iterationCount);
                [workerCount, pool] = ...
                    obj.ParallelPoolManager.ensureProcessPool( ...
                    requestedWorkerCount);

                if workerCount ~= requestedWorkerCount
                    error( ...
                        "OpenMebius2:MFAWorkflow:" + ...
                        "ParallelWorkerCountMismatch", ...
                        "The process pool started with %d workers " + ...
                        "instead of the requested %d.", ...
                        workerCount, requestedWorkerCount);
                end
            end

            options.MessageReporter( ...
                "info", ...
                "Optimization resources: physicalCores=" + ...
                string(physicalCoreCount) + ...
                ", logicalProcessors=" + ...
                string(logicalProcessorCount) + ...
                ", configuredWorkers=" + ...
                string(options.WorkerCount) + ...
                ", workers=" + string(workerCount) + ...
                ", iterations=" + string(iterationCount) + ".");

            iterationResults = cell(1, iterationCount);
            mappedMDVs = cell(1, iterationCount);
            completedCount = 0;
            isCanceled = false;

            if options.UseParallel
                [iterationResults, mappedMDVs, completedCount, ...
                    isCanceled] = obj.runParallel( ...
                    pool, ...
                    rightHandSides(:, 1:iterationCount), ...
                    iterationFunction, ...
                    options.MDVMapper, ...
                    options.ProgressReporter, ...
                    options.IterationCompleted, ...
                    options.CancellationRequested);
            else

                for i = 1:iterationCount
                    if logical(options.CancellationRequested())
                        isCanceled = true;
                        break;
                    end

                    iterationResult = ...
                        iterationFunction(rightHandSides(:, i));
                    obj.validateIterationResult(iterationResult);
                    completedCount = i;
                    iterationResults{i} = iterationResult;
                    mappedMDVs{i} = ...
                        options.MDVMapper(iterationResult.MDV);
                    options.IterationCompleted(i, iterationResult);
                    options.ProgressReporter(i, iterationCount);

                    if logical(options.CancellationRequested())
                        isCanceled = true;
                        break;
                    end
                end

            end

            iterationResults = iterationResults(1:completedCount);
            mappedMDVs = mappedMDVs(1:completedCount);
            [objectiveValues, fluxes, mdvs] = ...
                openmebius.mfa.MFAWorkflow.aggregate( ...
                iterationResults, mappedMDVs);

            if ~isCanceled
                [objectiveValues, order] = ...
                    sort(objectiveValues, "ascend");
                fluxes = fluxes(:, order);
                mdvs = mdvs(:, :, order);
            else
                order = 1:completedCount;
            end

            workflowResult = openmebius.mfa.MFAWorkflowResult( ...
                ObjectiveValues = objectiveValues, ...
                Fluxes = fluxes, ...
                MDVs = mdvs, ...
                Order = order, ...
                IterationResults = iterationResults, ...
                IsCanceled = isCanceled);

        end % run

    end % methods

    methods (Access = private)

        function [iterationResults, mappedMDVs, completedCount, ...
                isCanceled] = runParallel( ...
                obj, pool, rightHandSides, iterationFunction, ...
                mdvMapper, progressReporter, iterationCompleted, ...
                cancellationRequested)

            iterationCount = size(rightHandSides, 2);
            iterationResults = cell(1, iterationCount);
            mappedMDVs = cell(1, iterationCount);
            completedIndices = zeros(1, iterationCount);
            completedCount = 0;
            isCanceled = logical(cancellationRequested());

            if isCanceled
                iterationResults = cell(1, 0);
                mappedMDVs = cell(1, 0);
                return
            end

            futures = parallel.FevalFuture.empty;

            for i = 1:iterationCount
                futures(i) = parfeval( ...
                    pool, iterationFunction, 1, rightHandSides(:, i));
            end

            cancelOutstanding = onCleanup(@() cancel(futures));

            while completedCount < iterationCount
                if logical(cancellationRequested())
                    isCanceled = true;
                    break
                end

                [iterationIndex, iterationResult] = ...
                    fetchNext(futures, 0.25);

                if isempty(iterationIndex) || iterationIndex == 0
                    continue
                end

                obj.validateIterationResult(iterationResult);
                completedCount = completedCount + 1;
                completedIndices(completedCount) = iterationIndex;
                iterationResults{iterationIndex} = iterationResult;
                mappedMDVs{iterationIndex} = ...
                    mdvMapper(iterationResult.MDV);
                progressReporter(completedCount, iterationCount);
                iterationCompleted(iterationIndex, iterationResult);
            end

            if isCanceled
                completedIndices = ...
                    completedIndices(1:completedCount);
                iterationResults = ...
                    iterationResults(completedIndices);
                mappedMDVs = mappedMDVs(completedIndices);
            end

            clear cancelOutstanding

        end % runParallel

    end % methods (Access = private)

    methods (Static, Access = private)

        function validateIterationResult(iterationResult)

            if ~isa(iterationResult, ...
                    'openmebius.mfa.MFAIterationResult')
                error( ...
                    "OpenMebius2:MFAWorkflow:" + ...
                    "InvalidIterationResult", ...
                    "The iteration function must return an " + ...
                    "MFAIterationResult.");
            end

        end % validateIterationResult

        function [objectiveValues, fluxes, mdvs] = ...
                aggregate(iterationResults, mappedMDVs)

            completedCount = numel(iterationResults);

            if completedCount == 0
                objectiveValues = zeros(1, 0);
                fluxes = zeros(0, 0);
                mdvs = zeros(0, 0, 0);
                return;
            end

            objectiveValues = cellfun( ...
                @(result) result.ObjectiveValue, iterationResults);
            fluxes = cell2mat(cellfun( ...
                @(result) result.Flux, ...
                iterationResults, ...
                UniformOutput = false));
            expectedMDVSize = size(mappedMDVs{1});

            if any(cellfun( ...
                    @(mdv) ~isequal(size(mdv), expectedMDVSize), ...
                    mappedMDVs))
                error( ...
                    "OpenMebius2:MFAWorkflow:MDVDimensionMismatch", ...
                    "Mapped MDV dimensions must match across iterations.");
            end

            mdvs = cat(3, mappedMDVs{:});

        end % aggregate

    end % methods (Static, Access = private)

end % classdef
