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

        charList = ['A':'Z' 'a':'z'];

    end % properties (Access = private)

    methods

        function obj = EMUModel(modelInput, varargin)
            % EMUMODEL: Constructor for the EMUModel class.
            %
            % Parameters:
            % -----------
            % modelInput
            %     File directory or openmebius.domain.model.ModelLocation.

            obj = obj@Stoichiometry(modelInput, varargin{:});

            if ~obj.isUpdatedModel

                isSucceeded = obj.loadEMUModelFromFile();

                if ~isSucceeded
                    isConstructed = constructEMUNetwork(obj);
                else
                    isConstructed = false;
                end % if

            else

                isConstructed = constructEMUNetwork(obj);

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

            initializeEMUModel(obj);

            listupAllEMU(obj);
            throwIfConstructionFailed( ...
                obj, ...
                "OpenMebius2:ModelRepository:" + ...
                "EMUConstructionFailed", ...
                "Failed to construct the EMU network.");
            EMUSizeTable = obj.getEMUSizeInformation();
            obj.tableEMUSizeInfo = EMUSizeTable;
            obj.buildAnBnMatrix();
            obj.buildCnMatrix();
            obj.buildXnYnMatrix();
            obj.buildMDVVector();

            tf = true;

        end % method constructEMUNetwork

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

            MDV = zeros(obj.globalMDVSize, 1);

            [An, Bn] = substituteAnBnMatrix(obj, flux);
            [Xn, ~] = substituteXnYnMatrix(obj, EMU, An, Bn);

            for iMDVList = 1:size(obj.globalMDVList, 1)

                sizeIdx = obj.tableEMUSizeInfo.EMUSize == obj.globalMDVList(iMDVList, 1);

                % Convolution
                if obj.globalMDVList(iMDVList, 2) == 0

                    iMDV = ...
                        Xn( ...
                        obj.globalMDVList(iMDVList, 3), ... % i index
                        1:obj.globalMDVList(iMDVList, 1) + 1, ... % j index
                        sizeIdx ... % EMU size index
                    )';

                    MDV( ...
                        obj.globalMDVList(iMDVList, 4): ...
                        obj.globalMDVList(iMDVList, 4) + obj.globalMDVList(iMDVList, 1) ... % j index
                    ) = ...
                        iMDV(1:obj.globalMDVList(iMDVList, 1) + 1);

                else

                    currentMDV = ...
                        MDV( ...
                        obj.globalMDVList(iMDVList, 4): ...
                        obj.globalMDVList(iMDVList, 4) + obj.globalMDVList(iMDVList, 5) ... % j index
                    );

                    iMDV = conv( ...
                        Xn( ...
                        obj.globalMDVList(iMDVList, 3), ... % i index
                        1:obj.globalMDVList(iMDVList, 1) + 1, ... % j index
                        sizeIdx ... % EMU size index
                    )', ...
                        currentMDV ...
                    );

                    MDV( ...
                        obj.globalMDVList(iMDVList, 4): ...
                        obj.globalMDVList(iMDVList, 4) + obj.globalMDVList(iMDVList, 5) ... % j index
                    ) = ...
                        iMDV(1:obj.globalMDVList(iMDVList, 5) + 1);

                end % if obj.globalMDVList(iMDVList,4)==0

            end % for iMDVList

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

            numEMUSizeRows = size(obj.tableEMUSizeInfo, 1);

            Xn = reshape(Xn, size(obj.globalXn));

            [An, Bn] = substituteAnBnMatrix(obj, flux);
            [~, Yn] = substituteXnYnMatrix(obj, EMU, An, Bn, Xn);
            Cn = substituteCnMatrix(obj, poolsize);
            dXdT = zeros(size(Xn));

            for iEMUSizeRow = 1:numEMUSizeRows

                currentEMUSize = obj.tableEMUSizeInfo.EMUSize(iEMUSizeRow);
                Ann = obj.tableEMUSizeInfo.An(iEMUSizeRow);
                Bnn = obj.tableEMUSizeInfo.Bn(iEMUSizeRow);
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

            An = obj.globalAn;
            Bn = obj.globalBn;

            for iAnList = 1:size(obj.globalAnList, 1)

                rxnIdx = obj.globalAnList(iAnList, 2);
                An( ...
                    obj.globalAnList(iAnList, 3), ... % i index
                    obj.globalAnList(iAnList, 4), ... % j index
                    obj.globalAnList(iAnList, 1) ... % EMU size
                ) = ...
                    An( ...
                    obj.globalAnList(iAnList, 3), ... % i index
                    obj.globalAnList(iAnList, 4), ... % j index
                    obj.globalAnList(iAnList, 1) ... % EMU size
                ) + ...
                    flux(rxnIdx) * obj.globalAnList(iAnList, 5); % flux * coefficient

            end % for iAnList

            for iBnList = 1:size(obj.globalBnList, 1)

                rxnIdx = obj.globalBnList(iBnList, 2);
                Bn( ...
                    obj.globalBnList(iBnList, 3), ... % i index
                    obj.globalBnList(iBnList, 4), ... % j index
                    obj.globalBnList(iBnList, 1) ... % EMU size
                ) = ...
                    Bn( ...
                    obj.globalBnList(iBnList, 3), ... % i index
                    obj.globalBnList(iBnList, 4), ... % j index
                    obj.globalBnList(iBnList, 1) ... % EMU size
                ) + ...
                    flux(rxnIdx) * obj.globalBnList(iBnList, 5); % flux * coefficient

            end % for iBnList

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

            CnBool = obj.globalCn;
            Cn = obj.globalCnDiag;
            numEMUSizeRows = size(obj.tableEMUSizeInfo, 1);
            poolsize = double(poolsize(:));
            numPoolMetabolites = numel(poolsize);
            numCnMetabolites = size(CnBool, 2);

            if numPoolMetabolites ~= numCnMetabolites
                error( ...
                    'EMUModel:PoolSizeDimensionMismatch', ...
                    ['The pool size vector length (%d) does not match the number of ' ...
                     'model metabolites in the EMU Cn matrix (%d). Check the INST-MFA ' ...
                 'pool-size table and rebuild the EMU model cache if necessary.'], ...
                    numPoolMetabolites, ...
                    numCnMetabolites ...
                );
            end % if

            if any(~isfinite(poolsize)) || any(poolsize <= 0)
                error( ...
                    'EMUModel:InvalidPoolSize', ...
                    'INST-MFA pool sizes must be finite positive values.' ...
                );
            end % if

            for iEMUSizeRow = 1:numEMUSizeRows

                currentEMUSize = obj.tableEMUSizeInfo.EMUSize(iEMUSizeRow);

                for jMetabolite = 1:numCnMetabolites

                    CnBoolIdx = ...
                        CnBool(:, jMetabolite, currentEMUSize);
                    Cn(CnBoolIdx, currentEMUSize) = ...
                        1 / poolsize(jMetabolite);

                end % for jMetabolite

            end % for iEMUSizeRow

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

            if nargin < 5
                Xn = obj.globalXn;
            end

            Yn = obj.globalYn;

            for iSelectedSize = 1:height(obj.tableEMUSizeInfo)

                iSelectedYnList = obj.globalYnList( ...
                    obj.globalYnList(:, 1) == iSelectedSize, :);

                % Yn
                for jSelectedYnList = 1:size(iSelectedYnList, 1)

                    if iSelectedYnList(jSelectedYnList, 3) == 0

                        % Substrate EMU
                        if iSelectedYnList(jSelectedYnList, 4) == 1

                            Yn( ...
                                iSelectedYnList(jSelectedYnList, 2), ... % i index
                                1:iSelectedSize + 1, ... % j index
                                iSelectedSize ... % EMU size index
                            ) = ...
                                EMU( ...
                                iSelectedYnList(jSelectedYnList, 5), ... % substrate EMU index
                                1:iSelectedSize + 1 ... % EMU size
                            );

                        else

                            XnIdx = ...
                                obj.tableEMUSizeInfo.EMUSize == ...
                                iSelectedYnList(jSelectedYnList, 5);

                            Yn( ...
                                iSelectedYnList(jSelectedYnList, 2), ... % i index
                                1:iSelectedSize + 1, ... % j index
                                iSelectedSize ... % EMU size index
                            ) = ...
                                Xn( ...
                                iSelectedYnList(jSelectedYnList, 6), ... % i index
                                1:iSelectedSize + 1, ... % j index
                                XnIdx ... % EMU size index
                            );

                        end % if isSelectedYnList(jSelectedYnList,4)==0

                    else

                        % Substrate EMU
                        currentYn = Yn( ...
                            iSelectedYnList(jSelectedYnList, 2), ... % i index
                            1:iSelectedSize + 1, ... % j index
                            iSelectedSize ... % EMU size index
                        );

                        if iSelectedYnList(jSelectedYnList, 4) == 1

                            jConvolution = ...
                                conv( ...
                                EMU( ...
                                iSelectedYnList(jSelectedYnList, 5), ... % substrate EMU index
                                1:iSelectedSize + 1 ... % EMU size
                            ), ...
                                currentYn ...
                            );

                            Yn( ...
                                iSelectedYnList(jSelectedYnList, 2), ... % i index
                                1:iSelectedSize + 1, ... % j index
                                iSelectedSize ... % EMU size index
                            ) = jConvolution(1:iSelectedSize + 1);

                        else

                            XnIdx = ...
                                obj.tableEMUSizeInfo.EMUSize == ...
                                iSelectedYnList(jSelectedYnList, 5);

                            jConvolution = ...
                                conv( ...
                                Xn( ...
                                iSelectedYnList(jSelectedYnList, 6), ... % i index
                                1:iSelectedSize + 1, ... % j index
                                XnIdx ... % EMU size index
                            ), ...
                                currentYn ...
                            );

                            Yn( ...
                                iSelectedYnList(jSelectedYnList, 2), ... % i index
                                1:iSelectedSize + 1, ... % j index
                                iSelectedSize ... % EMU size index
                            ) = jConvolution(1:iSelectedSize + 1);

                        end % if isSelectedYnList(jSelectedYnList,4)==0

                    end % if iSelectedYnList(jSelectedYnList,3)==0

                end % for jSelectedYnList

                Ann = obj.tableEMUSizeInfo.An(iSelectedSize);
                Bnn = obj.tableEMUSizeInfo.Bn(iSelectedSize);

                % Calculate Xn
                lambdaE = 10 ^ -8 * eye(Ann);

                if nargin < 5
                    iXn = ...
                        (lambdaE + An(1:Ann, 1:Ann, iSelectedSize)) \ (Bn(1:Ann, 1:Bnn, iSelectedSize) * Yn(1:Bnn, 1:iSelectedSize + 1, iSelectedSize));

                    Xn(1:Ann, 1:iSelectedSize + 1, iSelectedSize) = iXn;
                end

            end % for iSelectedSize = 1:height(obj.tableEMUSizeInfo)

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

        %% Private initialize methods
        function initialzeEMUModel(obj)
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

        end % method initialzeEMUModel

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

            initialzeEMUModel(obj);

            msg = 'Listing up all EMUs from the model.';
            emitMsg(obj, msg, "Info", obj.logLevel);

            % List up all EMUs
            [~, isError] = listupEMUs(obj);

            if isError
                recordValidationError( ...
                    obj, ...
                    "The EMU network contains invalid MS reactions.");
                return;
            end % if isError

        end % method listupAllEMU

        %% Private get methods
        function emu = getEMULabel(~, metabolite, position)
            % GETEMULABEL: Get the EMU label.
            %
            % Parameters
            % ----------
            % metabolite: string
            %    Metabolite name
            % position: array
            %    Position of the atoms in the metabolite
            %
            % Returns
            % -------
            % emu: string
            %    EMU label

            if isempty(metabolite) || isempty(position)
                emu = "";
                return;
            end % if

            % Replace underscores with hyphens in metabolite name
            metName = strrep(metabolite, '_', '-');
            posStr = strjoin(string(position), '');

            emu = sprintf('%s_{%s}', metName, posStr);

        end % method getEMULabel

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
                emuReactantUnique = getUniqueEMUName(obj, EMUReactantProducts);

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

        function enuOut = getUniqueEMUName(~, emu)
            % GETUNIQUEEMUNAME: Get a unique EMU name by replacing underscores with hyphens.
            %
            % Parameters
            % ----------
            % emu: cell
            %    EMU name
            %
            % Returns
            % -------
            % emu: cell
            %    Unique EMU name

            numEMU = length(emu);

            enuOut = cell(0);

            for i = 1:numEMU

                currentEMU = emu{i};

                % Get current listed EMU
                tmpEMU = enuOut;
                isListed = false;

                for j = 1:length(tmpEMU)

                    if length(currentEMU) ~= length(tmpEMU{j})
                        continue;
                    end % if length(currentEMU)~=length(tmpEMU{j})

                    for k = 1:length(currentEMU)

                        if strcmp(currentEMU{k}, tmpEMU{j}{k})
                            isListed = true;
                        else
                            isListed = false;
                            break;
                        end % if strcmp(currentEMU{k}, tmpEMU{j}{k})

                    end % for k=1:length(currentEMU)

                    if isListed
                        break;
                    end % if isListed

                end % for j=1:length(currentEMU)

                if ~isListed
                    enuOut{end + 1} = currentEMU; %#ok<AGROW>
                end % if ~isListed

            end % for i=1:numEMU

        end % method getUniqueEMUName

        function pos = getAtomPosition(~, reactant, product)
            % GETATOMPOSITION: Get the atom position from the reactant to the product.
            %
            % Parameters
            % ----------
            % reactant: string
            %    Reactant atom string example: 'ABC'
            % product: string
            %    Product atom string example: 'AC'
            %
            % Returns
            % -------
            % pos: array
            %    Position of the atoms in the reactant corresponding to the product
            %    Example:
            %        reactant = 'ABC'
            %        product = 'AC'
            %        pos = [1 3]
            %        >> getAtomPosition('ABC', 'AC')
            %        ans =
            %             1     3
            %        >> getAtomPosition('ABC', 'CDE')
            %        ans =
            %             3
            %        >> getAtomPosition('ABC', 'DEF')
            %        ans =
            %             []
            %        >> getAtomPosition('ABCD', 'ABC')
            %        ans =
            %             1     2     3

            pos = [];

            if isempty(reactant) || isempty(product)
                return;
            end % if

            for i = 1:strlength(product)
                idx = strfind(reactant, product(i));

                if isempty(idx)
                    continue;
                end % if

                pos = [pos idx]; %#ok<AGROW>
            end % for i=1:strlength(product)

        end % method getAtomPosition

        function idx = getSubstrateEMUPosition(~, pattern)
            % GETSUBSTRATEEMUPOSITION: Get the position of the substrate EMU.
            %
            % Parameters
            % ----------
            % pattern: array
            %    Label pattern
            %    ex: [0 1 0 0 1 0]
            %
            % Returns
            % -------
            % idx: array
            %    Position of the substrate EMU

            if isempty(pattern)
                idx = [];
                return;
            end % if

            strPattern = num2str(pattern, '%d');
            idx = bin2dec(strPattern);

        end % method getSubstrateEMUPosition

        %% Private search methods
        function [EMUs, isError] = listupEMUs(obj)
            % LISTUPEMUS: List up all EMUs from the model.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % EMUs: table
            %    Table containing all EMUs

            EMUs = table();
            isError = false;

            MSRxn = getMSRxnTable(obj);

            errorRows = false(height(MSRxn), 1);

            % Check if the MSRxn table is more than 1 row
            for i = 1:height(MSRxn)

                if size(MSRxn.Products{i}, 2) > 1 || ~strcmp(MSRxn.Products{i}{1}, MSRxn.Properties.RowNames{i})
                    errorRows(i) = true;
                    msg = sprintf('EMUModel: More than one product or no reactant.');
                    emitMsg(obj, msg, "Error", obj.logLevel);
                    continue;
                end % if

            end % for i=1:height(MSRxn)

            if any(errorRows)
                isError = true;
                return;
            end % if any(errorRows)

            listupTargetEMUs(obj);
            listupIntermediateEMUs(obj);

            % Sort
            obj.tableEMU = ...
                sortrows(obj.tableEMU, {'Size', 'Metabolite', 'EMU'}, {'descend', 'ascend', 'ascend'});
            EMUs = obj.tableEMU;
            obj.tableEMUReaction = ...
                sortrows(obj.tableEMUReaction, {'Size', 'RxnID'}, {'descend', 'ascend'});

        end % method listupEMUs

        function listupTargetEMUs(obj)
            % LISTUPTARGETEMUS: List up target EMUs from the model.
            %
            % Parameters
            % ----------
            % isIncludeAllMetabolites: bool, optional
            %    If true, include all metabolites as target EMUs. Default is false.
            %
            % Returns
            % -------
            % None

            MSRxn = getMSRxnTable(obj);
            MSTrans = getMSTransTable(obj);

            for i = 1:height(MSTrans)

                % 'Ala57'
                targetMetabolite = MSRxn.Products{i}{1};
                % 'ABC'
                targetAtomString = MSTrans.Products{i}{1};
                % 3
                targetNumAtoms = strlength(targetAtomString);
                % [1 2 3]
                targetPosition = 1:targetNumAtoms;
                % 'BC' --> 'AB'
                targetArrangedAtomString = obj.charList(1:targetNumAtoms);
                % Ala57_{ABC}
                targetEMU = getEMULabel(obj, targetMetabolite, targetArrangedAtomString);

                products = {targetEMU};
                reactants = {};

                if strlength(targetAtomString) == 0
                    continue;
                end % if strlength(targetAtomString)==0

                addEMUToList( ...
                    obj, targetEMU, targetMetabolite, targetPosition, targetNumAtoms, true);

                for j = 1:numel(MSTrans.Reactants{i})

                    reactantMetabolite = MSRxn.Reactants{i}{j};
                    reactantAtomString = MSTrans.Reactants{i}{j};
                    reactantNumAtoms = strlength(reactantAtomString);
                    reactantPosition = getAtomPosition(obj, reactantAtomString, targetAtomString);
                    reactantArrangedAtomString = obj.charList(1:reactantNumAtoms);
                    reactantPositionArranged = reactantArrangedAtomString(reactantPosition);
                    reactantEMU = getEMULabel(obj, reactantMetabolite, reactantPositionArranged);

                    if strlength(reactantAtomString) == 0 || isempty(reactantPosition)
                        continue;
                    end % if strlength(reactantAtomString)==0 || isempty(reactantPosition)

                    reactants{end + 1} = reactantEMU; %#ok<AGROW>
                    addEMUToList( ...
                        obj, reactantEMU, reactantMetabolite, reactantPosition, numel(reactantPosition), false);

                end % for j=1:numel(MSTrans.Reactants{i})

                addEMUReactionToList( ...
                    obj, MSRxn.Properties.RowNames{i}, reactants, products, 1, targetNumAtoms, true);

            end % for i=1:height(MSTrans)

        end % method listupTargetEMUs

        function listupIntermediateEMUs(obj)
            % LISTUPINTERMEDIATEEMUS: List up intermediate EMUs from the model.
            %
            % Parameters
            % ----------
            % None
            %
            % Returns
            % -------
            % None

            % Get the EMU reactions already listed
            existingEMUReactions = obj.tableEMUReaction;
            obj.searchedProduct = existingEMUReactions.Products;

            for iRxn = 1:height(existingEMUReactions)

                for jReactant = 1:length(existingEMUReactions.Reactants{iRxn})

                    if obj.isSearchedProduct( ...
                            existingEMUReactions.Reactants{iRxn}{jReactant})
                        continue;
                    end % if obj.isSearchedProduct(

                    iReactant = existingEMUReactions.Reactants{iRxn}{jReactant};
                    EMUrow = obj.tableEMU( ...
                        obj.tableEMU.EMU == iReactant, :);
                    searchEMU(obj, iReactant, false, EMUrow);

                end % for j=1:length(existingEMUReactions.Reactants{iRxn})

            end % for i=1:height(existingEMUReactions)

        end % method listupIntermediateEMUs

        function isSearched = isSearchedProduct(obj, productEMU)
            % ISSEARCHEDPRODUCT: Check if the product EMU has already been searched.
            %
            % Parameters
            % ----------
            % productEMU: cell
            %    Product EMU
            %
            % Returns
            % -------
            % None

            isSearched = false;

            for i = 1:length(obj.searchedProduct)

                iEMU = obj.searchedProduct{i};

                if isequal(iEMU, productEMU)
                    isSearched = true;
                    break;
                end % if isequal(iEMU, productEMU)

            end % for i=1:length(obj.searchedProduct)

            if ~isSearched
                obj.searchedProduct{end + 1} = productEMU;
            end % if ~isSearched

        end % method isSearchedProduct

        function searchEMU(obj, emuName, continueFlag, tableEMU)
            % SEARCHEMU: Search for an EMU from the EMU reaction table recursively.
            %
            % Parameters
            % ----------
            % emuName: string
            %    EMU name
            % continueFlag: bool, optional
            %    If true, continue searching for EMUs recursively.

            % If the EMU already exists, return
            isSearched = obj.tableEMU.EMU == emuName;

            if any(isSearched) && continueFlag
                return;
            end % if any(obj.tableEMU.EMU == emuName)

            metabolite = tableEMU.Metabolite( ...
                tableEMU.EMU == emuName);
            position = tableEMU.Position{tableEMU.EMU == emuName};

            % Add the EMU to the list
            obj.addEMUToList( ...
                emuName, metabolite, position, length(position), false);

            % If the metabolite is a substrate, return
            if isSubstrateMetabolite(obj, metabolite)
                return;
            end % if isSubstrateMetabolite(obj, metabolite)

            % Get reactions involving the metabolite as a product
            idx = findReaction(obj, metabolite, true);
            rxn = getModelRxnRev(obj, idx);
            trans = getModelTransRev(obj, idx);

            % Each reaction
            for i = 1:height(rxn)

                % Each product in the reaction
                for j = 1:length(trans.Products{i})

                    coefficient = 1;

                    if isSymmetricMetabolite(obj, rxn.Products{i}{j})
                        coefficient = coefficient / 2;
                    end % if isSymmetricMetabolite(obj, rxn.Products{i}{j})

                    % If the product metabolite is not the target metabolite, continue
                    if ~strcmp(metabolite, string(rxn.Products{i}{j}))
                        continue
                    end % if ~strcmp(metabolite, rxn.Products{i}{j})

                    productAtomString = trans.Products{i}{j};
                    % Extract the atom position corresponding to the target EMU
                    productAtomString = productAtomString(position);
                    [tableEMU, ~] = parseEMUReaction( ...
                        obj, ...
                        emuName, ...
                        productAtomString, ...
                        rxn(i, :), ...
                        trans(i, :), ...
                        coefficient ...
                    );

                    for k = 1:height(tableEMU)

                        % Recursive search for the reactant EMUs
                        searchEMU(obj, tableEMU.EMU{k}, true, tableEMU);

                    end % for k=1:height(tableEMU)

                    if isSymmetricMetabolite(obj, rxn.Products{i}{j})

                        % For symmetric metabolites, search for the other symmetric EMU
                        % position = [2 3 4], numAtoms = 4 --> symPosition = [3 2 1]
                        % position = [1 3], numAtoms = 4 --> symPosition = [4 2]
                        % position = [1 2 3], numAtoms = 4 --> symPosition = [4 3 2]
                        numAtoms = strlength(trans.Products{i}{j});
                        positionLogical = false(1, numAtoms);
                        positionLogical(position) = true;
                        symPositionLogical = flip(positionLogical);
                        symProductAtomString = trans.Products{i}{j}(symPositionLogical);
                        symTableEMU = parseEMUReaction( ...
                            obj, ...
                            emuName, ...
                            symProductAtomString, ...
                            rxn(i, :), ...
                            trans(i, :), ...
                            coefficient ...
                        );

                        for k = 1:height(symTableEMU)

                            % Recursive search for the reactant EMUs
                            searchEMU(obj, symTableEMU.EMU{k}, true, symTableEMU);

                        end % for k=1:height(symTableEMU)

                    end % if isSymmetricMetabolite(obj, rxn.Products{i}{j})

                end % for j=1:length(trans.Products{i})

            end % for i=1:length(rxn)

        end % method searchEMU

        function [tableEMU, tableEMURxn] = parseEMUReaction( ...
                obj, ...
                EMUname, ...
                productAtomString, ...
                rxn, ...
                trans, ...
                coefficient ...
            )
            % PARSEEMUREACTION: Parse an EMU reaction from the model.
            %
            % Parameters
            % ----------
            % EMUname: string
            %    EMU name
            % rxn: table
            %    Reaction table
            % trans
            %    Transformation table
            %
            % Returns
            % -------
            % None

            sizeEMU = strlength(productAtomString);

            tableEMU = table('Size', [0 5], ...
                'VariableNames', {'EMU', 'Metabolite', 'Position', 'Size', 'Target'}, ...
                'VariableTypes', {'string', 'string', 'cell', 'double', 'logical'});
            tableEMU.Properties.Description = 'EMU table';
            tableEMURxn = table('Size', [0 6], ...
                'VariableNames', {'RxnID', 'Reactants', 'Products', 'Coefficient', 'Size', 'Target'}, ...
                'VariableTypes', {'string', 'cell', 'cell', 'double', 'double', 'logical'});
            tableEMURxn.Properties.Description = 'EMU reaction table';

            numReactants = length(trans.Reactants{1});
            reactantEMU = {};
            reactantNumAtoms = [];

            for i = 1:numReactants

                iReactantAtomString = trans.Reactants{1}{i};
                iReactantMetabolite = rxn.Reactants{1}{i};
                iPosition = getAtomPosition(obj, iReactantAtomString, productAtomString);

                if isempty(iPosition)
                    continue;
                end % if isempty(iPosition)

                % Flip the position if the reactant metabolite is symmetric
                if isSymmetricMetabolite(obj, iReactantMetabolite)
                    numAtoms = strlength(iReactantAtomString);
                    positionLogical = false(1, numAtoms);
                    positionLogical(iPosition) = true;
                    symPositionLogical = flip(positionLogical);

                    if find(positionLogical) >= find(symPositionLogical)
                        iPosition = find(symPositionLogical);
                    end % if find(positionLpogical) >= find(symPositionLogical)

                end % if isSymmetricMetabolite(obj, iReactantMetabolite)

                iReactantLabel = obj.charList(sort(iPosition));
                iReactantEMU = getEMULabel(obj, iReactantMetabolite, iReactantLabel);

                reactantEMU = [reactantEMU, iReactantEMU]; %#ok<AGROW>
                reactantNumAtoms = [reactantNumAtoms, numel(iPosition)]; %#ok<AGROW>
                tableEMU = [tableEMU; ...
                                {iReactantEMU, iReactantMetabolite, iPosition, numel(iPosition), false}]; %#ok<AGROW>

            end % for i=1:numReactants

            addEMUReactionToList( ...
                obj, rxn.Properties.RowNames{1}, reactantEMU, {EMUname}, coefficient, sizeEMU, false);

        end % method parseEMUReaction

        function addEMUToList( ...
                obj, EMUname, targetMet, position, numAtoms, isTarget)
            % ADDEMUTOLIST: Add an EMU to the EMU list.
            %
            % Parameters
            % ----------
            % EMUname: string
            %    EMU name
            % targetMet: string
            %    Metabolite name of the EMU
            % position: array
            %    Position of the atoms in the metabolite
            % numAtoms: double
            %    EMU size
            % isTarget: bool
            %    True if the EMU is a target EMU
            %
            % Returns
            % -------
            % None

            newRow = {EMUname, targetMet, position, numAtoms, isTarget};

            % Check if the EMU already exists
            if any(obj.tableEMU.EMU == EMUname)
                return;
            end % if any(obj.tableEMU.EMU == EMUname)

            % If numAtoms is zero, do not add
            if numAtoms == 0
                return;
            end % if numAtoms == 0

            obj.tableEMU = [obj.tableEMU; newRow];

        end % method addEMUToList

        function addEMUReactionToList( ...
                obj, rxnID, reactants, products, coefficient, size, isTarget)
            % ADDEMUREACTIONTOLIST: Add an EMU reaction to the EMU reaction list.
            %
            % Parameters
            % ----------
            % rxnID: string
            %    Reaction ID
            % reactants: cell
            %    Reactant EMUs
            % products: cell
            %    Product EMUs
            % coefficient: double
            %    Stoichiometric coefficient
            % size: double
            %    EMU reaction size
            % isTarget: bool
            %    True if the EMU reaction is a target reaction
            %
            % Returns
            % -------
            % None

            newRow = {rxnID, {reactants}, {products}, coefficient, size, isTarget};
            newRowTable = cell2table(newRow, 'VariableNames', obj.tableEMUReaction.Properties.VariableNames);

            % Add the new row to the table
            obj.tableEMUReaction = [obj.tableEMUReaction; newRowTable];

        end % method addEMUReactionToList

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

            % Initialize
            info = obj.tableEMUSizeInfo;
            maxAn = max(info.An);
            maxBn = max(info.Bn);
            numSizes = max(info.EMUSize);

            obj.globalAn = zeros(maxAn, maxAn, numSizes);
            obj.globalBn = zeros(maxAn, maxBn, numSizes);
            obj.globalAnEMUName = cell(maxAn, numSizes);
            obj.globalAnEMUNameMetabolite = cell(maxAn, numSizes);
            obj.globalBnEMUName = cell(maxBn, numSizes);
            obj.globalBnEMUNameMetabolite = cell(maxBn, numSizes);
            tableEMURxn = obj.tableEMUReaction(obj.tableEMUReaction.Target == false, :);

            % Message
            msg = 'List up A and B EMUs for each EMU size.';
            emitMsg(obj, msg, "Info", obj.logLevel);

            for iSizeEMU = 1:numSizes

                iAnCount = 0;
                iBnCount = 0;
                iEMU = tableEMURxn( ...
                    tableEMURxn.Size == iSizeEMU, :);

                if isempty(iEMU)
                    continue
                end % if isempty(iEMU)

                iEMUList = vertcat(iEMU.Reactants, iEMU.Products);
                iEMUUnique = getUniqueEMUName(obj, iEMUList);

                % An and Bn EMUs
                for j = 1:length(iEMUUnique)

                    isSubstrate = false;

                    if length(iEMUUnique{j}) > 1
                        isSubstrate = true;
                    end % if length(iEMUUnique{j})>1

                    for k = 1:length(iEMUUnique{j})

                        tmpEMU = iEMUUnique{j}{k};
                        tmpMetabolite = obj.tableEMU.Metabolite( ...
                            obj.tableEMU.EMU == tmpEMU);

                        if obj.isSubstrateMetabolite(tmpMetabolite)
                            isSubstrate = true;
                            break;
                        end % if isSubstrateMetabolite(tmpMetabolite)

                    end % for k=1:length(iEMUUnique{j})

                    if ~isSubstrate
                        iAnCount = iAnCount + 1;
                        obj.globalAnEMUName{iAnCount, iSizeEMU} = iEMUUnique{j};
                        obj.globalAnEMUNameMetabolite{iAnCount, iSizeEMU} = tmpMetabolite;
                    else
                        iBnCount = iBnCount + 1;
                        obj.globalBnEMUName{iBnCount, iSizeEMU} = iEMUUnique{j};
                        obj.globalBnEMUNameMetabolite{iBnCount, iSizeEMU} = tmpMetabolite;
                    end % if ~isSubstrate

                end % for j=1:length(iEMUUnique)

            end % for iSizeEMU=1:numSizes

            % EMU size loop
            for iSizeEMU = 1:numSizes

                iAnEMU = obj.globalAnEMUName(1:info.An(iSizeEMU), iSizeEMU);
                iBnEMU = obj.globalBnEMUName(1:info.Bn(iSizeEMU), iSizeEMU);
                iAnBnEMU = [iAnEMU; iBnEMU];

                % | EMUSize | RxnIdx | i | j | coefficient |
                tmpRxnList = nan(0, 5);

                % EMU loop
                for j = 1:(length(iAnEMU))

                    jRxns = tableEMURxn( ...
                        cellfun(@(x) any(isequal(x, iAnEMU{j})), tableEMURxn.Reactants) | ...
                        cellfun(@(x) any(isequal(x, iAnEMU{j})), tableEMURxn.Products), :);

                    % Each reaction loop
                    for k = 1:height(jRxns)

                        kRxnID = jRxns.RxnID{k};
                        kRxnIdx = findRxnIdx(obj, kRxnID);

                        if isempty(kRxnIdx)
                            kRxnIdx = -1;
                        end % if isempty(kRxnIdx)

                        kReactants = jRxns.Reactants{k};
                        kProducts = jRxns.Products{k};
                        kCoefficient = jRxns.Coefficient(k);

                        if isequal(kProducts, iAnBnEMU{j})

                            kCurrentColIdx = find(cellfun(@(x) isequal(x, kReactants), iAnBnEMU));
                            tmpRxnList(end + 1, :) = [ ...
                                                          iSizeEMU, ...
                                                          kRxnIdx, ...
                                                          j, ...
                                                          kCurrentColIdx, ...
                                                          -kCoefficient ...
                                                      ]; %#ok<AGROW>

                            tmpRxnList(end + 1, :) = [ ...
                                                          iSizeEMU, ...
                                                          kRxnIdx, ...
                                                          j, ...
                                                          j, ...
                                                          kCoefficient ...
                                                      ]; %#ok<AGROW>

                        end % if isequal(kProducts, iAnBnEMU{j})

                    end % for k=1:height(jRxns)

                end % for j=1:(info.An(i)+info.Bn(i))

                tmpAnList = tmpRxnList(tmpRxnList(:, 4) <= info.An(iSizeEMU), :);
                tmpAnList(:, 5) = -tmpAnList(:, 5);
                tmpBnList = tmpRxnList(tmpRxnList(:, 4) > info.An(iSizeEMU), :);
                tmpBnList(:, 4) = tmpBnList(:, 4) - info.An(iSizeEMU);
                obj.globalAnList = [obj.globalAnList; tmpAnList];
                obj.globalBnList = [obj.globalBnList; tmpBnList];

            end % for iSizeEMU=1:numSizes

            [uniqueAnRows, ~, icAn] = unique(obj.globalAnList(:, 1:4), 'rows');
            sumCol = accumarray(icAn, obj.globalAnList(:, 5));
            obj.globalAnList = [uniqueAnRows, sumCol];

            [uniqueBnRows, ~, icBn] = unique(obj.globalBnList(:, 1:4), 'rows');
            sumCol = accumarray(icBn, obj.globalBnList(:, 5));
            obj.globalBnList = [uniqueBnRows, sumCol];

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

            info = obj.tableEMUSizeInfo;
            maxEMUSize = max(info.EMUSize);
            maxAn = max(info.An);
            metabolite = obj.getMetaboliteTableMetabolite();
            numMetabolite = length(metabolite);

            obj.globalCn = false(maxAn, numMetabolite, maxEMUSize);
            obj.globalCnDiag = zeros(maxAn, maxEMUSize);

            % Initialize Cn matrix
            for iSizeEMU = 1:maxEMUSize

                Xi = obj.globalAnEMUNameMetabolite(:, iSizeEMU);
                isEmptyXi = cellfun(@isempty, Xi);
                Xi(isEmptyXi) = {""};
                Xi = string(Xi);

                for jMetabolite = 1:numMetabolite

                    jMetName = metabolite(jMetabolite);
                    isMatch = ismember(Xi, jMetName);
                    obj.globalCn(isMatch, jMetabolite, iSizeEMU) = true;

                end % for iSizeEMU=1:maxSize

            end % method buildCnMatrix

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

            info = obj.tableEMUSizeInfo;
            maxSize = max(info.EMUSize);
            maxAn = max(info.An);
            maxBn = max(info.Bn);

            obj.globalXn = zeros(maxAn, maxSize + 1, maxSize);
            obj.globalYn = zeros(maxBn, maxSize + 1, maxSize);
            obj.globalXn(:, 1, :) = 1;
            obj.globalYn(:, 1, :) = 1;

            % Calculate the size of substrate EMUs for each EMU size
            metabolite = obj.getMetaboliteTable();
            substrateMetabolite = metabolite( ...
                cellfun(@(x) obj.isSubstrateMetabolite(x), metabolite.Metabolite), :);
            substrateEMUInfo = nan(height(substrateMetabolite), 2); % | Start | number of substrate EMUs |

            if height(substrateMetabolite) == 0
                disp('No substrate metabolites found.');
                return;
            end % if height(substrateMetabolite)==0

            substrateEMUInfo(1, 1) = 1;

            for i = 1:height(substrateMetabolite)

                if i > 1
                    substrateEMUInfo(i, 1) = substrateEMUInfo(i - 1, 1) + substrateEMUInfo(i - 1, 2);
                end % if i>1

                substrateEMUInfo(i, 2) = 2 ^ substrateMetabolite.Carbon{i} - 1;

            end % for i=1:height(substrateMetabolite)

            for iSizeEMU = 1:maxSize

                % | EMUSize | i | convolution (bool) | substrate (bool) | A | B |
                % If isSubstrate
                %   A: i (In substrate EMU)
                %   B: 0
                % Else
                %   A: sizeEMU (Xn)
                %   B: i (Xn)
                tmpYnList = zeros(0, 6);

                tmpBnEMUName = obj.globalBnEMUName(1:info.Bn(iSizeEMU), iSizeEMU);

                for j = 1:length(tmpBnEMUName)

                    tmpEMU = tmpBnEMUName{j};

                    for kEMU = 1:length(tmpEMU)

                        isConvolution = false;
                        isSubstrate = false;

                        if kEMU > 1
                            isConvolution = true;
                        end % if kEMU>1

                        kMetaboliteName = obj.tableEMU.Metabolite( ...
                            obj.tableEMU.EMU == tmpEMU{kEMU});

                        if obj.isSubstrateMetabolite(kMetaboliteName)
                            isSubstrate = true;
                            pattern = obj.tableEMU.Position{ ...
                                                                obj.tableEMU.EMU == tmpEMU{kEMU}};
                            subsSize = metabolite.Carbon{ ...
                                                             metabolite.Metabolite == kMetaboliteName};
                            patternLogical = false(1, subsSize);
                            patternLogical(pattern) = true;
                            dpos = obj.getSubstrateEMUPosition(patternLogical);

                            % Find the corresponding row in substrateEMUInfo
                            substrateRowIdx = find( ...
                                strcmp(substrateMetabolite.Metabolite, kMetaboliteName), 1);
                            startIdx = substrateEMUInfo(substrateRowIdx, 1);
                            pos = startIdx + dpos - 1;

                            tmpYnList(end + 1, :) = [ ...
                                                         iSizeEMU, ...
                                                         j, ...
                                                         isConvolution, ...
                                                         isSubstrate, ...
                                                         pos, ...
                                                         0 ...
                                                     ]; %#ok<AGROW>

                            continue;

                        end % if isSubstrateMetabolite(kMetaboliteName)

                        % Non-substrate EMU
                        % Get target EMU size
                        tmpEMUSize = obj.tableEMU.Size( ...
                            obj.tableEMU.EMU == tmpEMU{kEMU});
                        tmpIdxEMUName = find(info.EMUSize == tmpEMUSize, 1);
                        tmpAnIdx = find( ...
                            cellfun(@(x) isequal(x, tmpEMU(kEMU)), ...
                            obj.globalAnEMUName(1:info.An(tmpIdxEMUName), tmpIdxEMUName)), 1);
                        tmpYnList(end + 1, :) = [ ...
                                                     iSizeEMU, ...
                                                     j, ...
                                                     isConvolution, ...
                                                     isSubstrate, ...
                                                     tmpEMUSize, ...
                                                     tmpAnIdx ...
                                                 ]; %#ok<AGROW>

                    end % for kEMU=1:length(tmpEMU)

                end % for j=1:length(tmpBnEMUName)

                obj.globalYnList = [obj.globalYnList; tmpYnList];

            end % for i=1:height(info)

            % Sort Yn list by EMU size, i, convolution, substrate
            obj.globalYnList = sortrows(obj.globalYnList, [1 2 3 4]);

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

            targetEMU = obj.tableEMU(obj.tableEMU.Target == true, :);
            targetEMU = sortrows(targetEMU, 'Metabolite');
            sizeVector = targetEMU.Size;
            numTargetEMU = height(targetEMU);
            obj.globalMDVInfo = zeros(numTargetEMU, 2); % | size | position |

            for i = 1:numTargetEMU

                iSizeEMU = sizeVector(i);
                obj.globalMDVInfo(i, 1) = iSizeEMU;

                if i > 1
                    obj.globalMDVInfo(i, 2) = obj.globalMDVInfo(i - 1, 2) + obj.globalMDVInfo(i - 1, 1) + 1;
                else
                    obj.globalMDVInfo(i, 2) = 1;
                end % if i>1

            end % for i=1:numTargetEMU

            obj.globalMDVSize = obj.globalMDVInfo(end, 2) + obj.globalMDVInfo(end, 1);

            % | EMU size | isConvolution (bool) | i | MDV index |
            tmpMDVList = zeros(0, 5);

            for i = 1:numTargetEMU

                sizeEMU = obj.globalMDVInfo(i, 1);
                startIdx = obj.globalMDVInfo(i, 2);

                targetEMUReactant = obj.tableEMUReaction( ...
                    cellfun(@(x) any(isequal(x, targetEMU.EMU(i))), obj.tableEMUReaction.Products), :);

                tmpReactants = targetEMUReactant.Reactants{:};

                for j = 1:length(tmpReactants)

                    isConvolution = false;

                    if j > 1
                        isConvolution = true;
                    end % if j>1

                    jSizeEMU = obj.tableEMU.Size( ...
                        obj.tableEMU.EMU == tmpReactants{j});

                    jAnIdx = find( ...
                        cellfun(@(x) isequal(x, tmpReactants(j)), ...
                        obj.globalAnEMUName(1:obj.tableEMUSizeInfo.An( ...
                        obj.tableEMUSizeInfo.EMUSize == jSizeEMU), ...
                        obj.tableEMUSizeInfo.EMUSize == jSizeEMU)), 1);

                    tmpMDVList(end + 1, :) = [ ...
                                                  jSizeEMU, ...
                                                  isConvolution, ...
                                                  jAnIdx, ...
                                                  startIdx, ...
                                                  sizeEMU ... % EMU size of MDV
                                              ]; %#ok<AGROW>

                end % for j=1:length(targetEMUReactant.Reactants{i})

            end % for i=1:numTargetEMU

            obj.globalMDVList = ...
                [obj.globalMDVList; tmpMDVList];

            % Sort
            obj.globalMDVList = sortrows(obj.globalMDVList, 2, "ascend");

        end % method buildMDVVector

        %% Private utility methods
        function tf = saveEMUModelToFile(obj)
            % SAVEMODEL Save the model cache and source-file hash.
            %
            % The file locations are resolved by IOModel.pathCache and
            % IOModel.pathModel.

            tf = false;

            tableEMU = obj.tableEMU; %#ok<PROPLC>
            tableEMUReaction = obj.tableEMUReaction; %#ok<PROPLC>
            tableEMUSizeInfo = obj.tableEMUSizeInfo; %#ok<PROPLC>
            searchedProduct = obj.searchedProduct; %#ok<PROPLC>
            globalAn = obj.globalAn; %#ok<PROPLC>
            globalAnEMUName = obj.globalAnEMUName; %#ok<PROPLC>
            globalAnEMUNameMetabolite = obj.globalAnEMUNameMetabolite; %#ok<PROPLC>
            globalAnList = obj.globalAnList; %#ok<PROPLC>
            globalBn = obj.globalBn; %#ok<PROPLC>
            globalBnEMUName = obj.globalBnEMUName; %#ok<PROPLC>
            globalBnEMUNameMetabolite = obj.globalBnEMUNameMetabolite; %#ok<PROPLC>
            globalBnList = obj.globalBnList; %#ok<PROPLC>
            globalCn = obj.globalCn; %#ok<PROPLC>
            globalCnDiag = obj.globalCnDiag; %#ok<PROPLC>
            globalXn = obj.globalXn; %#ok<PROPLC>
            globalXnList = obj.globalXnList; %#ok<PROPLC>
            globalYn = obj.globalYn; %#ok<PROPLC>
            globalYnList = obj.globalYnList; %#ok<PROPLC>
            globalMDVInfo = obj.globalMDVInfo; %#ok<PROPLC>
            globalMDVList = obj.globalMDVList; %#ok<PROPLC>
            globalMDVSize = obj.globalMDVSize; %#ok<PROPLC>

            filePath = obj.pathCache;

            try
                save(filePath, ...
                    'tableEMU', ...
                    'tableEMUReaction', ...
                    'tableEMUSizeInfo', ...
                    'searchedProduct', ...
                    'globalAn', ...
                    'globalAnEMUName', ...
                    'globalAnEMUNameMetabolite', ...
                    'globalAnList', ...
                    'globalBn', ...
                    'globalBnEMUName', ...
                    'globalBnEMUNameMetabolite', ...
                    'globalBnList', ...
                    'globalCn', ...
                    'globalCnDiag', ...
                    'globalXn', ...
                    'globalXnList', ...
                    'globalYn', ...
                    'globalYnList', ...
                    'globalMDVInfo', ...
                    'globalMDVList', ...
                    'globalMDVSize' ...
                );
                tf = true;
            catch ME
                msg = "Failed to save the model: " + ME.message;
                emitMsg(obj, msg, "Error", obj.logLevel);
            end % try-catch

            try
                saveHashFile(obj, obj.pathModel);
            catch ME
                msg = "Failed to compute    hash for the model file: " + ME.message;
                emitMsg(obj, msg, "Error", obj.logLevel);
                return;
            end % try-catch

        end % saveModel

        function tf = loadEMUModelFromFile(obj)
            % LOADMODEL Load the model cache resolved by IOModel.pathCache.

            tf = false;
            filePath = obj.pathCache;

            if ~isfile(filePath)
                msg = "Model file not found: " + filePath;
                emitMsg(obj, msg, "Warning", obj.logLevel);
                return;
            end % if ~isfile(filePath)

            try
                loadedData = load(filePath);
                fields = fieldnames(loadedData);

                for i = 1:length(fields)
                    obj.(fields{i}) = loadedData.(fields{i});
                end % for i=1:length(fields)

                ensureCnMatrixAvailable(obj);

                tf = true;

            catch ME
                msg = "Failed to load the model: " + ME.message;
                emitMsg(obj, msg, "Error", obj.logLevel);
            end % try-catch

        end % loadModel

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
