classdef InstationaryObjective
    % INSTATIONARYOBJECTIVE
    % Evaluates time-course MDV and free-efflux residuals.

    properties (SetAccess = private)
        Problem
        RightHandSide (:, 1) double
        Model
        SubstrateEMU double
        Input
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
                options.Input (1, 1) openmebius.mfa.InstationaryInput
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
                    numel(options.Input.TimePoints)
                error( ...
                    "OpenMebius2:InstationaryObjective:" + ...
                    "TimePointCountMismatch", ...
                "Experimental MDV columns must match time points.");
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
            obj.Input = options.Input;
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
                obj.Input.PoolSizes, ...
                obj.Input.TimePoints);

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
