classdef EffluxPerturbationProfile
    % EFFLUXPERTURBATIONPROFILE
    % Immutable free-efflux measurements mapped to flux indices.

    properties (SetAccess = private)
        ReactionIndices (:, 1) double
        ExperimentalValues (:, 1) double
        StandardDeviations (:, 1) double
    end

    properties (Dependent, SetAccess = private)
        MeasurementCount (1, 1) double
    end

    methods

        function obj = EffluxPerturbationProfile(options)

            arguments
                options.ReactionIndices (:, 1) double = zeros(0, 1)
                options.ExperimentalValues (:, 1) double = zeros(0, 1)
                options.StandardDeviations (:, 1) double = zeros(0, 1)
            end

            measurementCount = numel(options.ReactionIndices);

            if numel(options.ExperimentalValues) ~= measurementCount || ...
                    numel(options.StandardDeviations) ~= measurementCount
                error( ...
                    "OpenMebius2:EffluxPerturbationProfile:" + ...
                    "DimensionMismatch", ...
                    "Efflux perturbation vectors must have the same " + ...
                "length.");
            end

            if any(~isfinite(options.ReactionIndices)) || ...
                    any(options.ReactionIndices < 1) || ...
                    any(options.ReactionIndices ~= ...
                    fix(options.ReactionIndices))
                error( ...
                    "OpenMebius2:EffluxPerturbationProfile:" + ...
                    "InvalidReactionIndex", ...
                "Efflux reaction indices must be positive integers.");
            end

            if numel(unique(options.ReactionIndices)) ~= measurementCount
                error( ...
                    "OpenMebius2:EffluxPerturbationProfile:" + ...
                    "DuplicateReactionIndex", ...
                "Each efflux reaction index must be unique.");
            end

            if any(~isfinite(options.ExperimentalValues))
                error( ...
                    "OpenMebius2:EffluxPerturbationProfile:" + ...
                    "InvalidExperimentalValue", ...
                "Efflux experimental values must be finite.");
            end

            if any(~isfinite(options.StandardDeviations)) || ...
                    any(options.StandardDeviations <= 0)
                error( ...
                    "OpenMebius2:EffluxPerturbationProfile:" + ...
                    "InvalidStandardDeviation", ...
                    "Efflux standard deviations must be positive and " + ...
                "finite.");
            end

            obj.ReactionIndices = options.ReactionIndices;
            obj.ExperimentalValues = options.ExperimentalValues;
            obj.StandardDeviations = options.StandardDeviations;

        end % constructor

        function value = get.MeasurementCount(obj)

            value = numel(obj.ReactionIndices);

        end

    end % methods

end % classdef
