classdef InitialPointResult
    % INITIALPOINTRESULT
    % Immutable collection of generated feasible initial points.

    properties (SetAccess = private)
        Fluxes double
        RightHandSides double
        IsCanceled (1, 1) logical
        IsError (1, 1) logical
        ErrorMessage (1, 1) string
    end

    methods

        function obj = InitialPointResult(options)

            arguments
                options.Fluxes double
                options.RightHandSides double
                options.IsCanceled (1, 1) logical = false
                options.IsError (1, 1) logical = false
                options.ErrorMessage (1, 1) string = ""
            end

            obj.Fluxes = options.Fluxes;
            obj.RightHandSides = options.RightHandSides;
            obj.IsCanceled = options.IsCanceled;
            obj.IsError = options.IsError;
            obj.ErrorMessage = options.ErrorMessage;

        end % constructor

    end % methods

end % classdef
