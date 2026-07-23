classdef MonteCarloConfidenceIntervalResult
    % MONTECARLOCONFIDENCEINTERVALRESULT
    % Immutable result of a Monte Carlo confidence-interval run.

    properties (SetAccess = private)
        LowerBounds (:, :) double
        UpperBounds (:, :) double
        PerturbedMDVs double
        Fluxes (:, :) double
        IterationCount (1, 1) double
        ElapsedTime (1, 1) double
        IsCanceled (1, 1) logical
    end

    methods

        function obj = MonteCarloConfidenceIntervalResult(options)

            arguments
                options.LowerBounds (:, :) double
                options.UpperBounds (:, :) double
                options.PerturbedMDVs double
                options.Fluxes (:, :) double
                options.IterationCount (1, 1) double
                options.ElapsedTime (1, 1) double
                options.IsCanceled (1, 1) logical = false
            end

            if ~isequal(size(options.LowerBounds), ...
                    size(options.UpperBounds))
                error( ...
                    "OpenMebius2:MonteCarloCI:BoundSizeMismatch", ...
                    "Lower and upper confidence-interval bounds " + ...
                "must have the same size.");
            end

            if size(options.LowerBounds, 1) ~= ...
                    size(options.Fluxes, 1)
                error( ...
                    "OpenMebius2:MonteCarloCI:FluxSizeMismatch", ...
                    "Confidence-interval bounds and sampled fluxes " + ...
                "must have the same row count.");
            end

            if size(options.PerturbedMDVs, 3) ~= ...
                    options.IterationCount || ...
                    size(options.Fluxes, 2) ~= options.IterationCount
                error( ...
                    "OpenMebius2:MonteCarloCI:IterationSizeMismatch", ...
                    "Sampled MDVs and fluxes must match the configured " + ...
                "iteration count.");
            end

            obj.LowerBounds = options.LowerBounds;
            obj.UpperBounds = options.UpperBounds;
            obj.PerturbedMDVs = options.PerturbedMDVs;
            obj.Fluxes = options.Fluxes;
            obj.IterationCount = options.IterationCount;
            obj.ElapsedTime = options.ElapsedTime;
            obj.IsCanceled = options.IsCanceled;

        end % constructor

    end % methods

end % classdef
