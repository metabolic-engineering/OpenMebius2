classdef MFAIterationSettings
    % MFAITERATIONSETTINGS Validated settings for one nonlinear MFA fit.

    properties (SetAccess = private)
        AnalysisMode
        OptimizationMethod
        SolverOptions (1, 1) openmebius.mfa.SteadyStateOptions
        OptionWarnings (:, 1) string
    end

    methods

        function obj = MFAIterationSettings(options)

            arguments
                options.AnalysisMode (1, 1) ...
                    openmebius.mfa.MFAAnalysisMode = ...
                    openmebius.mfa.MFAAnalysisMode.SteadyState
                options.OptimizationMethod (1, 1) ...
                    openmebius.mfa.MFAOptimizationMethod = ...
                    openmebius.mfa.MFAOptimizationMethod.GradientOnly
                options.SolverOptions (1, 1) ...
                    openmebius.mfa.SteadyStateOptions = ...
                    openmebius.mfa.SteadyStateOptions()
                options.OptionWarnings string = strings(0, 1)
            end

            obj.AnalysisMode = options.AnalysisMode;
            obj.OptimizationMethod = options.OptimizationMethod;
            obj.SolverOptions = options.SolverOptions;
            obj.OptionWarnings = options.OptionWarnings(:);

        end % constructor

        function settings = withAnalysisMode(obj, analysisMode)

            arguments
                obj (1, 1) openmebius.mfa.MFAIterationSettings
                analysisMode (1, 1) openmebius.mfa.MFAAnalysisMode
            end

            settings = openmebius.mfa.MFAIterationSettings( ...
                AnalysisMode = analysisMode, ...
                OptimizationMethod = obj.OptimizationMethod, ...
                SolverOptions = obj.SolverOptions, ...
                OptionWarnings = obj.OptionWarnings);

        end % withAnalysisMode

    end % methods

end % classdef
