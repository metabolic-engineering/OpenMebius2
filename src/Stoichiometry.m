classdef Stoichiometry < IOModel

    properties (Access = protected)

        % Stoichiometry matrix
        SBefore table;
        % Stoiciometry matrix and independent fluxes
        S table;
        % Metabolite type
        Stype cell;

        % Table
        tableModelRev table;
        modelRxnRev table;
        modelTransRev table;
        idxRev double;

        % Error flag
        modelErrorRxnRev logical = [];

    end

    methods (Access = public)

        function obj = Stoichiometry(fileDirectory)

            obj = obj@IOModel(fileDirectory);

            if obj.isError
                return;
            end

            obj.separateReversibleReaction();
            obj.generateReversivleReactionInfo();

            obj.generateS();
            obj.generateSAll();

            obj.validateS();

        end

        function tableModelRev = getModelTableRev(obj)

            tableModelRev = obj.tableModelRev;

        end % getModelTableRev

        function modelRxnRev = getModelRxnRev(obj, idx)

            if nargin == 2
                modelRxnRev = obj.modelRxnRev(idx, :);
                return;
            end

            modelRxnRev = obj.modelRxnRev;

        end % getModelRxnRev

        function idx = getModelRxnRevIdx(obj, rxnID)

            idx = obj.findRxnIdx(rxnID);

        end % getModelRxnRevIdx

        function modelTransRev = getModelTransRev(obj, idx)

            if nargin == 2
                modelTransRev = obj.modelTransRev(idx, :);
                return;
            end

            modelTransRev = obj.modelTransRev;

        end % getModelTransRev

        function S = getS(obj)
            S = obj.S;
        end % getS

        function SBefore = getSBefore(obj)
            SBefore = obj.SBefore;
        end % getSBefore

        function Stype = getSType(obj)
            Stype = obj.Stype;
        end % getStype

        function idx = getIdxRev(obj)
            idx = obj.idxRev;
        end % getIdxRev

        function dof = getDOF(obj)
            % getDOF Get the degree of freedom
            %
            % dof = getDOF(obj)
            %
            % Returns
            % -------
            % dof: double (1x1)
            %     Degree of freedom
            %
            % Example
            % -------
            % dof = getDOF(obj) -> 5

            tmpS = obj.SBefore;
            dof = size(tmpS, 2) - size(tmpS, 1);

        end % getDOF

        function metabolite = getSubstrateNameFromRxnID(obj, RxnID)
            % FINDMETABOLITEFROMMODELTABLE Return the index of
            % the metabolite in the model table
            %
            % Parameters
            % ----------
            % obj IOModel
            %     The IOModel object
            % metabolite (1, 1) string
            %     The name of the metabolite
            %
            % Returns
            % -------
            % metabolite (1, 1) string
            %     The name of the metabolite
            %
            % Example
            % --------
            % >> metabolite = findMetaboliteFromModelTable(obj, "r1");
            %    metabolite = "Subs_Glc";
            %
            % >> metabolite = findMetaboliteFromModelTable(obj, "r29");
            %    metabolite = "Subs_Ace";

            arguments
                obj;
                RxnID (1, 1) string;
            end

            % Get reaction row from the model table
            rxnTable = obj.modelRxnRev;

            if ~any(ismember(RxnID, rxnTable.Properties.RowNames))
                metabolite = string().empty;
                return;
            end

            react = string(rxnTable{RxnID, "Reactants"});
            product = string(rxnTable{RxnID, "Products"});

            substrateTable = getSubstrateTable(obj);
            substrate = string(substrateTable.Metabolite);
            maskReact = ismember(substrate, react);
            maskProduct = ismember(substrate, product);
            metabolite = substrate(maskReact | maskProduct);

        end % findMetaboliteFromModelTable

        function idx = findCounterReaction(obj, rxnID)

            % FINDCOUNTERREACTION Find the index of the counter reaction
            %
            % idx = findCounterReaction(obj, rxnID)
            %
            % Parameters
            % ----------
            % rxnID: str (1x1)
            %     Reaction ID (e.g. 'r1')
            %
            % Returns
            % -------
            % idx: double (1x1)
            %     Index of the counter reaction
            %     If the reaction is not found, idx is NaN
            % Example
            % -------
            % findCounterReaction(obj, 'r1') -> 2
            % findCounterReaction(obj, 'r2') -> 1
            % findCounterReaction(obj, 'r3') -> NaN

            idxID = findRxnIdx(obj, rxnID);

            idx = nan;

            if isempty(idxID)
                return;
            end

            idxRevMatrix = obj.idxRev;
            numRow = size(idxRevMatrix, 1);
            posIdx = find(idxRevMatrix == idxID, 1);

            if isempty(posIdx)
                return;
            end

            if posIdx <= numRow
                idx = idxRevMatrix(posIdx + numRow);
            else
                idx = idxRevMatrix(posIdx - numRow);
            end

        end % findCounterReaction

        function idx = findReaction(obj, compound, isProductOnly)
            % FINDREACTION Find the index of reactions involving the specified compound
            %
            % idx = findReaction(obj, compound, isProductOnly)
            %
            % Parameters
            % ----------
            % compound: str (1x1)
            %     Compound name (e.g. "Pyr")
            % isProductOnly: logical (1x1)
            %     If true, only search in products
            %
            % Returns
            % -------
            % idx: double (nx1)
            %     Indices of reactions involving the specified compound
            %

            arguments
                obj;
                compound string;
                isProductOnly logical = false;
            end

            rxnTable = obj.modelRxnRev;
            numRxn = height(rxnTable);
            idxList = [];

            for i = 1:numRxn

                reactants = rxnTable.Reactants{i};
                products = rxnTable.Products{i};

                if isProductOnly

                    if ismember(compound, products)
                        idxList = [idxList; i]; %#ok<AGROW>
                    end

                else

                    if ismember(compound, reactants) || ismember(compound, products)
                        idxList = [idxList; i]; %#ok<AGROW>
                    end

                end % if

            end % for

            idx = idxList;

        end % method findReaction

        function tf = isSubstrateMetabolite(obj, compound)
            % ISSUBSTRATE Check if a compound is a substrate
            %
            % isSubstrate(obj, compound)
            %
            % Parameters
            % ----------
            % compound: str (1x1)
            %     Compound name (e.g. "Subs_Glc")
            %

            tableMetabolite = obj.modelMetabolite;
            metabolite = tableMetabolite.Metabolite( ...
                ismember(tableMetabolite.Type, "substrate"));

            if ismember(compound, metabolite)
                tf = true;
            else
                tf = false;
            end

        end % isSubstrate

    end % methods (Access = public)

    methods (Access = protected)

        function idx = findRxnIdx(obj, rxnID)
            % FINDRXNIDX Find the index of a reaction
            %
            % idx = findRxnIdx(obj, rxnID)
            %
            % Parameters
            % ----------
            % rxnID: str (1x1)
            %     Reaction ID (e.g. 'r1')
            %
            % Returns
            % -------
            % idx: double (1x1)
            %     Index of the reaction
            %     If the reaction is not found, idx is NaN

            rxnIDs = obj.modelRxnRev.Properties.RowNames;
            idx = find(strcmp(rxnIDs, rxnID));

        end % findRxnIdx

    end % methods (Access = protected)

    methods (Access = private)

        function separateReversibleReaction(obj)

            rxn = obj.modelRxn;
            tsn = obj.modelTrans;

            % Separate reversible reactions into two irreversible reactions

            numRev = sum(rxn.Reversible);
            idx = find(rxn.Reversible);
            idxRevRev = idx + (1:numRev)';
            idxRevFwd = idxRevRev - 1;

            for i = 1:numRev

                rw = rxn(idxRevFwd(i), :);
                rxn = insert(obj, rxn, rw, idxRevRev(i));

                rw = tsn(idxRevFwd(i), :);
                tsn = insert(obj, tsn, rw, idxRevRev(i));

            end

            for i = 1:numRev

                tmpRxnRev = rxn.Reactants(idxRevRev(i));
                tmpTsnRev = tsn.Reactants(idxRevRev(i));

                rxn.Reactants(idxRevRev(i)) = rxn.Products(idxRevRev(i));
                rxn.Products(idxRevRev(i)) = tmpRxnRev;
                tsn.Reactants(idxRevRev(i)) = tsn.Products(idxRevRev(i));
                tsn.Products(idxRevRev(i)) = tmpTsnRev;

            end

            obj.modelRxnRev = rxn;
            obj.modelTransRev = tsn;
            obj.idxRev = [idxRevFwd, idxRevRev];

        end % separateReversibleReaction

        function generateReversivleReactionInfo(obj)
            % GENERATEREVERSIVLEREACTIONINFO Generate reversible reaction information
            % such as tableModelRev, and tableMSRev.
            %
            % generateReversivleReactionInfo(obj)

            tableModel = obj.getModelTable();
            modelRxn = obj.modelRxn;
            rxnIDRev = obj.modelRxnRev.Properties.RowNames;

            tableModelRev = table( ...
                'Size', [0, width(tableModel)], ...
                'VariableNames', tableModel.Properties.VariableNames, ...
                'VariableTypes', tableModel.Properties.VariableTypes); %#ok<PROP>

            isReversible = modelRxn.Reversible;

            for iRxn = 1:size(modelRxn, 1)

                tableModelRev = ...
                    [tableModelRev; tableModel(iRxn, :)]; %#ok<PROP,AGROW>

                if isReversible(iRxn)

                    rw = tableModel(iRxn, :);

                    rxn = rw.Reaction{:};
                    tsn = rw.Transition{:};
                    % まずは空白でsplit
                    partsRxn = strsplit(rxn, ' ');
                    partsTsn = strsplit(tsn, ' ');
                    % <=>の位置を特定
                    idxArrow = find(strcmp(partsRxn, '<=>'));
                    % 反転
                    partsRxnRev = [partsRxn(idxArrow + 1:end), {'<=>'}, partsRxn(1:idxArrow - 1)];
                    partsTsnRev = [partsTsn(idxArrow + 1:end), {'<=>'}, partsTsn(1:idxArrow - 1)];
                    rxnRev = strjoin(partsRxnRev, ' ');
                    tsnRev = strjoin(partsTsnRev, ' ');
                    rw.Reaction = {rxnRev};
                    rw.Transition = {tsnRev};

                    % Rename row temporarily to avoid duplicate row names
                    rw.Properties.RowNames{1} = append(rw.Properties.RowNames{1}, '_rev_tmp');

                    tableModelRev = ...
                        [tableModelRev; rw]; %#ok<PROP,AGROW>

                end % if

            end % for iRxn

            tableModelRev.Properties.RowNames = rxnIDRev; %#ok<PROP>
            obj.tableModelRev = tableModelRev; %#ok<PROP>

        end % generateReversivleReactionInfo

        function [tableInserted] = insert(~, tbl, rw, idx)

            rn = tbl.Properties.RowNames;
            rw.Properties.RowNames = append(rn(idx - 1), '_rev');
            tableInserted = [tbl(1:idx - 1, :); rw; tbl(idx:end, :)];

        end % insert

        function generateS(obj)

            rxnID = obj.modelRxnRev.Properties.RowNames;
            rxnID = vertcat(rxnID, 'biomass');
            rxnID = transpose(rxnID);
            numRxn = length(rxnID);
            metList = obj.modelMetabolite.Metabolite(ismember(obj.modelMetabolite.Type, "metabolite"));

            % Metabolic network matrix
            [tmpS, numMet] = metaboliteMatrix(obj, 'metabolite');

            StypeTmp = cell(numMet, 1);

            for i = 1:numMet
                StypeTmp{i} = 'metabolite';
            end

            % Add biomass column
            biomassRow = obj.biomassRow();
            tmpS(:, end) = biomassRow;

            % Add biomass row
            tmpS = [tmpS; zeros(1, numRxn)];
            metList = [metList; 'biomass'];
            StypeTmp{numMet + 1} = 'biomass';
            tmpS(end, end) = 1;

            obj.SBefore = array2table(tmpS, 'VariableNames', rxnID, 'RowNames', metList);
            obj.Stype = StypeTmp;

            % Add efflux reactions
            efflux = findEffluxRxn(obj);
            effluxDependent = removeIndependentRxn(obj, efflux);
            numEfflux = length(effluxDependent);
            StypeEfflux = repmat({'efflux'}, numEfflux, 1);

            % Add efflux reactions to the metabolic network matrix
            SEfflux = reactionMatrix(obj, effluxDependent);
            tmpSEffluxAdded = [tmpS; SEfflux];
            StypeEffluxAdded = [StypeTmp; StypeEfflux];
            metListEffluxAdded = [metList; effluxDependent];

            obj.SBefore = array2table(tmpSEffluxAdded, 'VariableNames', rxnID, 'RowNames', metListEffluxAdded);
            obj.Stype = StypeEffluxAdded;

            n = size(obj.SBefore, 1);
            r = size(obj.SBefore, 2);
            msg = "Stoichiometry matrix was successfully generated (" + n + " x " + r + ").";
            updateMsg(obj, msg, "Info", obj.logLevel);

        end % generateS

        function generateSAll(obj)
            % GENERATESALL Generate stoichiometry matrix and independent reaction matrix
            %
            % generateSAll(obj)
            %
            % Note
            % ----
            % This method generates the stoichiometry matrix and the list of efflux reactions.
            % The method generateS must be called before calling this method.
            %
            % see also: generateS

            independentRxn = findIndependentRxn(obj);
            matrixIndependent = reactionMatrix(obj, independentRxn);

            variableNames = obj.SBefore.Properties.VariableNames;
            SIndependent = array2table( ...
                matrixIndependent, ...
                'VariableNames', variableNames, ...
                'RowNames', independentRxn);

            numSIndependent = height(SIndependent);

            SIndependentType = repmat({'independent'}, numSIndependent, 1);
            obj.Stype = [obj.Stype; SIndependentType];

            obj.S = [obj.SBefore; SIndependent];

        end % generateSAll

        function [independentRxn] = findIndependentRxn(obj)
            % FINDINDEPENDENTRXN Find independent reactions
            %
            % independentRxn = findIndependentRxn(obj)
            %
            % Returns
            % -------
            % independentRxn: cell (nx1)
            %     List of independent reactions
            %
            % Note
            % ----
            % Before calling this method, the method generateS must be called.
            % The method generateS generates the stoichiometry matrix and
            % the list of efflux reactions.
            %
            % see also: generateS

            rxnTable = obj.SBefore;
            matrix = rxnTable{:, :};

            % --- 追加: 不可逆反応を優先的に独立変数として選択するための並べ替え ---

            % 反応列に対応するインデックス（modelRxnRev に対応）
            numRxn = height(obj.modelRxnRev);
            idxRxnCols = 1:numRxn;
            idxOtherCols = (numRxn + 1):size(matrix, 2); % biomass など

            % 可逆反応に対応する列インデックス
            idxRevAll = unique(obj.idxRev(:));
            idxRevAll = idxRevAll(~isnan(idxRevAll));
            idxRevAll = intersect(idxRevAll, idxRxnCols, 'stable');

            % 不可逆反応に対応する列インデックス
            idxIrrev = setdiff(idxRxnCols, idxRevAll, 'stable');

            % RREF での pivot 選択時に「可逆 → 不可逆」の順に見せる
            % → pivot はできるだけ可逆反応から選ばれ，
            %    残り（非 pivot）として不可逆反応が独立変数として残りやすくなる
            colOrder = [idxRevAll', idxIrrev, idxOtherCols];

            matrixReordered = matrix(:, colOrder);
            [~, pivotColumnsReordered] = rref(matrixReordered);

            % 元の列インデックスに戻す
            pivotColumns = colOrder(pivotColumnsReordered);

            % ここからは元のロジックと同じ（pivot 列以外を独立反応とみなす）
            maskDependent = ismember(1:size(matrix, 2), pivotColumns);
            maskIndependent = ~maskDependent;
            independentRxn = rxnTable.Properties.VariableNames(maskIndependent);

            msg = "Independent reaction matrix was successfully generated (" + length(independentRxn) + " reactions).";
            updateMsg(obj, msg, "Info", obj.logLevel);

        end % findIndependentRxn

        function efflux = findEffluxRxn(obj)
            % FINDEFFLUXRXN Find efflux reactions
            %
            % efflux = findEffluxRxn(obj)
            %
            % Returns
            % -------
            % efflux: cell (nx1)
            %     List of efflux reactions
            %
            % see also: isEfflux

            rxn = obj.modelRxnRev;
            numRxn = height(rxn);
            isListed = false(numRxn, 1);
            efflux = cell(numRxn, 1);

            for i = 1:numRxn

                if isListed(i)
                    continue;
                end

                reactants = rxn.Reactants{i};
                products = rxn.Products{i};

                if isEfflux(obj, reactants) || isEfflux(obj, products)

                    isListed(i) = true;
                    rxnID = rxn.Properties.RowNames{i};

                    efflux{i} = rxnID;

                end % if

            end % for

            efflux = efflux(~cellfun('isempty', efflux));

        end % findEffluxRxn

        function isEfflux = isEfflux(obj, compounds)
            % ISEFFLUX Check if a reaction is an efflux reaction
            %
            % isEfflux = isEfflux(obj, compounds)
            %
            % Parameters
            % ----------
            % compounds: cell (nx1)
            %     List of compounds
            %     ex: {'Subs_Glc', 'G6P'}
            %     ex: {'G6P', 'F6P', FBP'}
            %
            % Returns
            % -------
            % isEfflux: logical (1x1)
            %     True if the reaction is an efflux reaction
            %
            % Example
            % -------
            % isEfflux(obj, {'Subs_Glc', 'G6P'}) -> true
            % isEfflux(obj, {'G6P', 'F6P', FBP'}) -> false
            %

            numCompounds = length(compounds);
            tableMetabolite = obj.modelMetabolite;
            metabolite = tableMetabolite.Metabolite(ismember(tableMetabolite.Type, "substrate"));
            isEfflux = false;

            for i = 1:numCompounds

                compound = compounds{i};

                if ismember(compound, metabolite)

                    isEfflux = true;
                    break;

                end % if

            end % for

        end % isEfflux

        function [rtn, idxRev] = isReversible(obj, rxnID)
            % ISREVERSIBLE Check if a reaction is reversible or not
            %
            % [rtn, idxRev] = isReversible(obj, rxnID)
            %
            % Parameters
            % ----------
            % rxnID: str (1x1)
            %     Reaction ID (e.g. 'r1')
            %
            % Returns
            % -------
            % rtn: logical (1x1)
            %     True if the reaction is reversible
            % idxRev: double (1x1)
            %     Index of the counterpart reaction
            %     If the reaction is irreversible, idxRev is NaN
            %     ex: 1, r1: A --> B
            %         2, r2f: B --> C
            %         3, r2r: C --> B
            %         4, r3: C --> D
            %         isReversible(obj, 'r1') -> false, NaN
            %         isReversible(obj, 'r2f') -> true, 3
            %         isReversible(obj, 'r2r') -> true, 2
            %         isReversible(obj, 'r3') -> false, NaN
            %
            % see also: findRxnIdx

            idx = findRxnIdx(obj, rxnID);
            idxRev = nan;
            idxRevList = obj.idxRev;
            rtn = false;

            if ismember(idx, idxRevList)

                rtn = true;

                if isempty(find(idxRevList(:, 1) == idx, 1))

                    idxIdxRevListRow = find(idxRevList(:, 2) == idx, 1);
                    idxRev = idxRevList(idxIdxRevListRow, 1);

                else

                    idxIdxRevListRow = find(idxRevList(:, 1) == idx, 1);
                    idxRev = idxRevList(idxIdxRevListRow, 2);

                end % if

            end

        end % isReversible

        function [rxnIDs] = removeIndependentRxn(obj, rxnIDsIn)
            % REMOVEINDEPENDENTRXN Remove independent reactions from the provided list
            %
            % rxnIDs = removeIndependentRxn(obj, rxnIDsIn)
            %
            % Parameters
            % ----------
            % rxnIDsIn: cell (nx1)
            %     List of reaction IDs
            %
            % Returns
            % -------
            % rxnIDs: cell (mx1)
            %     List of reaction IDs without independent reactions
            %

            arguments
                obj;
                rxnIDsIn cell;
            end

            extractedTable = obj.modelRxnRev(rxnIDsIn, :);

            if isempty(extractedTable)
                rxnIDs = cell(0, 1);
                return;
            end

            mask = extractedTable.Independent;
            rxnIDs = rxnIDsIn(~mask);

        end % removeIndependentRxn

        function newList = updateIsListed(~, oldList, isRev, idxRev)
            % UPDATEISLISTED Update isListed in the findEffluxRxn method
            %
            % updateIsListed(obj, isRev, idxRev)
            %
            % Parameters
            % ----------
            % isRev: logical (1x1)
            %     True if the reaction is reversible
            % idxRev: double (1x1)
            %     Index of the counterpart reaction
            %     If the reaction is irreversible, idxRev is NaN
            %
            % Returns
            % -------
            % newList: logical (nx1)
            %     Updated isListed
            %
            % see also: findEffluxRxn

            newList = oldList;

            if isRev

                newList = oldList;
                newList(idxRev) = true;

            end % if

        end % updateIsListed

        function idx = findRxnColumnIdx(obj, rxnID)

            variableeNames = obj.SBefore.Properties.VariableNames;

            idx = find(strcmp(variableeNames, rxnID));

        end % findRxnColumnIdx

        function [isSubs] = isSubstrate(~, reactant, product)

            % Check if a reactant or product is a substrate
            isSubs = false;

            % Regular expression to determine if it starts with Subs_
            pattern = 'Subs_';
            numChar = length(pattern);

            reactant = reactant{:};
            product = product{:};

            sumSubsReactant = sum(strncmp(pattern, reactant, numChar), "all");
            sumSubsProduct = sum(strncmp(pattern, product, numChar), "all");
            sumSubs = sumSubsReactant + sumSubsProduct;

            if sumSubs > 0
                isSubs = true;
            end

        end % isSubstrate

        function [S] = reactionMatrix(obj, RxnIDs)
            % REACTIONMATRIX Generate a reaction matrix with the provided reaction IDs
            %
            % S = reactionMatrix(obj, RxnIDs)
            %
            % Parameters
            % ----------
            % RxnIDs: cell (mx1)
            %     List of reaction IDs
            %
            % Returns
            % -------
            % S: double (mxn)
            %     Reaction matrix with the provided reaction IDs
            %
            % Example
            % -------
            % S = reactionMatrix(obj, {'r1', 'r2', 'r3'})
            % >> S
            %     r1 r2 r3 r4 ... rn
            % r1  1  0  0  0 ...  0
            % r2  0  1  0  0 ...  0
            % r3  0  0  1  0 ...  0
            %
            % S = reactionMatrix(obj, {'r1', 'r4'})
            % >> S
            %     r1 r2 r3 r4 ... rn
            % r1  1  0  0  0 ...  0
            % r4  0  0  0  1 ...  0

            arguments
                obj;
                RxnIDs cell;
            end

            m = length(RxnIDs);
            n = size(obj.SBefore, 2);
            S = zeros(m, n);
            variableNames = obj.SBefore.Properties.VariableNames;

            for i = 1:m

                iRxnID = RxnIDs{i};
                mask = strcmp(variableNames, iRxnID);
                S(i, mask) = 1;

            end

        end % reactionMatrix

        function [S, numMet] = metaboliteMatrix(obj, type)

            metabolite = obj.modelMetabolite;
            metabolite = metabolite(strcmp(metabolite.Type, type), :);
            numMet = size(metabolite, 1);

            S = zeros(height(metabolite), height(obj.modelRxnRev) + 1);

            for iMet = 1:numMet

                % Count forward metabolites
                tmp = countMetabolite(obj, metabolite{iMet, 1}, obj.modelRxnRev.Reactants);
                S(iMet, :) = S(iMet, :) - tmp;

                % Count reverse metabolites
                tmp = countMetabolite(obj, metabolite{iMet, 1}, obj.modelRxnRev.Products);
                S(iMet, :) = S(iMet, :) + tmp;

            end

        end % metaboliteMatrix

        function met = countMetabolite(~, metabolite, reactionList)

            numRxn = size(reactionList, 1);
            % Add biomas column
            met = zeros(1, numRxn + 1);

            for iRxn = 1:numRxn

                tmp = reactionList{iRxn};
                met(iRxn) = sum(strcmp(metabolite(1), tmp), "all");

            end

        end % countMetabolite

        function rw = biomassRow(obj)

            precursor = obj.tableBiomass.Precursor;
            coeeficient = obj.tableBiomass.Biomass;
            metabolite = obj.modelMetabolite.Metabolite(ismember(obj.modelMetabolite.Type, "metabolite"));

            % metabolite(i) == precursor(j)のとき、rw(i) = -coefficient(j)
            idxMetabolite = [];

            for i = 1:length(precursor)
                idxTmp = find(strcmp(metabolite, precursor{i}));
                idxMetabolite = [idxMetabolite; idxTmp]; %#ok<AGROW>
            end

            rw = zeros(1, height(metabolite));

            rw(idxMetabolite) = -coeeficient;

        end % biomassRow

        function tf = validateS(obj)
            % VALIDATES Validate the stoichiometry matrix
            %
            % tf = validateS(obj)
            %
            % Returns
            % -------
            % tf: logical (1x1)
            %     True if the stoichiometry matrix is valid
            %

            SMatrix = obj.S{:, :};
            [n, r] = size(SMatrix);
            tf = true;

            if n ~= r
                tf = false;
            end

            if ~tf
                msg = "Stoichiometry matrix is invalid.";
                updateMsg(obj, msg, "Error", obj.logLevel);
            end

        end % validateS

    end % methods (Access = private)

end % classdef
