classdef FluxVariabilityWorkflowResult
    % FLUXVARIABILITYWORKFLOWRESULT
    % Immutable output of FVA problem preparation and solution.

    properties (SetAccess = private)
        RightHandSide (:, 1) double
        Problem = []
        UpperBounds (:, 1) double
        LowerBounds (:, 1) double
        ExitFlag (1, 1) double
        ErrorMessage (1, 1) string = ""
        IsError (1, 1) logical = false
    end

    methods

        function obj = FluxVariabilityWorkflowResult(options)

            arguments
                options.RightHandSide (:, 1) double
                options.Problem
                options.UpperBounds (:, 1) double
                options.LowerBounds (:, 1) double
                options.ExitFlag (1, 1) double
                options.ErrorMessage (1, 1) string = ""
                options.IsError (1, 1) logical = false
            end

            if ~isequal( ...
                    size(options.UpperBounds), ...
                    size(options.LowerBounds))
                error( ...
                    "OpenMebius2:FluxVariabilityWorkflow:" + ...
                    "BoundSizeMismatch", ...
                    "FVA bounds must have the same size.");
            end

            obj.RightHandSide = options.RightHandSide;
            obj.Problem = options.Problem;
            obj.UpperBounds = options.UpperBounds;
            obj.LowerBounds = options.LowerBounds;
            obj.ExitFlag = options.ExitFlag;
            obj.ErrorMessage = options.ErrorMessage;
            obj.IsError = options.IsError;

        end % constructor

    end % methods

end % classdef
