classdef EMUMDVCalculator
    % EMUMDVCALCULATOR Evaluates a constructed EMU network.

    methods

        function mdv = calculate(obj, snapshot, flux, substrateEMU)

            arguments
                obj
                snapshot (1, 1) openmebius.domain.model.EMUNetworkSnapshot
                flux double
                substrateEMU double
            end

            [an, bn] = obj.substituteAnBn(snapshot, flux);
            [xn, ~] = obj.substituteXnYn( ...
                snapshot, substrateEMU, an, bn);
            mdv = openmebius.mfa.EMUMDVCalculator ...
                .assembleMDV(snapshot, xn);

        end % calculate

        function mdv = calculateTimeCourse( ...
                obj, snapshot, flux, substrateEMU, poolSize, timeSpan)

            arguments
                obj
                snapshot (1, 1) openmebius.domain.model.EMUNetworkSnapshot
                flux double
                substrateEMU double
                poolSize double
                timeSpan double
            end

            [an, bn] = obj.substituteAnBn(snapshot, flux);
            cn = obj.substituteCn(snapshot, poolSize);
            [~, xnTimeCourse] = ode15s( ...
                @(~, xn) obj.calculateDerivativeFromMatrices( ...
                    snapshot, xn, substrateEMU, an, bn, cn), ...
                timeSpan, ...
                snapshot.GlobalXn(:));
            mdv = obj.assembleTimeCourse(snapshot, xnTimeCourse);

        end % calculateTimeCourse

        function derivative = calculateDerivative( ...
                obj, snapshot, xn, flux, substrateEMU, poolSize)

            arguments
                obj
                snapshot (1, 1) openmebius.domain.model.EMUNetworkSnapshot
                xn double
                flux double
                substrateEMU double
                poolSize double
            end

            [an, bn] = obj.substituteAnBn(snapshot, flux);
            cn = obj.substituteCn(snapshot, poolSize);
            derivative = obj.calculateDerivativeFromMatrices( ...
                snapshot, xn, substrateEMU, an, bn, cn);

        end % calculateDerivative

        function mdv = assembleTimeCourse(~, snapshot, xnTimeCourse)

            arguments
                ~
                snapshot (1, 1) openmebius.domain.model.EMUNetworkSnapshot
                xnTimeCourse double
            end

            numTimePoints = size(xnTimeCourse, 1);
            xn = reshape( ...
                xnTimeCourse, ...
                [numTimePoints, ...
                 size(snapshot.GlobalXn, 1), ...
                 size(snapshot.GlobalXn, 2), ...
                 size(snapshot.GlobalXn, 3)]);
            mdvByTime = zeros(numTimePoints, snapshot.GlobalMDVSize);
            mdvList = snapshot.GlobalMDVList;
            sizeInfo = snapshot.TableEMUSizeInfo;

            for listIndex = 1:size(mdvList, 1)
                entry = mdvList(listIndex, :);
                emuSize = entry(1);
                sizeIndex = sizeInfo.EMUSize == emuSize;
                mdvStart = entry(4);
                source = reshape( ...
                    xn(:, entry(3), 1:emuSize + 1, sizeIndex), ...
                    numTimePoints, emuSize + 1);

                if entry(2) == 0
                    mdvByTime(:, mdvStart:mdvStart + emuSize) = source;
                    continue
                end

                productSize = entry(5);
                targetRange = mdvStart:mdvStart + productSize;

                for timeIndex = 1:numTimePoints
                    value = conv( ...
                        source(timeIndex, :), ...
                        mdvByTime(timeIndex, targetRange));
                    mdvByTime(timeIndex, targetRange) = ...
                        value(1:productSize + 1);
                end
            end

            mdv = mdvByTime.';

        end % assembleTimeCourse

        function [an, bn] = substituteAnBn(~, snapshot, flux)

            arguments
                ~
                snapshot (1, 1) openmebius.domain.model.EMUNetworkSnapshot
                flux double
            end

            an = snapshot.GlobalAn;
            bn = snapshot.GlobalBn;

            for listIndex = 1:size(snapshot.GlobalAnList, 1)
                entry = snapshot.GlobalAnList(listIndex, :);
                reactionIndex = entry(2);
                an(entry(3), entry(4), entry(1)) = ...
                    an(entry(3), entry(4), entry(1)) + ...
                    flux(reactionIndex) * entry(5);
            end

            for listIndex = 1:size(snapshot.GlobalBnList, 1)
                entry = snapshot.GlobalBnList(listIndex, :);
                reactionIndex = entry(2);
                bn(entry(3), entry(4), entry(1)) = ...
                    bn(entry(3), entry(4), entry(1)) + ...
                    flux(reactionIndex) * entry(5);
            end

        end % substituteAnBn

        function cn = substituteCn(~, snapshot, poolSize)

            arguments
                ~
                snapshot (1, 1) openmebius.domain.model.EMUNetworkSnapshot
                poolSize double
            end

            cnMask = snapshot.GlobalCn;
            cn = snapshot.GlobalCnDiag;
            poolSize = double(poolSize(:));
            numPoolMetabolites = numel(poolSize);
            numCnMetabolites = size(cnMask, 2);

            if numPoolMetabolites ~= numCnMetabolites
                error( ...
                    'EMUModel:PoolSizeDimensionMismatch', ...
                    ['The pool size vector length (%d) does not match the number of ' ...
                     'model metabolites in the EMU Cn matrix (%d). Check the INST-MFA ' ...
                     'pool-size table and rebuild the EMU model cache if necessary.'], ...
                    numPoolMetabolites, ...
                    numCnMetabolites);
            end

            if any(~isfinite(poolSize)) || any(poolSize <= 0)
                error( ...
                    'EMUModel:InvalidPoolSize', ...
                    'INST-MFA pool sizes must be finite positive values.');
            end

            sizeInfo = snapshot.TableEMUSizeInfo;

            for sizeRow = 1:height(sizeInfo)
                emuSize = sizeInfo.EMUSize(sizeRow);

                for metaboliteIndex = 1:numCnMetabolites
                    mask = cnMask(:, metaboliteIndex, emuSize);
                    cn(mask, emuSize) = 1 / poolSize(metaboliteIndex);
                end
            end

        end % substituteCn

        function [xn, yn] = substituteXnYn( ...
                ~, snapshot, substrateEMU, an, bn, currentXn)

            arguments
                ~
                snapshot (1, 1) openmebius.domain.model.EMUNetworkSnapshot
                substrateEMU double
                an double
                bn double
                currentXn double = []
            end

            calculateXn = nargin < 6;

            if calculateXn
                xn = snapshot.GlobalXn;
            else
                xn = currentXn;
            end

            yn = snapshot.GlobalYn;
            sizeInfo = snapshot.TableEMUSizeInfo;

            for sizeRow = 1:height(sizeInfo)
                selectedSize = sizeRow;
                selectedYnList = snapshot.GlobalYnList( ...
                    snapshot.GlobalYnList(:, 1) == selectedSize, :);

                for listIndex = 1:size(selectedYnList, 1)
                    entry = selectedYnList(listIndex, :);
                    ynRow = entry(2);
                    isConvolution = entry(3) ~= 0;
                    isSubstrate = entry(4) == 1;
                    sourceSizeOrIndex = entry(5);

                    if isSubstrate
                        source = substrateEMU( ...
                            sourceSizeOrIndex, 1:selectedSize + 1);
                    else
                        sourceSizeIndex = ...
                            sizeInfo.EMUSize == sourceSizeOrIndex;
                        source = xn( ...
                            entry(6), 1:selectedSize + 1, sourceSizeIndex);
                    end

                    if isConvolution
                        current = yn( ...
                            ynRow, 1:selectedSize + 1, selectedSize);
                        value = conv(source, current);
                        value = value(1:selectedSize + 1);
                    else
                        value = source;
                    end

                    yn(ynRow, 1:selectedSize + 1, selectedSize) = value;
                end

                if calculateXn
                    numAn = sizeInfo.An(sizeRow);
                    numBn = sizeInfo.Bn(sizeRow);
                    regularization = 10^-8 * eye(numAn);
                    xn(1:numAn, 1:selectedSize + 1, selectedSize) = ...
                        (regularization + ...
                         an(1:numAn, 1:numAn, selectedSize)) \ ...
                        (bn(1:numAn, 1:numBn, selectedSize) * ...
                         yn(1:numBn, 1:selectedSize + 1, selectedSize));
                end
            end

        end % substituteXnYn

    end % methods

    methods (Access = private)

        function derivative = calculateDerivativeFromMatrices( ...
                obj, snapshot, xn, substrateEMU, an, bn, cn)

            xn = reshape(xn, size(snapshot.GlobalXn));
            [~, yn] = obj.substituteXnYn( ...
                snapshot, substrateEMU, an, bn, xn);
            derivative = zeros(size(xn));
            sizeInfo = snapshot.TableEMUSizeInfo;

            for sizeRow = 1:height(sizeInfo)
                emuSize = sizeInfo.EMUSize(sizeRow);
                numAn = sizeInfo.An(sizeRow);
                numBn = sizeInfo.Bn(sizeRow);
                currentAn = an(1:numAn, 1:numAn, emuSize);
                currentBn = bn(1:numAn, 1:numBn, emuSize);
                currentCn = diag(cn(1:numAn, emuSize));
                currentXn = xn( ...
                    1:numAn, 1:emuSize + 1, emuSize);
                currentYn = yn( ...
                    1:numBn, 1:emuSize + 1, emuSize);
                derivative( ...
                    1:numAn, 1:emuSize + 1, emuSize) = ...
                    currentCn * ...
                    (currentAn * currentXn - currentBn * currentYn);
            end

            derivative = derivative(:);

        end % calculateDerivativeFromMatrices

    end % methods (Access = private)

    methods (Static, Access = private)

        function mdv = assembleMDV(snapshot, xn)

            mdv = zeros(snapshot.GlobalMDVSize, 1);
            mdvList = snapshot.GlobalMDVList;
            sizeInfo = snapshot.TableEMUSizeInfo;

            for listIndex = 1:size(mdvList, 1)
                entry = mdvList(listIndex, :);
                emuSize = entry(1);
                sizeIndex = sizeInfo.EMUSize == emuSize;
                mdvStart = entry(4);

                if entry(2) == 0
                    value = xn(entry(3), 1:emuSize + 1, sizeIndex)';
                    mdv(mdvStart:mdvStart + emuSize) = ...
                        value(1:emuSize + 1);
                else
                    productSize = entry(5);
                    current = mdv(mdvStart:mdvStart + productSize);
                    value = conv( ...
                        xn(entry(3), 1:emuSize + 1, sizeIndex)', ...
                        current);
                    mdv(mdvStart:mdvStart + productSize) = ...
                        value(1:productSize + 1);
                end
            end

        end % assembleMDV

    end % methods (Static, Access = private)

end % classdef
