classdef InitialFluxWorkflowResult
    % INITIALFLUXWORKFLOWRESULT
    % Immutable output of initial feasible-flux generation and scoring.

    properties (SetAccess = private)
        Problem = []
        Fluxes double = []
        RightHandSides double = []
        ObjectiveValues double = []
        IsCanceled (1, 1) logical = false
        IsError (1, 1) logical = false
        ErrorMessage (1, 1) string = ""
    end

    methods

        function obj = InitialFluxWorkflowResult(options)

            arguments
                options.Problem = []
                options.Fluxes double = []
                options.RightHandSides double = []
                options.ObjectiveValues double = []
                options.IsCanceled (1, 1) logical = false
                options.IsError (1, 1) logical = false
                options.ErrorMessage (1, 1) string = ""
            end

            if options.IsError && options.IsCanceled
                error( ...
                    "OpenMebius2:InitialFluxResult:InconsistentStatus", ...
                    "Initial-flux generation cannot be both failed " + ...
                    "and canceled.");
            end

            if options.IsError && strlength(options.ErrorMessage) == 0
                error( ...
                    "OpenMebius2:InitialFluxResult:MissingErrorMessage", ...
                    "A failed initial-flux result must describe the error.");
            end

            if ~options.IsError && ~options.IsCanceled && ...
                    isempty(options.Problem)
                error( ...
                    "OpenMebius2:InitialFluxResult:MissingProblem", ...
                    "A successful initial-flux result must contain an MFA problem.");
            end

            candidateCount = size(options.Fluxes, 2);

            if ~options.IsError && ~options.IsCanceled && ...
                    candidateCount == 0
                error( ...
                    "OpenMebius2:InitialFluxResult:MissingCandidates", ...
                    "A successful initial-flux result must contain candidates.");
            end

            if size(options.RightHandSides, 2) ~= candidateCount
                error( ...
                    "OpenMebius2:InitialFluxResult:CandidateDimensionMismatch", ...
                    "Fluxes and right-hand sides must contain the same candidates.");
            end

            if ~options.IsError && ~options.IsCanceled && ...
                    numel(options.ObjectiveValues) ~= candidateCount
                error( ...
                    "OpenMebius2:InitialFluxResult:ObjectiveDimensionMismatch", ...
                    "Each successful candidate must have one objective value.");
            end

            obj.Problem = options.Problem;
            obj.Fluxes = options.Fluxes;
            obj.RightHandSides = options.RightHandSides;
            obj.ObjectiveValues = options.ObjectiveValues;
            obj.IsCanceled = options.IsCanceled;
            obj.IsError = options.IsError;
            obj.ErrorMessage = options.ErrorMessage;

        end

    end

    methods (Static)

        function result = success(options)

            arguments
                options.Problem
                options.Fluxes double
                options.RightHandSides double
                options.ObjectiveValues double
            end

            result = openmebius.mfa.InitialFluxWorkflowResult( ...
                Problem = options.Problem, ...
                Fluxes = options.Fluxes, ...
                RightHandSides = options.RightHandSides, ...
                ObjectiveValues = options.ObjectiveValues);

        end % success

        function result = failure(message, options)

            arguments
                message (1, 1) string
                options.Problem = []
                options.Fluxes double = []
                options.RightHandSides double = []
            end

            result = openmebius.mfa.InitialFluxWorkflowResult( ...
                Problem = options.Problem, ...
                Fluxes = options.Fluxes, ...
                RightHandSides = options.RightHandSides, ...
                IsError = true, ...
                ErrorMessage = message);

        end % failure

        function result = canceled(options)

            arguments
                options.Problem = []
                options.Fluxes double = []
                options.RightHandSides double = []
            end

            result = openmebius.mfa.InitialFluxWorkflowResult( ...
                Problem = options.Problem, ...
                Fluxes = options.Fluxes, ...
                RightHandSides = options.RightHandSides, ...
                IsCanceled = true);

        end % canceled

    end % methods (Static)

end
