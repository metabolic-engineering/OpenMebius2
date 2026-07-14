classdef MFAWorkflow
    % MFAWORKFLOW
    % Executes, reports, aggregates, and orders MFA iterations.

    methods

        function workflowResult = run( ...
                ~, rightHandSides, iterationFunction, options)

            arguments
                ~
                rightHandSides (:, :) double
                iterationFunction (1, 1) function_handle
                options.ProgressReporter (1, 1) function_handle = ...
                    @(~, ~) []
                options.IterationCompleted (1, 1) function_handle = ...
                    @(~, ~) []
                options.CancellationRequested (1, 1) function_handle = ...
                    @() false
                options.MDVMapper (1, 1) function_handle = @(mdv) mdv
            end

            iterationCount = size(rightHandSides, 2);

            if iterationCount == 0
                error( ...
                    "OpenMebius2:MFAWorkflow:MissingIterations", ...
                    "At least one MFA iteration is required.");
            end

            iterationResults = cell(1, iterationCount);
            mappedMDVs = cell(1, iterationCount);
            completedCount = 0;
            isCanceled = false;

            for i = 1:iterationCount
                if logical(options.CancellationRequested())
                    isCanceled = true;
                    break;
                end

                options.ProgressReporter(i, iterationCount);
                iterationResult = ...
                    iterationFunction(rightHandSides(:, i));

                if ~isa(iterationResult, ...
                        'openmebius.mfa.MFAIterationResult')
                    error( ...
                        "OpenMebius2:MFAWorkflow:" + ...
                        "InvalidIterationResult", ...
                        "The iteration function must return an " + ...
                        "MFAIterationResult.");
                end

                completedCount = i;
                iterationResults{i} = iterationResult;
                mappedMDVs{i} = options.MDVMapper(iterationResult.MDV);
                options.IterationCompleted(i, iterationResult);

                if logical(options.CancellationRequested())
                    isCanceled = true;
                    break;
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

    methods (Static, Access = private)

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
