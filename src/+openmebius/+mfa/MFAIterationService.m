classdef MFAIterationService
    % MFAITERATIONSERVICE
    % Coordinates and executes one steady or instationary MFA fit.

    properties (SetAccess = private)
        Runner
        ObjectiveFactory
    end

    methods

        function obj = MFAIterationService(options)

            arguments
                options.Runner = openmebius.mfa.MFAIterationRunner()
                options.ObjectiveFactory = ...
                    openmebius.mfa.MFAObjectiveFactory()
            end

            obj.Runner = options.Runner;
            obj.ObjectiveFactory = options.ObjectiveFactory;

        end

        function iterationResult = run(obj, input, options)

            arguments
                obj (1, 1) openmebius.mfa.MFAIterationService
                input (1, 1) openmebius.mfa.MFAIterationInput
                options.MessageReporter (1, 1) function_handle = ...
                    @(~, ~) []
            end

            reporter = openmebius.mfa.MFAIterationReporter( ...
                MessageReporter = options.MessageReporter);
            objective = obj.ObjectiveFactory.create(input);
            settings = input.Settings;
            reporter.reportSettings(settings);

            iterationResult = obj.Runner.run( ...
                input.Problem, ...
                input.RightHandSide, ...
                objective, ...
                settings.SolverOptions, ...
                MessageReporter = reporter.callback());
            reporter.reportResult( ...
                iterationResult, input.analysisMode());

        end

    end

end
