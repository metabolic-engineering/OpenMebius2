classdef MFAProblem
    % MFAPROBLEM
    % Immutable linear flux system used by MFA solvers.

    properties (SetAccess = private)
        Stoichiometry (:, :) double
        RightHandSide (:, 1) double
        LowerBounds (:, 1) double
        UpperBounds (:, 1) double
        IndependentMask (:, 1) logical
        BoundaryReactionMask (:, 1) logical
        IndependentIndices (:, 1) double
    end

    methods

        function obj = MFAProblem(options)

            arguments
                options.Stoichiometry (:, :) double
                options.RightHandSide (:, 1) double
                options.LowerBounds (:, 1) double
                options.UpperBounds (:, 1) double
                options.IndependentMask (:, 1) logical
                options.BoundaryReactionMask (:, 1) logical
            end

            rowCount = size(options.Stoichiometry, 1);
            fluxCount = size(options.Stoichiometry, 2);

            if rowCount ~= fluxCount
                error( ...
                    "OpenMebius2:MFAProblem:NonSquareStoichiometry", ...
                    "The MFA stoichiometry matrix must be square.");
            end

            if numel(options.RightHandSide) ~= rowCount || ...
                    numel(options.LowerBounds) ~= fluxCount || ...
                    numel(options.UpperBounds) ~= fluxCount || ...
                    numel(options.IndependentMask) ~= rowCount || ...
                    numel(options.BoundaryReactionMask) ~= fluxCount
                error( ...
                    "OpenMebius2:MFAProblem:DimensionMismatch", ...
                    "MFA problem vectors must match the flux system.");
            end

            if any(options.LowerBounds > options.UpperBounds)
                error( ...
                    "OpenMebius2:MFAProblem:InvalidBounds", ...
                    "Flux lower bounds must not exceed upper bounds.");
            end

            independentCount = nnz(options.IndependentMask);
            boundaryReactionCount = nnz(options.BoundaryReactionMask);

            if independentCount == 0
                error( ...
                    "OpenMebius2:MFAProblem:MissingIndependentVariables", ...
                    "The MFA problem must define independent variables.");
            end

            if independentCount ~= boundaryReactionCount
                error( ...
                    "OpenMebius2:MFAProblem:IndependentMappingMismatch", ...
                    "Independent RHS values must map one-to-one to reaction bounds.");
            end

            obj.Stoichiometry = options.Stoichiometry;
            obj.RightHandSide = options.RightHandSide;
            obj.LowerBounds = options.LowerBounds;
            obj.UpperBounds = options.UpperBounds;
            obj.IndependentMask = options.IndependentMask;
            obj.BoundaryReactionMask = options.BoundaryReactionMask;
            obj.IndependentIndices = find(options.IndependentMask);

        end % constructor

        function values = extractIndependentValues(obj, rightHandSide)

            arguments
                obj (1, 1) openmebius.mfa.MFAProblem
                rightHandSide double
            end

            obj.validateRightHandSide(rightHandSide);
            values = rightHandSide(obj.IndependentMask, :);

        end % extractIndependentValues

        function rightHandSide = composeRightHandSide( ...
                obj, independentValues, options)

            arguments
                obj (1, 1) openmebius.mfa.MFAProblem
                independentValues double
                options.BaseRightHandSide double = obj.RightHandSide
            end

            independentCount = nnz(obj.IndependentMask);

            if size(independentValues, 1) ~= independentCount
                error( ...
                    "OpenMebius2:MFAProblem:IndependentValueDimensionMismatch", ...
                    "Independent values must match the independent variable count.");
            end

            obj.validateRightHandSide(options.BaseRightHandSide);
            valueCount = size(independentValues, 2);
            baseCount = size(options.BaseRightHandSide, 2);

            if baseCount == 1 && valueCount > 1
                rightHandSide = repmat( ...
                    options.BaseRightHandSide, 1, valueCount);
            elseif baseCount == valueCount
                rightHandSide = options.BaseRightHandSide;
            else
                error( ...
                    "OpenMebius2:MFAProblem:RightHandSideColumnMismatch", ...
                    "Base RHS columns must be one or match independent values.");
            end

            rightHandSide(obj.IndependentMask, :) = independentValues;

        end % composeRightHandSide

        function flux = solveFlux(obj, independentValues, options)

            arguments
                obj (1, 1) openmebius.mfa.MFAProblem
                independentValues double
                options.BaseRightHandSide double = obj.RightHandSide
            end

            rightHandSide = obj.composeRightHandSide( ...
                independentValues, ...
                BaseRightHandSide = options.BaseRightHandSide);
            flux = obj.Stoichiometry \ rightHandSide;

        end % solveFlux

        function [inequalityMatrix, inequalityRightHandSide] = ...
                nonnegativeFluxInequalities(obj, options)

            arguments
                obj (1, 1) openmebius.mfa.MFAProblem
                options.BaseRightHandSide (:, 1) double = ...
                    obj.RightHandSide
            end

            obj.validateRightHandSide(options.BaseRightHandSide);
            independentCount = nnz(obj.IndependentMask);
            selector = zeros(numel(obj.RightHandSide), independentCount);
            selector(obj.IndependentMask, :) = eye(independentCount);
            fixedRightHandSide = options.BaseRightHandSide;
            fixedRightHandSide(obj.IndependentMask) = 0;
            fluxOffset = obj.Stoichiometry \ fixedRightHandSide;
            fluxCoefficient = obj.Stoichiometry \ selector;
            inequalityMatrix = -fluxCoefficient;
            inequalityRightHandSide = fluxOffset;

        end % nonnegativeFluxInequalities

    end % methods

    methods (Access = private)

        function validateRightHandSide(obj, rightHandSide)

            if size(rightHandSide, 1) ~= size(obj.Stoichiometry, 1)
                error( ...
                    "OpenMebius2:MFAProblem:RightHandSideDimensionMismatch", ...
                    "The RHS must match the stoichiometry row count.");
            end

        end % validateRightHandSide

    end % methods (Access = private)

end % classdef
