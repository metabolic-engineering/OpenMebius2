classdef EMUModel < Stoichiometry

    events

        generalMsg

    end % events

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
        % Reactants: string
        %    Reactant EMUs
        % Products: string
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

        % EMU size information
        tableEMUSizeInfo = table();
        % tableEMUSizeInfo: table (m x 3)
        % Parameters
        % ----------
        % EMUSize: double
        %    EMU size
        % An: double
        %    Number of non-substrate EMUs of the size
        % Bn: double
        %    Number of substrate EMUs of the size
        %
        % | EMUSize |  An |  Bn |
        % |---------|-----|-----|
        % |       3 |  10 |   5 |
        % |       2 |  15 |   8 |
        % |       1 |  20 |  12 |

        searchedProduct = {};

        % global An matrix
        globalAn = [];
        globalAnEMUName = {};
        globalAnEMUNameMetabolite = {};
        globalAnList = [];
        % global Bn matrix
        globalBn = [];
        globalBnEMUName = {};
        globalBnEMUNameMetabolite = {};
        globalBnList = [];
        % | EMUSize | RxnIdx | i | j | coefficient |
        % |---------|--------|---|---|-------------|
        % |       3 |      1 | 1 | 1 |         0.5 |
        globalCn = [];
        globalCnDiag = [];

        globalXn = [];
        globalXnList = [];
        globalYn = [];
        globalYnList = [];

        globalMDVInfo = [];
        globalMDVSize = 0;
        globalMDVList = [];

        % Substrate EMU
        structSubstrateEMU = struct();
        targetMetaboliteList = string();

    end % properties (Access = public)

    properties (Access = private)

        CacheRepository
        NetworkBuilder
        MatrixBuilder
        NetworkEnumerator
        MDVCalculator

    end % properties (Access = private)

    methods

        function obj = EMUModel(modelInput, options)
            % EMUMODEL: Constructor for the EMUModel class.
            %
            % Parameters:
            % -----------
            % modelInput
            %     File directory or openmebius.domain.model.ModelLocation.

            arguments
                modelInput
                options.ModelRepository = ...
                    openmebius.infrastructure.model.ModelRepository()
                options.CacheRepository = ...
                    openmebius.infrastructure.model ...
                        .EMUNetworkCacheRepository()
                options.NetworkBuilder = openmebius.mfa.EMUNetworkBuilder()
                options.MatrixBuilder = openmebius.mfa.EMUMatrixBuilder()
                options.NetworkEnumerator = ...
                    openmebius.mfa.EMUNetworkEnumerator()
                options.MDVCalculator = openmebius.mfa.EMUMDVCalculator()
            end

            obj = obj@Stoichiometry( ...
                modelInput, ...
                ModelRepository = options.ModelRepository);
            obj.CacheRepository = options.CacheRepository;
            obj.NetworkBuilder = options.NetworkBuilder;
            obj.MatrixBuilder = options.MatrixBuilder;
            obj.NetworkEnumerator = options.NetworkEnumerator;
            obj.MDVCalculator = options.MDVCalculator;

            isSucceeded = obj.loadEMUModelFromFile();

            if ~isSucceeded
                isConstructed = constructEMUNetwork(obj);
            else
                isConstructed = false;
            end % if

            if isConstructed
                saveEMUModelToFile(obj);
            end % if

            throwIfConstructionFailed( ...
                obj, ...
                "OpenMebius2:ModelRepository:" + ...
                "EMUConstructionFailed", ...
                "Failed to construct the EMU network.");

            warning('off', 'MATLAB:nearlySingularMatrix');

        end % constructor

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

    end % methods

    methods (Access = public)

        %% Public utility methods
        function initializeEMUModel(obj)
            % INITIALIZEEMUMODEL: Initialize the EMU model.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            % Reset EMU-related properties
            obj.tableEMU = table();
            obj.tableEMUReaction = table();
            obj.tableEMUSizeInfo = table();
            obj.globalAn = [];
            obj.globalAnEMUName = {};
            obj.globalAnList = [];
            obj.globalBn = [];
            obj.globalBnEMUName = {};
            obj.globalBnList = [];
            obj.globalCn = [];
            obj.globalCnDiag = [];
            obj.globalXn = [];
            obj.globalXnList = [];
            obj.globalYn = [];
            obj.globalYnList = [];
            obj.globalMDVInfo = [];
            obj.globalMDVSize = 0;
            obj.globalMDVList = [];

        end % method initializeEMUModel

        function tf = constructEMUNetwork(obj)
            % CONSTRUCTEMUNETWORK: Construct the EMU network.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            operations = createBuildOperations(obj);
            snapshot = obj.NetworkBuilder.build(operations);
            applyCacheSnapshot(obj, snapshot);

            tf = true;

        end % method constructEMUNetwork

        function snapshot = getEMUNetworkSnapshot(obj)
            % GETEMUNETWORKSNAPSHOT Return the constructed network state.

            snapshot = createCacheSnapshot(obj);

        end % getEMUNetworkSnapshot

        function [An, Bn] = visualizeAnBnMatrix(obj, fluxLabel)
            % VISUALIZEANBNMATRIX Visualize the An and Bn matrices for a given flux label.
            %
            % [An, Bn] = Model.visualizeAnBnMatrix("r");
            %
            % Parameters
            % ----------
            % fluxLabel: char
            %    Flux label
            %
            % Returns
            % -------
            % An: (s * n * n) string
            %    An matrix with flux labels
            % Bn: (s * n * n) string
            %    Bn matrix with flux labels

            An = strings(size(obj.globalAn));
            Bn = strings(size(obj.globalBn));

            for iAnList = 1:size(obj.globalAnList, 1)

                rxnIdx = obj.globalAnList(iAnList, 2);

                currentElement = ...
                    An( ...
                    obj.globalAnList(iAnList, 3), ... % i index
                    obj.globalAnList(iAnList, 4), ... % j index
                    obj.globalAnList(iAnList, 1) ... % EMU size
                );

                coefficient = obj.globalAnList(iAnList, 5);

                if coefficient == 1 || coefficient == -1
                    coefficientStr = '';
                elseif coefficient > 0
                    coefficientStr = sprintf(' %.1f * ', coefficient);
                else
                    coefficientStr = sprintf(' %.1f * ', -coefficient);
                end % if

                signStr = '';

                if coefficient > 0 && ~isempty(currentElement)
                    signStr = ' + ';
                elseif coefficient < 0
                    signStr = ' - ';
                end % if

                An( ...
                    obj.globalAnList(iAnList, 3), ... % i index
                    obj.globalAnList(iAnList, 4), ... % j index
                    obj.globalAnList(iAnList, 1) ... % EMU size
                ) = ...
                    currentElement + ...
                    signStr + ...
                    coefficientStr + ...
                    fluxLabel + ...
                    sprintf('_%d', rxnIdx);

            end % for iAnList

            for iBnList = 1:size(obj.globalBnList, 1)

                rxnIdx = obj.globalBnList(iBnList, 2);

                currentElement = ...
                    Bn( ...
                    obj.globalBnList(iBnList, 3), ... % i index
                    obj.globalBnList(iBnList, 4), ... % j index
                    obj.globalBnList(iBnList, 1) ... % EMU size
                );

                coefficient = obj.globalBnList(iBnList, 5);

                if coefficient == 1 || coefficient == -1
                    coefficientStr = '';
                elseif coefficient > 0
                    coefficientStr = sprintf(' %.1f * ', coefficient);
                else
                    coefficientStr = sprintf(' %.1f * ', -coefficient);
                end % if

                signStr = '';

                if coefficient > 0 && ~isempty(currentElement)
                    signStr = ' + ';
                elseif coefficient < 0
                    signStr = ' - ';
                end % if

                Bn( ...
                    obj.globalBnList(iBnList, 3), ... % i index
                    obj.globalBnList(iBnList, 4), ... % j index
                    obj.globalBnList(iBnList, 1) ... % EMU size
                ) = ...
                    currentElement + ...
                    signStr + ...
                    coefficientStr + ...
                    fluxLabel + ...
                    sprintf('_%d', rxnIdx);

            end % for iBnList

        end % method visualizeAnBnMatrix

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

            tableTracer = obj.getTableLabelView();
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

        %% Public calcalation methods
        function MDV = calculateMDV(obj, flux, EMU)
            % CALCULATEMDV Calculate MDV from flux and substrate EMU.
            %
            % Parameters
            % ----------
            % flux: (m x 1) double
            %    Flux values
            %    m: The number of reactions in the model
            % EMU: (k x n) double
            %    Substrate EMU
            %    k: The total number of substrate EMUs
            %       k = sum_i (2^numCarbon_i - 1)
            %    n: The maximum number of carbons among substrates
            % Returns
            % -------
            % MDV: (n x 1) double
            %    MDV vector

            MDV = obj.MDVCalculator.calculate( ...
                createCacheSnapshot(obj), flux, EMU);

        end % method calculateMDV

        function MDV = calculateMDVTimeCourse(obj, flux, EMU, poolsize, tspan)
            % CALCULATEMDVTIMECOURSE Calculate MDV time course from flux and substrate EMU.
            %
            % MDV = calculateMDVTimeCourse(obj, flux, EMU, poolsize, tspan, MDV0)
            %
            % Parameters
            % ----------
            % flux: (m x 1) double
            %    Flux values
            %    m: The number of reactions in the model
            % EMU: (k x n) double
            %    Substrate EMU
            %    k: The total number of substrate EMUs
            %       k = sum_i (2^numCarbon_i - 1)
            %    n: The maximum number of carbons among substrates
            % poolsize: (p x 1) double
            %    Pool size values
            %    p: The number of metabolites in the model
            % tspan: (q x 1) double
            %    Time span for simulation
            %
            % Returns
            % -------
            % MDV: (length(tspan) x s) double
            %    MDV time course

            [t, XnTimeCourse] = ode15s( ...
                @(t, Xn) calculatedXdT(obj, t, Xn, flux, EMU, poolsize), ...
                tspan, ...
                obj.globalXn(:) ...
            );

            numTimePoint = length(t);
            Xn = reshape(XnTimeCourse, [numTimePoint, size(obj.globalXn, 1), size(obj.globalXn, 2), size(obj.globalXn, 3)]);
            MDV = zeros(numTimePoint, obj.globalMDVSize);

            for iMDVList = 1:size(obj.globalMDVList, 1)

                sizeIdx = obj.tableEMUSizeInfo.EMUSize == obj.globalMDVList(iMDVList, 1);

                % Convolution
                if obj.globalMDVList(iMDVList, 2) == 0

                    iMDV = ...
                        Xn( ...
                        :, ... % time index
                        obj.globalMDVList(iMDVList, 3), ... % i index
                        1:obj.globalMDVList(iMDVList, 1) + 1, ... % j index
                        sizeIdx ... % EMU size index
                    );

                    MDV( ...
                        :, ... % time index
                        obj.globalMDVList(iMDVList, 4): ...
                        obj.globalMDVList(iMDVList, 4) + obj.globalMDVList(iMDVList, 1) ... % j index
                    ) = ...
                        iMDV(:, 1:obj.globalMDVList(iMDVList, 1) + 1);

                else

                    currentMDV = ...
                        MDV( ...
                        :, ... % time index
                        obj.globalMDVList(iMDVList, 4): ...
                        obj.globalMDVList(iMDVList, 4) + obj.globalMDVList(iMDVList, 5) ... % j index
                    );

                    iMDV = conv( ...
                        Xn( ...
                        :, ... % time index
                        obj.globalMDVList(iMDVList, 3), ... % i index
                        1:obj.globalMDVList(iMDVList, 1) + 1, ... % j index
                        sizeIdx ... % EMU size index
                    )', ...
                        currentMDV ...
                    );

                    MDV( ...
                        :, ... % time index
                        obj.globalMDVList(iMDVList, 4): ...
                        obj.globalMDVList(iMDVList, 4) + obj.globalMDVList(iMDVList, 5) ... % j index
                    ) = ...
                        iMDV(:, 1:obj.globalMDVList(iMDVList, 5) + 1);

                end % if obj.globalMDVList(iMDVList,4)==0

            end % for iMDVList

            MDV = MDV';

        end % method calculateMDVTimeCourse

        function dXdT = calculatedXdT(obj, ~, Xn, flux, EMU, poolsize)
            % CALCULATEMDVTIMECOURSE Calculate MDV time course from flux and substrate EMU.
            %
            % MDV = calculateMDVTimeCourse(obj, flux, EMU, t0, tspan, poolsize)
            %
            % Parameters
            % ----------
            % flux: (m x 1) double
            %    Flux values
            %    m: The number of reactions in the model
            % EMU: (k x n) double
            %    Substrate EMU
            %    k: The total number of substrate EMUs
            %       k = sum_i (2^numCarbon_i - 1)
            %    n: The maximum number of carbons among substrates
            % t0: (n x 1) double
            %    Initial MDV values
            % tspan: (p x 1) double
            %    Time span for simulation

            ensureCnMatrixAvailable(obj);
            snapshot = createCacheSnapshot(obj);
            numEMUSizeRows = height(snapshot.TableEMUSizeInfo);

            Xn = reshape(Xn, size(snapshot.GlobalXn));

            [An, Bn] = obj.MDVCalculator.substituteAnBn( ...
                snapshot, flux);
            [~, Yn] = obj.MDVCalculator.substituteXnYn( ...
                snapshot, EMU, An, Bn, Xn);
            Cn = obj.MDVCalculator.substituteCn(snapshot, poolsize);
            dXdT = zeros(size(Xn));

            for iEMUSizeRow = 1:numEMUSizeRows

                currentEMUSize = ...
                    snapshot.TableEMUSizeInfo.EMUSize(iEMUSizeRow);
                Ann = snapshot.TableEMUSizeInfo.An(iEMUSizeRow);
                Bnn = snapshot.TableEMUSizeInfo.Bn(iEMUSizeRow);
                iAn = An(1:Ann, 1:Ann, currentEMUSize);
                iBn = Bn(1:Ann, 1:Bnn, currentEMUSize);
                iCn = diag(Cn(1:Ann, currentEMUSize));
                iXn = Xn(1:Ann, 1:currentEMUSize + 1, currentEMUSize);
                iYn = Yn(1:Bnn, 1:currentEMUSize + 1, currentEMUSize);

                dXdT(1:Ann, 1:currentEMUSize + 1, currentEMUSize) = ...
                    iCn * (iAn * iXn - iBn * iYn);

            end % for iEMUSizeRow

            dXdT = dXdT(:);

        end % method calculateMDVTimeCourse

        function [An, Bn] = substituteAnBnMatrix(obj, flux)
            % SUBSTITUTEANBNMATRIX Substitute flux values into the An and Bn matrices.
            %
            % Parameters
            % ----------
            % flux: (m x 1) double
            %    Flux values
            %    m: The number of reactions in the model
            %
            % Returns
            % -------
            % An: (s * n * n) double
            %    Substituted An matrix
            % Bn: (s * n * n) double
            %    Substituted Bn matrix

            [An, Bn] = obj.MDVCalculator.substituteAnBn( ...
                createCacheSnapshot(obj), flux);

        end % method substituteAnBnMatrix

        function Cn = substituteCnMatrix(obj, poolsize)
            % SUBSTITUTEXCNMATRIX Substitute pool size values into the Cn matrix.
            %
            % Parameters
            % ----------
            % poolsize: (m x 1) double
            %    Pool size values
            %    m: The number of metabolites in the model
            %
            % Returns
            % -------
            % Cn: (s * n * n) double
            %    Substituted Cn matrix

            ensureCnMatrixAvailable(obj);
            Cn = obj.MDVCalculator.substituteCn( ...
                createCacheSnapshot(obj), poolsize);

        end % method substituteXCnMatrix

        function [Xn, Yn] = substituteXnYnMatrix(obj, EMU, An, Bn, Xn)
            % SUBSTITUTEXNYNMATRIX Substitute flux values into the Xn and Yn matrices.
            %
            % Parameters
            % ----------
            % EMU: (k x n) double
            %    Substrate EMU
            %    k: The total number of substrate EMUs
            %       k = sum_i (2^numCarbon_i - 1)
            %    n: The maximum number of carbons among substrates
            %
            % Returns
            % -------
            % Xn: (s * n * i + 1) double
            %    Substituted Xn matrix
            % Yn: (s * n * i + 1) double
            %    Substituted Yn matrix
            % s: The number of EMU sizes
            % n: The matrix size of An
            % i: The number of carbons in the EMU

            snapshot = createCacheSnapshot(obj);

            if nargin < 5
                [Xn, Yn] = obj.MDVCalculator.substituteXnYn( ...
                    snapshot, EMU, An, Bn);
            else
                [Xn, Yn] = obj.MDVCalculator.substituteXnYn( ...
                    snapshot, EMU, An, Bn, Xn);
            end

        end % method substituteXnYnMatrix

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

    end % methods (Access = public)

    methods (Access = private)

        function operations = createBuildOperations(obj)

            operations = openmebius.mfa.EMUNetworkBuildOperations( ...
                Initialize = @() initializeEMUModel(obj), ...
                Enumerate = @() listupAllEMU(obj), ...
                Validate = @() assertEMUConstructionSucceeded(obj), ...
                ResolveSizeInfo = @() getEMUSizeInformation(obj), ...
                AssignSizeInfo = @(value) assignEMUSizeInfo(obj, value), ...
                BuildAnBn = @() buildAnBnMatrix(obj), ...
                BuildCn = @() buildCnMatrix(obj), ...
                BuildXnYn = @() buildXnYnMatrix(obj), ...
                BuildMDV = @() buildMDVVector(obj), ...
                CreateSnapshot = @() createCacheSnapshot(obj));

        end % createBuildOperations

        function assignEMUSizeInfo(obj, sizeInfo)

            obj.tableEMUSizeInfo = sizeInfo;

        end % assignEMUSizeInfo

        function assertEMUConstructionSucceeded(obj)

            throwIfConstructionFailed( ...
                obj, ...
                "OpenMebius2:ModelRepository:" + ...
                "EMUConstructionFailed", ...
                "Failed to construct the EMU network.");

        end % assertEMUConstructionSucceeded

        function listupAllEMU(obj)
            % LISTUPALLEMU: List up all EMUs from the model.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            emitMsg( ...
                obj, ...
                "Listing up all EMUs from the model.", ...
                "Info", ...
                obj.logLevel);
            source = openmebius.mfa.EMUNetworkSource( ...
                MSReactions = obj.getMSRxnTable(), ...
                MSTransitions = obj.getMSTransTable(), ...
                Reactions = obj.getModelRxnRev(), ...
                Transitions = obj.getModelTransRev(), ...
                Metabolites = obj.getMetaboliteTable());
            result = obj.NetworkEnumerator.enumerate(source);

            for message = result.ErrorMessages'
                emitMsg(obj, message, "Error", obj.logLevel);
            end

            if ~result.IsValid
                recordValidationError( ...
                    obj, ...
                    "The EMU network contains invalid MS reactions.");
                return;
            end

            obj.tableEMU = result.TableEMU;
            obj.tableEMUReaction = result.TableEMUReaction;
            obj.searchedProduct = result.SearchedProducts;

        end % method listupAllEMU

        function emuInfo = getEMUSizeInformation(obj)
            % GETEMUSIZEINFORMATION: Get EMU size information.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % emuInfo: table
            %    Table containing EMU size information

            emu = obj.tableEMUReaction(obj.tableEMUReaction.Target == false, :);
            maxSize = max(emu.Size);

            if isempty(maxSize)
                maxSize = 0;
            end

            emuInfo = table('Size', [maxSize 3], ...
                'VariableNames', {'EMUSize', 'An', 'Bn'}, ...
                'VariableTypes', {'double', 'double', 'double'});
            emuInfo.Properties.Description = 'EMU size information';

            if maxSize == 0
                return
            end

            for currentSize = maxSize:-1:1

                emuOfCurrentSize = emu(emu.Size == currentSize, :);

                if isempty(emuOfCurrentSize)
                    emuInfo.EMUSize(currentSize) = currentSize;
                    emuInfo.An(currentSize) = 0;
                    emuInfo.Bn(currentSize) = 0;
                    continue;
                end % if isempty(emuOfCurrentSize)

                EMUReactantProducts = vertcat(emuOfCurrentSize.Reactants, emuOfCurrentSize.Products);
                emuReactantUnique = openmebius.mfa.EMUMatrixBuilder ...
                    .uniqueEMUGroups(EMUReactantProducts);

                isSubstrate = false(length(emuReactantUnique), 1);

                for j = 1:length(emuReactantUnique)

                    if length(emuReactantUnique{j}) > 1
                        isSubstrate(j) = true;
                    end % if length(emuReactantUnique{j})>1

                    tmpEMU = emuReactantUnique{j}{1};
                    tmpMetabolite = obj.tableEMU.Metabolite( ...
                        obj.tableEMU.EMU == tmpEMU);

                    if obj.isSubstrateMetabolite(tmpMetabolite)
                        isSubstrate(j) = true;
                    end % if isSubstrate(j)

                    if isSubstrate(j)
                        emuInfo.Bn(currentSize) = emuInfo.Bn(currentSize) + 1;
                    else
                        emuInfo.An(currentSize) = emuInfo.An(currentSize) + 1;
                    end % if isSubstrate(j)

                end % for j=1:length(emuReactantUnique)

                emuInfo.EMUSize(currentSize) = currentSize;

            end % for currentSize=1:length(uniqueSizes)

            emuInfo = sortrows(emuInfo, 'EMUSize', 'ascend');

        end % method getEMUSizeInformation


        %% Private matrix methods
        function buildAnBnMatrix(obj)
            % BUILDANBNMATRIX: Build the global An and Bn matrices.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            emitMsg( ...
                obj, ...
                "List up A and B EMUs for each EMU size.", ...
                "Info", ...
                obj.logLevel);
            modelReactions = obj.getModelRxnRev();
            result = obj.MatrixBuilder.buildAnBn( ...
                obj.tableEMUSizeInfo, ...
                obj.tableEMU, ...
                obj.tableEMUReaction, ...
                obj.getMetaboliteTableSubstrate(), ...
                string(modelReactions.Properties.RowNames));
            obj.globalAn = result.An;
            obj.globalBn = result.Bn;
            obj.globalAnEMUName = result.AnNames;
            obj.globalAnEMUNameMetabolite = result.AnMetabolites;
            obj.globalBnEMUName = result.BnNames;
            obj.globalBnEMUNameMetabolite = result.BnMetabolites;
            obj.globalAnList = result.AnList;
            obj.globalBnList = result.BnList;

        end % method buildAnBnMatrix

        function buildCnMatrix(obj)
            % BUILDCNMATRIX: Build the global Cn matrix.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            result = obj.MatrixBuilder.buildCn( ...
                obj.tableEMUSizeInfo, ...
                obj.globalAnEMUNameMetabolite, ...
                obj.getMetaboliteTableMetabolite());
            obj.globalCn = result.Matrix;
            obj.globalCnDiag = result.Diagonal;

        end % method buildCnMatrix

        function buildXnYnMatrix(obj)
            % BUILDXYNMATRIX: Build the global Xn and Yn matrices.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            result = obj.MatrixBuilder.buildXnYn( ...
                obj.tableEMUSizeInfo, ...
                obj.tableEMU, ...
                obj.globalAnEMUName, ...
                obj.globalBnEMUName, ...
                obj.getMetaboliteTable());
            obj.globalXn = result.Xn;
            obj.globalYn = result.Yn;
            obj.globalXnList = result.XnList;
            obj.globalYnList = result.YnList;

            if ~result.HasSubstrates
                disp("No substrate metabolites found.");
            end

        end % method buildXnYnMatrix

        function buildMDVVector(obj)
            % BUILDMDVVECTOR: Build the MDV vector.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            result = obj.MatrixBuilder.buildMDV( ...
                obj.tableEMU, ...
                obj.tableEMUReaction, ...
                obj.globalAnEMUName, ...
                obj.tableEMUSizeInfo);
            obj.globalMDVInfo = result.Info;
            obj.globalMDVSize = result.Size;
            obj.globalMDVList = result.List;

        end % method buildMDVVector

        %% Private utility methods
        function tf = saveEMUModelToFile(obj)
            % SAVEMODEL Save the model cache and source-file hash.
            %
            % File locations and source-hash validation are owned by the
            % cache repository.

            tf = false;

            try
                snapshot = createCacheSnapshot(obj);
                obj.CacheRepository.save( ...
                    obj.getModelLocation(), ...
                    obj.fileModel, ...
                    obj.fileTypeModel, ...
                    snapshot);
                tf = true;
            catch ME
                msg = "Failed to save the EMU cache: " + ME.message;
                emitMsg(obj, msg, "Error", obj.logLevel);
            end % try-catch

        end % saveEMUModelToFile

        function tf = loadEMUModelFromFile(obj)
            % LOADEMUMODELFROMFILE Restore a current EMU network snapshot.

            try
                [snapshot, tf] = obj.CacheRepository.load( ...
                    obj.getModelLocation(), ...
                    obj.fileModel, ...
                    obj.fileTypeModel);

                if tf
                    applyCacheSnapshot(obj, snapshot);
                    ensureCnMatrixAvailable(obj);
                end

            catch ME
                tf = false;
                msg = "Failed to load the EMU cache: " + ME.message;
                emitMsg(obj, msg, "Error", obj.logLevel);
            end % try-catch

        end % loadEMUModelFromFile

        function snapshot = createCacheSnapshot(obj)

            payload = struct( ...
                "tableEMU", obj.tableEMU, ...
                "tableEMUReaction", obj.tableEMUReaction, ...
                "tableEMUSizeInfo", obj.tableEMUSizeInfo, ...
                "searchedProduct", {obj.searchedProduct}, ...
                "globalAn", obj.globalAn, ...
                "globalAnEMUName", {obj.globalAnEMUName}, ...
                "globalAnEMUNameMetabolite", ...
                    {obj.globalAnEMUNameMetabolite}, ...
                "globalAnList", obj.globalAnList, ...
                "globalBn", obj.globalBn, ...
                "globalBnEMUName", {obj.globalBnEMUName}, ...
                "globalBnEMUNameMetabolite", ...
                    {obj.globalBnEMUNameMetabolite}, ...
                "globalBnList", obj.globalBnList, ...
                "globalCn", obj.globalCn, ...
                "globalCnDiag", obj.globalCnDiag, ...
                "globalXn", obj.globalXn, ...
                "globalXnList", obj.globalXnList, ...
                "globalYn", obj.globalYn, ...
                "globalYnList", obj.globalYnList, ...
                "globalMDVInfo", obj.globalMDVInfo, ...
                "globalMDVList", obj.globalMDVList, ...
                "globalMDVSize", obj.globalMDVSize);

            snapshot = openmebius.domain.model.EMUNetworkSnapshot(payload);

        end % createCacheSnapshot

        function applyCacheSnapshot(obj, snapshot)

            obj.tableEMU = snapshot.TableEMU;
            obj.tableEMUReaction = snapshot.TableEMUReaction;
            obj.tableEMUSizeInfo = snapshot.TableEMUSizeInfo;
            obj.searchedProduct = snapshot.SearchedProduct;
            obj.globalAn = snapshot.GlobalAn;
            obj.globalAnEMUName = snapshot.GlobalAnEMUName;
            obj.globalAnEMUNameMetabolite = ...
                snapshot.GlobalAnEMUNameMetabolite;
            obj.globalAnList = snapshot.GlobalAnList;
            obj.globalBn = snapshot.GlobalBn;
            obj.globalBnEMUName = snapshot.GlobalBnEMUName;
            obj.globalBnEMUNameMetabolite = ...
                snapshot.GlobalBnEMUNameMetabolite;
            obj.globalBnList = snapshot.GlobalBnList;
            obj.globalCn = snapshot.GlobalCn;
            obj.globalCnDiag = snapshot.GlobalCnDiag;
            obj.globalXn = snapshot.GlobalXn;
            obj.globalXnList = snapshot.GlobalXnList;
            obj.globalYn = snapshot.GlobalYn;
            obj.globalYnList = snapshot.GlobalYnList;
            obj.globalMDVInfo = snapshot.GlobalMDVInfo;
            obj.globalMDVList = snapshot.GlobalMDVList;
            obj.globalMDVSize = snapshot.GlobalMDVSize;

        end % applyCacheSnapshot

        function ensureCnMatrixAvailable(obj)
            % ENSURECNMATRIXAVAILABLE Build Cn matrices when absent from an old cache.

            if isCnMatrixConsistent(obj)
                return
            end % if

            buildCnMatrix(obj);

            if ~isCnMatrixConsistent(obj)
                error( ...
                    'EMUModel:InvalidCnMatrix', ...
                    'Failed to build a valid Cn matrix for INST-MFA.' ...
                );
            end % if

        end % ensureCnMatrixAvailable

        function tf = isCnMatrixConsistent(obj)
            % ISCNMATRIXCONSISTENT Validate the cached Cn matrix dimensions.

            tf = false;

            try

                if isempty(obj.tableEMUSizeInfo) || isempty(obj.globalAnEMUNameMetabolite)
                    return
                end % if

                info = obj.tableEMUSizeInfo;

                if isempty(info) || height(info) == 0
                    return
                end % if

                maxEMUSize = max(info.EMUSize);
                maxAn = max(info.An);
                numMetabolite = numel(obj.getMetaboliteTableMetabolite());

                tf = ...
                    ~isempty(obj.globalCn) && ...
                    ~isempty(obj.globalCnDiag) && ...
                    ~ismatrix(obj.globalCn) && ...
                    size(obj.globalCn, 1) >= maxAn && ...
                    size(obj.globalCn, 2) == numMetabolite && ...
                    size(obj.globalCn, 3) >= maxEMUSize && ...
                    size(obj.globalCnDiag, 1) >= maxAn && ...
                    size(obj.globalCnDiag, 2) >= maxEMUSize;
            catch
                tf = false;
            end % try-catch

        end % isCnMatrixConsistent

    end % methods (Access = private)

    %% Protected methods
    methods (Access = protected)

        function emitMsg(obj, msg, level, varargin)
            % 既存呼び出し互換のメッセージ通知ヘルパー
            % level: "Info" | "Warning" | "Error" | "Debug"
            if nargin < 3 || strlength(string(level)) == 0
                level = "Info";
            end

            evt = MsgEventData(msg, level, "EMUModel");
            notify(obj, 'generalMsg', evt);
        end % method updateMsg

    end % methods (Access = protected)

end % classdef EMUModel
