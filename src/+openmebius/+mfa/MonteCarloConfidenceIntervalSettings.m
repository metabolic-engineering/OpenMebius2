classdef MonteCarloConfidenceIntervalSettings
    % MONTECARLOCONFIDENCEINTERVALSETTINGS Validated Monte Carlo settings.

    properties (SetAccess = private)
        IterationCount (1, 1) double
        WorkerCount (1, 1) double
        FixMDV (1, 1) logical
        StandardDeviation (1, 1) double
        Procedure (1, 1) openmebius.mfa ...
            .MonteCarloOptimizationProcedure
        TerminationTolerance (1, 1) double
        ProximityThreshold (1, 1) double
        CertainThreshold (1, 1) double
        TrialCount (1, 1) double
        CalculationMethod (1, 1) openmebius.mfa ...
            .ConfidenceIntervalCalculationMethod
    end

    methods

        function obj = MonteCarloConfidenceIntervalSettings(options)

            arguments
                options.IterationCount (1, 1) double = 500
                options.WorkerCount (1, 1) double = 8
                options.FixMDV (1, 1) logical = true
                options.StandardDeviation (1, 1) double = 0.01
                options.Procedure (1, 1) openmebius.mfa ...
                    .MonteCarloOptimizationProcedure = openmebius.mfa ...
                    .MonteCarloOptimizationProcedure.MultipleRun
                options.TerminationTolerance (1, 1) double = 1e-4
                options.ProximityThreshold (1, 1) double = 1e-4
                options.CertainThreshold (1, 1) double = 3
                options.TrialCount (1, 1) double = 50
                options.CalculationMethod (1, 1) openmebius.mfa ...
                    .ConfidenceIntervalCalculationMethod = ...
                    openmebius.mfa ...
                    .ConfidenceIntervalCalculationMethod.Discarding
            end

            obj.validatePositiveInteger( ...
                options.IterationCount, "IterationCount");
            obj.validatePositiveInteger( ...
                options.WorkerCount, "WorkerCount");
            obj.validateNonnegative( ...
                options.StandardDeviation, "StandardDeviation");
            obj.validateNonnegative( ...
                options.TerminationTolerance, "TerminationTolerance");
            obj.validateNonnegative( ...
                options.ProximityThreshold, "ProximityThreshold");
            obj.validatePositiveInteger( ...
                options.CertainThreshold, "CertainThreshold");
            obj.validatePositiveInteger(options.TrialCount, "TrialCount");

            obj.IterationCount = options.IterationCount;
            obj.WorkerCount = options.WorkerCount;
            obj.FixMDV = options.FixMDV;
            obj.StandardDeviation = options.StandardDeviation;
            obj.Procedure = options.Procedure;
            obj.TerminationTolerance = options.TerminationTolerance;
            obj.ProximityThreshold = options.ProximityThreshold;
            obj.CertainThreshold = options.CertainThreshold;
            obj.TrialCount = options.TrialCount;
            obj.CalculationMethod = options.CalculationMethod;

        end

    end

    methods (Static, Access = private)

        function validatePositiveInteger(value, name)

            if ~isfinite(value) || value < 1 || fix(value) ~= value
                error( ...
                    "OpenMebius2:MonteCarloConfidenceIntervalSettings:" + ...
                    "InvalidPositiveInteger", ...
                    "%s must be a positive integer.", name);
            end

        end

        function validateNonnegative(value, name)

            if ~isfinite(value) || value < 0
                error( ...
                    "OpenMebius2:MonteCarloConfidenceIntervalSettings:" + ...
                    "InvalidNonnegativeValue", ...
                    "%s must be a finite, nonnegative number.", name);
            end

        end

    end

end
