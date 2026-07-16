classdef EMUMatrixBuilder
    % EMUMATRIXBUILDER Builds state-independent EMU matrix artifacts.

    methods

        function result = buildCn( ...
                ~, sizeInfo, anEMUMetabolites, metaboliteNames)

            arguments
                ~
                sizeInfo table
                anEMUMetabolites cell
                metaboliteNames
            end

            maxEMUSize = max(sizeInfo.EMUSize);
            maxAn = max(sizeInfo.An);
            metaboliteNames = string(metaboliteNames(:));
            numMetabolites = numel(metaboliteNames);
            matrix = false(maxAn, numMetabolites, maxEMUSize);
            diagonal = zeros(maxAn, maxEMUSize);

            for emuSize = 1:maxEMUSize
                emuMetabolites = anEMUMetabolites(:, emuSize);
                isEmpty = cellfun(@isempty, emuMetabolites);
                emuMetabolites(isEmpty) = {""};
                emuMetabolites = string(emuMetabolites);

                for metaboliteIndex = 1:numMetabolites
                    isMatch = ismember( ...
                        emuMetabolites, ...
                        metaboliteNames(metaboliteIndex));
                    matrix(isMatch, metaboliteIndex, emuSize) = true;
                end
            end

            result = openmebius.mfa.EMUCnMatrixResult( ...
                matrix, diagonal);

        end % buildCn

        function result = buildMDV( ...
                ~, tableEMU, tableEMUReaction, anEMUNames, sizeInfo)

            arguments
                ~
                tableEMU table
                tableEMUReaction table
                anEMUNames cell
                sizeInfo table
            end

            targetEMU = tableEMU(tableEMU.Target == true, :);
            targetEMU = sortrows(targetEMU, "Metabolite");
            sizeVector = targetEMU.Size;
            numTargetEMU = height(targetEMU);
            info = zeros(numTargetEMU, 2);

            for targetIndex = 1:numTargetEMU
                emuSize = sizeVector(targetIndex);
                info(targetIndex, 1) = emuSize;

                if targetIndex > 1
                    info(targetIndex, 2) = ...
                        info(targetIndex - 1, 2) + ...
                        info(targetIndex - 1, 1) + 1;
                else
                    info(targetIndex, 2) = 1;
                end
            end

            vectorSize = info(end, 2) + info(end, 1);
            indexList = zeros(0, 5);

            for targetIndex = 1:numTargetEMU
                mdvSize = info(targetIndex, 1);
                startIndex = info(targetIndex, 2);
                targetReaction = tableEMUReaction( ...
                    cellfun( ...
                        @(products) any(isequal( ...
                            products, targetEMU.EMU(targetIndex))), ...
                        tableEMUReaction.Products), ...
                    :);
                reactants = targetReaction.Reactants{:};

                for reactantIndex = 1:length(reactants)
                    isConvolution = reactantIndex > 1;
                    reactantSize = tableEMU.Size( ...
                        tableEMU.EMU == reactants{reactantIndex});
                    sizeColumn = sizeInfo.EMUSize == reactantSize;
                    anIndex = find( ...
                        cellfun( ...
                            @(name) isequal( ...
                                name, reactants(reactantIndex)), ...
                            anEMUNames(1:sizeInfo.An(sizeColumn), ...
                                sizeColumn)), ...
                        1);
                    indexList(end + 1, :) = [ ...
                        reactantSize, ...
                        isConvolution, ...
                        anIndex, ...
                        startIndex, ...
                        mdvSize ...
                    ]; %#ok<AGROW>
                end
            end

            indexList = sortrows(indexList, 2, "ascend");
            result = openmebius.mfa.EMUMDVIndexResult( ...
                info, vectorSize, indexList);

        end % buildMDV

    end % methods

end % classdef
