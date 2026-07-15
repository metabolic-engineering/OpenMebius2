classdef MFAIterationService
    % MFAITERATIONSERVICE
    % Coordinates and executes one steady or instationary MFA fit.

    properties (SetAccess = private)
        Runner
        ObjectiveFactory
        EffluxPenaltyFactory
    end

    methods

        function obj = MFAIterationService(options)

            arguments
                options.Runner = openmebius.mfa.MFAIterationRunner()
                options.ObjectiveFactory = ...
                    openmebius.mfa.MFAObjectiveFactory()
                options.EffluxPenaltyFactory = ...
                    openmebius.mfa.EffluxPenaltyFactory()
            end

            obj.Runner = options.Runner;
            obj.ObjectiveFactory = options.ObjectiveFactory;
            obj.EffluxPenaltyFactory = options.EffluxPenaltyFactory;

        end

        function iterationResult = run(obj, input, options)

            arguments
                obj (1, 1) openmebius.mfa.MFAIterationService
                input (1, 1) openmebius.mfa.MFAIterationInput
                options.MessageReporter (1, 1) function_handle = ...
                    @(~, ~) []
            end

            reporter = options.MessageReporter;
            penalty = obj.EffluxPenaltyFactory.create( ...
                input.Model, ...
                input.SubstrateList, ...
                input.Efflux, ...
                input.EffluxStandardDeviation, ...
                input.EffluxFree);

            objective = obj.ObjectiveFactory.create(input, penalty);

            if input.usesInstationaryMFA()
                context = " for instationary MFA";
            else
                context = "";
            end

            settings = input.Settings;

            if settings.requestsHybridOptimization()
                reporter( ...
                    "info", ...
                    "Hybrid GA optimization is temporarily disabled. " + ...
                    "Using FMINCON only.");
            elseif ~settings.hasKnownOptimizationMethod()
                reporter( ...
                    "warning", ...
                    "Unknown optimizationMethod '" + ...
                    settings.OptimizationMethod + ...
                    "'. Using FMINCON only.");
            end

            for iWarning = 1:numel(settings.OptionWarnings)
                reporter("warning", settings.OptionWarnings(iWarning));
            end

            iterationResult = obj.Runner.run( ...
                input.Problem, ...
                input.RightHandSide, ...
                objective, ...
                settings.SolverOptions, ...
                MessageReporter = reporter);
            fval = iterationResult.ObjectiveValue;
            subject = "Nonlinear optimization" + context;

            if iterationResult.IsError || ~isfinite(fval)
                message = subject + " failed.";

                if strlength(iterationResult.ErrorMessage) > 0
                    message = message + " " + ...
                        iterationResult.ErrorMessage;
                end

                reporter("error", message);
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

            reporter( ...
                "info", ...
                subject + " completed. RSS: " + string(fval) + ...
                "." + stepSizeMessage);

        end

    end

end
