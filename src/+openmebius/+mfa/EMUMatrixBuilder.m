classdef EMUMatrixBuilder
    % EMUMATRIXBUILDER Builds state-independent EMU matrix artifacts.

    methods

        function result = buildAnBn( ...
                ~, sizeInfo, tableEMU, tableEMUReaction, ...
                substrateMetabolites, reactionIDs)

            arguments
                ~
                sizeInfo table
                tableEMU table
                tableEMUReaction table
                substrateMetabolites string
                reactionIDs string
            end

            maxAn = max(sizeInfo.An);
            maxBn = max(sizeInfo.Bn);
            numSizes = max(sizeInfo.EMUSize);
            an = zeros(maxAn, maxAn, numSizes);
            bn = zeros(maxAn, maxBn, numSizes);
            anNames = cell(maxAn, numSizes);
            anMetabolites = cell(maxAn, numSizes);
            bnNames = cell(maxBn, numSizes);
            bnMetabolites = cell(maxBn, numSizes);
            anList = [];
            bnList = [];
            substrateMetabolites = string(substrateMetabolites(:));
            reactionIDs = string(reactionIDs(:));
            reactions = tableEMUReaction( ...
                tableEMUReaction.Target == false, :);

            for emuSize = 1:numSizes
                anCount = 0;
                bnCount = 0;
                sizeReactions = reactions( ...
                    reactions.Size == emuSize, :);

                if isempty(sizeReactions)
                    continue
                end

                emuGroups = vertcat( ...
                    sizeReactions.Reactants, ...
                    sizeReactions.Products);
                uniqueGroups = openmebius.mfa.EMUMatrixBuilder ...
                    .uniqueEMUGroups(emuGroups);

                for groupIndex = 1:length(uniqueGroups)
                    group = uniqueGroups{groupIndex};
                    isSubstrate = length(group) > 1;
                    metabolite = "";

                    for emuIndex = 1:length(group)
                        emuName = group{emuIndex};
                        metabolite = tableEMU.Metabolite( ...
                            tableEMU.EMU == emuName);

                        if ismember(metabolite, substrateMetabolites)
                            isSubstrate = true;
                            break
                        end
                    end

                    if ~isSubstrate
                        anCount = anCount + 1;
                        anNames{anCount, emuSize} = group;
                        anMetabolites{anCount, emuSize} = metabolite;
                    else
                        bnCount = bnCount + 1;
                        bnNames{bnCount, emuSize} = group;
                        bnMetabolites{bnCount, emuSize} = metabolite;
                    end
                end
            end

            for emuSize = 1:numSizes
                sizeAnNames = anNames(1:sizeInfo.An(emuSize), emuSize);
                sizeBnNames = bnNames(1:sizeInfo.Bn(emuSize), emuSize);
                sizeNames = [sizeAnNames; sizeBnNames];
                reactionList = nan(0, 5);

                for anIndex = 1:length(sizeAnNames)
                    matchingReactions = reactions( ...
                        cellfun( ...
                        @(value) any(isequal( ...
                        value, sizeAnNames{anIndex})), ...
                        reactions.Reactants) | ...
                        cellfun( ...
                        @(value) any(isequal( ...
                        value, sizeAnNames{anIndex})), ...
                        reactions.Products), ...
                        :);

                    for reactionIndex = 1:height(matchingReactions)
                        reactionID = matchingReactions.RxnID{reactionIndex};
                        modelReactionIndex = find(strcmp( ...
                            reactionIDs, reactionID));

                        if isempty(modelReactionIndex)
                            modelReactionIndex = -1;
                        end

                        reactants = matchingReactions.Reactants{reactionIndex};
                        products = matchingReactions.Products{reactionIndex};
                        coefficient = ...
                            matchingReactions.Coefficient(reactionIndex);

                        if isequal(products, sizeNames{anIndex})
                            currentColumn = find(cellfun( ...
                                @(value) isequal(value, reactants), ...
                                sizeNames));
                            reactionList(end + 1, :) = [ ...
                                emuSize, ...
                                modelReactionIndex, ...
                                anIndex, ...
                                currentColumn, ...
                                -coefficient ...
                                ]; %#ok<AGROW>
                            reactionList(end + 1, :) = [ ...
                                emuSize, ...
                                modelReactionIndex, ...
                                anIndex, ...
                                anIndex, ...
                                coefficient ...
                                ]; %#ok<AGROW>
                        end
                    end
                end

                sizeAnList = reactionList( ...
                    reactionList(:, 4) <= sizeInfo.An(emuSize), :);
                sizeAnList(:, 5) = -sizeAnList(:, 5);
                sizeBnList = reactionList( ...
                    reactionList(:, 4) > sizeInfo.An(emuSize), :);
                sizeBnList(:, 4) = ...
                    sizeBnList(:, 4) - sizeInfo.An(emuSize);
                anList = [anList; sizeAnList]; %#ok<AGROW>
                bnList = [bnList; sizeBnList]; %#ok<AGROW>
            end

            [uniqueAnRows, ~, anGroups] = unique( ...
                anList(:, 1:4), "rows");
            anCoefficients = accumarray(anGroups, anList(:, 5));
            anList = [uniqueAnRows, anCoefficients];
            [uniqueBnRows, ~, bnGroups] = unique( ...
                bnList(:, 1:4), "rows");
            bnCoefficients = accumarray(bnGroups, bnList(:, 5));
            bnList = [uniqueBnRows, bnCoefficients];

            result = openmebius.mfa.EMUAnBnMatrixResult( ...
                An = an, ...
                Bn = bn, ...
                AnNames = anNames, ...
                AnMetabolites = anMetabolites, ...
                BnNames = bnNames, ...
                BnMetabolites = bnMetabolites, ...
                AnList = anList, ...
                BnList = bnList);

        end % buildAnBn

        function result = buildXnYn( ...
                ~, sizeInfo, tableEMU, anNames, bnNames, metaboliteTable)

            arguments
                ~
                sizeInfo table
                tableEMU table
                anNames cell
                bnNames cell
                metaboliteTable table
            end

            maxSize = max(sizeInfo.EMUSize);
            maxAn = max(sizeInfo.An);
            maxBn = max(sizeInfo.Bn);
            xn = zeros(maxAn, maxSize + 1, maxSize);
            yn = zeros(maxBn, maxSize + 1, maxSize);
            xn(:, 1, :) = 1;
            yn(:, 1, :) = 1;
            xnList = [];
            ynList = [];
            metaboliteNames = string(metaboliteTable.Metabolite);
            isSubstrateRow = string(metaboliteTable.Type) == "substrate";
            substrateMetabolites = metaboliteTable(isSubstrateRow, :);
            substrateNames = string(substrateMetabolites.Metabolite);

            if height(substrateMetabolites) == 0
                result = openmebius.mfa.EMUXnYnMatrixResult( ...
                    Xn = xn, ...
                    Yn = yn, ...
                    XnList = xnList, ...
                    YnList = ynList, ...
                    HasSubstrates = false);
                return
            end

            substrateEMUInfo = nan(height(substrateMetabolites), 2);
            substrateEMUInfo(1, 1) = 1;

            for substrateIndex = 1:height(substrateMetabolites)
                if substrateIndex > 1
                    substrateEMUInfo(substrateIndex, 1) = ...
                        substrateEMUInfo(substrateIndex - 1, 1) + ...
                        substrateEMUInfo(substrateIndex - 1, 2);
                end

                carbonCount = ...
                    substrateMetabolites.Carbon{substrateIndex};
                substrateEMUInfo(substrateIndex, 2) = ...
                    2 ^ carbonCount - 1;
            end

            for emuSize = 1:maxSize
                sizeYnList = zeros(0, 6);
                sizeBnNames = bnNames( ...
                    1:sizeInfo.Bn(emuSize), emuSize);

                for bnIndex = 1:length(sizeBnNames)
                    emuGroup = sizeBnNames{bnIndex};

                    for emuIndex = 1:length(emuGroup)
                        isConvolution = emuIndex > 1;
                        emuName = emuGroup{emuIndex};
                        metaboliteName = tableEMU.Metabolite( ...
                            tableEMU.EMU == emuName);
                        isSubstrate = ismember( ...
                            string(metaboliteName), substrateNames);

                        if isSubstrate
                            position = tableEMU.Position{ ...
                                tableEMU.EMU == emuName};
                            carbonCount = metaboliteTable.Carbon{ ...
                                metaboliteNames == string(metaboliteName)};
                            pattern = false(1, carbonCount);
                            pattern(position) = true;
                            relativePosition = ...
                                openmebius.mfa.EMUMatrixBuilder ...
                                .substrateEMUPosition(pattern);
                            substrateRow = find(strcmp( ...
                                substrateNames, metaboliteName), 1);
                            startIndex = substrateEMUInfo( ...
                                substrateRow, 1);
                            emuPosition = ...
                                startIndex + relativePosition - 1;
                            sizeYnList(end + 1, :) = [ ...
                                emuSize, ...
                                bnIndex, ...
                                isConvolution, ...
                                true, ...
                                emuPosition, ...
                                0 ...
                                ]; %#ok<AGROW>
                            continue
                        end

                        sourceSize = tableEMU.Size( ...
                            tableEMU.EMU == emuName);
                        sourceSizeColumn = find( ...
                            sizeInfo.EMUSize == sourceSize, 1);
                        sourceAnIndex = find(cellfun( ...
                            @(name) isequal(name, emuGroup(emuIndex)), ...
                            anNames(1:sizeInfo.An(sourceSizeColumn), ...
                            sourceSizeColumn)), ...
                            1);
                        sizeYnList(end + 1, :) = [ ...
                            emuSize, ...
                            bnIndex, ...
                            isConvolution, ...
                            false, ...
                            sourceSize, ...
                            sourceAnIndex ...
                            ]; %#ok<AGROW>
                    end
                end

                ynList = [ynList; sizeYnList]; %#ok<AGROW>
            end

            ynList = sortrows(ynList, [1, 2, 3, 4]);
            result = openmebius.mfa.EMUXnYnMatrixResult( ...
                Xn = xn, ...
                Yn = yn, ...
                XnList = xnList, ...
                YnList = ynList, ...
                HasSubstrates = true);

        end % buildXnYn

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

    methods (Static)

        function uniqueGroups = uniqueEMUGroups(emuGroups)

            uniqueGroups = cell(0);

            for groupIndex = 1:length(emuGroups)
                currentGroup = emuGroups{groupIndex};
                isListed = false;

                for listedIndex = 1:length(uniqueGroups)
                    listedGroup = uniqueGroups{listedIndex};

                    if length(currentGroup) ~= length(listedGroup)
                        continue
                    end

                    isListed = true;

                    for emuIndex = 1:length(currentGroup)
                        if ~strcmp( ...
                                currentGroup{emuIndex}, ...
                                listedGroup{emuIndex})
                            isListed = false;
                            break
                        end
                    end

                    if isListed
                        break
                    end
                end

                if ~isListed
                    uniqueGroups{end + 1} = currentGroup; %#ok<AGROW>
                end
            end

        end % uniqueEMUGroups

    end % methods (Static)

    methods (Static, Access = private)

        function position = substrateEMUPosition(pattern)

            if isempty(pattern)
                position = [];
                return
            end

            position = bin2dec(num2str(pattern, "%d"));

        end % substrateEMUPosition

    end % methods (Static, Access = private)

end % classdef
