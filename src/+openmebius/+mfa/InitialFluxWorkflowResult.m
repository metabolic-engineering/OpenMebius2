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

            obj.Problem = options.Problem;
            obj.Fluxes = options.Fluxes;
            obj.RightHandSides = options.RightHandSides;
            obj.ObjectiveValues = options.ObjectiveValues;
            obj.IsCanceled = options.IsCanceled;
            obj.IsError = options.IsError;
            obj.ErrorMessage = options.ErrorMessage;

        end

    end

end
