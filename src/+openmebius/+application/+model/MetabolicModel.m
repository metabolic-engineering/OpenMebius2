classdef MetabolicModel < handle

    events

        generalMsg

    end % events

    properties (GetAccess = public, SetAccess = private)

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

        Workspace
        StoichiometricNetwork
        StoichiometricNetworkFactory
        NetworkBuilder
        MatrixBuilder
        NetworkEnumerator
        MDVCalculator
        EMUValidationErrors (:, 1) string = strings(0, 1)

    end % properties (Access = private)

    methods

        function obj = MetabolicModel(workspace, stoichiometricNetwork, options)
            % METABOLICMODEL Compose loaded model data and numerical state.

            arguments
                workspace (1, 1) openmebius.application.model.ModelWorkspace
                stoichiometricNetwork (1, 1) ...
                    openmebius.domain.model.StoichiometricNetwork
                options.NetworkBuilder = openmebius.mfa.EMUNetworkBuilder()
                options.MatrixBuilder = openmebius.mfa.EMUMatrixBuilder()
                options.NetworkEnumerator = ...
                    openmebius.mfa.EMUNetworkEnumerator()
                options.MDVCalculator = openmebius.mfa.EMUMDVCalculator()
                options.StoichiometricNetworkFactory = ...
                    openmebius.application.model ...
                        .StoichiometricNetworkFactory()
            end

            obj.Workspace = workspace;
            obj.StoichiometricNetwork = stoichiometricNetwork;
            obj.StoichiometricNetworkFactory = ...
                options.StoichiometricNetworkFactory;
            obj.NetworkBuilder = options.NetworkBuilder;
            obj.MatrixBuilder = options.MatrixBuilder;
            obj.NetworkEnumerator = options.NetworkEnumerator;
            obj.MDVCalculator = options.MDVCalculator;

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
            obj.EMUValidationErrors = strings(0, 1);

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

        function restoreEMUNetwork(obj, snapshot)
            % RESTOREEMUNETWORK Restore a repository-owned cache snapshot.

            arguments
                obj
                snapshot (1, 1) openmebius.domain.model.EMUNetworkSnapshot
            end

            applyCacheSnapshot(obj, snapshot);
            ensureCnMatrixAvailable(obj);

        end % restoreEMUNetwork

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
            emitMsg(obj, msg, "Info");

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
                emitMsg(obj, msg, "Error");
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
            % MDV: (s x length(tspan)) double
            %    MDV time course

            ensureCnMatrixAvailable(obj);
            MDV = obj.MDVCalculator.calculateTimeCourse( ...
                createCacheSnapshot(obj), ...
                flux, ...
                EMU, ...
                poolsize, ...
                tspan);

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
            dXdT = obj.MDVCalculator.calculateDerivative( ...
                createCacheSnapshot(obj), ...
                Xn, ...
                flux, ...
                EMU, ...
                poolsize);

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

        %% Workspace facade
        function value = getModelLocation(obj)
            value = obj.Workspace.getModelLocation();
        end
        function [fileName, fileType] = getModelFileDescriptor(obj)
            [fileName, fileType] = obj.Workspace.getModelFileDescriptor();
        end
        function path = getModelFilePath(obj)
            path = obj.Workspace.getModelFilePath();
        end
        function value = getInfoTable(obj)
            value = obj.Workspace.getInfoTable();
        end
        function value = getModelTable(obj)
            value = obj.Workspace.getModelTable();
        end
        function value = getModelTableGUI(obj)
            value = obj.Workspace.getModelTableGUI();
        end
        function value = getMSTable(obj)
            value = obj.Workspace.getMSTable();
        end
        function value = getMSRxnTable(obj)
            value = obj.Workspace.getMSRxnTable();
        end
        function value = getMSTransTable(obj)
            value = obj.Workspace.getMSTransTable();
        end
        function value = getAtomTable(obj)
            value = obj.Workspace.getAtomTable();
        end
        function value = getBiomassTable(obj)
            value = obj.Workspace.getBiomassTable();
        end
        function value = getMetaboliteTable(obj)
            value = obj.Workspace.getMetaboliteTable();
        end
        function value = getMetaboliteTableMetabolite(obj)
            value = obj.Workspace.getMetaboliteTableMetabolite();
        end
        function value = getMetaboliteTableSubstrate(obj)
            value = obj.Workspace.getMetaboliteTableSubstrate();
        end
        function value = getMSMetaboliteTable(obj)
            value = obj.Workspace.getMSMetaboliteTable();
        end
        function value = getInvalidModelRowIdx(obj)
            value = obj.Workspace.getInvalidModelRowIdx();
        end
        function value = getInvalidMSRowIdx(obj)
            value = obj.Workspace.getInvalidMSRowIdx();
        end
        function value = getInvalidAtomRowIdx(obj)
            value = obj.Workspace.getInvalidAtomRowIdx();
        end
        function value = getTableLabelView(obj)
            value = obj.Workspace.getTableLabelView();
        end
        function value = getLabelStruct(obj)
            value = obj.Workspace.getLabelStruct();
        end
        function value = getLabelStructView(obj)
            value = obj.Workspace.getLabelStructView();
        end
        function value = getTemplateMSTable(obj)
            value = obj.Workspace.getTemplateMSTable();
        end
        function value = getPathwayData(obj)
            value = obj.Workspace.getPathwayData();
        end
        function value = snapshot(obj)
            value = obj.Workspace.snapshot();
        end
        function updatePathwayLabelPosition(obj, reactionID, position)
            obj.Workspace.updatePathwayLabelPosition(reactionID, position);
        end
        function updateLabelConfiguration(obj, labelTable, ratioTables)
            obj.Workspace.updateLabelConfiguration(labelTable, ratioTables);
        end
        function setupTableInfo(obj)
            obj.Workspace.setupTableInfo();
        end
        function loadLabel(obj)
            obj.Workspace.loadLabel();
        end
        function exportLabel(obj)
            obj.Workspace.exportLabel();
        end
        function value = isSymmetricMetabolite(obj, metaboliteName)
            value = obj.Workspace.isSymmetricMetabolite(metaboliteName);
        end
        function value = getSubstrateTable(obj)
            value = obj.Workspace.getSubstrateTable();
        end
        function value = getSplittedFlux(obj, netFlux)
            value = obj.Workspace.getSplittedFlux(netFlux);
        end
        function updateStructLabel(obj, value)
            obj.Workspace.updateStructLabel(value);
        end

        function report = updateModelTableGUI(obj, value)
            report = obj.Workspace.updateModelTableGUI(value);
            if report.IsValid
                rebuildDerivedModels(obj);
            end
        end
        function report = updateMSTable(obj, value)
            report = obj.Workspace.updateMSTable(value);
            if report.IsValid
                rebuildDerivedModels(obj);
            end
        end
        function report = updateAtomTable(obj, value)
            report = obj.Workspace.updateAtomTable(value);
            if report.IsValid
                rebuildDerivedModels(obj);
            end
        end
        function reconstructModel(obj)
            obj.Workspace.reconstructModel();
            rebuildDerivedModels(obj);
        end

        %% Stoichiometric network facade
        function value = getModelTableRev(obj)
            value = obj.StoichiometricNetwork.getModelTableRev();
        end
        function value = getModelRxnRev(obj, index)
            if nargin == 2
                value = obj.StoichiometricNetwork.getModelRxnRev(index);
            else
                value = obj.StoichiometricNetwork.getModelRxnRev();
            end
        end
        function value = getModelRxnRevIdx(obj, reactionID)
            value = obj.StoichiometricNetwork.getModelRxnRevIdx(reactionID);
        end
        function value = getModelTransRev(obj, index)
            if nargin == 2
                value = obj.StoichiometricNetwork.getModelTransRev(index);
            else
                value = obj.StoichiometricNetwork.getModelTransRev();
            end
        end
        function value = getS(obj)
            value = obj.StoichiometricNetwork.getS();
        end
        function value = getSBefore(obj)
            value = obj.StoichiometricNetwork.getSBefore();
        end
        function value = getSType(obj)
            value = obj.StoichiometricNetwork.getSType();
        end
        function value = getConstraintTypes(obj)
            value = obj.StoichiometricNetwork.getConstraintTypes();
        end
        function value = getIdxRev(obj)
            value = obj.StoichiometricNetwork.getIdxRev();
        end
        function value = getDOF(obj)
            value = obj.StoichiometricNetwork.getDOF();
        end
        function value = getReactionIndependent(obj, reactionID)
            value = obj.StoichiometricNetwork ...
                .getReactionIndependent(reactionID);
        end
        function setReactionIndependent(obj, reactionID, independent)
            obj.Workspace.setReactionIndependent(reactionID, independent);
            obj.StoichiometricNetwork = ...
                obj.StoichiometricNetworkFactory.create(obj.Workspace);
        end
        function value = getSubstrateNameFromRxnID(obj, reactionID)
            value = obj.StoichiometricNetwork ...
                .getSubstrateNameFromRxnID(reactionID);
        end
        function value = ...
                findSubstrateRxnIDFromMetaboliteIrrev(obj, metabolite)
            value = obj.StoichiometricNetwork ...
                .findSubstrateRxnIDFromMetaboliteIrrev(metabolite);
        end
        function value = findCounterReaction(obj, reactionID)
            value = obj.StoichiometricNetwork.findCounterReaction(reactionID);
        end
        function value = findReaction(obj, compound, productOnly)
            if nargin < 3
                productOnly = false;
            end
            value = obj.StoichiometricNetwork ...
                .findReaction(compound, productOnly);
        end
        function value = isSubstrateMetabolite(obj, compound)
            value = obj.StoichiometricNetwork ...
                .isSubstrateMetabolite(compound);
        end
        function makeEffluxFree(obj, substrateNames)
            substrateNames = reshape(string(substrateNames), 1, []);
            for substrateName = substrateNames
                reactionID = obj.findSubstrateRxnIDFromMetaboliteIrrev( ...
                    substrateName);
                if ~isempty(reactionID)
                    obj.Workspace.setReactionIndependent(reactionID, true);
                end
            end
            obj.StoichiometricNetwork = ...
                obj.StoichiometricNetworkFactory.create(obj.Workspace);
        end

    end % methods (Access = public)

    methods (Access = private)

        function rebuildDerivedModels(obj)

            obj.StoichiometricNetwork = ...
                obj.StoichiometricNetworkFactory.create(obj.Workspace);
            obj.constructEMUNetwork();

        end % rebuildDerivedModels

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

            if isempty(obj.EMUValidationErrors)
                return
            end

            error( ...
                "OpenMebius2:MetabolicModel:EMUConstructionFailed", ...
                "%s", ...
                strjoin(obj.EMUValidationErrors, newline));

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
                "Info");
            source = openmebius.mfa.EMUNetworkSource( ...
                MSReactions = obj.getMSRxnTable(), ...
                MSTransitions = obj.getMSTransTable(), ...
                Reactions = obj.getModelRxnRev(), ...
                Transitions = obj.getModelTransRev(), ...
                Metabolites = obj.getMetaboliteTable());
            result = obj.NetworkEnumerator.enumerate(source);

            for message = result.ErrorMessages'
                emitMsg(obj, message, "Error");
            end

            if ~result.IsValid
                obj.EMUValidationErrors = [ ...
                    obj.EMUValidationErrors; ...
                    "The EMU network contains invalid MS reactions."];
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
                "Info");
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
                    'OpenMebius2:MetabolicModel:InvalidCnMatrix', ...
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

            evt = MsgEventData(msg, level, "MetabolicModel");
            notify(obj, 'generalMsg', evt);
        end % method updateMsg

    end % methods (Access = protected)

end % classdef MetabolicModel
