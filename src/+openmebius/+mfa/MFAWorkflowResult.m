classdef MFAWorkflowResult
    % MFAWORKFLOWRESULT
    % Aggregated and ordered results from an MFA workflow run.

    properties (SetAccess = private)
        ObjectiveValues (1, :) double
        Fluxes (:, :) double
        MDVs double
        Order (1, :) double
        IterationResults cell
        CompletedCount (1, 1) double
        IsCanceled (1, 1) logical
    end

    methods

        function obj = MFAWorkflowResult(options)

            arguments
                options.ObjectiveValues (1, :) double
                options.Fluxes (:, :) double
                options.MDVs double
                options.Order (1, :) double
                options.IterationResults cell
                options.IsCanceled (1, 1) logical = false
            end

            completedCount = numel(options.IterationResults);

            if numel(options.ObjectiveValues) ~= completedCount || ...
                    size(options.Fluxes, 2) ~= completedCount || ...
                    size(options.MDVs, 3) ~= completedCount || ...
                    numel(options.Order) ~= completedCount
                error( ...
                    "OpenMebius2:MFAWorkflowResult:DimensionMismatch", ...
                    "Aggregated MFA results must match the completed " + ...
                    "iteration count.");
            end

            obj.ObjectiveValues = options.ObjectiveValues;
            obj.Fluxes = options.Fluxes;
            obj.MDVs = options.MDVs;
            obj.Order = options.Order;
            obj.IterationResults = options.IterationResults;
            obj.CompletedCount = completedCount;
            obj.IsCanceled = options.IsCanceled;

        end % constructor

    end % methods

end % classdef
