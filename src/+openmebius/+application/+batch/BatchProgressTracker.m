classdef BatchProgressTracker < handle
    % BATCHPROGRESSTRACKER Aggregates weighted analysis task progress.

    properties (SetAccess = private)
        BatchTable table = table()
        Reporter (1, 1) function_handle = @(~) []
        Runnable (:, 1) logical = false(0, 1)
        PhaseTotals (:, 3) double = zeros(0, 3)
        PhaseWeights (:, 3) double = zeros(0, 3)
        PhaseCompleted (:, 3) double = zeros(0, 3)
    end

    methods

        function obj = BatchProgressTracker(batchTable, model, reporter)

            arguments
                batchTable table
                model
                reporter (1, 1) function_handle = @(~) []
            end

            obj.BatchTable = batchTable;
            obj.Reporter = reporter;
            batchCount = height(batchTable);
            obj.Runnable = false(batchCount, 1);
            obj.PhaseTotals = zeros(batchCount, 3);
            obj.PhaseWeights = zeros(batchCount, 3);
            obj.PhaseCompleted = zeros(batchCount, 3);

            for index = 1:batchCount
                config = batchTable.config(index);
                obj.Runnable(index) = ...
                    lower(strtrim(string(config.status))) == "ready";

                if ~obj.Runnable(index)
                    continue
                end

                [obj.PhaseTotals(index, :), ...
                    obj.PhaseWeights(index, :)] = ...
                    obj.taskPlan(config, model);
            end

        end % constructor

        function reportAnalysisProgress( ...
                obj, batchIndex, phase, completed, total)

            phaseIndex = obj.phaseIndex(phase);
            completed = double(completed);
            total = double(total);

            if ~obj.Runnable(batchIndex) || ...
                    ~isscalar(completed) || ~isfinite(completed) || ...
                    ~isscalar(total) || ~isfinite(total) || total < 0
                return
            end

            % Grid-search can determine the exact number of nonconstant
            % fluxes only after FVA has completed. Replace the run-start
            % estimate as soon as that exact total is reported.
            if phaseIndex == 3
                obj.PhaseTotals(batchIndex, phaseIndex) = total;
            end

            plannedTotal = obj.PhaseTotals(batchIndex, phaseIndex);
            boundedCompleted = max(0, min(completed, plannedTotal));
            obj.PhaseCompleted(batchIndex, phaseIndex) = max( ...
                obj.PhaseCompleted(batchIndex, phaseIndex), ...
                boundedCompleted);
            progress = obj.progressStruct( ...
                batchIndex, ...
                "running", ...
                obj.progressMessage(phaseIndex, completed, total));
            obj.Reporter(progress);

        end % reportAnalysisProgress

        function reportStatus(obj, batchIndex, status)

            status = lower(strtrim(string(status)));

            if obj.Runnable(batchIndex) && ...
                    ismember(status, ["finished", "error", "warning"])
                obj.PhaseCompleted(batchIndex, :) = ...
                    obj.PhaseTotals(batchIndex, :);
            end

            obj.Reporter(obj.progressStruct(batchIndex, status, ""));

        end % reportStatus

        function value = rate(obj)

            totalLoad = sum( ...
                obj.PhaseTotals .* obj.PhaseWeights, "all");

            if totalLoad <= 0
                value = 0;
                return
            end

            completedLoad = sum( ...
                obj.PhaseCompleted .* obj.PhaseWeights, "all");
            value = max(0, min(1, completedLoad / totalLoad));

        end % rate

    end % methods

    methods (Access = private)

        function progress = progressStruct( ...
                obj, batchIndex, status, message)

            progress = struct( ...
                'id', obj.BatchTable.id(batchIndex), ...
                'status', string(status), ...
                'rate', obj.rate());

            if strlength(string(message)) > 0
                progress.message = string(message);
            end

        end % progressStruct

    end % methods (Access = private)

    methods (Static, Access = private)

        function [totals, weights] = taskPlan(config, model)

            totals = [double(config.iteration), 0, 0];
            weights = [1, 0, 0];

            if ~logical(config.isCalcCI) || ...
                    logical(config.suggestNextFlux)
                return
            end

            method = lower(strtrim(string(config.CIConf.algorithm)));

            if method == "monte carlo"
                totals(2) = double(config.CIConf.MC.iteration);
                weights(2) = double( ...
                    config.CIConf.MC.theNumberOfRuns);
                return
            end

            if method ~= "grid search"
                return
            end

            grid = config.CIConf.grid;
            totals(3) = openmebius.application.batch ...
                .BatchProgressTracker.gridReactionCount(grid, model);
            weights(3) = double(grid.iteration) * ...
                (double(grid.points) + 2 * double(grid.maximumTrial));

        end % taskPlan

        function count = gridReactionCount(grid, model)

            reactions = grid.reactions;
            selection = logical(reactions.select(:));
            reactionIDs = string(reactions.id(:));

            if ~isempty(reactionIDs) && ...
                    numel(selection) == numel(reactionIDs)
                count = nnz(selection);
                return
            end

            try
                modelTable = model.getModelTable();
                % The unfiltered solver profile contains the model
                % reactions plus the biomass flux.
                count = height(modelTable) + 1;
            catch
                % The exact count will be supplied by Grid Search after
                % FVA. Keep the estimate empty until then.
                count = 0;
            end

        end % gridReactionCount

        function index = phaseIndex(phase)

            switch lower(strtrim(string(phase)))
                case "optimization"
                    index = 1;
                case "monte-carlo"
                    index = 2;
                case "grid-search"
                    index = 3;
                otherwise
                    error( ...
                        "OpenMebius2:BatchProgressTracker:" + ...
                        "UnknownPhase", ...
                        "Unknown analysis progress phase: %s.", phase);
            end

        end % phaseIndex

        function message = progressMessage(phaseIndex, completed, total)

            switch phaseIndex
                case 1
                    label = "Optimization";
                    suffix = "";
                case 2
                    label = "Monte Carlo";
                    suffix = "";
                otherwise
                    label = "Grid search";
                    suffix = " reactions";
            end

            message = label + ": " + string(completed) + ...
                "/" + string(total) + suffix;

        end % progressMessage

    end % methods (Static, Access = private)

end % classdef
