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

        function MDVNormalized = correctNaturalIsotopoper(obj, MDV, nC, nH, nO, nN, nS, nSi)
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
            %
            % Returns:
            % --------
            % MDVNormalized: (:, 1) double
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
            end % arguments

            matrix = getCorrectedMatrix(obj, nC, nH, nO, nN, nS, nSi);
            numMDV = length(MDV);
            matrix = matrix(1:numMDV, 1:numMDV);
            MDVCorrected(1:numMDV) = matrix \ MDV;
            MDVNormalized = MDVCorrected / sum(MDVCorrected);

        end % correctNaturalIsotopoper

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

    end % methods (Access = private)

end % classdef
