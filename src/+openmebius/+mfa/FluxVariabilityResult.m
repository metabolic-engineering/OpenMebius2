classdef FluxVariabilityResult
    % FLUXVARIABILITYRESULT
    % Immutable result of a flux variability calculation.

    properties (SetAccess = private)
        UpperBounds (:, 1) double
        LowerBounds (:, 1) double
        ExitFlag (1, 1) double
        ErrorMessage (1, 1) string
        IsError (1, 1) logical
    end

    methods

        function obj = FluxVariabilityResult(options)

            arguments
                options.UpperBounds (:, 1) double
                options.LowerBounds (:, 1) double
                options.ExitFlag (1, 1) double
                options.ErrorMessage (1, 1) string = ""
            end

            obj.UpperBounds = options.UpperBounds;
            obj.LowerBounds = options.LowerBounds;
            obj.ExitFlag = options.ExitFlag;
            obj.ErrorMessage = options.ErrorMessage;
            obj.IsError = options.ExitFlag < 0 || ...
                strlength(options.ErrorMessage) > 0;

        end % constructor

    end % methods

end % classdef
