classdef SteadyStateObjective
    % STEADYSTATEOBJECTIVE
    % Evaluates steady-state MDV and free-efflux residuals.

    properties (SetAccess = private)
        Problem
        RightHandSide (:, 1) double
        Model
        SubstrateEMUs cell
        ExperimentalMDV (:, :) double
        FragmentMask (:, 1) logical
        EffluxPenalty (1, 1) openmebius.mfa.EffluxPenalty
        MeasurementStandardDeviation (1, 1) double
        MDVPredictor (1, 1) openmebius.mfa.SteadyStateMDVPredictor
    end

    methods

        function obj = SteadyStateObjective(options)

            arguments
                options.Problem (1, 1) openmebius.mfa.MFAProblem
                options.RightHandSide (:, 1) double
                options.Model
                options.SubstrateEMUs cell
                options.ExperimentalMDV (:, :) double
                options.FragmentMask (:, 1) logical
                options.EffluxPenalty (1, 1) ...
                    openmebius.mfa.EffluxPenalty = ...
                    openmebius.mfa.EffluxPenalty()
                options.MeasurementStandardDeviation (1, 1) double = 0.01
                options.MDVPredictor (1, 1) ...
                    openmebius.mfa.SteadyStateMDVPredictor = ...
                    openmebius.mfa.SteadyStateMDVPredictor()
            end

            experimentCount = numel(options.SubstrateEMUs);

            if size(options.ExperimentalMDV, 2) ~= experimentCount
                error( ...
                    "OpenMebius2:SteadyStateObjective:ExperimentCountMismatch", ...
                    "Experimental MDV columns must match substrate EMUs.");
            end

            if size(options.ExperimentalMDV, 1) ~= ...
                    numel(options.FragmentMask)
                error( ...
                    "OpenMebius2:SteadyStateObjective:FragmentCountMismatch", ...
                    "The fragment mask must match experimental MDV rows.");
            end

            if ~isfinite(options.MeasurementStandardDeviation) || ...
                    options.MeasurementStandardDeviation <= 0
                error( ...
                    "OpenMebius2:SteadyStateObjective:" + ...
                    "InvalidMeasurementStandardDeviation", ...
                    "The MDV standard deviation must be positive and finite.");
            end

            obj.Problem = options.Problem;
            obj.RightHandSide = options.RightHandSide;
            obj.Model = options.Model;
            obj.SubstrateEMUs = options.SubstrateEMUs(:).';
            obj.ExperimentalMDV = options.ExperimentalMDV;
            obj.FragmentMask = options.FragmentMask;
            obj.EffluxPenalty = options.EffluxPenalty;
            obj.MeasurementStandardDeviation = ...
                options.MeasurementStandardDeviation;
            obj.MDVPredictor = options.MDVPredictor;

            obj.Problem.extractIndependentValues(obj.RightHandSide);

        end % constructor

        function rss = evaluate(obj, independentValues)

            arguments
                obj (1, 1) openmebius.mfa.SteadyStateObjective
                independentValues (:, 1) double
            end

            flux = obj.Problem.solveFlux( ...
                independentValues, ...
                BaseRightHandSide = obj.RightHandSide);
            rss = obj.evaluateFlux(flux);

        end % evaluate

        function rss = evaluateFlux(obj, flux)

            arguments
                obj (1, 1) openmebius.mfa.SteadyStateObjective
                flux (:, 1) double
            end

            predictedMDV = obj.MDVPredictor.predictByExperiment( ...
                obj.Model, flux, obj.SubstrateEMUs);

            if ~isequal(size(predictedMDV), size(obj.ExperimentalMDV))
                error( ...
                    "OpenMebius2:SteadyStateObjective:" + ...
                    "PredictedMDVDimensionMismatch", ...
                    "Predicted and experimental MDV sizes must match.");
            end

            residual = ...
                (predictedMDV(obj.FragmentMask, :) - ...
                obj.ExperimentalMDV(obj.FragmentMask, :)) ./ ...
                obj.MeasurementStandardDeviation;
            rss = sum(residual .^ 2, "all") + ...
                obj.EffluxPenalty.evaluate(flux);

        end % evaluateFlux

        function mdv = predictFlux(obj, flux)

            arguments
                obj (1, 1) openmebius.mfa.SteadyStateObjective
                flux (:, 1) double
            end

            mdv = obj.MDVPredictor.predictLinearized( ...
                obj.Model, flux, obj.SubstrateEMUs);

        end % predictFlux

    end % methods

end % classdef
