classdef SteadyStateResult
    % STEADYSTATERESULT
    % Immutable result of one steady-state nonlinear optimization trial.

    properties (SetAccess = private)
        IndependentValues (:, 1) double
        Flux (:, 1) double
        ObjectiveValue (1, 1) double
        ExitFlag (1, 1) double
        Output (1, 1) struct
        IsError (1, 1) logical
        ErrorMessage (1, 1) string
    end

    methods

        function obj = SteadyStateResult(options)

            arguments
                options.IndependentValues (:, 1) double
                options.Flux (:, 1) double
                options.ObjectiveValue (1, 1) double
                options.ExitFlag (1, 1) double
                options.Output (1, 1) struct = struct
                options.ErrorMessage (1, 1) string = ""
            end

            obj.IndependentValues = options.IndependentValues;
            obj.Flux = options.Flux;
            obj.ObjectiveValue = options.ObjectiveValue;
            obj.ExitFlag = options.ExitFlag;
            obj.Output = options.Output;
            obj.ErrorMessage = options.ErrorMessage;
            obj.IsError = strlength(options.ErrorMessage) > 0;

        end % constructor

    end % methods

end % classdef
