classdef MFAIterationSettingsMapper
    % MFAITERATIONSETTINGSMAPPER Maps batch structs to typed MFA settings.

    methods (Static)

        function settings = fromBatchConfig(config)

            arguments
                config (1, 1) struct
            end

            analysisMode = openmebius.application.analysis ...
                .MFAIterationSettingsMapper.mapAnalysisMode(config);
            [optimizationMethod, methodWarnings] = ...
                openmebius.application.analysis ...
                .MFAIterationSettingsMapper.mapOptimizationMethod( ...
                config);
            [solverOptions, solverWarnings] = ...
                openmebius.application.analysis ...
                .SteadyStateOptionsMapper.fromBatchConfig(config);
            settings = openmebius.mfa.MFAIterationSettings( ...
                AnalysisMode = analysisMode, ...
                OptimizationMethod = optimizationMethod, ...
                SolverOptions = solverOptions, ...
                OptionWarnings = ...
                [methodWarnings; solverWarnings(:)]);

        end % fromBatchConfig

    end % methods (Static)

    methods (Static, Access = private)

        function analysisMode = mapAnalysisMode(config)

            analysisFlag = [];

            if isfield(config, 'isINSTMFA')
                analysisFlag = config.isINSTMFA;
            end

            if isempty(analysisFlag) || ~isscalar(analysisFlag) || ...
                    ~(islogical(analysisFlag) || ...
                    isnumeric(analysisFlag)) || ...
                    (isnumeric(analysisFlag) && ...
                    (~isfinite(analysisFlag) || ...
                    ~ismember(analysisFlag, [0, 1])))
                error( ...
                    "OpenMebius2:MFAIterationSettingsMapper:" + ...
                    "InvalidAnalysisMode", ...
                    "The analysis configuration must define a scalar " + ...
                "isINSTMFA flag.");
            end

            if logical(analysisFlag)
                analysisMode = ...
                    openmebius.mfa.MFAAnalysisMode.Instationary;
            else
                analysisMode = ...
                    openmebius.mfa.MFAAnalysisMode.SteadyState;
            end

        end % mapAnalysisMode

        function [method, warnings] = mapOptimizationMethod(config)

            method = ...
                openmebius.mfa.MFAOptimizationMethod.GradientOnly;
            warnings = strings(0, 1);

            if ~isfield(config, 'optimizationMethod') || ...
                    isempty(config.optimizationMethod)
                return
            end

            candidate = lower(string(config.optimizationMethod));
            candidate = candidate(1);

            switch candidate
                case {"hybrid-ga-gradient", "hybrid", "ga-gradient"}
                    method = openmebius.mfa ...
                        .MFAOptimizationMethod.HybridGAGradient;
                case {"gradient-only", "fmincon", "local"}
                    method = openmebius.mfa ...
                        .MFAOptimizationMethod.GradientOnly;
                otherwise
                    warnings(end + 1, 1) = ...
                        "Unknown optimizationMethod '" + candidate + ...
                        "'. Using FMINCON only.";
            end

        end % mapOptimizationMethod

    end % methods (Static, Access = private)

end % classdef
