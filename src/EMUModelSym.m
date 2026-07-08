classdef EMUModelSym < Stoichiometry

    properties (Access = public)

        % EMU list
        tableEMU = table();
        % tableEMU: table (n x 5)
        % Parameters
        % ----------
        % EMU: string
        %    EMU name
        %    Format:
        %        Metabolite_{Position}
        %    - If the metabolite has underscores, the underscores are replaced by
        %      a hyphen.
        % Metabolite: string
        %    Metabolite name of the EMU
        % Position: array
        %    Position of the atoms in the metabolite
        % Size: double
        %    EMU size
        % Target: bool
        %    True if the EMU is a target EMU
        %
        % | EMU        | Metabolite | Position | Size | Target |
        % |------------|------------|----------|------|--------|
        % |  Pyr_{AB}  | Pyr        | [1 2]    |    2 |      0 |
        % |  Pyr_{AC}  | Pyr        | [1 3]    |    2 |      0 |
        % |  Pyr_{BC}  | Pyr        | [2 3]    |    2 |      0 |
        % |  Pyr_{ABC} | Pyr        | [1 2 3]  |    3 |      0 |

        % EMU reaction table
        tableEMUReaction = table();
        % tableEMUReaction: table (n x 4)
        % Parameters
        % ----------
        % RxnID: string
        %    Reaction ID
        % Reactants: cell
        %    Reactant EMUs
        % Products: cell
        %    Product EMUs
        % Coefficient: double
        %    Stoichiometric coefficient
        % Size: double
        %    EMU reaction seze
        %
        % | RxnID | Reactants       | Products   | Coefficient | Size | Target |
        % |-------|-----------------|------------|-------------|------|--------|
        % | r1    | {A_{ABC}}       | {B_{ABC}}  |           1 |    3 |      0 |
        % | r2    | {B_{ABC}}       | {C_{A}}    |           1 |    1 |      0 |
        % | r2    | {B_{BC}}        | {D_{BC}}   |           1 |    2 |      0 |
        % | r3    | {B_{A}, D_{BC}} | {E_{ABC}}  |           1 |    3 |      0 |

        % Flag for include all metabolites to EMU
        includeAllMetabolite = false;

        % Matrix X of EMU
        matrixX = {};
        matrixY = {};
        matrixA = {};
        matrixB = {};
        substrateEMUsym = [];
        MDVsym = sym([]);
        % Substrate EMU
        structSubstrateEMU = struct();

    end % properties (Access = public)

    properties (Access = private)

        % Basic char list
        charList = ['A':'Z' 'a':'z'];

        % Symbolic variable
        fluxSym = [];
        convertXToMDV;
        Xn;

        matrixXsym = {};
        matrixYsym = {};
        calculateAn;
        calculateBn;
        calculateYn;

    end % properties (Access = private)

    properties (Dependent)

        % EMU
        EMUSizeMax double;

        % Viewer
        targetMetaboliteList;

        % # of X rows
        totalX double;
        totalY double;

    end % properties (Dependent)

    methods

        function EMUSizeMax = get.EMUSizeMax(obj)
            % GET.EMUSIZEMAX Get maximum EMU size
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % EMUSizeMax: double
            %    Maximum EMU size

            NoTargetEMU = obj.tableEMU(obj.tableEMU.Target == false, :);
            EMUSizeMax = max(NoTargetEMU.Size);

        end % get.EMUSizeMax

        function targetMetaboliteList = get.targetMetaboliteList(obj)
            % GET.TARGETMETABOLITELIST Get target metabolite list
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % targetMetaboliteList: (n x 1) string
            %    Target metabolite list

            metabolite = obj.tableEMU.EMU;
            target = obj.tableEMU.Target;
            targetMetabolite = metabolite(target);
            targetMetaboliteSorted = sort(targetMetabolite);
            % Convert to string
            targetMetaboliteList = string(targetMetaboliteSorted);

            % targetMetaboliteListがproductとなるEMURxnのRxnIDを取得
            rxns = obj.tableEMUReaction;
            targetMetaboliteList = rxns.RxnID(ismember(string(rxns.Products), targetMetaboliteList));
            targetMetaboliteList = sort(unique(targetMetaboliteList));

        end % get.targetMetaboliteList

        function totalX = get.totalX(obj)
            % GET.TOTALX Get total number of X rows
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % totalX: double
            %    Total number of X rows

            totalXEachSize = cellfun(@(x) size(x, 1), obj.matrixX);
            totalX = sum(totalXEachSize);

        end % get.totalX

        function totalY = get.totalY(obj)
            % GET.TOTALY Get total number of Y rows
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % totalY: double
            %    Total number of Y rows

            totalYEachSize = cellfun(@(x) size(x, 1), obj.matrixY);
            totalY = sum(totalYEachSize);

        end % get.totalY

    end % methods

    methods (Access = public)

        function obj = EMUModelSym(modelInput)
            % EMUMODEL Constructor
            %
            % Parameters
            % ----------
            % modelInput
            %    File directory or openmebius.domain.model.ModelLocation.
            %
            % Returns
            % -------
            % obj: EMUModel
            %    EMUModel object

            obj = obj@Stoichiometry(modelInput);

            if obj.isError
                return;
            end

            if ~obj.isUpdatedModel
                % Load model from file
                isSucceeded = loadModelFromFile(obj);

                if isSucceeded
                    return;
                end

            end

            % Initialize EMU table
            initializeEMUTable(obj);
            resetHashFile(obj);

            if obj.isError
                return;
            end

        end % constructor

        %% Public getters methods
        function tableEMUReaction = getEMURxnTable(obj)
            % GETEMURXNTABLE Get EMU reaction table
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % tableEMUReaction: table
            %    EMU reaction table

            tableEMUReaction = obj.tableEMUReaction;

        end % getEMURxnTable

        function list = getTargetMetaboliteList(obj)
            % GETTARGETMETABOLITELIST Get target metabolite list
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % list: (n x 1) string
            %    Target metabolite list
            %
            % Example
            % -------
            % >> getTargetMetaboliteList(obj);
            % ["Ala159"; "Ala57"; "Ala85"; "Asx159"]

            list = obj.targetMetaboliteList;

        end % getTargetMetaboliteList

        function structEMU = getLabelStructEMU(obj)
            % GETLABELSTRUCTEMU Get label structure
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % structEMU: struct
            %    Label structure

            structEMU = obj.structSubstrateEMU;

        end % getLabelStructEMU

        %% Public utility methods
        function constructEMUNetwork(obj)
            % CONSTRUCTEMUNETWORK Construct EMU network
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            % Construct EMU network
            trackAllEMU(obj);

            if obj.isError
                return;
            end

            obj.fluxSym = defineFluxSym(obj);

            defineMatrixX(obj);

            if obj.isError
                return;
            end

            defineMatrixY(obj);

            if obj.isError
                return;
            end

            defineMatrixA(obj);

            if obj.isError
                return;
            end

            obj.calculateAn = defineCalculateAn(obj);

            if obj.isError
                return;
            end

            obj.calculateBn = defineCalculateBn(obj);

            if obj.isError
                return;
            end

            % Generate substrate EMUs
            LabelStructEMUAdded = addSubstrateEMU(obj);

            if obj.isError
                return;
            end

            updateStructLabel(obj, LabelStructEMUAdded);

            if obj.isError
                return;
            end

            obj.substrateEMUsym = defineSubstrateEMUSym(obj);

            if obj.isError
                return;
            end

            obj.calculateYn = defineCalculateYn(obj);

            if obj.isError
                return;
            end

            obj.MDVsym = createCalculateMDV(obj);

            if obj.isError
                return;
            end

            msg = "EMU network was successfully constructed.";
            updateMsg(obj, msg, "Info", obj.logLevel);

            substrateEMUsAll(obj);

            saveModelToFile(obj);

        end % constructEMUNetwork

        function tf = loadModelFromFile(obj)
            % LOADMODELFROMFILE Load model from file
            %
            % The cache location is resolved by IOModel.pathCache.

            filepath = obj.pathCache;

            try
                load(filepath, "matrixX", "matrixXsym", "matrixY", "matrixYsym", "matrixA", "matrixB", ...
                    "calculateAn", "calculateBn", "calculateYn", "convertXToMDV", "Xn", "totalX", ...
                    "targetMetaboliteList", "tableEMU", "tableEMUReaction", "substrateEMUsym");

                obj.matrixX = matrixX;
                obj.matrixXsym = matrixXsym;
                obj.matrixY = matrixY;
                obj.matrixYsym = matrixYsym;
                obj.matrixA = matrixA;
                obj.matrixB = matrixB;
                obj.calculateAn = calculateAn;
                obj.calculateBn = calculateBn;
                obj.calculateYn = calculateYn;
                obj.convertXToMDV = convertXToMDV;
                obj.Xn = Xn;
                obj.tableEMU = tableEMU;
                obj.tableEMUReaction = tableEMUReaction;
                obj.substrateEMUsym = substrateEMUsym;

                msg = "Model was successfully loaded from the file.";
                updateMsg(obj, msg, "Info", obj.logLevel);
                tf = true;
            catch
                msg = "Model could not be loaded from the file.";
                updateMsg(obj, msg, "Error", obj.logLevel);
                tf = false;
            end

        end % loadModelFromFile

        %% Public substrate EMU methods
        function structEMU = addSubstrateEMU(obj)

            label = getLabelStruct(obj);

            labelPattern = fields(label);

            for iLabel = 1:length(labelPattern)

                iLabelStruct = label.(labelPattern{iLabel});
                iRatio = iLabelStruct.ratio;
                iLabelPattern = iLabelStruct.label;
                iEMU = substrateEMUs(obj, iLabelPattern, iRatio);
                label.(labelPattern{iLabel}).EMU = iEMU;

            end % for iLabel

            structEMU = label;

        end

        function substrateEMUsAll(obj)

            tableTracer = obj.getTableLavelView();
            structTracer = obj.getLabelStructView();
            fieldName = fieldnames(structTracer);
            maximumCNumber = max(cell2mat(tableTracer.Num));

            msg = "Constructing substrate EMUs...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            for i = 1:size(tableTracer, 1)

                iTracer = structTracer.(fieldName{i});
                iTracerLabel = iTracer.Label;
                iTracerRatio = iTracer.Ratio;

                iEMU = substrateEMUs( ...
                    obj, iTracerLabel, iTracerRatio, numAtom = maximumCNumber);

                obj.structSubstrateEMU.(fieldName{i}) = iEMU;

            end % for i

        end % substrateEMUsAll

        function EMU = substrateEMUs(obj, pattern, ratio, options)
            % SUBSTRATEEMUS Create substrate EMUs for multiple label patterns
            %
            % EMU = substrateEMUs(obj, pattern, ratio)
            %
            % Parameters
            % ----------
            % pattern: (n x 1) cell
            %   Label patterns
            %   ex: {'#010010', '#001001'}
            % ratio: (n x 1) double
            %   Label ratio
            %   ex: [0.5, 0.5]
            %
            % Returns
            % -------
            % EMU: (2^numCarbon - 1 x 1) cell
            %   Substrate EMUs of following format

            arguments
                obj;
                pattern (:, 1) cell
                ratio (:, 1) double {mustBeNonnegative, mustBeLessThanOrEqual(ratio, 1)};
                options.numAtom = 0;
            end

            numPattern = length(pattern);

            for iPattern = 1:numPattern

                EMUTemp = substrateEMU(obj, pattern{iPattern}, numAtom = options.numAtom);
                EMURatio = EMUTemp * ratio(iPattern);

                if iPattern == 1
                    EMU = EMURatio;
                else
                    EMU = EMURatio + EMU;
                end % if

            end % for iPattern

        end % substrateEMUs

        function EMU = substrateEMU(obj, pattern, options)
            % SUBSTRATEEMU Create substrate EMU for one label pattern
            %
            % EMU = substrateEMU(obj, pattern)
            %
            % Parameters
            % ----------
            % pattern: string
            %    Label pattern
            %    ex: '#010010'
            %
            % Returns
            % -------
            % EMU: (2^numCarbon - 1 x 1) cell
            %    Substrate EMUs of following format
            %    ex:
            %    {[0 1], [1 0], [0 0 1], [1 0 0], [0 1 0], [0 0 0 1], [0 0 1 0], [0 0 0 0 1] ... }

            arguments
                obj;
                pattern string;
                options.numAtom = 0;
            end

            regex = '^#[0-1]*$';

            if isempty(regexp(pattern, regex, 'once'))
                msg = "Label pattern must be in the format of '#dddddd'.";
                updateMsg(obj, msg, "Error", obj.logLevel);
                EMU = [];
                return
            end

            % convert "#010000" --> [0 1 0 0 0 0]
            pattern = char(pattern);
            labeledAtom = pattern == '1';
            labeledAtom = labeledAtom(2:end);

            numCarbon = length(labeledAtom);

            maskAll = dec2bin(0:2 ^ numCarbon - 1, numCarbon) - '0';
            maskAll = logical(maskAll(2:end, :));

            if options.numAtom > 0
                EMU = nan(size(maskAll, 1), options.numAtom + 1);
            else
                EMU = nan(size(maskAll, 1), numCarbon + 1);
            end

            % Define single EMU vector
            nonlabel = [1, 0];
            label = [0, 1];

            for iPattern = 1:size(maskAll, 1)

                iMask = maskAll(iPattern, :);

                iLabeledAtom = labeledAtom(iMask);

                if iLabeledAtom(1)
                    iEMU = label;
                else
                    iEMU = nonlabel;
                end

                for i = 2:length(iLabeledAtom)

                    if iLabeledAtom(i)
                        iEMU = conv(iEMU, label);
                    else
                        iEMU = conv(iEMU, nonlabel);
                    end % if

                end % for i

                numAtom = length(iEMU);
                EMU(iPattern, 1:numAtom) = iEMU;

            end % for iPattern

        end % substrateEMU

        %% Public calculate methods
        function includeAllMetaboliteToEMU(obj, tf)
            % INCLUDEALLMETABOLITETOEMU Include all metabolites to EMU
            %
            % Parameters
            % ----------
            % tf: bool
            %    True if all metabolites are included to EMU
            %
            % Returns
            % -------
            % None

            arguments
                obj;
                tf (1, 1) logical;
            end

            if tf
                obj.includeAllMetabolite = true;
            else
                obj.includeAllMetabolite = false;
            end

        end % includeAllMetaboliteToEMU

        function Xn = calculateXn(obj, flux, subsEMU)

            EMUMax = obj.EMUSizeMax;
            totalXm = obj.totalX;
            Xn = nan(totalXm, EMUMax + 1);
            idx = 1;

            for i = 1:EMUMax

                if i == 1

                    Ai = obj.calculateAn{i}(flux);
                    Bi = obj.calculateBn{i}(flux);
                    Yi = obj.calculateYn{i}(subsEMU);
                    Xi = Ai \ Bi * Yi;
                    n = size(Xi, 1);
                    Xn(1:n, 1:i + 1) = Xi;
                    idx = idx + n;

                    continue

                end

                Ai = obj.calculateAn{i}(flux);
                Bi = obj.calculateBn{i}(flux);
                Yi = obj.calculateYn{i}(subsEMU, Xn);
                Xi = Ai \ Bi * Yi;
                n = size(Xi, 1);
                Xn(idx:idx + n - 1, 1:i + 1) = Xi;
                idx = idx + n;

            end % for i

        end % calculateXn

        function MDV = calculateMDV(obj, flux, substrateEMU)
            % CALCULATEMDV Calculate MDV from fluxes and substrate EMUs
            %
            % Parameters
            % ----------
            % flux: (n x 1) double
            %    Fluxes
            % substrateEMU: (n x m+1) double
            %    Substrate EMUs
            %    n: # of EMU pattern
            %    m: Maximum EMU size
            %
            % Returns
            % -------
            % MDV: (n x 1) double
            %    Linearized MDV

            X = calculateXn(obj, flux, substrateEMU);
            MDV = obj.convertXToMDV(X);

        end % calculateMDV

    end % methods (Access = public)

    methods (Access = private)

        %% Private EMU methods
        function trackAllEMU(obj)
            % TRACKALLEMU Track all EMUs
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Constructing EMU network from the model";
            updateMsg(obj, msg, "Info", obj.logLevel);

            % Initialize EMU table
            initializeEMUTable(obj);

            trackTargetEMU(obj);
            trackMetaboliteEMU(obj);

        end % trackAllEMU

        function trackTargetEMU(obj)
            % TRACKTARGETEMU Track target EMUs
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Explore target EMUs...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            % List up target metabolites
            MSRxn = getMSRxnTable(obj);
            MSTrans = getMSTransTable(obj);

            numRxn = height(MSRxn);

            errorFlag = false(1, numRxn);

            for i = 1:numRxn

                product = MSRxn.Products{i};
                reactant = MSRxn.Reactants{i};
                index = MSRxn.Properties.RowNames{i};
                productLabel = MSTrans.Products{i};
                reactantLabel = MSTrans.Reactants{i};

                if length(product) > 1 || length(productLabel) > 1
                    errorFlag(i) = 1;
                    continue;
                end % if

                EMU = product{1};
                EMULabel = productLabel{1};

                % Replace underscore with hyphen
                EMUReplaced = strrep(EMU, '_', 'x');
                Metabolite = '';
                [~, Position] = replaceCharToNumber(obj, EMULabel);
                % EMUNumbered: Pyr_{AB}, Oxa_{ABC}
                EMUNumbered = EMUReplaced + "_" + EMULabel + "";
                EMUSize = length(EMULabel);
                EMUNew = { ...
                              EMUNumbered, ...
                              Metabolite, ...
                              Position, ...
                              EMUSize, ...
                              true ...
                          };

                % Add new EMU to the list
                newTable = addNewEMUToList(obj, EMUNew);

                % Find reactants EMU from product
                reactantEMU = findReactantsEMUFromProduct(obj, newTable, EMULabel, reactant, reactantLabel);
                reactantEMUcell = table2cell(reactantEMU);
                addNewEMUToList(obj, reactantEMUcell);

                % Add new reaction to the list
                addNewRxnToList(obj, index, reactantEMU, newTable);

            end % for i

            if any(errorFlag)
                msg = "Error: Multiple products in the MS table are not supported.";
                updateMsg(obj, msg, "Error", obj.logLevel);
                return;
            end

            numTarget = sum(obj.tableEMU.Target);
            msg = num2str(numTarget) + " target EMUs are found.";
            updateMsg(obj, msg, "Info", obj.logLevel);

            addAllMetaboliteToEMU(obj);

        end % trackTargetEMU

        function trackMetaboliteEMU(obj)
            % TRACKMETABOLITEEMU Track metabolite EMUs
            %
            % trackMetaboliteEMU(obj)
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Explore metabolite EMUs...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            % target = false
            EMUs = obj.tableEMU;
            tableEMUNoTarget = EMUs(EMUs.Target == false, :);

            numTotalEMU = height(EMUs);
            numTotalRxns = height(obj.tableEMUReaction);

            exploreEMUNetwork(obj, tableEMUNoTarget);

            % Delete duplicate EMUs by EMU name
            [~, idx] = unique(obj.tableEMU.EMU);
            obj.tableEMU = obj.tableEMU(idx, :);

            numAddedEMU = height(obj.tableEMU) - numTotalEMU;
            numAddedRxns = height(obj.tableEMUReaction) - numTotalRxns;
            msg = num2str(numAddedEMU) + " EMUs were added to the EMU network.";
            updateMsg(obj, msg, "Info", obj.logLevel);
            msg = num2str(numAddedRxns) + " reactions are added to the EMU network.";
            updateMsg(obj, msg, "Info", obj.logLevel);

        end % trackMetaboliteEMU

        % Initialization
        function initializeEMUTable(obj)
            % INITIALIZEEMUTABLE Initialize EMU table
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            % Initialize EMU table
            obj.tableEMU = table('Size', [0 5], ...
                'VariableNames', {'EMU', 'Metabolite', 'Position', 'Size', 'Target'}, ...
                'VariableTypes', {'string', 'string', 'cell', 'double', 'logical'});
            obj.tableEMU.Properties.Description = 'EMU table';

            obj.tableEMUReaction = table('Size', [0 6], ...
                'VariableNames', {'RxnID', 'Reactants', 'Products', 'Coefficient', 'Size', 'Target'}, ...
                'VariableTypes', {'string', 'cell', 'cell', 'double', 'double', 'logical'});
            obj.tableEMUReaction.Properties.Description = 'EMU reaction table';

        end % initializeEMUTable

        function exploreEMUNetwork(obj, EMU)
            % EXPLOREEMUNETWORK Explore EMU network
            %
            % Parameters
            % ----------
            % EMU: (n x 5) table
            %    EMU information
            %

            for i = 1:height(EMU)

                iEMU = EMU(i, :);
                iEMUName = iEMU.EMU;
                idx = findRxnFromEMU(obj, iEMUName);
                reactantEMU = createEMURow(obj, iEMU, idx);
                reactantEMUListedRemoved = removeListedEMUFromEMUTable(obj, reactantEMU);
                reactantEMUSubsRemoved = removeSubstrateEMUFromEMUTable(obj, reactantEMUListedRemoved);
                addNewEMUToList(obj, reactantEMUListedRemoved);

                if ~isempty(reactantEMUSubsRemoved)
                    exploreEMUNetwork(obj, reactantEMUSubsRemoved);
                end

            end % for i

        end % exploreEMUNetwork

        function reactantEMU = createEMURow(obj, EMU, idx)
            % CREATEEMUROW Create EMU row
            %
            % Parameters
            % ----------
            % EMU: (1 x 5) table
            %    EMU information
            % idx: (1 x n) double
            %    Reaction index
            %
            % Returns
            % -------
            % reactantEMU: (1 x 5) table
            %    EMU information
            %
            % See also
            % --------
            % exploreEMUNetwork

            reactantEMU = table( ...
                'Size', [0 5], ...
                'VariableNames', obj.tableEMU.Properties.VariableNames, ...
                'VariableTypes', obj.tableEMU.Properties.VariableTypes ...
            );

            if isempty(idx)
                return;
            end

            modelRev = getModelRxnRev(obj);
            modelTrans = getModelTransRev(obj);
            modelRevSelected = modelRev(idx, :);
            modelTransSelected = modelTrans(idx, :);

            numRxn = height(modelRevSelected);

            for iRxn = 1:numRxn

                product = modelRevSelected.Products{iRxn};
                reactant = modelRevSelected.Reactants{iRxn};
                productLabel = modelTransSelected.Products{iRxn};
                reactantLabel = modelTransSelected.Reactants{iRxn};

                numProduct = length(product);

                for i = 1:numProduct

                    iProduct = product{i};

                    if ~strcmp(iProduct, EMU.Metabolite)
                        continue;
                    end

                    iProductLabel = productLabel{i};

                    iReactantEMU = findReactantsEMUFromProduct(obj, EMU, iProductLabel, reactant, reactantLabel);

                    if isempty(reactantEMU)
                        reactantEMU = iReactantEMU;
                    else
                        reactantEMU = [ ...
                                           reactantEMU; ...
                                           iReactantEMU ...
                                       ];
                    end % if

                    addNewRxnToList(obj, modelRevSelected.Properties.RowNames{iRxn}, iReactantEMU, EMU);

                end % for i

            end % for iRxn

        end % createEMURow

        function EMU = removeSubstrateEMUFromEMUTable(obj, EMU)
            % REMOVESUBSTRATEEMUFROMEMUTABLE Remove substrate EMU from EMU table
            %
            % Parameters
            % ----------
            % EMU: (1 x 5) table
            %    EMU information
            %
            % Returns
            % -------
            % None

            metabolite = EMU.Metabolite;
            modelMetabolite = getSubstrateTable(obj);

            mask = ismember(metabolite, modelMetabolite.Metabolite);
            EMU = EMU(~mask, :);

        end % removeSubstrateEMUFromEMUTable

        function EMU = removeListedEMUFromEMUTable(obj, EMU)
            % REMOVELISTEDEMUFROMEMUTABLE Remove listed EMU from EMU table
            %
            % Parameters
            % ----------
            % EMU: (1 x 5) table
            %    EMU information
            %
            % Returns
            % -------
            % None

            EMUList = obj.tableEMU.EMU;
            mask = ismember(EMU.EMU, EMUList);
            EMU = EMU(~mask, :);

        end % removeListedEMUFromEMUTable

        function addAllMetaboliteToEMU(obj)
            % ADDALLMETABOLITETOEMU Add all metabolites to EMU
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            if ~obj.includeAllMetabolite
                return;
            end

            msg = "Include all metabolites to EMU...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            metabolite = getMetaboliteTable(obj);
            numMetabolite = height(metabolite);

            for i = 1:numMetabolite

                % Pyr, AcCoA
                iMetabolite = metabolite.Metabolite{i};
                iNumCarbon = metabolite.Carbon{i};

                % Replace underscore with hyphen
                % Pyr, AcCoA
                iMetaboliteReplaced = strrep(iMetabolite, '_', 'x');
                % ABC, ABCDE
                iCharLabel = convertNumberToChar(obj, 1:iNumCarbon);
                % Pyr_{ABC}, AcCoA_{ABCDE}
                iEMUNumbered = iMetaboliteReplaced + "_" + iCharLabel + "";
                iPosition = 1:iNumCarbon;

                iEMUNew = { ...
                               iEMUNumbered, ...
                               iMetabolite, ...
                               iPosition, ...
                               iNumCarbon, ...
                               false ...
                           };

                % Add new EMU to the list
                addNewEMUToList(obj, iEMUNew);

            end % for i

            msg = num2str(numMetabolite) + " metabolites are included to EMU list.";
            updateMsg(obj, msg, "Info", obj.logLevel);

        end % addAllMetaboliteToEMU

        function newTable = addNewEMUToList(obj, EMU)
            % ADDNEWEMUTOLIST Add new EMU to the list if it is not in the list
            %
            % addNewEMUToList(obj, EMU)
            %
            % Parameters
            % ----------
            % EMU: (1 x 5) cell
            %   EMU information
            %
            % Returns
            % -------
            % newTable: table
            %   New EMU table

            % Add new EMU to the list

            if istable(EMU)
                newTable = EMU;
            else
                newTable = cell2table(EMU, 'VariableNames', obj.tableEMU.Properties.VariableNames);
            end

            % Check if EMU is in the list

            mask = isExistEMUsInLists(obj, newTable.EMU);

            % Remove existing EMU from newTable row
            newTable = newTable(~mask, :);

            obj.tableEMU = [ ...
                                obj.tableEMU; ...
                                newTable ...
                            ];

        end % addNewEMUToList

        function newRxn = addNewRxnToList(obj, RxnID, reactants, products)
            % ADDNEWRXNTOLIST Add new reaction to the list
            %
            % newRxn = addNewRxnToList(obj, RxnID, reactants, products)
            %
            % Parameters
            % ----------
            % RxnID: string
            %    Reaction ID
            % reactants: (n x 5) table
            %    Reactant EMUs
            % products: (n x 5) table
            %    Product EMUs
            %
            % Returns
            % -------
            % newRxn: (n x 6) table
            %    New reaction table
            %
            % Example
            % -------
            % RxnID = 'r1';
            % products = table( ...
            %     'C_{ABCDE}', 'C', [1 2 3 4 5], 5, false, ...
            %      );
            % reactants = table( ...
            %     'A_{AB}', 'A', [1 2], 2, false, ...
            %     'B_{CDE}', 'B', [3 4 5], 3, false, ...
            %      );
            % newRxn = addNewRxnToList(obj, RxnID, reactants, products);
            % disp(newRxn)
            % | RxnID | Reactants         | Products    | Coefficient | Size | Target |
            % |-------|-------------------|-------------|-------------|------|--------|
            % | r1    | {A_{AB}, B_{CDE}} | {C_{ABCDE}} |           1 |    5 |      0 |

            EMUreactants = reactants.EMU;
            EMUproducts = products.EMU;
            sizeProduct = products.Size;

            isTarget = products.Target;

            newRxnCell = { ...
                              RxnID, ...
                              {EMUreactants}, ...
                              {EMUproducts}, ...
                              1, ...
                              sizeProduct, ...
                              isTarget ...
                          };

            newRxn = cell2table( ...
                newRxnCell, ...
                'VariableNames', obj.tableEMUReaction.Properties.VariableNames ...
            );

            obj.tableEMUReaction = [ ...
                                        obj.tableEMUReaction; ...
                                        newRxn ...
                                    ];

        end % addNewRxnToList

        function mask = isExistEMUsInLists(obj, EMUList)
            % ISEXISTEMUSINLISTS Check if EMUs are in the list
            %
            % mask = isExistEMUsInList(obj, EMUList)
            %
            % Parameters
            % ----------
            % EMUList: (n x 1) cell
            %    EMU list
            %
            % Returns
            % -------
            % mask: (n x 1) logical
            %    True if EMU is in the list

            % Check if EMUs are in the list

            mask = ismember(EMUList, obj.tableEMU.EMU);

        end % isExistEMUsInLists

        function [tf, idx] = isExistEMUInList(obj, EMUName)
            % ISEXISTEMUINLIST Check if EMU is in the list
            %
            % isExistEMUInList(obj, EMU)
            %
            % Parameters
            % ----------
            % EMU: string
            %    EMU name
            %    Format:
            %        Metabolite_{Position}
            %
            % Returns
            % -------
            % tf: bool
            %    True if EMU is in the list
            % idx: double
            %    Index of the EMU in the list
            %    If the EMU is not in the list, idx is 0

            % Check if EMU is in the list

            tf = any(strcmp(obj.tableEMU.EMU, EMUName));
            idx = find(strcmp(obj.tableEMU.EMU, EMUName));

        end % isExistEMUInList

        function EMUs = findReactantsEMUFromProduct(obj, productEMU, productTrans, reactant, reactantTrans)
            % FINDREACTANTSEMUFROMPRODUCT Find reactants EMU from product
            %
            % EMUs = findReactantsEMUFromProduct(obj, productEMU, reactant, reactantTrans)
            %
            % Parameters
            % ----------
            % productEMU: (1 x 5) table
            %    Product EMU column
            %    | EMU        | Metabolite | Position | Size | Target |
            %    |------------|------------|----------|------|--------|
            %    |  Pyr_{12}  | Pyr        | [1 2]    |    2 |      0 |
            % productTrans: string
            %    Product carbon pattern
            %    example: "AB"
            % reactant: (1 x n) cell
            %    Reactant cell
            %    example: {'A', 'B'}
            % reactantTrans: (1 x n) cell
            %    Reactant carbon pattern
            %    example: {'AB', 'CDE'}
            %
            % Returns
            % -------
            % EMUs: (n x 5) table
            %    EMU information

            EMUs = table();

            numReactant = length(reactant);
            % [1 2], [1 3]
            productAtom = productEMU.Position;

            isTarget = productEMU.Target;

            if ~isTarget
                % "ABCDE" --> "AB", "AC"
                [~, selectedAtomList] = selectAtom(obj, productTrans, productAtom);

            else
                selectedAtomList = productAtom;
            end

            for i = 1:numReactant

                % Replace underscore with hyphen
                % Pyr, Oxa
                EMU = reactant{i};
                EMUReplaced = strrep(EMU, '_', 'x');
                % Pyr, Oxa
                Metabolite = EMU;
                % [1 2], [1 3]
                [~, Position] = replaceCharToNumber(obj, reactantTrans{i});

                % [1 0 1 0 1 0], [1 0 0 1 0 1]
                isUsedAtom = ismember(Position, selectedAtomList);
                % [1 3 5], [1 4 6]
                PositionReactant = find(isUsedAtom);
                charABC = convertNumberToChar(obj, PositionReactant);
                % Pyr_{12}, Pyr_{13}
                EMUNumbered = EMUReplaced + "_" + charABC + "";
                EMUSize = length(PositionReactant);

                if EMUSize == 0
                    continue;
                end

                EMUNew = { ...
                              EMUNumbered, ...
                              Metabolite, ...
                              transpose(PositionReactant), ...
                              EMUSize, ...
                              false ...
                          };

                if isempty(EMUs)
                    EMUs = cell2table(EMUNew, 'VariableNames', obj.tableEMU.Properties.VariableNames);
                else
                    newTable = cell2table(EMUNew, 'VariableNames', obj.tableEMU.Properties.VariableNames);
                    EMUs = [EMUs; newTable];
                end % if

                EMUs.Properties.VariableTypes = obj.tableEMU.Properties.VariableTypes;

            end % for i

        end % findReactantsEMUFromProduct

        function idx = findRxnFromEMU(obj, EMU)
            % FINDRXNFROMEMU Find reaction containing designated EMU in only "Products"
            %
            % idx = findRxnFromEMU(obj, EMU)
            %
            % Parameters
            % ----------
            % EMU: string
            %    EMU name
            %
            % Returns
            % -------
            % idx: (1 x n) double
            %    Index of the reaction containing the designated EMU
            %
            % Example
            % -------
            % idx = findRxnFromEMU('Pyr_{ABC}')
            % idx = [1 2]

            % Pyr_{ABC} --> Pyr
            metabolite = metaboliteFromEMU(obj, EMU);

            % Find metabolite from the model
            modelRxnRev = getModelRxnRev(obj);

            mask = false(1, height(modelRxnRev));

            for i = 1:height(modelRxnRev)

                % Find reaction containing the designated EMU
                product = modelRxnRev.Products{i};

                if any(strcmp(product, metabolite))
                    mask(i) = true;
                end

            end % for i

            idx = find(mask);

        end % findRxnFromEMU

        function [idx] = findEMURxnFromEMU(obj, EMU)
            % FINDEMURXNFROMEMU Find EMU reaction containing designated EMU in "Products"
            %
            % idx = findEMURxnFromEMU(obj, EMU)
            %
            % Parameters
            % ----------
            % EMU: string (1 x 1)
            %    EMU name
            %
            % Returns
            % -------
            % idx: (1 x n) double
            %    Index of the EMU reaction containing the designated EMU
            %
            % Example
            % -------
            % idx = findEMURxnFromEMU('Pyr_{ABC}')
            % idx = [1 2]

            % Find EMU reaction containing designated EMU in "Products"
            EMURxn = getEMURxnTable(obj);
            product = EMURxn.Products;

            mask = cellfun(@(x) any(strcmp(x, EMU)), product);

            idx = find(mask);

        end % findEMURxnFromEMU

        function metabolite = metaboliteFromEMU(obj, EMU)
            % METABOLITEFROMEMU Find metabolite from EMU
            %
            % metabolite = metaboliteFromEMU(obj, EMU)
            %
            % Parameters
            % ----------
            % EMU: string
            %    EMU name
            %
            % Returns
            % -------
            % metabolite: string
            %    Metabolite name
            %
            % Example
            % -------
            % metabolite = metaboliteFromEMU('Pyr_{ABC}')
            % metabolite = 'Pyr'

            % Find EMU from the list
            [tf, idx] = isExistEMUInList(obj, EMU);

            if ~tf
                metabolite = "";
                return;
            end

            metabolite = obj.tableEMU.Metabolite{idx};

        end % metaboliteFromEMU

        function sizeEMU = getSizeFromEMU(obj, EMU)
            % GETSIZEFROMEMU Get size of EMU
            %
            % sizeEMU = getSizeFromEMU(obj, EMU)
            %
            % Parameters
            % ----------
            % EMU: string
            %    EMU name
            %
            % Returns
            % -------
            % sizeEMU: double
            %    Size of EMU
            %
            % Example
            % -------
            % sizeEMU = getSizeFromEMU('Pyr_{ABC}')
            % sizeEMU = 3

            arguments
                obj;
                EMU (1, 1) string {mustBeNonempty};
            end

            % Find EMU from the list
            [tf, idx] = isExistEMUInList(obj, EMU);

            if ~tf
                sizeEMU = -1;
                return;
            end

            sizeEMU = obj.tableEMU.Size(idx);

        end % getSizeFromEMU

        function [charLabel, position] = selectAtom(obj, label, list)
            % SELECTATOM Select atom from the list
            %
            % [charLabel, position] = selectAtom(obj, label, list)
            %
            % Parameters
            % ----------
            % label: string
            %    Label of the atom
            % list: array
            %    List of the atom
            %
            % Returns
            % -------
            % charLabel: string
            %    Label of the atom
            % position: array
            %    Position of the atom
            %
            % Example
            % -------
            % >> [charLabel, position] = selectAtom('ABCDE', [1 2 3])
            % charLabel = 'ABC'
            % position = [1 2 3]
            %
            % >> [charLabel, position] = selectAtom('CABDE', [1 3 5])
            % charLabel = 'CBE'
            % position = [3 2 5]
            %
            % >> [charLabel, position] = selectAtom('EDCBA', [1 2 3 4 5])
            % charLabel = 'EDCBA'
            % position = [5 4 3 2 1]

            if iscell(list)
                list = list{:};
            end

            % Select atom from the list
            charLabel = '';

            for i = 1:length(list)
                idx = list(i);
                charLabel = [charLabel, label(idx)];
            end % for i

            [~, position] = replaceCharToNumber(obj, charLabel);

        end % selectAtom

        function [charLabel, listLabel] = replaceCharToNumber(obj, label)
            % REPLACECHARTONUMBER Replace character to number
            %
            % [charLabel, listLabel] = replaceCharToNumber(obj, label)
            %
            % Parameters
            % ----------
            % string
            %    Character e.g. 'ABC'
            %
            % Returns
            % -------
            % charLabel: string
            %    Character replaced by number e.g. '123'
            % listLabel: array
            %    List of number e.g. [1 2 3]
            %
            % Example
            % -------
            % >> [charLabel, listLabel] = replaceCharToNumber('ABC')
            % charLabel = '123'
            % listLabel = [1 2 3]
            %
            % >> [charLabel, listLabel] = replaceCharToNumber('ABDE')
            % charLabel = '1245'
            % listLabel = [1 2 4 5]

            % Replace character to number
            charLabel = '';
            listLabel = zeros(1, length(label));

            for i = 1:length(label)
                idx = find(obj.charList == label(i));
                charLabel = [charLabel, num2str(idx)];
                listLabel(i) = idx;
            end % for i

        end % replaceCharToNumber

        function charABC = convertNumberToChar(obj, list)
            % CONVERTNUMBERTOCHAR Convert number to character
            %
            % charABC = convertNumberToChar(obj, list)
            %
            % Parameters
            % ----------
            % list: array
            %    List of number e.g. [1 2 3]
            %
            % Returns
            % -------
            % charABC: string
            %    Character e.g. "ABC"
            %
            % Example
            % -------
            % >> charABC = convertNumberToChar([1 2 3])
            % charABC = 'ABC'
            %
            % >> charABC = convertNumberToChar([1 2 4 5])
            % charABC = 'ABDE'

            % Convert number to character
            charABC = obj.charList(list);

        end % convertNumberToChar

        function fluxSym = defineFluxSym(obj)
            % DEFINEFLUXSYM Define flux of EMU
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None
            %
            % Object
            % ------
            % flux: (n x 1) symbolic
            %    Symbolic flux

            modelRxnRev = getModelRxnRev(obj);
            numRxn = height(modelRxnRev);

            fluxSym = sym('flux', [numRxn 1]);

        end % defineFluxSym

        function defineMatrixX(obj)
            % DEFINEMATRIXX Define matrix X of EMU
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None
            %
            % Object
            % ------
            % matrixX: cell
            %    Matrix X of EMU
            %    matrixX{EMUSize}: (n x 1) cell
            %       EMU list of EMUSize
            %    matrixX{EMUSize}{i}: string
            %       EMU name
            % matrixXsym: cell
            %    Matrix X of symbolic EMU
            %    matrixXsym{EMUSize}: (n x EMUSizeMax + 1) double
            %       EMU matrix X of EMUSize

            msg = "Allocating matrix X...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            EMU = obj.tableEMU;
            EMUNoTarget = EMU(EMU.Target == false, :);
            X = cell(obj.EMUSizeMax, 1);
            symX = cell(obj.EMUSizeMax, 1);

            for EMUSize = obj.EMUSizeMax:-1:1

                iEMU = EMUNoTarget(EMUNoTarget.Size == EMUSize, :);
                iEMUMetabolite = removeSubstrateEMUFromEMUTable(obj, iEMU);
                iXCell = iEMUMetabolite.EMU;
                iXCellSorted = sort(iXCell);
                CellEMU = cellstr(iXCellSorted);

                X{EMUSize} = cellfun(@string, CellEMU, "UniformOutput", false);

                symX{EMUSize} = createSymFromCell(obj, X{EMUSize}, EMUSize);

                EMUSizei = size(X{EMUSize}, 1);

                msg = "EMU size " + num2str(EMUSize) + ": (" + num2str(EMUSizei) + " x " + num2str(EMUSize + 1) + ")";
                dispNormalMsg(obj, msg, "Debug", obj.logLevel);

            end % for EMUSize

            obj.matrixX = X;
            obj.matrixXsym = symX;

        end % defineMatrixX

        function defineMatrixY(obj)
            % DEFINEMATRIXY Define matrix Y of EMU
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Allocating matrix Y...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            EMURxn = obj.tableEMUReaction;
            EMURxnNoTarget = EMURxn(EMURxn.Target == false, :);
            Y = cell(obj.EMUSizeMax, 1);
            Ysym = cell(obj.EMUSizeMax, 1);

            for EMUSize = obj.EMUSizeMax:-1:1

                iEMURxn = EMURxnNoTarget(EMURxnNoTarget.Size == EMUSize, :);
                EMUList = findEMUFromRxn(obj, iEMURxn);

                Y{EMUSize} = EMUList;
                Ysym{EMUSize} = createSymFromCell(obj, Y{EMUSize}, EMUSize);

                YiSizeRow = size(Y{EMUSize}, 1);

                msg = "EMU size " + num2str(EMUSize) + ": (" + num2str(YiSizeRow) + " x " + num2str(EMUSize + 1) + ")";
                dispNormalMsg(obj, msg, "Debug", obj.logLevel);

            end % for EMUSize

            obj.matrixY = Y;
            obj.matrixYsym = Ysym;

        end % defineMatrixY

        function defineMatrixA(obj)
            % DEFINEMATRIXA Define matrix A of EMU
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Constructing matrix A and B...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            EMURxn = obj.tableEMUReaction;

            matrixAM = cell(obj.EMUSizeMax, 1);
            matrixBM = cell(obj.EMUSizeMax, 1);

            for i = 1:obj.EMUSizeMax

                % Process for each EMU of size i
                iX = obj.matrixX{i};
                iY = obj.matrixY{i};

                iMatrixA = sym(zeros(length(iX), length(iX)));
                iMatrixB = sym(zeros(length(iX), length(iY)));

                iXY = [iX; iY];

                for iProductEMU = 1:size(iX, 1)

                    ipProduct = iXY{iProductEMU};
                    rxnIdx = findEMURxnFromEMU(obj, ipProduct);
                    selectedEMURxn = EMURxn(rxnIdx, :);
                    fluxSymRow = createEMUMatrixRow(obj, selectedEMURxn, iXY);
                    fluxSymRow(iProductEMU) = -sum(fluxSymRow);
                    fluxSymRowX = fluxSymRow(1:length(iX));
                    fluxSymRowY = fluxSymRow(length(iX) + 1:end);
                    iMatrixA(iProductEMU, :) = -fluxSymRowX;
                    iMatrixB(iProductEMU, :) = fluxSymRowY;

                end % for iProductEMU

                matrixAM{i} = iMatrixA;
                matrixBM{i} = iMatrixB;

                msg = "Matrix A and B of size " + num2str(i) + " were constructed.";
                updateMsg(obj, msg, "Debug", obj.logLevel);

            end % for i

            obj.matrixA = matrixAM;
            obj.matrixB = matrixBM;

            msg = "Matrix A and B are constructed.";
            updateMsg(obj, msg, "Info", obj.logLevel);

        end % defineMatrixA

        function symMatrix = createSymFromCell(obj, cellMatrix, EMUSize)
            % CREATESYMFROMCELL Create symbolic matrix from cell
            %
            % symMatrix = createSymFromCell(obj, cellMatrix)
            %
            % Parameters
            % ----------
            % cellMatrix: (n x 1) cell
            %    Cell matrix
            %    n: number of EMUs
            % EMUSize: (1 x 1) double
            %    EMU size
            %
            % Returns
            % -------
            % symMatrix: (n x m) sym
            %    Symbolic matrix
            %    m: The size of EMU + 1

            arguments
                obj
                cellMatrix (:, 1) cell
                EMUSize (1, 1) double {mustBeInteger}
            end

            symMatrix = sym(zeros(length(cellMatrix), EMUSize + 1));

            % Create symbolic matrix in the cell
            for iEntry = 1:length(cellMatrix)

                % {"A_ABC"; "B_CDE"; ["C_A"; "D_A"; "E_E"]}
                iEntryContents = cellMatrix{iEntry};

                iEMUContents = cell(length(iEntryContents), 1);

                for iEMU = 1:length(iEntryContents)

                    % "A_ABC"
                    iEMUName = iEntryContents{iEMU};
                    % Check EMU size
                    iSize = getSizeFromEMU(obj, iEMUName);
                    % [A_ABC1, A_ABC2, A_ABC3, A_ABC4]
                    iEMUSym = sym(iEMUName, [1, iSize + 1]);

                    iEMUContents{iEMU} = iEMUSym;

                end % for iEMU

                symMatrix(iEntry, :) = conv_syms(obj, iEMUContents);

            end % for iEMU

        end % createSymFromCell

        function row = createEMUMatrixRow(obj, RxnTable, iXY)
            % CREATEEMUMATRIXROW Create EMU matrix row
            %
            % Parameters
            % ----------
            % Reactants: (n x 1) cell
            %    Reactant EMUs
            % iXY: (n x 1) cell
            %    EMU list

            row = sym(zeros(1, length(iXY)));

            for i = 1:length(iXY)

                iEMU = iXY{i};

                for j = 1:height(RxnTable)

                    jReactant = RxnTable.Reactants{j};

                    if isequal(iEMU, jReactant)

                        coefficient = RxnTable.Coefficient(j);
                        idx = findRxnIdx(obj, RxnTable.RxnID{j});

                        if isempty(idx)
                            continue
                        end

                        row(i) = -coefficient * obj.fluxSym(idx);

                    end

                end % for j

            end % for i

        end % createEMUMatrixRow

        function EMUList = findEMUFromRxn(obj, EMURxn)
            % FINDEMUFROMRXN Find EMU from reaction
            %
            % EMUList = findEMUFromRxn(obj, EMURxn)
            %
            % Parameters
            % ----------
            % EMURxn: (n x 5) table
            %    EMU reaction information
            %
            % Returns
            % -------
            % EMUList: (m x 1) cell
            %    EMU list
            %
            % See also
            % --------
            % defineMatrixY

            EMUListTemp = {};
            numRxn = height(EMURxn);
            substrate = getSubstrateTable(obj);

            for i = 1:numRxn

                iEMURxn = EMURxn(i, :);
                iReactants = iEMURxn.Reactants{:};

                % 1. If the size is 2 or more, the reaction is a condensation reaction,
                % so add iReactants to EMUList
                if length(iReactants) > 1
                    EMUListTemp = [EMUListTemp; {iReactants}];
                    continue
                end

                % 2. It the reactant is a substrate, add iReactants to EMUList
                Metabolitereactant = metaboliteFromEMU(obj, iReactants);

                if ismember(Metabolitereactant, substrate.Metabolite)
                    EMUListTemp = [EMUListTemp; {iReactants}];
                end

            end % for i

            EMUList = EMUListTemp;

        end % findEMUFromRxn

        function [rtn] = conv_syms(obj, C)
            % CONV_SYMS Calculate convolution of symbolic matrix
            %
            % conv_syms = conv_syms(C)
            %
            % Parameters
            % ----------
            % C: (n) cell
            %    Symbolic matrix
            %
            % Returns
            % -------
            % conv_syms: sym
            %    Convolution of symbolic matrix

            arguments
                obj
                C (:, 1) cell
            end

            % Calculate convolution of symbolic matrix
            numC = length(C);
            rtn = C{1};

            for i = 2:numC
                rtn = conv_sym(obj, rtn, C{i});
            end % for i

        end % conv_syms

        function [conv_syms] = conv_sym(~, A, B)

            arguments
                ~
                A (1, :) sym
                B (1, :) sym
            end

            [n, m] = size(A);
            [l, k] = size(B);

            conv_syms = sym(zeros(n + l - 1, m + k - 1));

            for i = 1:n

                for j = 1:m

                    for p = 1:l

                        for q = 1:k
                            conv_syms(i + p - 1, j + q - 1) = conv_syms(i + p - 1, j + q - 1) + A(i, j) * B(p, q);
                        end

                    end

                end

            end

            conv_syms = simplify(conv_syms);

        end

        function substrateEMUs = defineSubstrateEMUSym(obj)
            % DEFINESUBSTRATEEMUS Define substrate EMUs
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Defining substrate EMUs...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            substrates = getSubstrateTable(obj);
            numSubstrate = height(substrates);

            % Investigate the maximum number of carbon in the substrate
            maxAtom = max(cell2mat(substrates.Carbon));

            substrateEMUs = [];

            for iSubstrate = 1:numSubstrate

                % Pyr, AcCoA
                iMetabolite = substrates.Metabolite{iSubstrate};
                iNumCarbon = substrates.Carbon{iSubstrate};

                maskPosition = dec2bin(1:2 ^ iNumCarbon - 1) == '1';
                iSubstrateEMU = sym(nan(2 ^ iNumCarbon - 1, maxAtom + 1));

                for iPosition = 1:2 ^ iNumCarbon - 1

                    iCharLabel = convertNumberToChar(obj, maskPosition(iPosition, :));
                    iMetabolite = strrep(iMetabolite, '_', 'x');
                    iEMUNumbered = iMetabolite + "_" + iCharLabel;
                    iSize = sum(maskPosition(iPosition, :));

                    iSubstrateEMU(iPosition, 1:iSize + 1) = sym(iEMUNumbered, [1, iSize + 1]);

                end % for iPosition

                sizeBefore = size(substrateEMUs, 2);
                sizeAfter = size(iSubstrateEMU, 2);

                if sizeBefore > sizeAfter
                    iSubstrateEMU = [iSubstrateEMU, sym(nan(size(iSubstrateEMU, 1), sizeBefore - sizeAfter))];
                elseif sizeAfter < sizeBefore
                    substrateEMUs = [substrateEMUs, sym(nan(size(substrateEMUs, 1), sizeAfter - sizeBefore))];
                end

                substrateEMUs = [substrateEMUs; iSubstrateEMU];

                msg = "Substrate EMUs of " + iMetabolite + " was defined.";
                updateMsg(obj, msg, "Debug", obj.logLevel);

            end % for iSubstrate

        end % defineSubstrateEMUs

        function cauculateAn = defineCalculateAn(obj)
            % DEFINECALCULATEAN Define function handle for calculate An
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Defining function handle for calculate An...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            cauculateAn = cell(obj.EMUSizeMax, 1);

            for i = 1:obj.EMUSizeMax

                cauculateAn{i} = ...
                    matlabFunction(obj.matrixA{i}, 'Vars', {obj.fluxSym});

                msg = "Function handle for calculate An of size " + num2str(i) + " is defined.";
                updateMsg(obj, msg, "Debug", obj.logLevel);

            end % for i

        end % defineCalculateAn

        function calculateBn = defineCalculateBn(obj)
            % DEFINECACULATEBN Define function handle for calculate Bn
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Defining function handle for calculate Bn...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            calculateBn = cell(obj.EMUSizeMax, 1);

            for i = 1:obj.EMUSizeMax

                calculateBn{i} = ...
                    matlabFunction(obj.matrixB{i}, 'Vars', {obj.fluxSym});

                msg = "Function handle for calculate Bn of size " + num2str(i) + " is defined.";
                updateMsg(obj, msg, "Debug", obj.logLevel);

            end % for i

        end % defineCalculateBn

        function calculateYn = defineCalculateYn(obj)
            % DEFINECALCULATEYN Define function handle for calculate Yn
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Defining function handle for calculate Yn...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            calculateYn = cell(obj.EMUSizeMax, 1);
            totalXn = obj.totalX;

            Xi = sym(nan(totalXn, obj.EMUSizeMax + 1));
            idx = 1;

            for i = 1:obj.EMUSizeMax

                if i == 1

                    calculateYn{i} = ...
                        matlabFunction(obj.matrixYsym{i}, 'Vars', {obj.substrateEMUsym});

                    XiTemp = obj.matrixXsym{i};
                    n = size(XiTemp, 1);
                    Xi(1:n, 1:i + 1) = XiTemp;
                    idx = idx + n;

                    msg = "Function handle for calculate Yn of size " + num2str(i) + " is defined.";
                    updateMsg(obj, msg, "Debug", obj.logLevel);

                    continue

                end

                calculateYn{i} = ...
                    matlabFunction(obj.matrixYsym{i}, 'Vars', {obj.substrateEMUsym, Xi});

                XiTemp = obj.matrixXsym{i};
                n = size(XiTemp, 1);
                Xi(idx:idx + n - 1, 1:i + 1) = XiTemp;
                idx = idx + n;

                msg = "Function handle for calculate Yn of size " + num2str(i) + " is defined.";
                updateMsg(obj, msg, "Debug", obj.logLevel);

            end % for i

            obj.Xn = Xi;

        end % defineCalculateYn

        function MDVSym = createCalculateMDV(obj)
            % CREATECALCULATEMDV Create function handle for calculate MDV
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            msg = "Defining function handle for calculate MDV...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            target = obj.targetMetaboliteList;

            MDV = sym(nan);

            for iTarget = 1:length(target)

                iTargetMetabolite = target{iTarget};

                rxnIdx = find(ismember(obj.tableEMUReaction.RxnID, iTargetMetabolite));
                reactant = obj.tableEMUReaction.Reactants{rxnIdx};
                sizeProduct = obj.tableEMUReaction.Size(rxnIdx);

                iEMU = createSymFromCell(obj, {reactant}, sizeProduct);
                iEMUTranspose = iEMU.';
                MDV = [MDV; iEMUTranspose];

            end % for iTarget

            MDVSym = MDV(2:end, :);

            obj.convertXToMDV = matlabFunction(MDVSym, 'Vars', {obj.Xn});

        end % createCalculateMDV

        function saveModelToFile(obj)
            % SAVEMODELTOFILE Save model to file
            %
            % saveModelToFile(obj)
            %
            % Parameters
            % ----------
            % filename: string
            %    Filename
            %
            % Returns
            % -------
            % None

            msg = "Saving model...";
            updateMsg(obj, msg, "Info", obj.logLevel);

            variables = { ...
                             'matrixX', ...
                             'matrixXsym', ...
                             'matrixY', ...
                             'matrixYsym', ...
                             'matrixA', ...
                             'matrixB', ...
                             'substrateEMUs', ...
                             'calculateAn', ...
                             'calculateBn', ...
                             'calculateYn', ...
                             'convertXToMDV', ...
                             'Xn', ...
                             'totalX', ...
                             'targetMetaboliteList', ...
                             'tableEMU', ...
                             'tableEMUReaction' ...
                         };

            filePath = obj.pathCache;

            matrixX = obj.matrixX;
            matrixXsym = obj.matrixXsym;
            matrixY = obj.matrixY;
            matrixYsym = obj.matrixYsym;
            matrixA = obj.matrixA;
            matrixB = obj.matrixB;
            calculateAn = obj.calculateAn;
            calculateBn = obj.calculateBn;
            calculateYn = obj.calculateYn;
            convertXToMDV = obj.convertXToMDV;
            substrateEMUsym = obj.substrateEMUsym;
            Xn = obj.Xn;
            totalX = obj.totalX;
            targetMetaboliteList = obj.targetMetaboliteList;
            tableEMU = obj.tableEMU;
            tableEMUReaction = obj.tableEMUReaction;

            save(filePath, "matrixX", "matrixXsym", "matrixY", "matrixYsym", "matrixA", "matrixB", ...
                "calculateAn", "calculateBn", "calculateYn", "convertXToMDV", "Xn", "totalX", ...
                "targetMetaboliteList", "tableEMU", "tableEMUReaction", "substrateEMUsym" ...
            );

            saveHashFile(obj, obj.pathModel);

        end % saveModel

        function resetHashFile(obj)
            % RESETHASHFILE Delete hash file
            %
            % resetHashFile(obj)
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            filePath = obj.pathHash;

            if isfile(filePath)
                delete(filePath);
            end

        end % resetHashFile

    end % methods (Access = private)

end % classdef
