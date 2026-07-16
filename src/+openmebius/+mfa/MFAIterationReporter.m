classdef MFAIterationReporter
    % MFAITERATIONREPORTER Reports settings and results for one MFA fit.

    properties (SetAccess = private)
        MessageReporter (1, 1) function_handle = @(~, ~) []
    end

    methods

        function obj = MFAIterationReporter(options)

            arguments
                options.MessageReporter (1, 1) function_handle = ...
                    @(~, ~) []
            end

            obj.MessageReporter = options.MessageReporter;

        end % constructor

        function callback = callback(obj)

            callback = @(level, message) obj.report(level, message);

        end % callback

        function report(obj, level, message)

            obj.MessageReporter(level, message);

        end % report

        function reportSettings(obj, settings)

            arguments
                obj (1, 1) openmebius.mfa.MFAIterationReporter
                settings (1, 1) openmebius.mfa.MFAIterationSettings
            end

            if settings.OptimizationMethod.usesHybridGA()
                obj.report( ...
                    "info", ...
                    "Hybrid GA optimization is temporarily disabled. " + ...
                    "Using FMINCON only.");
            end

            for iWarning = 1:numel(settings.OptionWarnings)
                obj.report("warning", settings.OptionWarnings(iWarning));
            end

        end % reportSettings

        function reportResult(obj, iterationResult, analysisMode)

            arguments
                obj (1, 1) openmebius.mfa.MFAIterationReporter
                iterationResult (1, 1) ...
                    openmebius.mfa.MFAIterationResult
                analysisMode (1, 1) openmebius.mfa.MFAAnalysisMode
            end

            subject = "Nonlinear optimization";

            if analysisMode.isInstationary()
                subject = subject + " for instationary MFA";
            end

            fval = iterationResult.ObjectiveValue;

            if iterationResult.IsError || ~isfinite(fval)
                message = subject + " failed.";

                if strlength(iterationResult.ErrorMessage) > 0
                    message = message + " " + ...
                        iterationResult.ErrorMessage;
                end

                obj.report("error", message);
                return
            end

            stepSizeMessage = "";
            optimizationOutput = iterationResult.Output;

            if isfield( ...
                    optimizationOutput, ...
                    'fminconFiniteDifferenceStepSize')
                stepSizeMessage = " FiniteDifferenceStepSize: " + ...
                    string(optimizationOutput ...
                    .fminconFiniteDifferenceStepSize) + ".";
            end

            obj.report( ...
                "info", ...
                subject + " completed. RSS: " + string(fval) + ...
                "." + stepSizeMessage);

        end % reportResult

    end % methods

end % classdef
