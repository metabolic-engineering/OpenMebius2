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
        FluxInequalityMatrix (:, :) double
        FluxInequalityRightHandSide (:, 1) double
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
                options.FluxInequalityMatrix (:, :) double = []
                options.FluxInequalityRightHandSide (:, 1) double = ...
                    zeros(0, 1)
            end

            rowCount = size(options.Stoichiometry, 1);
            fluxCount = size(options.Stoichiometry, 2);
            fluxInequalityMatrix = options.FluxInequalityMatrix;

            if isempty(fluxInequalityMatrix)
                fluxInequalityMatrix = zeros(0, fluxCount);
            end

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

            if size(fluxInequalityMatrix, 2) ~= fluxCount || ...
                    size(fluxInequalityMatrix, 1) ~= ...
                    numel(options.FluxInequalityRightHandSide)
                error( ...
                    "OpenMebius2:MFAProblem:" + ...
                    "FluxInequalityDimensionMismatch", ...
                    "Flux inequalities must contain one column per " + ...
                    "flux and one right-hand-side value per row.");
            end

            if any(~isfinite(fluxInequalityMatrix), 'all') || ...
                    any(~isfinite( ...
                    options.FluxInequalityRightHandSide))
                error( ...
                    "OpenMebius2:MFAProblem:InvalidFluxInequality", ...
                    "Flux inequalities must contain finite values.");
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
            obj.FluxInequalityMatrix = ...
                fluxInequalityMatrix;
            obj.FluxInequalityRightHandSide = ...
                options.FluxInequalityRightHandSide;

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
            [additionalMatrix, additionalRightHandSide] = ...
                obj.fluxInequalitiesInIndependentSpace( ...
                BaseRightHandSide = options.BaseRightHandSide);
            inequalityMatrix = [ ...
                -fluxCoefficient; additionalMatrix];
            inequalityRightHandSide = [ ...
                fluxOffset; additionalRightHandSide];

        end % nonnegativeFluxInequalities

        function [inequalityMatrix, inequalityRightHandSide] = ...
                fluxInequalitiesInIndependentSpace(obj, options)

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
            inequalityMatrix = ...
                obj.FluxInequalityMatrix * fluxCoefficient;
            inequalityRightHandSide = ...
                obj.FluxInequalityRightHandSide - ...
                obj.FluxInequalityMatrix * fluxOffset;

        end % fluxInequalitiesInIndependentSpace

        function [equalityMatrix, equalityRightHandSide] = ...
                fixedFluxEqualities(obj, fluxWeights, targetValue, options)

            arguments
                obj (1, 1) openmebius.mfa.MFAProblem
                fluxWeights (:, 1) double
                targetValue (1, 1) double
                options.BaseRightHandSide (:, 1) double = ...
                    obj.RightHandSide
            end

            fluxCount = size(obj.Stoichiometry, 2);

            if numel(fluxWeights) ~= fluxCount
                error( ...
                    "OpenMebius2:MFAProblem:FluxWeightDimensionMismatch", ...
                    "Flux weights must match the flux system.");
            end

            independentCount = nnz(obj.IndependentMask);

            % E maps independent variables to the RHS vector.
            selector = zeros(numel(obj.RightHandSide), independentCount);
            selector(obj.IndependentMask, :) = eye(independentCount);

            % Remove the current independent-variable values from the base RHS.
            fixedRightHandSide = options.BaseRightHandSide;
            fixedRightHandSide(obj.IndependentMask) = 0;

            fluxOffset = obj.Stoichiometry \ fixedRightHandSide;
            fluxCoefficient = obj.Stoichiometry \ selector;

            equalityMatrix = fluxWeights.' * fluxCoefficient;
            equalityRightHandSide = ...
                targetValue - fluxWeights.' * fluxOffset;

        end % method fixedFluxEqualities

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
