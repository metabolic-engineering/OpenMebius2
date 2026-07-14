classdef InstationaryObjective
    % INSTATIONARYOBJECTIVE
    % Evaluates time-course MDV and free-efflux residuals.

    properties (SetAccess = private)
        Problem
        RightHandSide (:, 1) double
        Model
        SubstrateEMU double
        PoolSizes (:, 1) double
        TimePoints (:, 1) double
        ExperimentalMDV (:, :) double
        FragmentMask (:, 1) logical
        EffluxPenalty (1, 1) openmebius.mfa.EffluxPenalty
        MeasurementStandardDeviation (1, 1) double
    end

    methods

        function obj = InstationaryObjective(options)

            arguments
                options.Problem (1, 1) openmebius.mfa.MFAProblem
                options.RightHandSide (:, 1) double
                options.Model
                options.SubstrateEMU double
                options.PoolSizes (:, 1) double
                options.TimePoints (:, 1) double
                options.ExperimentalMDV (:, :) double
                options.FragmentMask (:, 1) logical
                options.EffluxPenalty (1, 1) ...
                    openmebius.mfa.EffluxPenalty = ...
                    openmebius.mfa.EffluxPenalty()
                options.MeasurementStandardDeviation (1, 1) double = 0.01
            end

            if size(options.ExperimentalMDV, 1) ~= ...
                    numel(options.FragmentMask)
                error( ...
                    "OpenMebius2:InstationaryObjective:" + ...
                    "FragmentCountMismatch", ...
                    "The fragment mask must match experimental MDV rows.");
            end

            if size(options.ExperimentalMDV, 2) ~= ...
                    numel(options.TimePoints)
                error( ...
                    "OpenMebius2:InstationaryObjective:" + ...
                    "TimePointCountMismatch", ...
                    "Experimental MDV columns must match time points.");
            end

            if numel(options.TimePoints) < 2 || ...
                    any(~isfinite(options.TimePoints)) || ...
                    any(options.TimePoints < 0)
                error( ...
                    "OpenMebius2:InstationaryObjective:InvalidTimePoints", ...
                    "At least two finite nonnegative time points are required.");
            end

            if isempty(options.PoolSizes) || ...
                    any(~isfinite(options.PoolSizes)) || ...
                    any(options.PoolSizes <= 0)
                error( ...
                    "OpenMebius2:InstationaryObjective:InvalidPoolSize", ...
                    "Pool sizes must be positive and finite.");
            end

            if ~isfinite(options.MeasurementStandardDeviation) || ...
                    options.MeasurementStandardDeviation <= 0
                error( ...
                    "OpenMebius2:InstationaryObjective:" + ...
                    "InvalidMeasurementStandardDeviation", ...
                    "The MDV standard deviation must be positive and finite.");
            end

            obj.Problem = options.Problem;
            obj.RightHandSide = options.RightHandSide;
            obj.Model = options.Model;
            obj.SubstrateEMU = options.SubstrateEMU;
            obj.PoolSizes = options.PoolSizes;
            obj.TimePoints = options.TimePoints;
            obj.ExperimentalMDV = options.ExperimentalMDV;
            obj.FragmentMask = options.FragmentMask;
            obj.EffluxPenalty = options.EffluxPenalty;
            obj.MeasurementStandardDeviation = ...
                options.MeasurementStandardDeviation;

            obj.Problem.extractIndependentValues(obj.RightHandSide);

        end % constructor

        function rss = evaluate(obj, independentValues)

            arguments
                obj (1, 1) openmebius.mfa.InstationaryObjective
                independentValues (:, 1) double
            end

            flux = obj.Problem.solveFlux( ...
                independentValues, ...
                BaseRightHandSide = obj.RightHandSide);
            rss = obj.evaluateFlux(flux);

        end % evaluate

        function rss = evaluateFlux(obj, flux)

            arguments
                obj (1, 1) openmebius.mfa.InstationaryObjective
                flux (:, 1) double
            end

            predictedMDV = obj.predictFlux(flux);
            residual = ...
                (predictedMDV(obj.FragmentMask, :) - ...
                obj.ExperimentalMDV(obj.FragmentMask, :)) ./ ...
                obj.MeasurementStandardDeviation;
            rss = sum(residual .^ 2, "all");
            rss = rss + obj.EffluxPenalty.evaluate(flux);

        end % evaluateFlux

        function mdv = predictFlux(obj, flux)

            arguments
                obj (1, 1) openmebius.mfa.InstationaryObjective
                flux (:, 1) double
            end

            mdv = calculateMDVTimeCourse( ...
                obj.Model, ...
                flux, ...
                obj.SubstrateEMU, ...
                obj.PoolSizes, ...
                obj.TimePoints);

            if ~isequal(size(mdv), size(obj.ExperimentalMDV))
                error( ...
                    "OpenMebius2:InstationaryObjective:" + ...
                    "PredictedMDVDimensionMismatch", ...
                    "Predicted and experimental time-course MDV sizes " + ...
                    "must match.");
            end

        end % predictFlux

    end % methods

end % classdef
