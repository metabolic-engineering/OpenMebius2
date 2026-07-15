classdef MFAIterationSettings
    % MFAITERATIONSETTINGS Validated settings for one nonlinear MFA fit.

    properties (SetAccess = private)
        UseInstationaryMFA (1, 1) logical
        OptimizationMethod (1, 1) string
        SolverOptions (1, 1) openmebius.mfa.SteadyStateOptions
        OptionWarnings (:, 1) string
    end

    methods

        function obj = MFAIterationSettings(options)

            arguments
                options.UseInstationaryMFA (1, 1) logical
                options.OptimizationMethod (1, 1) string = ...
                    "gradient-only"
                options.SolverOptions (1, 1) ...
                    openmebius.mfa.SteadyStateOptions = ...
                    openmebius.mfa.SteadyStateOptions()
                options.OptionWarnings string = strings(0, 1)
            end

            obj.UseInstationaryMFA = options.UseInstationaryMFA;
            obj.OptimizationMethod = options.OptimizationMethod;
            obj.SolverOptions = options.SolverOptions;
            obj.OptionWarnings = options.OptionWarnings(:);

        end % constructor

        function value = requestsHybridOptimization(obj)

            value = obj.OptimizationMethod == "hybrid-ga-gradient";

        end % requestsHybridOptimization

        function value = hasKnownOptimizationMethod(obj)

            value = ismember( ...
                obj.OptimizationMethod, ...
                ["gradient-only", "hybrid-ga-gradient"]);

        end % hasKnownOptimizationMethod

    end % methods

    methods (Static)

        function settings = fromBatchConfig(config)

            arguments
                config (1, 1) struct
            end

            analysisMode = [];

            if isfield(config, 'isINSTMFA')
                analysisMode = config.isINSTMFA;
            end

            if isempty(analysisMode) || ~isscalar(analysisMode) || ...
                    ~(islogical(analysisMode) || ...
                    isnumeric(analysisMode)) || ...
                    (isnumeric(analysisMode) && ...
                    (~isfinite(analysisMode) || ...
                    ~ismember(analysisMode, [0, 1])))
                error( ...
                    "OpenMebius2:MFAIterationSettings:" + ...
                    "InvalidAnalysisMode", ...
                    "The analysis configuration must define a scalar " + ...
                    "isINSTMFA flag.");
            end

            method = "gradient-only";

            if isfield(config, 'optimizationMethod') && ...
                    ~isempty(config.optimizationMethod)
                method = lower(string(config.optimizationMethod));
                method = method(1);
            end

            switch method
                case {"hybrid-ga-gradient", "hybrid", "ga-gradient"}
                    method = "hybrid-ga-gradient";
                case {"gradient-only", "fmincon", "local"}
                    method = "gradient-only";
            end

            [solverOptions, optionWarnings] = ...
                openmebius.mfa.SteadyStateOptions.fromBatchConfig( ...
                config);
            settings = openmebius.mfa.MFAIterationSettings( ...
                UseInstationaryMFA = logical(analysisMode), ...
                OptimizationMethod = method, ...
                SolverOptions = solverOptions, ...
                OptionWarnings = optionWarnings);

        end % fromBatchConfig

    end % methods (Static)

end % classdef
