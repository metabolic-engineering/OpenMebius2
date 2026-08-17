classdef MDVCorrection < handle

    properties (SetAccess = private)

        % Natural isotpe abundance of the elements in the molecule
        rC = [0.9893, 0.0107]; % 12C, 13C
        lC = 2;
        rH = [0.99985, 0.00015]; % 1H, 2H
        lH = 2;
        rO = [0.99757, 0.00038, 0.00205]; % 16O, 17O, 18O
        lO = 3;
        rN = [0.99632, 0.00368]; % 14N, 15N
        lN = 2;
        rS = [0.9493, 0.0076, 0.0429]; % 32S, 33S, 34S
        lS = 3;
        rSi = [0.922297, 0.046832, 0.030871]; % 28Si, 29Si, 30Si
        lSi = 3;

        numSize = 0;

    end % properties

    methods

        function obj = MSCorrection(obj)

        end % constructor

        function CM = getCorrectedMatrix(obj, nC, nH, nO, nN, nS, nSi)

            arguments

                obj (1, 1) MDVCorrection
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
            end % arguments

            obj.numSize = getSizeMatrix(obj, nC, nH, nO, nN, nS, nSi);

            CMC = getCorrectedMatrixAtom(obj, obj.rC, nC);
            CMH = getCorrectedMatrixAtom(obj, obj.rH, nH);
            CMO = getCorrectedMatrixAtom(obj, obj.rO, nO);
            CMN = getCorrectedMatrixAtom(obj, obj.rN, nN);
            CMS = getCorrectedMatrixAtom(obj, obj.rS, nS);
            CMSi = getCorrectedMatrixAtom(obj, obj.rSi, nSi);

            CM = ...
                CMC * CMH * CMO * CMN * CMS * CMSi;

            obj.numSize = 0;

        end % getCorrectedMatrix

        function CM = getCorrectedMatrixSkew(obj, nC, nH, nO, nN, nS, nSi, options)
            % GETCORRECTEDMATRIXSKEW returns the skewed natural isotope correction matrix.
            % CM = getCorrectedMatrixSkew(obj, nC, nH, nO, nN, nS, nSi, options)
            %
            %  Inputs:
            %   obj - MDVCorrection object
            %   nC - Number of carbon atoms in the molecule
            %   nH - Number of hydrogen atoms in the molecule
            %   nO - Number of oxygen atoms in the molecule
            %   nN - Number of nitrogen atoms in the molecule
            %   nS - Number of sulfur atoms in the molecule
            %   nSi - Number of silicon atoms in the molecule
            %   options.numObservedMDV - Number of observed MDV (default: getSizeMatrix(obj, nC, nH, nO, nN, nS, nSi))
            %   options.numTracerCarbon - Number of carbon atoms that can be labeled by the tracer in the fragment (default: nC)

            arguments
                obj (1, 1) MDVCorrection
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
                options.numObservedMDV (1, 1) {mustBeInteger, mustBePositive} = getSizeMatrix(obj, nC, nH, nO, nN, nS, nSi)
                options.numTracerCarbon (1, 1) {mustBeInteger, mustBeNonnegative} = nC
            end % arguments

            numObservedMDV = options.numObservedMDV;
            numTracerCarbon = min(options.numTracerCarbon, nC);
            numCorrectedMDV = numTracerCarbon + 1;

            CM = zeros(numObservedMDV, numCorrectedMDV);
            nonCarbonVector = getNaturalIsotopeDistribution(obj, 0, nH, nO, nN, nS, nSi);

            for iTracerCarbon = 0:numTracerCarbon

                carbonVector = getNaturalIsotopeDistributionAtom(obj, obj.rC, nC - iTracerCarbon);
                isotopeVector = conv(carbonVector, nonCarbonVector);
                rowStart = iTracerCarbon + 1;
                rowEnd = min(numObservedMDV, rowStart + length(isotopeVector) - 1);

                if rowStart > numObservedMDV
                    continue
                end % if

                numRows = rowEnd - rowStart + 1;
                CM(rowStart:rowEnd, iTracerCarbon + 1) = isotopeVector(1:numRows)';

            end % for iTracerCarbon

        end % getCorrectedMatrixSkew

        function methodList = getCorrectionMethodList(~)
            % GETCORRECTIONMETHODLIST returns supported natural isotope correction methods.

            methodList = ["matrix", "skew", "least-squares"];

        end % getCorrectionMethodList

        function MDVNormalized = correctNaturalIsotopoper(obj, MDV, nC, nH, nO, nN, nS, nSi, options)
            % CORRECTNATURALISOTOPOPER returns the corrected matrix of the molecule
            %
            % Parameters:
            % -----------
            % MDV: (:, 1) double
            %     Natural isotopic abundance of the molecule
            % nC: (int)
            %     Number of carbon atoms in the molecule
            % nH: (int)
            %     Number of hydrogen atoms in the molecule
            % nO: (int)
            %     Number of oxygen atoms in the molecule
            % nN: (int)
            %     Number of nitrogen atoms in the molecule
            % nS: (int)
            %     Number of sulfur atoms in the molecule
            % nSi: (int)
            %     Number of silicon atoms in the molecule
            % method: (string)
            %     Natural isotope correction method: "matrix", "skew", or "least-squares"
            % numTracerCarbon: (int)
            %     Number of carbon atoms that can be labeled by the tracer in the fragment
            %
            % Returns:
            % --------
            % MDVNormalized: (1, :) double
            %     Corrected matrix of the molecule

            arguments
                obj (1, 1) MDVCorrection
                MDV (:, 1) double {mustBeNonNan, mustBeFinite}
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
                options.method (1, 1) string = "matrix"
                options.numTracerCarbon (1, 1) {mustBeInteger, mustBeNonnegative} = max(0, length(MDV) - 1)
            end % arguments

            method = normalizeCorrectionMethod(obj, options.method);

            switch method
                case "matrix"
                    MDVNormalized = correctNaturalIsotopoperByMatrix( ...
                        obj, MDV, nC, nH, nO, nN, nS, nSi ...
                        );

                case "skew"
                    MDVNormalized = correctNaturalIsotopoperBySkew( ...
                        obj, MDV, nC, nH, nO, nN, nS, nSi, ...
                        numTracerCarbon = options.numTracerCarbon ...
                        );

                case "least-squares"
                    MDVNormalized = correctNaturalIsotopoperByLeastSquares( ...
                        obj, MDV, nC, nH, nO, nN, nS, nSi, ...
                        numTracerCarbon = options.numTracerCarbon ...
                        );
            end % switch

        end % correctNaturalIsotopoper

        function MDVNormalized = correctNaturalIsotopoperByMatrix(obj, MDV, nC, nH, nO, nN, nS, nSi)
            % CORRECTNATURALISOTOPOPERBYMATRIX applies the existing matrix inverse correction.

            arguments
                obj (1, 1) MDVCorrection
                MDV (:, 1) double {mustBeNonNan, mustBeFinite}
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
            end % arguments

            matrix = getCorrectedMatrix(obj, nC, nH, nO, nN, nS, nSi);
            numMDV = length(MDV);
            matrix = matrix(1:numMDV, 1:numMDV);
            MDVCorrected = matrix \ MDV;
            MDVNormalized = normalizeCorrectedMDV(obj, MDVCorrected, numMDV);

        end % correctNaturalIsotopoperByMatrix

        function MDVNormalized = correctNaturalIsotopoperBySkew(obj, MDV, nC, nH, nO, nN, nS, nSi, options)
            % CORRECTNATURALISOTOPOPERBYSKEW applies the skewed matrix correction.

            arguments
                obj (1, 1) MDVCorrection
                MDV (:, 1) double {mustBeNonNan, mustBeFinite}
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
                options.numTracerCarbon (1, 1) {mustBeInteger, mustBeNonnegative} = max(0, length(MDV) - 1)
            end % arguments

            numMDV = length(MDV);
            numTracerCarbon = min([options.numTracerCarbon, nC, numMDV - 1]);
            numCorrectedMDV = numTracerCarbon + 1;

            matrix = getCorrectedMatrixSkew( ...
                obj, nC, nH, nO, nN, nS, nSi, ...
                numObservedMDV = numCorrectedMDV, ...
                numTracerCarbon = numTracerCarbon ...
                );

            MDVCorrected = zeros(numMDV, 1);
            MDVCorrected(1:numCorrectedMDV) = matrix \ MDV(1:numCorrectedMDV);
            MDVNormalized = normalizeCorrectedMDV(obj, MDVCorrected, numMDV);

        end % correctNaturalIsotopoperBySkew

        function MDVNormalized = correctNaturalIsotopoperByLeastSquares(obj, MDV, nC, nH, nO, nN, nS, nSi, options)
            % CORRECTNATURALISOTOPOPERBYLEASTSQUARES applies non-negative least-squares correction.

            arguments
                obj (1, 1) MDVCorrection
                MDV (:, 1) double {mustBeNonNan, mustBeFinite}
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
                options.numTracerCarbon (1, 1) {mustBeInteger, mustBeNonnegative} = max(0, length(MDV) - 1)
            end % arguments

            numMDV = length(MDV);
            numTracerCarbon = min([options.numTracerCarbon, nC, numMDV - 1]);
            numCorrectedMDV = numTracerCarbon + 1;

            matrix = getCorrectedMatrixSkew( ...
                obj, nC, nH, nO, nN, nS, nSi, ...
                numObservedMDV = numMDV, ...
                numTracerCarbon = numTracerCarbon ...
                );

            MDVCorrected = zeros(numMDV, 1);
            MDVCorrected(1:numCorrectedMDV) = solveLeastSquares(obj, matrix, MDV);
            MDVNormalized = normalizeCorrectedMDV(obj, MDVCorrected, numMDV);

        end % correctNaturalIsotopoperByLeastSquares

        function MDVCorrected = correctBiomass(~, MDVInitial, MDVFinal, fraction)
            % CORRECTBIOMASS returns the corrected matrix of the molecule
            %
            % Parameters:
            % -----------
            % MDVInitial: (:, 1) double
            %     Natural isotopic abundance of the molecule
            % MDVFinal: (:, 1) double
            %     Measured isotopic abundance of the molecule
            % fraction: (1, 1) double
            %     Fraction of the molecule
            %
            % Returns:
            % --------
            % MDVCorrected: (:, 1) double
            %     Corrected matrix of the molecule

            arguments
                ~
                MDVInitial (:, 1) double {mustBeNonNan, mustBeFinite}
                MDVFinal (:, 1) double {mustBeNonNan, mustBeFinite}
                % 0 <= fraction <= 1
                fraction (1, 1) {mustBeNonnegative, mustBeLessThanOrEqual(fraction, 1)}
            end % arguments

            MDVCorrected = (MDVFinal - fraction * MDVInitial) / (1 - fraction);

        end % correctBiomass

        function [MDVNormalized, objective, optimalFraction] = ...
                correctWithOptimizedFraction( ...
                obj, MDV, nC, nH, nO, nN, nS, nSi, fraction, options)
            % CORRECTWITHOPTIMIZEDFRACTION jointly corrects isotope and biomass carryover.
            %
            % The transformed variables are w = (1-r)x and r, where x is
            % the newly synthesized MDV and r is the biomass carryover
            % fraction.  This gives the convex constrained least-squares
            % problem
            %
            %   min ||W^(1/2)(y - A(w + r*u))||^2
            %       + ((r-r0)/sigmaR)^2
            %   s.t. w >= 0, rL <= r <= rU, sum(w) + r = 1.
            %
            % Here u is the unlabeled initial-biomass MDV.  The returned
            % MDV is x = w/(1-r).

            arguments
                obj (1, 1) MDVCorrection
                MDV (:, 1) double {mustBeNonNan, mustBeFinite}
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
                fraction (1, 1) double {mustBeFinite}
                options.numTracerCarbon (1, 1) ...
                    {mustBeInteger, mustBeNonnegative} = ...
                    max(0, length(MDV) - 1)
                options.fractionStandardDeviation (1, 1) double ...
                    {mustBePositive, mustBeFinite} = 0.01
                options.fractionBounds (1, 2) double ...
                    {mustBeFinite} = [0, (1 -1e-8)]
                options.weights (:, 1) double ...
                    {mustBePositive, mustBeFinite} = 0.01 * ones(size(MDV))
            end % arguments

            numMDV = length(MDV);

            if length(options.weights) ~= numMDV
                error( ...
                    "MDVCorrection:InvalidOptimizationWeights", ...
                    "There must be one optimization weight per MDV value.");
            end % if

            fractionBounds = options.fractionBounds;

            if fractionBounds(1) < 0 || ...
                    fractionBounds(2) >= 1 || ...
                    fractionBounds(1) > fractionBounds(2)
                error( ...
                    "MDVCorrection:InvalidFractionBounds", ...
                    "Fraction bounds must satisfy " + ...
                    "0 <= lower <= upper < 1.");
            end % if

            numTracerCarbon = min( ...
                [options.numTracerCarbon, nC, numMDV - 1]);
            numCorrectedMDV = numTracerCarbon + 1;
            correctionMatrix = getCorrectedMatrixSkew( ...
                obj, nC, nH, nO, nN, nS, nSi, ...
                numObservedMDV = numMDV, ...
                numTracerCarbon = numTracerCarbon ...
                );
            initialMDV = zeros(numCorrectedMDV, 1);
            initialMDV(1) = 1;
            squareRootWeights = sqrt(options.weights);
            predictionMatrix = [ ...
                correctionMatrix, correctionMatrix * initialMDV];
            weightedPredictionMatrix = ...
                squareRootWeights .* predictionMatrix;
            augmentedMatrix = [
                weightedPredictionMatrix
                zeros(1, numCorrectedMDV), ...
                1 / options.fractionStandardDeviation
                ];
            augmentedTarget = [
                squareRootWeights .* MDV
                fraction / options.fractionStandardDeviation
                ];
            equalityMatrix = [ones(1, numCorrectedMDV), 1];
            lowerBounds = [zeros(numCorrectedMDV, 1); fractionBounds(1)];
            upperBounds = [inf(numCorrectedMDV, 1); fractionBounds(2)];
            solution = solveFractionConstrainedLeastSquares( ...
                obj, ...
                augmentedMatrix, ...
                augmentedTarget, ...
                equalityMatrix, ...
                lowerBounds, ...
                upperBounds, ...
                fraction);

            w = solution(1:numCorrectedMDV);
            optimalFraction = solution(end);
            corrected = w / (1 - optimalFraction);
            MDVCorrected = zeros(numMDV, 1);
            MDVCorrected(1:numCorrectedMDV) = corrected;
            MDVNormalized = normalizeCorrectedMDV( ...
                obj, MDVCorrected, numMDV);

            predictedMDV = correctionMatrix * ...
                (w + optimalFraction * initialMDV);
            residual = MDV - predictedMDV;
            objective = sum(options.weights .* residual .^ 2) + ...
                ((optimalFraction - fraction) / ...
                options.fractionStandardDeviation) ^ 2;

        end % correctWithOptimizedFraction

    end % methods

    methods (Access = private)

        function sizeMatrix = getSizeMatrix(obj, nC, nH, nO, nN, nS, nSi)
            % GETSIZEMATRIX returns the size matrix of the molecule
            %
            % Parameters:
            % -----------
            % nC: (int)
            %     Number of carbon atoms in the molecule
            % nH: (int)
            %     Number of hydrogen atoms in the molecule
            % nO: (int)
            %     Number of oxygen atoms in the molecule
            % nN: (int)
            %     Number of nitrogen atoms in the molecule
            % nS: (int)
            %     Number of sulfur atoms in the molecule
            % nSi: (int)
            %     Number of silicon atoms in the molecule
            %
            % Returns:
            % --------
            % sizeMatrix: (int)
            %     Size matrix of the molecule

            arguments
                obj (1, 1) MDVCorrection
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
            end % arguments

            sizeMatrix = ...
                (obj.lC - 1) * nC + ...
                (obj.lH - 1) * nH + ...
                (obj.lO - 1) * nO + ...
                (obj.lN - 1) * nN + ...
                (obj.lS - 1) * nS + ...
                (obj.lSi - 1) * nSi + 1;

        end % getSizeMatrix

        function CM = getCorrectedMatrixAtom(obj, ratio, numAtom)
            % GETCORRECTEDMATRIXATOM returns the corrected matrix of the atom
            %
            % Parameters:
            % -----------
            % ratio: (1, 1) double
            %     Natural isotopic abundance of the atom
            % numAtom: (1, 1) int
            %     Number of atoms in the molecule
            %
            % Returns:
            % --------
            % CM: (numSize, numSize) double
            %     Corrected matrix of the atom

            arguments
                obj (1, 1) MDVCorrection
                ratio (1, :) double {mustBeNonnegative}
                numAtom (1, 1) {mustBeInteger, mustBeNonnegative}
            end % arguments

            CM = zeros(obj.numSize, obj.numSize);

            CMVector = ratio;

            for i = 1:numAtom - 1
                CMVector = conv(CMVector, ratio);
            end % for i

            if numAtom == 0
                CMVector = 1;
            end % if

            CMVector = CMVector';

            for i = 1:obj.numSize

                iColumn = obj.numSize - i + 1;

                % If the size of MDV is larger than i (the number of fractions contained in the
                % matrix column numAtom)
                if length(CMVector) >= i

                    CM(iColumn:end, iColumn) = CMVector(1:i);
                    continue

                end % if

                CM(iColumn:iColumn + length(CMVector) - 1, iColumn) = CMVector;

            end % for i

        end % getCorrectedMatrixAtom

        function distribution = getNaturalIsotopeDistribution(obj, nC, nH, nO, nN, nS, nSi)
            % GETNATURALISOTOPEDISTRIBUTION returns the mass-shift distribution of a molecule.

            arguments
                obj (1, 1) MDVCorrection
                nC (1, 1) {mustBeInteger, mustBeNonnegative}
                nH (1, 1) {mustBeInteger, mustBeNonnegative}
                nO (1, 1) {mustBeInteger, mustBeNonnegative}
                nN (1, 1) {mustBeInteger, mustBeNonnegative}
                nS (1, 1) {mustBeInteger, mustBeNonnegative}
                nSi (1, 1) {mustBeInteger, mustBeNonnegative}
            end % arguments

            distribution = getNaturalIsotopeDistributionAtom(obj, obj.rC, nC);
            distribution = conv(distribution, getNaturalIsotopeDistributionAtom(obj, obj.rH, nH));
            distribution = conv(distribution, getNaturalIsotopeDistributionAtom(obj, obj.rO, nO));
            distribution = conv(distribution, getNaturalIsotopeDistributionAtom(obj, obj.rN, nN));
            distribution = conv(distribution, getNaturalIsotopeDistributionAtom(obj, obj.rS, nS));
            distribution = conv(distribution, getNaturalIsotopeDistributionAtom(obj, obj.rSi, nSi));

        end % getNaturalIsotopeDistribution

        function distribution = getNaturalIsotopeDistributionAtom(~, ratio, numAtom)
            % GETNATURALISOTOPEDISTRIBUTIONATOM returns the mass-shift distribution of atoms.

            arguments
                ~
                ratio (1, :) double {mustBeNonnegative}
                numAtom (1, 1) {mustBeInteger, mustBeNonnegative}
            end % arguments

            distribution = 1;

            for i = 1:numAtom
                distribution = conv(distribution, ratio);
            end % for i

        end % getNaturalIsotopeDistributionAtom

        function MDVNormalized = normalizeCorrectedMDV(~, MDVCorrected, numMDV)
            % NORMALIZECORRECTEDMDV normalizes an MDV and keeps the legacy row-vector output.

            arguments
                ~
                MDVCorrected (:, 1) double
                numMDV (1, 1) {mustBeInteger, mustBePositive}
            end % arguments

            MDVCorrected = MDVCorrected(1:numMDV);
            totalMDV = sum(MDVCorrected);

            if abs(totalMDV) <= eps
                MDVNormalized = nan(1, numMDV);
                return
            end % if

            MDVNormalized = transpose(MDVCorrected / totalMDV);

        end % normalizeCorrectedMDV

        function MDVCorrected = solveLeastSquares(~, matrix, MDV)
            % SOLVELEASTSQUARES solves a non-negative least-squares correction problem.

            arguments
                ~
                matrix (:, :) double {mustBeFinite}
                MDV (:, 1) double {mustBeNonNan, mustBeFinite}
            end % arguments

            if exist('lsqnonneg', 'file') == 2
                MDVCorrected = lsqnonneg(matrix, MDV);
                return
            end % if

            MDVCorrected = matrix \ MDV;
            MDVCorrected(MDVCorrected < 0) = 0;

        end % solveLeastSquares

        function solution = solveFractionConstrainedLeastSquares( ...
                obj, matrix, target, equalityMatrix, lowerBounds, ...
                upperBounds, measuredFraction)
            % SOLVEFRACTIONCONSTRAINEDLEASTSQUARES solves the convex QP.

            if exist('lsqlin', 'file') == 2
                solverOptions = optimoptions( ...
                    'lsqlin', ...
                    'Display', 'off', ...
                    'OptimalityTolerance', 1e-12, ...
                    'ConstraintTolerance', 1e-12);
                [candidate, ~, ~, exitFlag] = lsqlin( ...
                    matrix, ...
                    target, ...
                    [], ...
                    [], ...
                    equalityMatrix, ...
                    1, ...
                    lowerBounds, ...
                    upperBounds, ...
                    [], ...
                    solverOptions);

                if exitFlag > 0 && all(isfinite(candidate))
                    solution = candidate;
                    return
                end % if

            end % if

            % Toolbox-independent projected-gradient fallback.  Projection
            % is onto the bounded simplex defined by the linear constraints.
            initialFraction = min( ...
                max(measuredFraction, lowerBounds(end)), ...
                upperBounds(end));
            solution = [ ...
                1 - initialFraction; ...
                zeros(length(lowerBounds) - 2, 1); ...
                initialFraction];
            solution = projectBoundedSimplex( ...
                obj, solution, lowerBounds, upperBounds);
            lipschitz = 2 * norm(matrix, 2) ^ 2;

            if lipschitz <= eps
                return
            end % if

            stepSize = 1 / lipschitz;

            for iteration = 1:10000
                gradient = 2 * matrix' * (matrix * solution - target);
                candidate = projectBoundedSimplex( ...
                    obj, ...
                    solution - stepSize * gradient, ...
                    lowerBounds, ...
                    upperBounds);

                if norm(candidate - solution, inf) <= 1e-12
                    solution = candidate;
                    return
                end % if

                solution = candidate;
            end % for

        end % solveFractionConstrainedLeastSquares

        function projected = projectBoundedSimplex( ...
                ~, value, lowerBounds, upperBounds)
            % PROJECTBOUNDEDSIMPLEX projects a vector while preserving sum=1.

            lowerLambda = min(value) - 1;
            upperLambda = max(value - lowerBounds);

            for iteration = 1:100
                lambda = (lowerLambda + upperLambda) / 2;
                projected = min( ...
                    max(value - lambda, lowerBounds), ...
                    upperBounds);

                if sum(projected) > 1
                    lowerLambda = lambda;
                else
                    upperLambda = lambda;
                end % if

            end % for

            lambda = (lowerLambda + upperLambda) / 2;
            projected = min( ...
                max(value - lambda, lowerBounds), ...
                upperBounds);

        end % projectBoundedSimplex

        function method = normalizeCorrectionMethod(obj, method)
            % NORMALIZECORRECTIONMETHOD validates and canonicalizes correction method names.

            arguments
                obj (1, 1) MDVCorrection
                method (1, 1) string
            end % arguments

            method = lower(strtrim(method));

            switch method
                case {"matrix", "inverse", "legacy"}
                    method = "matrix";

                case {"skew", "skewed", "skewed-matrix", "skewed_matrix"}
                    method = "skew";

                case {"least-squares", "least_squares", "least squares", "ls", "lsq", "lsc", "nnls", "least-squares-skew"}
                    method = "least-squares";

                otherwise
                    methodList = strjoin(getCorrectionMethodList(obj), '", "');
                    error( ...
                        "MDVCorrection:InvalidCorrectionMethod", ...
                        "Unknown natural isotope correction method '%s'. Use one of: \", char(method), char(methodList) ...
                        );
            end % switch

        end % normalizeCorrectionMethod

    end % methods (Access = private)

end % classdef
