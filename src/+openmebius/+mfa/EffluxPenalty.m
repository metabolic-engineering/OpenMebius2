classdef EffluxPenalty
    % EFFLUXPENALTY
    % Evaluates the weighted residual of measured free effluxes.

    properties (SetAccess = private)
        ReactionIndices (:, 1) double
        ExperimentalValues (:, 1) double
        StandardDeviations (:, 1) double
    end

    methods

        function obj = EffluxPenalty(options)

            arguments
                options.ReactionIndices (:, 1) double = zeros(0, 1)
                options.ExperimentalValues (:, 1) double = zeros(0, 1)
                options.StandardDeviations (:, 1) double = zeros(0, 1)
            end

            measurementCount = numel(options.ReactionIndices);

            if numel(options.ExperimentalValues) ~= measurementCount || ...
                    numel(options.StandardDeviations) ~= measurementCount
                error( ...
                    "OpenMebius2:EffluxPenalty:DimensionMismatch", ...
                "Efflux penalty vectors must have the same length.");
            end

            if any(~isfinite(options.ReactionIndices)) || ...
                    any(options.ReactionIndices < 1) || ...
                    any(options.ReactionIndices ~= fix(options.ReactionIndices))
                error( ...
                    "OpenMebius2:EffluxPenalty:InvalidReactionIndex", ...
                "Efflux reaction indices must be positive integers.");
            end

            if any(~isfinite(options.ExperimentalValues))
                error( ...
                    "OpenMebius2:EffluxPenalty:InvalidExperimentalValue", ...
                "Efflux experimental values must be finite.");
            end

            if any(~isfinite(options.StandardDeviations)) || ...
                    any(options.StandardDeviations <= 0)
                error( ...
                    "OpenMebius2:EffluxPenalty:InvalidStandardDeviation", ...
                "Efflux standard deviations must be positive and finite.");
            end

            obj.ReactionIndices = options.ReactionIndices;
            obj.ExperimentalValues = options.ExperimentalValues;
            obj.StandardDeviations = options.StandardDeviations;

        end % constructor

        function rss = evaluate(obj, flux)

            arguments
                obj (1, 1) openmebius.mfa.EffluxPenalty
                flux (:, :) double
            end

            fluxCount = size(flux, 2);

            if isempty(obj.ReactionIndices)
                rss = zeros(1, fluxCount);
                return;
            end

            if max(obj.ReactionIndices) > size(flux, 1)
                error( ...
                    "OpenMebius2:EffluxPenalty:FluxDimensionMismatch", ...
                "Efflux reaction indices exceed the flux vector length.");
            end

            simulatedValues = flux(obj.ReactionIndices, :);
            normalizedResiduals = ...
                (simulatedValues - obj.ExperimentalValues) ./ ...
                obj.StandardDeviations;
            rss = sum(normalizedResiduals .^ 2, 1);

        end % evaluate

    end % methods

end % classdef
