classdef FluxVariabilityProblem
    % FLUXVARIABILITYPROBLEM
    % Immutable linear-program inputs for flux variability analysis.

    properties (SetAccess = private)
        EqualityMatrix (:, :) double
        EqualityRightHandSide (:, 1) double
        LowerBounds (:, 1) double
        UpperBounds (:, 1) double
        ReverseCounterpartIndices (:, 1) double
        UsedDefaultMaximumEfflux (1, 1) logical
        MaximumEfflux (1, 1) double
        FreeConstraintIDs (:, 1) string
    end

    methods

        function obj = FluxVariabilityProblem(options)

            arguments
                options.EqualityMatrix (:, :) double
                options.EqualityRightHandSide (:, 1) double
                options.LowerBounds (:, 1) double
                options.UpperBounds (:, 1) double
                options.ReverseCounterpartIndices (:, 1) double
                options.UsedDefaultMaximumEfflux (1, 1) logical
                options.MaximumEfflux (1, 1) double
                options.FreeConstraintIDs = strings(0, 1)
            end

            fluxCount = size(options.EqualityMatrix, 2);

            if size(options.EqualityMatrix, 1) ~= ...
                    numel(options.EqualityRightHandSide)
                error( ...
                    "OpenMebius2:FluxVariabilityProblem:" + ...
                    "EqualityDimensionMismatch", ...
                    "The equality matrix and right-hand side row counts " + ...
                    "must match.");
            end

            if numel(options.LowerBounds) ~= fluxCount || ...
                    numel(options.UpperBounds) ~= fluxCount || ...
                    numel(options.ReverseCounterpartIndices) ~= fluxCount
                error( ...
                    "OpenMebius2:FluxVariabilityProblem:" + ...
                    "FluxDimensionMismatch", ...
                    "Each flux must have bounds and a reverse-index " + ...
                    "entry.");
            end

            if any(options.LowerBounds > options.UpperBounds)
                error( ...
                    "OpenMebius2:FluxVariabilityProblem:InvalidBounds", ...
                    "Flux lower bounds must not exceed upper bounds.");
            end

            obj.EqualityMatrix = options.EqualityMatrix;
            obj.EqualityRightHandSide = ...
                options.EqualityRightHandSide;
            obj.LowerBounds = options.LowerBounds;
            obj.UpperBounds = options.UpperBounds;
            obj.ReverseCounterpartIndices = ...
                options.ReverseCounterpartIndices;
            obj.UsedDefaultMaximumEfflux = ...
                options.UsedDefaultMaximumEfflux;
            obj.MaximumEfflux = options.MaximumEfflux;
            obj.FreeConstraintIDs = ...
                string(options.FreeConstraintIDs(:));

        end % constructor

    end % methods

end % classdef
