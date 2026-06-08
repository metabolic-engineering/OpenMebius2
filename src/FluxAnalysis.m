classdef FluxAnalysis < handle & IO

    events

        GeneralMsg
        FluxResult

    end % events

    properties (Access = public)

        % Cancel flag
        isCanceled = false

    end % properties (Access = public)

    properties (SetAccess = private)

        %% Objects
        model % The EMU model object
        exps % The EMU experiments object
        config % The configuration object
        status % The status of the EMU model
        result % The result of the EMU model

        % File export
        isExport = true
        HDF5FileName = ""
        HDF5FilePath = ""

        % List of experimental conditions
        expsList = []

        % Specific growth rate
        mu (:, 1) double

        % List of substrates for the efflux
        % (e.g. Subs_Glc, Subs_Ace)
        subsList = []

        % List of efflux
        % [6.2; 2.1];
        efflux = []
        effluxSD = []
        effluxFree = []

        % Flux bounds
        UB = []
        LB = []
        rhs = []

        numMDV
        numLabeling

        % Substrate EMU
        subsEMUs

        % MDVExp
        MDVExp = [];
        MDVFragList = []
        MDVFragMask = []

        % Initial flux distribution
        initialFlux = [];
        initialRhs = []
        initialRSS = []
        maskIndependent = []
        maskRxnForBoundary = []

        % Variables for the optimization
        SFmincon;
        RHSFmincon;
        MDVExpFmincon = [];
        % Instationary 13C-MFA
        isInstationary = false
        poolsize = [];
        timePoints = []

        % The result of the flux calculation
        resultRSS = [];
        resultFlux = []
        resultMDV = [];

        % Status flag
        statusFlag
        % 1: Initial flux distribution calculation
        % 2: Nonlinear optimization
        % 3: CI calculation
        % 4: Next suggestion

    end % properties

    methods

        function obj = FluxAnalysis( ...
                model, ...
                experiments, ...
                expList, ...
                config, ...
                fileDir, ...
                ID, ...
                controller ...
            )

            obj@IO(fileDir);

            obj.HDF5FileName = ID;
            obj.HDF5FilePath = fullfile(fileDir, ID + ".h5");

            if obj.isError
                obj.isExport = false;
            end

            obj.model = model;
            obj.exps = experiments;

            if obj.model.isError || obj.exps.isError
                obj.isError = true;
                return;
            end

            val = expList;

            while iscell(val) && isscalar(val)
                val = val{1};
            end

            if iscell(val)
                val = string(val(:));
            elseif isstring(val)
                val = val(:);
            elseif ischar(val)
                val = string(val);
            elseif isnumeric(val)
                val = val(:);
            else
                error("Invalid experiment list.");
            end

            obj.expsList = val;

            obj.config = config;
            obj.status = Status();

            if exist("controller", "var") && ~isempty(controller) && isvalid(controller)

                if isprop(controller, "CancelRequested") || any(strcmp(events(controller), "CancelRequested"))
                    addlistener(controller, 'CancelRequested', @(src, evt)obj.cancel());
                end

            end

            % Set flag
            obj.statusFlag = ...
                zeros(1, 4);

        end % FluxAnalysis

        %% Main functions
        function calculateFluxDistribution(obj)
            % CALCULATEFLUXDISTRIBUTION Calculate the flux distribution.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            tStart = tic;

            % Data validation
            if ~isValidateData(obj)
                % Notify the initial flux event
                msg = "Data validation failed.";
                notifyGeneralMessage(obj, "error", msg);
                obj.isError = true;
                return;
            end % if

            calculateLinearizedMDV(obj);

            if ~isValidateMDV(obj)
                % Notify the initial flux event
                msg = "Invalid MDV data (e.g. NaN values).";
                notifyGeneralMessage(obj, "error", msg);
                obj.isError = true;
                return;
            end % if

            exportGeneralInformation(obj);
            exportModelInformation(obj);

            % Set the experimental values for the optimization
            obj.MDVExpFmincon = obj.MDVExp;

            % FVA
            [fluxUB, fluxLB, err, ~] = calculateFluxVariability(obj);

            if err
                obj.isError = true;
                return;
            else
                % Notify the initial flux event
                msg = "Flux variability calculation completed.";
                notifyGeneralMessage(obj, "info", msg);
            end % if

            obj.UB = fluxUB;
            obj.LB = fluxLB;

            % Export the result of FVA
            exportFluxVariability(obj, fluxLB, fluxUB);

            fluxRange = obj.UB - obj.LB;
            averageFlux = mean(fluxRange);
            msg = "Average flux range: " + string(averageFlux) + " mmol/g/h";
            notifyGeneralMessage(obj, "info", msg);

            % Construct the EMU of the substrate
            numExperiments = length(obj.expsList);
            obj.subsEMUs = cell(numExperiments, 1);

            for i = 1:numExperiments
                obj.subsEMUs{i} = getSubstrateEMU(obj, "experiment", obj.expsList(i));
            end % for

            % Find initial flux distribution
            [flux, tmpRhs, RSS, err] = calculateInitialFluxDistribution(obj);

            if obj.isCanceled
                % Notify the initial flux event
                msg = "Initial flux distribution calculation canceled.";
                notifyGeneralMessage(obj, "info", msg);
                return;
            elseif err
                % Notify the initial flux event
                msg = "Initial flux distribution calculation failed.";
                notifyGeneralMessage(obj, "error", msg);
                obj.isError = true;
                return;
            else
                % Notify the initial flux event
                msg = "Initial flux distribution calculation completed.";
                notifyGeneralMessage(obj, "info", msg);
            end % if

            obj.initialFlux = flux;
            obj.initialRhs = tmpRhs;
            obj.initialRSS = RSS;

            % Export the initial flux distribution
            exportInitialFluxDistribution(obj, flux, tmpRhs, RSS);

            % Set the empty flux distribution
            obj.resultRSS = nan(1, obj.config.iteration);
            obj.resultFlux = nan(size(tmpRhs, 1), obj.config.iteration);
            obj.resultMDV = nan(obj.numMDV, obj.config.numExperiments, obj.config.iteration);

            % Flux calculation for each iteration
            for i = 1:obj.config.iteration

                % Notify the initial flux event
                msg = "Calculating flux distribution (iteration " + string(i) + "/" + string(obj.config.iteration) + ")";
                notifyGeneralMessage(obj, "info", msg);

                % Define the initial values for the optimization
                obj.RHSFmincon = tmpRhs(:, i);

                if ~obj.config.isINSTMFA
                    [fval, estimatedFlux, estimatedMDV, exitflag, ~] = ...
                        calculateNonLinearOptimization(obj, obj.MDVExpFmincon);
                else
                    obj.setINSTMFA();
                    [fval, estimatedFlux, estimatedMDV, exitflag, ~] = ...
                        calculateNonLinearOptimizationInstationary(obj, obj.MDVExpFmincon);
                end

                exportFluxResult(obj, i, estimatedFlux, fval, estimatedMDV, exitflag);

                obj.resultRSS(i) = fval;
                obj.resultFlux(:, i) = estimatedFlux;
                obj.resultMDV(:, :, i) = arrangeMDV(obj, estimatedMDV);

                % Calcel the calculation
                if obj.isCanceled
                    msg = "Nonlinear optimization canceled.";
                    notifyGeneralMessage(obj, "info", msg);
                    return;
                end % if isCanceled

            end % for

            [obj.resultRSS, idx] = sort(obj.resultRSS);
            obj.resultFlux = obj.resultFlux(:, idx);
            obj.resultMDV = obj.resultMDV(:, :, idx);

            minRSS = obj.resultRSS(1);
            % Calculate the threshold for chi-squared test
            threshold = caluclateThreshold(obj);
            exportFluxResultRSS(obj, obj.resultRSS, idx, threshold);

            % Notify the result of the flux calculation
            notify(obj, 'FluxResult', BatchProgressEventData("FluxResult", obj.result));

            tStop = toc(tStart);
            datetime = string(seconds(tStop), "hh:mm:ss");
            msg = "Flux calculation completed" + ...
                " (Elapsed time: " + datetime + ", " + ...
                "RSS: " + string(minRSS) + ")";
            notifyGeneralMessage(obj, "info", msg);

        end % calculateFluxDistribution

        function [fluxLB, fluxUB, output] = calculateConfidenceInterval(obj, options)
            % CALCULATECONFIDENCEINTERVAL Calculate the confidence interval.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   options.forNextSuggestion (1, 1) logical = false

            arguments
                obj (1, 1) FluxAnalysis
                options.forNextSuggestion (1, 1) logical = false
            end % arguments

            fluxLB = [];
            fluxUB = [];
            output = struct();

            msg = "Calculating confidence interval...";
            notifyGeneralMessage(obj, "info", msg);

            % calculation conditions
            if ~obj.config.isCalcCI
                return;
            end % if

            method = obj.config.CIConf.algorithm;

            switch method

                case "Monte Carlo"

                    tmpConfig = obj.config.CIConf.MC;
                    [fluxLB, fluxUB, output] = calculateCIMC(obj, tmpConfig);

                    if ~options.forNextSuggestion
                        % Export the result of the Monte Carlo method
                        exportConfidenceIntervalMC(obj, fluxLB, fluxUB, output);
                    end % if

                    msg = "Confidence interval calculated using Monte Carlo method.";
                    notifyGeneralMessage(obj, "info", msg);

                otherwise
                    msg = "Unknown method for calculating confidence interval.";
                    notifyGeneralMessage(obj, "error", msg);
                    return;

            end % switch

        end % calculateConfidenceInterval

        function [UB, LB, err, status] = calculateFluxVariability(obj, options)
            % CALCULATEFLUXVARIABILITY Calculate the flux variability.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
                options.customBoundary (1, 1) logical = false
                options.fluxUB double;
                options.fluxLB double;
            end % arguments

            % Notify the initial flux event
            msg = "Calculating flux variability...";
            notifyGeneralMessage(obj, "info", msg);

            err = false;

            SBefore = obj.model.getSBefore();
            numFlux = size(SBefore, 2);

            % Get maximum efflux of the flux
            maxEfflux = max(obj.efflux);

            fluxUB = repmat(maxEfflux * 3, numFlux, 1);
            fluxLB = repmat(-maxEfflux * 3, numFlux, 1);

            if options.customBoundary
                fluxLB = options.fluxLB;
                fluxUB = options.fluxUB;
            end % if

            idxRevTable = obj.model.getIdxRev();
            masIrrev = ~ismember(1:numFlux, idxRevTable);
            fluxLB(masIrrev) = max(fluxLB(masIrrev), 0);

            UB = nan(numFlux, 1);
            LB = nan(numFlux, 1);

            tmpRhs = calculateRHS(obj);
            tmpRhs = tmpRhs(1:size(SBefore, 1));

            RxnName = string(SBefore.Properties.VariableNames);
            idxRev = regexp(RxnName, "_rev$", "match");
            maskRev = ~cellfun(@isempty, idxRev);
            SBefore{:, maskRev} = 0;

            % Define the optimization problem
            options_lp = optimoptions( ...
                @linprog, ...
                "Display", "off", ...
                "Algorithm", "dual-simplex-highs" ...
            );

            for i = 1:numFlux

                iObj = zeros(numFlux, 1);
                iObj(i) = 1;

                [~, fval, exitflag, ~] = linprog( ...
                    iObj, ...
                    [], ...
                    [], ...
                    table2array(SBefore), ...
                    tmpRhs, ...
                    fluxLB, ...
                    fluxUB, ...
                    options_lp ...
                );

                if exitflag < 0

                    switch exitflag
                        case -2
                            msg = "FVA error. No feasible point was found.";
                        case -3
                            msg = "FVA error. Problem is unbounded.";
                        case -4
                            msg = "FVA error. NaN value was encountered during execution of the algorithm.";
                        case -5
                            msg = "FVA error. Both primal and dual problems are infeasible.";
                        case -6
                            msg = "FVA error. Search direction became too small. No further progress could be made.";
                        case -7
                            msg = "FVA error. Solver lost feasibility.";
                        otherwise
                            msg = "Unknown error.";
                    end % switch

                    notifyGeneralMessage(obj, "error", msg);
                    err = true;
                    break;
                end % if

                LB(i) = fval;

                [~, fval, ~, ~] = linprog( ...
                    -iObj, ...
                    [], ...
                    [], ...
                    table2array(SBefore), ...
                    tmpRhs, ...
                    fluxLB, ...
                    fluxUB, ...
                    options_lp ...
                );

                UB(i) = -fval;

                if maskRev(i)

                    RxnID = SBefore.Properties.VariableNames{i};
                    idx = obj.model.findCounterReaction(RxnID);
                    clear RxnID;

                    LB(i) = -UB(idx);
                    UB(i) = -LB(idx);

                    LB(i) = LB(i) / 2;
                    UB(i) = UB(i) / 2;
                    LB(idx) = -UB(i);
                    UB(idx) = -LB(i);

                end % if

            end % for

            status = exitflag;

        end % calculateFluxVariability

        function [flux, rhs, RSS, err] = calculateInitialFluxDistribution(obj, options)
            % CALCULATEINITIALFLUXDISTRIBUTION Calculate the initial flux distribution.

            arguments
                obj (1, 1) FluxAnalysis
                options.method (1, 1) string {mustBeMember(options.method, ["random", "hit-and-run"])} = "hit-and-run"
                options.forNextSuggestion (1, 1) logical = false
                options.iterationRate (1, 1) double = 100
                options.whileIteration (1, 1) double = 1e5

                options.burnin (1, 1) double = 2000
                options.thinning (1, 1) double = 10
                options.maxTime (1, 1) double = 3600
                options.seed (1, 1) double = 0
                options.failStreakMax (1, 1) double = 2000
            end

            err = false;

            msg = "Calculating initial flux distribution...";
            notifyGeneralMessage(obj, "info", msg);

            switch options.method

                case "random"
                    [flux, rhs] = calculateInitialFluxDistributionRandom( ...
                        obj, ...
                        iterationRate = options.iterationRate, ...
                        whileIteration = options.whileIteration ...
                    );
                    msg = "Initial flux distribution calculated randomly.";
                    notifyGeneralMessage(obj, "info", msg);

                case "hit-and-run"
                    [flux, rhs] = calculateInitialFluxDistributionHitAndRun( ...
                        obj ...
                    );
                    msg = "Initial flux distribution calculated using Hit-and-Run.";
                    notifyGeneralMessage(obj, "info", msg);

                otherwise
                    error("Unknown method for initial flux distribution calculation.");
            end

            if obj.isCanceled
                msg = "Initial flux distribution calculation canceled.";
                notifyGeneralMessage(obj, "info", msg);
                err = true;
            end

            if options.forNextSuggestion
                [RSS, idx] = calculateRSS(obj, flux, obj.subsEMUs(1:end - 1));
            else
                [RSS, idx] = calculateRSS(obj, flux, obj.subsEMUs);
            end

            flux = flux(:, idx);
            rhs = rhs(:, idx);
        end

        function [fluxLB, fluxUB, output] = suggestNextFluxExperiment(obj)
            % SUGGESTNEXTFLUXEXPERIMENT Suggest the next flux experiment.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
            end % arguments

            fluxLB = [];
            fluxUB = [];
            output = struct();

            [fluxLBExp, fluxUBExp, outputCI] = calculateConfidenceInterval(obj);
            exportConfidenceIntervalMC(obj, fluxLBExp, fluxUBExp, outputCI);

            if obj.isCanceled
                msg = "Next flux experiment suggestion canceled.";
                notifyGeneralMessage(obj, "info", msg);
                return;
            end % if

            exportNextLabelPatternGeneralInformation(obj);

            % Split the fluxes (exclude the biomass reaction)
            obj.LB = obj.model.getSplittedFlux(fluxLBExp(1:end - 1, end));
            obj.UB = obj.model.getSplittedFlux(fluxUBExp(1:end - 1, end));
            obj.LB = [obj.LB; fluxLBExp(end, end)];
            obj.UB = [obj.UB; fluxUBExp(end, end)];

            fluxRange = obj.UB - obj.LB;
            averageFlux = mean(fluxRange);
            msg = "Average flux range: " + string(averageFlux) + " mmol/g/h";
            notifyGeneralMessage(obj, "info", msg);

            % Notify the initial flux event
            msg = "Suggesting next flux experiment...";
            notifyGeneralMessage(obj, "info", msg);

            suggestionTableCell = obj.config.suggestionTable;
            suggestionTableRowNames = obj.config.suggestionTableRowNames;
            suggestionTableVarNames = obj.config.suggestionTableVarNames;

            suggestionTable = array2table( ...
                suggestionTableCell, ...
                'VariableNames', suggestionTableVarNames, ...
                'RowNames', suggestionTableRowNames ...
            );

            numPattern = size(suggestionTable, 1);

            % Construct the EMU of the substrate
            numExperiments = length(obj.expsList) + 1;
            obj.subsEMUs = cell(numExperiments, 1);

            for i = 1:numExperiments - 1
                obj.subsEMUs{i} = getSubstrateEMU(obj, "experiment", obj.expsList(i));
            end % for

            for iPattern = 1:numPattern

                pattern = suggestionTable{iPattern, :};

                isEmpty = any(cellfun(@isempty, pattern));

                if isEmpty
                    continue;
                end % if

                msg = "Evaluating pattern " + string(iPattern) + "/" + string(numPattern) + "...";
                notifyGeneralMessage(obj, "info", msg);

                [iFluxLB, iFluxUB, ~] = calculateNextLabelPattern(obj, cellstr(pattern));

                exportNextLabelPatternCIMC(obj, pattern, iFluxLB, iFluxUB);

                if obj.isCanceled
                    msg = "Next flux experiment suggestion canceled.";
                    notifyGeneralMessage(obj, "info", msg);
                    return;
                end % if

            end % for

            msg = "Next flux experiment suggested.";
            notifyGeneralMessage(obj, "info", msg);

        end % suggestNextFluxExperiment

        %% Get functions
        function config = getConfig(obj)
            % GETCONFIG Get the configuration of the FluxAnalysis object.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %
            % Returns:
            %   config: struct
            %       The configuration of the FluxAnalysis object.

            config = obj.config;

        end % getConfig

    end % methods

    methods (Access = private)

        function rhs = calculateRHS(obj)
            % CALCULATERHS Calculate the right-hand side.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
            end % arguments

            tmpS = obj.model.getSBefore();
            RxnName = tmpS.Properties.RowNames;
            SType = obj.model.getSType();

            idxBiomass = find(strcmp(RxnName, "biomass"), 1);

            tmpRhs = zeros(size(tmpS, 2), 1);
            tmpRhs(idxBiomass) = obj.mu;
            tmpRhs(strcmp(SType, "efflux")) = obj.efflux;

            obj.rhs = tmpRhs;
            rhs = obj.rhs;

        end % calculateRHS

        function [flux, rhs] = calculateInitialFluxDistributionRandom(obj, options)
            % CALCULATEINITIALFLUXDISTRIBUTIONRANDOM Calculate the initial flux distribution randomly.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %
            % Description
            % -----------
            % This function generate a rondom feasible flux distribution
            % for further nonlinear optimization.
            % 1. Generate a random feasible flux balues.
            % 2. Check if the flux distribution is feasible.

            arguments
                obj (1, 1) FluxAnalysis
                options.iterationRate (1, 1) double = 100
                options.whileIteration (1, 1) double = 1e5
                options.maxTime (1, 1) double = 3600
            end % arguments

            iteration = obj.config.iteration;
            numInitalFluxReq = iteration * options.iterationRate;

            tmpS = obj.model.getS();
            tmpSType = obj.model.getSType();

            tmpMaskIndependent = strcmp(tmpSType, "independent");

            rowName = tmpS.Properties.RowNames;
            rxnName = tmpS.Properties.VariableNames;
            rxnNameIndependent = string(rowName(tmpMaskIndependent));
            obj.maskIndependent = tmpMaskIndependent;

            maskRxn = ismember(rxnName, rxnNameIndependent);
            obj.maskRxnForBoundary = maskRxn;

            tmpUB = obj.UB;
            tmpLB = obj.LB;

            tStart = tic;
            tmpRhs = obj.rhs;

            numInitialFlux = 0;
            initlalFlux = nan(size(tmpS, 2), 0);
            tmpInitialRhs = nan(size(tmpS, 2), 0);

            while (toc(tStart) <= options.maxTime)

                % Generate random flux values within the bounds
                [rhsRtn, fluxRtn] = getRondomInitialPoint(obj, table2array(tmpS), tmpRhs, tmpUB, tmpLB, maskRxn, options.whileIteration);

                numInitialFlux = numInitialFlux + size(fluxRtn, 2);

                tStop = toc(tStart);
                datetime = string(seconds(tStop), "hh:mm:ss");
                msg = "Calculating initial flux distribution randomly" + ...
                    " (Elapsed time: " + datetime + ", " + ...
                    "Found " + string(numInitialFlux) + " feasible flux distributions)";
                notifyGeneralMessage(obj, "info", msg);

                if obj.isCanceled
                    msg = "Initial flux distribution calculation canceled.";
                    notifyGeneralMessage(obj, "info", msg);
                    break;
                end % if

                initlalFlux = [initlalFlux, fluxRtn]; %#ok<AGROW>
                tmpInitialRhs = [tmpInitialRhs, rhsRtn]; %#ok<AGROW>

                if numInitialFlux >= numInitalFluxReq
                    break;
                end % if

            end % while

            flux = initlalFlux;
            rhs = tmpInitialRhs;

        end % calculateInitialFluxDistributionRandom

        function [flux, rhs, err] = calculateInitialFluxDistributionHitAndRun(obj, options)
            % CALCULATEINITIALFLUXDISTRIBUTIONHITANDRUN (Chord sampling version)
            % - Find TWO feasible points by LP (FBA-like) with random objective.
            % - Use the line (chord) through them as the sampling direction.
            % - Sample uniformly along the feasible segment of that chord.

            arguments
                obj (1, 1) FluxAnalysis
                options.iterationRate (1, 1) double = 100
                options.numChord (1, 1) double = 2000 % number of chords to try
                options.samplePerChord (1, 1) double = 1 % samples generated per chord
                options.maxTime (1, 1) double = 3600
                options.seed (1, 1) double = 0
                options.epsFeas (1, 1) double = 1e-8
                options.maxLPTrials (1, 1) double = 30 % LP retries to get 2 distinct points
                options.minChordNorm (1, 1) double = 1e-9 % avoid identical points
            end

            err = false;

            if options.seed ~= 0
                rng(options.seed);
            end

            iteration = obj.config.iteration;
            numReq = iteration * options.iterationRate;

            % Matrices / bounds
            S = obj.model.getS(); % table
            A = table2array(S); % numeric
            tmpUB = obj.UB;
            tmpLB = obj.LB;
            tmpRhs = obj.rhs;

            % --- Determine independent reactions count (robust) ---
            tmpSType = obj.model.getSType();
            rxnName = string(S.Properties.VariableNames);
            rowName = string(S.Properties.RowNames);

            if numel(tmpSType) == numel(rxnName)
                maskIndCol = (string(tmpSType(:)) == "independent");
            elseif numel(tmpSType) == numel(rowName)
                rxnNameIndependent = rowName(string(tmpSType(:)) == "independent");
                maskIndCol = ismember(rxnName, rxnNameIndependent);
            else
                notifyGeneralMessage(obj, "error", ...
                "Chord sampling: getSType size mismatch. Cannot determine independent reactions.");
                err = true; flux = []; rhs = []; return;
            end

            numInd = sum(maskIndCol);

            if numInd <= 0
                notifyGeneralMessage(obj, "error", ...
                "Chord sampling: independent reactions are zero. Check getSType mapping / IDs.");
                err = true; flux = []; rhs = []; return;
            end

            nRhs = size(A, 2);

            if nRhs < numInd
                notifyGeneralMessage(obj, "error", ...
                "Chord sampling: rhs dimension < #independent variables.");
                err = true; flux = []; rhs = []; return;
            end

            % independent part in rhs tail (your convention)
            indIdx = (nRhs - numInd + 1:nRhs)';

            % mask for fmincon pipeline (rhs indices)
            obj.maskIndependent = false(nRhs, 1);
            obj.maskIndependent(indIdx) = true;

            % --- Precompute affine map v(x) = v_base + B*x ---
            rhs_fixed = tmpRhs;
            rhs_fixed(indIdx) = 0;

            v_base = A \ rhs_fixed;

            E = zeros(nRhs, numInd);
            E(sub2ind([nRhs, numInd], indIdx, (1:numInd)')) = 1;
            B = A \ E;

            % --- Sampling ---
            flux = nan(nRhs, 0);
            rhs = nan(nRhs, 0);

            saved = 0;
            chordTried = 0;

            tStart = tic;

            notifyGeneralMessage(obj, "info", ...
                "Chord sampling: start (target=" + string(numReq) + ").");

            while (toc(tStart) <= options.maxTime) && ~obj.isCanceled && (saved < numReq)

                chordTried = chordTried + 1;

                if chordTried > options.numChord
                    break;
                end

                % 1) Find two feasible points (x1, x2) by LP with random objective
                [x1, x2, ok2, lpMsg] = obj.findTwoFeasibleXLP(tmpLB, tmpUB, v_base, B, ...
                    maxTrials = options.maxLPTrials, ...
                    minChordNorm = options.minChordNorm);

                if ~ok2
                    % could not get 2 points; continue trying
                    if mod(chordTried, 50) == 0
                        notifyGeneralMessage(obj, "warning", ...
                            "Chord sampling: failed to find 2 feasible points (" + lpMsg + "), tried=" + string(chordTried));
                    end

                    continue;
                end

                % 2) Use the chord direction
                d = x2 - x1;
                nd = norm(d);

                if nd < options.minChordNorm
                    continue;
                end

                d = d / nd;

                % 3) Find feasible segment on this chord using x = x1 + t d
                [tmin, tmax, okRange] = obj.localStepRange(tmpLB, tmpUB, v_base, B, x1, d);

                if ~okRange || ~(tmax > tmin)
                    continue;
                end

                % 4) Sample along the segment
                for k = 1:options.samplePerChord

                    if saved >= numReq || obj.isCanceled
                        break;
                    end

                    t = tmin + (tmax - tmin) * rand();
                    x = x1 + t * d;

                    v = v_base + B * x;

                    if ~all(v >= tmpLB - options.epsFeas & v <= tmpUB + options.epsFeas)
                        % numerical safety
                        continue;
                    end

                    iRhs = tmpRhs;
                    iRhs(indIdx) = x;

                    rhs = [rhs, iRhs]; %#ok<AGROW>
                    flux = [flux, v]; %#ok<AGROW>

                    saved = saved + 1;

                    if saved == 1 || mod(saved, 10) == 0
                        tStop = toc(tStart);
                        notifyGeneralMessage(obj, "info", ...
                            "Chord sampling: saved " + string(saved) + "/" + string(numReq) + ...
                            " (chords=" + string(chordTried) + ", elapsed=" + string(seconds(tStop), "hh:mm:ss") + ")");
                    end

                end

            end

            if obj.isCanceled
                notifyGeneralMessage(obj, "info", "Chord sampling: canceled.");
                err = true;
                return;
            end

            if saved == 0
                notifyGeneralMessage(obj, "error", ...
                "Chord sampling: no samples were generated. (Maybe infeasible region or LP failed repeatedly)");
                err = true;
                return;
            end

        end

        function [x1, x2, ok, msg] = findTwoFeasibleXLP(obj, LB, UB, v_base, B, options)
            % FINDTWOFEASIBLEXLP
            % Find two distinct feasible points by solving two LPs with random objectives.
            %
            % Feasible set: LB <= v_base + Bx <= UB

            arguments
                obj
                LB (:, 1) double
                UB (:, 1) double
                v_base (:, 1) double
                B double
                options.maxTrials (1, 1) double = 30
                options.minChordNorm (1, 1) double = 1e-9
            end

            x1 = [];
            x2 = [];
            ok = false;
            msg = "";

            % Build inequalities:  Bx <= UB - v_base,  -Bx <= -(LB - v_base)
            b1 = UB - v_base;
            b2 =- (LB - v_base);

            Aineq = [B; -B];
            bineq = [b1; b2];

            n = size(B, 2);

            opts = optimoptions(@linprog, ...
                "Display", "off", ...
                "Algorithm", "dual-simplex-highs");

            % Try multiple times to get two distinct solutions
            for trial = 1:options.maxTrials

                % random objective
                f = randn(n, 1);

                % LP1
                [xA, okA, msgA] = obj.solveLPFeasible(Aineq, bineq, f, opts);

                if ~okA
                    msg = msgA;
                    continue;
                end

                % another random objective
                g = randn(n, 1);

                % LP2
                [xB, okB, msgB] = obj.solveLPFeasible(Aineq, bineq, g, opts);

                if ~okB
                    msg = msgB;
                    continue;
                end

                if norm(xB - xA) >= options.minChordNorm
                    x1 = xA;
                    x2 = xB;
                    ok = true;
                    msg = "";
                    return;
                end

                msg = "LP returned nearly identical points.";
            end

            if msg == ""
                msg = "Failed to find two distinct feasible points.";
            end

        end

        function [x, ok, msg] = solveLPFeasible(~, Aineq, bineq, f, opts)
            % SOLVELPFEASIBLE Solve LP: minimize f'*x subject to Aineq x <= bineq

            ok = false;
            msg = "";
            x = [];

            try
                [xsol, ~, exitflag] = linprog(f, Aineq, bineq, [], [], [], [], opts);
            catch ME
                msg = "LP exception: " + string(ME.message);
                return;
            end

            if exitflag == 1 && ~isempty(xsol)
                x = xsol;
                ok = true;
                return;
            end

            msg = "LP failed (exitflag=" + string(exitflag) + ").";
        end

        function [tmin, tmax, ok] = localStepRange(~, LB, UB, v_base, B, x, d)
            % LOCALSTEPRANGE
            % Compute feasible step range t for:
            %   LB <= v_base + B*(x + t*d) <= UB
            %
            % Inputs
            %   LB, UB : (nFlux x 1) bounds
            %   v_base : base flux (A \ rhs_fixed)
            %   B      : direction mapping matrix
            %   x      : current point in independent space
            %   d      : direction (unit vector, independent space)
            %
            % Outputs
            %   tmin, tmax : feasible interval
            %   ok         : true if feasible interval exists

            ok = true;

            % Current flux
            v0 = v_base + B * x;

            % Direction in flux space
            a = B * d;

            epsA = 1e-12;
            epsFeas = 1e-10;

            % Components where direction is ~0
            maskZero = abs(a) < epsA;

            % If stationary components violate bounds → infeasible
            if any(v0(maskZero) < LB(maskZero) - epsFeas | ...
                    v0(maskZero) > UB(maskZero) + epsFeas)
                ok = false;
                tmin = NaN;
                tmax = NaN;
                return;
            end

            % Components that move with t
            mask = ~maskZero;

            if ~any(mask)
                % Direction does not change flux → infinite step
                tmin = -inf;
                tmax = +inf;
                return;
            end

            a2 = a(mask);
            v02 = v0(mask);
            LB2 = LB(mask);
            UB2 = UB(mask);

            % Solve inequalities
            %   LB <= v02 + t*a2 <= UB
            t1 = (LB2 - v02) ./ a2;
            t2 = (UB2 - v02) ./ a2;

            lo = min(t1, t2);
            hi = max(t1, t2);

            if any(isnan(lo)) || any(isnan(hi))
                ok = false;
                tmin = NaN;
                tmax = NaN;
                return;
            end

            tmin = max(lo);
            tmax = min(hi);

            ok = (tmax > tmin);
        end

        function [LB, UB, output] = calculateNextLabelPattern(obj, pattern)
            % CALCULATENEXTLABELPATTERN Calculate the next label pattern.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   pattern: (1, n) cell
            %       The label pattern.
            %       n: number of substrates
            %
            % Returns
            % -------
            %   LB: (m, 1) double
            %       The lower bound of the flux.
            %       m: number of reactions
            %   UB: (m, 1) double
            %       The upper bound of the flux.
            %       m: number of reactions
            %   output: struct
            %       The output of the calculation.

            arguments
                obj (1, 1) FluxAnalysis
                pattern (1, :) cell {mustBeNonempty}
            end % arguments

            LB = [];
            UB = [];
            output = struct();

            msg = "Generating EMU model for the pattern...";
            notifyGeneralMessage(obj, "info", msg);

            EMU = getSubstrateEMU(obj, ...
                "useCustomEMU", true, ...
                "customPattern", pattern);

            % Store the EMU of the substrate
            obj.subsEMUs{end} = EMU;

            if obj.isCanceled
                msg = "Next flux experiment suggestion canceled.";
                notifyGeneralMessage(obj, "info", msg);
                return;
            end % if

            MDV = calculateMDV(obj, obj.resultFlux(:, 1), obj.subsEMUs);
            obj.MDVExpFmincon = MDV;

            % CI calculation
            [LB, UB, ~] = calculateConfidenceInterval( ...
                obj, ...
                forNextSuggestion = true ...
            );

            if obj.isCanceled
                msg = "Next flux experiment suggestion canceled.";
                notifyGeneralMessage(obj, "info", msg);
                return;
            end % if

        end % calculateNextLabelPattern

        function [RSS, idx] = calculateRSS(obj, fluxes, subsEMU)
            % CALCULATERS Calculate the RSS.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   fluxes: (n, m) double
            %       The flux distribution.
            %       n: number of reactions
            %       m: The number of fluxes
            %   subsEMU: (1, n) cell
            %       The EMU of the substrate.
            %       n: number of tracers
            %
            %       subsEMU{i}: (n, m) double
            %       EMU of the i-th tracer
            %       n: number of EMUs
            %       m: The maximum number of atoms in the EMU

            numFlux = size(fluxes, 2);
            RSS = nan(1, numFlux);
            epsilon = 1e-3;
            RSSInvalid = 1e9;

            MDVExpTemp = arrangeMDV(obj, obj.MDVExpFmincon, ...
                numExperiments = length(subsEMU));

            for i = 1:numFlux

                if obj.isCanceled
                    break;
                end % if

                iMDV = calculateMDV(obj, fluxes(:, i), subsEMU);

                % MDVi >= 1 + e or MDVi <= 0 - e
                if any(iMDV >= 1 + epsilon) || any(iMDV <= 0 - epsilon)
                    % If the MDV is invalid, set the RSS to a large value
                    RSS(i) = RSSInvalid;
                    continue;
                end % if

                % Calculate the RSS
                iRSS = ((iMDV(obj.MDVFragMask) - MDVExpTemp(obj.MDVFragMask)) / ...
                    0.01) .^ 2;
                RSS(i) = sum(iRSS, 1);

            end % for

            % Sort the RSS
            [RSS, idx] = sort(RSS, "ascend");

            % Count the number of valid flux distributions
            numValidFlux = sum(RSS < RSSInvalid);
            msg = "Number of valid flux distributions: " + string(numValidFlux);
            notifyGeneralMessage(obj, "info", msg);

        end % calculateRSS

        function MDV = calculateMDV(obj, flux, subsEMU)
            % CALCULATEMDV Calculate the MDV.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   flux: (n, 1) double
            %       The flux distribution.
            %       n: number of reactions
            %   subsEMU: (1, n) cell
            %       The EMU of the substrate.
            %       n: number of tracers
            %
            %       subsEMU{i}: (n, m) double
            %       EMU of the i-th tracer
            %       n: number of EMUs
            %       m: The maximum number of atoms in the EMU
            %
            % Returns
            % -------
            %   MDV: (n, m) double
            %       The MDV of the substrate.
            %       n: The number of fragments
            %       m: The number of tracers

            MDV = [];

            for i = 1:length(subsEMU)

                % Get the EMU of the substrate
                iEMU = subsEMU{i};

                % Get the flux distribution
                iFlux = flux;

                % Calculate the MDV
                iMDV = calculateMDV(obj.model, iFlux, iEMU);

                % Store the MDV
                MDV = [MDV; iMDV]; %#ok<AGROW>

            end % for

        end % calculateMDV

        function MDVAll = arrangeMDV(obj, MDV, options)
            % ARRANGEMDV Arrange the MDV.
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   MDV: (n, 1) double
            %       The MDV of all experiments.
            %       n: The number of experiments * number of fragments
            %
            % Returns
            % -------
            %   MDVAll: (m, p) double
            %       The arranged MDV.
            %       m: The number of fragments
            %       p: The number of experiments

            arguments
                obj (1, 1) FluxAnalysis
                MDV (:, :) double
                options.numExperiments (1, 1) double = length(obj.expsList)
            end % arguments

            MDVAll = nan(obj.numMDV, options.numExperiments);

            for i = 1:options.numExperiments

                idxStart = (i - 1) * obj.numMDV + 1;
                idxEnd = i * obj.numMDV;

                MDVAll(:, i) = MDV(idxStart:idxEnd);

            end % for

        end % arrangeMDV

        function calculateLinearizedMDV(obj)
            % CALCULATELINEARIZEDMDV Create the linearized MDV for fmincon.

            % Get the fragment list from the EMU model
            fragmentList = getTargetMetaboliteList(obj.model);
            MSMetabolite = getMSMetaboliteTable(obj.model);

            % Generate mask
            if strcmp(obj.config.MS.fragment, "all")

                MSTable = getMSTable(obj.model);
                selectedFragmentMask = MSTable.Used;
                selectedFragmentList = ...
                    MSTable.Properties.RowNames(selectedFragmentMask);
                selectedFragmentList = string(selectedFragmentList);

                clear MSTable selectedFragmentMask;

            else

                list = obj.config.MS.fragmentList;
                mask = obj.config.MS.customFragment;

            end % if

            MDV = [];
            MDVFragListTemp = string();
            tempFragmentMask = [];

            for iLabel = 1:length(obj.expsList)

                MDVExpTable = getMDVBiomassTable(obj.exps, obj.expsList(iLabel));
                ExpFragList = MDVExpTable.Properties.VariableNames;
                MDVLabel = [];

                % For custom fragments
                if ~strcmp(obj.config.MS.fragment, "all")

                    [fragmentList, sortIdx] = sort(string(list));
                    selectedFragmentList = fragmentList(mask(sortIdx));

                end % if

                for iFragment = 1:length(fragmentList)

                    idx = find(ismember(MSMetabolite.Metabolite, fragmentList(iFragment)));
                    numAtom = cell2mat(MSMetabolite.Carbon(idx));

                    % Search for the fragment in the MDV table
                    if any(strcmp(ExpFragList, fragmentList(iFragment)))

                        iMDV = MDVExpTable.(fragmentList(iFragment));
                        iMDV = iMDV(1:numAtom + 1);
                        MDVLabel = [MDVLabel; iMDV]; %#ok<AGROW>

                    else

                        % If the fragment is not found, set it to NaN
                        iMDV = nan(numAtom + 1, 1);
                        MDVLabel = [MDVLabel; iMDV]; %#ok<AGROW>

                    end % if

                    if iLabel == 1

                        % Add the fragment to the MDVFragList
                        iFragList = repmat(fragmentList(iFragment), numAtom + 1, 1);
                        MDVFragListTemp = [MDVFragListTemp; iFragList]; %#ok<AGROW>

                        if any(ismember(fragmentList(iFragment), selectedFragmentList))
                            tempFragmentMask = ...
                                [tempFragmentMask; true(numAtom + 1, 1)]; %#ok<AGROW>
                        else
                            tempFragmentMask = ...
                                [tempFragmentMask; false(numAtom + 1, 1)]; %#ok<AGROW>
                        end % if

                    end % if

                end % for iFragment

                MDV = [MDV, MDVLabel]; %#ok<AGROW>

            end % for iLabel

            obj.MDVExp = MDV;
            obj.MDVFragList = MDVFragListTemp(2:end);
            obj.MDVFragMask = logical(tempFragmentMask);

            % Set the number of MDV and labeling experiments
            obj.numMDV = size(MDV, 1);
            obj.numLabeling = size(MDV, 2);

        end % calculateLinearizedMDV

        %% Optimization functions
        function SSR = calculateObjectiveFunction(obj, independentFlux, MDVExpTemp)
            % CALCULATEOBJECTIVEFUNCTION Calculate the objective function.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   independentFlux: (n, 1) double
            %       The independent flux distribution.
            %       n: number of independent fluxes
            %   MDVExpTemp: (n, m) double
            %       The experimental MDV.
            %       n: number of fragments
            %       m: number of labeling experiments
            %
            % Returns
            % -------
            %   SSR: (1, 1) double
            %       The sum of squares of the residuals.

            tmpRHS = obj.RHSFmincon;
            tmpRHS(obj.maskIndependent) = independentFlux;
            tmpFlux = obj.SFmincon \ tmpRHS;

            MDVExpTemp = arrangeMDV(obj, MDVExpTemp, numExperiments = length(obj.subsEMUs));

            SSR = 0;

            for i = 1:length(obj.subsEMUs)

                % Get the EMU of the substrate
                iEMU = obj.subsEMUs{i};

                % Calculate the MDV
                iMDV = calculateMDV(obj.model, tmpFlux, iEMU);

                % Calculate the RSS
                iRSS = ((iMDV(obj.MDVFragMask) - MDVExpTemp(obj.MDVFragMask, i)) / ...
                    0.01) .^ 2;
                SSR = SSR + sum(iRSS, 1);

            end % for

        end % calculateObjectiveFunction

        function SSR = calculateObjectiveFunctionInstationary( ...
                obj, ...
                independentFlux, ...
                MDVExpTemp ...
            )
            % CALCULATEOBJECTIVEFUNCTIONINSTATIONARY Calculate the objective function for
            % instationary MFA.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   independentFlux: (n, 1) double
            %       The independent flux distribution.
            %       n: number of independent fluxes
            %   MDVExpTemp: (n, m) double
            %       The experimental MDV.
            %       n: number of fragments
            %       m: number of time points
            %
            % Returns
            % -------
            %   SSR: (1, 1) double
            %       The sum of squares of the residuals.

            tmpRHS = obj.RHSFmincon;
            tmpRHS(obj.maskIndependent) = independentFlux;
            tmpFlux = obj.SFmincon \ tmpRHS;
            MDVSize = size(MDVExpTemp);
            numTimePoints = MDVSize(2);

            MDVExpTemp = MDVExpTemp(:);
            MDVMaskUnit = obj.MDVFragMask;
            MDVMask = repmat(MDVMaskUnit, numTimePoints, 1);
            MDVExp = obj.model.calculateMDVTimeCourse( ...
                tmpFlux, ...
                obj.subsEMUs{1}, ...
                obj.poolsize, ...
                obj.timePoints ...
            ); %#ok<PROPLC>
            MDVExp = MDVExp(:); %#ok<PROPLC>

            SSR = ((MDVExp(MDVMask) - MDVExpTemp(MDVMask)) / 0.01) .^ 2; %#ok<PROPLC>
            SSR = sum(SSR, 1);

        end % calculateObjectiveFunctionInstationary

        function [c, ceq] = calculateConstraints(obj, independentFlux)
            % CALCULATECONSTRAINTS Calculate the constraints.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   independentFlux: (n, 1) double
            %       The independent flux distribution.
            %       n: number of independent fluxes
            %
            % Returns
            % -------
            %   c: (n, 1) double
            %       The inequality constraints.
            %       n: number of constraints
            %   ceq: (n, 1) double
            %       The equality constraints.
            %       n: number of constraints

            tmpRHS = obj.RHSFmincon;
            tmpRHS(obj.maskIndependent) = independentFlux;
            c = -1 * obj.SFmincon \ tmpRHS;
            ceq = [];

        end % calculateConstraints

        function [fval, estimatedFlux, estimatedMDV, exitflag, output] = ...
                calculateNonLinearOptimization(obj, MDVExpTemp)
            % CALCULATENONLINEAROPTIMIZATION Calculate the nonlinear optimization.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            tmpInitialRhs = obj.RHSFmincon;
            tmpInitialFlux = tmpInitialRhs(obj.maskIndependent);

            % Set up large scale optimization
            switch obj.config.largeScale
                case true
                    largeScale = "on";
                case false
                    largeScale = "off";
                otherwise
                    largeScale = "off";
            end % switch obj.config.largeScale

            fmincon_options = optimset( ...
                'Algorithm', obj.config.algorithm, ...
                'Display', 'off', ...
                'LargeScale', largeScale, ...
                'MaxFunEvals', 500000, ...
                'MaxIter', 500, ...
                "UseParallel", false ...
            );

            [x, fval, exitflag, output] = ...
                fmincon( ...
                @(x) calculateObjectiveFunction(obj, x, MDVExpTemp), ...
                tmpInitialFlux, ...
                [], ...
                [], ...
                [], ...
                [], ...
                [], ...
                [], ...
                @(x) calculateConstraints(obj, x), ...
                fmincon_options ...
            );

            estimatedRhs = tmpInitialRhs;
            estimatedRhs(obj.maskIndependent) = x;
            estimatedFlux = obj.SFmincon \ estimatedRhs;
            estimatedMDV = calculateMDV(obj, estimatedFlux, obj.subsEMUs);

            if isnan(fval)
                msg = "Nonlinear optimization failed.";
                notifyGeneralMessage(obj, "error", msg);
                return;
            else
                msg = "Nonlinear optimization completed. " + ...
                    "RSS: " + string(fval) + ")";
            end % if

            notifyGeneralMessage(obj, "info", msg);

        end % calculateNonLinearOptimization

        function [fval, estimatedFlux, estimatedMDV, exitflag, output] = ...
                calculateNonLinearOptimizationInstationary(obj, MDVExpTemp)
            % CALCULATENONLINEAROPTIMIZATIONINSTATIONARY Calculate the nonlinear
            % optimization for instationary MFA.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   MDVExpTemp: (n, m) double
            %       The experimental MDV.
            %       n: number of fragments
            %       m: number of time points

            tmpInitialRhs = obj.RHSFmincon;
            tmpInitialFlux = tmpInitialRhs(obj.maskIndependent);

            % Set up large scale optimization
            switch obj.config.largeScale
                case true
                    largeScale = "on";
                case false
                    largeScale = "off";
                otherwise
                    largeScale = "off";
            end % switch obj.config.largeScale

            fmincon_options = optimset( ...
                'Algorithm', obj.config.algorithm, ...
                'LargeScale', largeScale, ...
                'Display', 'off', ...
                'MaxFunEvals', 500000, ...
                'MaxIter', 500, ...
                "UseParallel", false ...
            );

            [x, fval, exitflag, output] = ...
                fmincon( ...
                @(x) calculateObjectiveFunctionInstationary(obj, x, MDVExpTemp), ...
                tmpInitialFlux, ...
                [], ...
                [], ...
                [], ...
                [], ...
                [], ...
                [], ...
                @(x) calculateConstraints(obj, x), ...
                fmincon_options ...
            );

            estimatedRhs = tmpInitialRhs;
            estimatedRhs(obj.maskIndependent) = x;
            estimatedFlux = obj.SFmincon \ estimatedRhs;
            estimatedMDV = obj.model.calculateMDVTimeCourse( ...
                estimatedFlux, ...
                obj.subsEMUs{1}, ...
                obj.poolsize, ...
                obj.timePoints ...
            );

            if isnan(fval)
                msg = "Nonlinear optimization for instationary MFA failed.";
                notifyGeneralMessage(obj, "error", msg);
                return;
            else
                msg = "Nonlinear optimization for instationary MFA completed. " + ...
                    "RSS: " + string(fval) + ")";
                notifyGeneralMessage(obj, "info", msg);
            end % if

        end % calculateNonLinearOptimizationInstationary

        %% Tools
        function threshold = caluclateThreshold(obj, alpha)
            % CALCULATETHRESHOLD Calculate the threshold for chi-squared test
            % for the flux distribution.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %
            % Returns
            % -------
            %   threshold: (1, 1) double
            %
            % Description
            % -----------
            % The flux distribution is estimated from a fitted mass distribution
            % vector (MDV) and a set of EMUs. The residual sum of squares (RSS)
            % is used to evaluate how well the model fits the data. The threshold
            % of the chi-squared test is calculated based on the degrees of
            % freedom of the model and the significance level (alpha).

            arguments
                obj (1, 1) FluxAnalysis
                alpha (1, 1) double {mustBeGreaterThanOrEqual(alpha, 0), ...
                                         mustBeLessThanOrEqual(alpha, 1)} = 0.05
            end % arguments

            % The degrees of freedom of the model
            % The degrees of freedom of the model
            DOFModel = getDOF(obj.model);

            % The number of fragments
            fragmentLabelList = obj.MDVFragList;
            fragmentMask = obj.MDVFragMask;

            numLabel = size(fragmentMask, 2);

            DOFFragment = 0;

            % For parallel labeling experiments
            for i = 1:numLabel

                % Get the number of fragments
                iFragmentMask = fragmentMask(:, i);
                iFragmentLabel = fragmentLabelList(:, i);

                % Extract the unique labels
                iFragmentLabelSelected = iFragmentLabel(iFragmentMask);
                iFragmentLabelUnique = unique(iFragmentLabelSelected);

                numFragment = length(iFragmentLabelUnique);
                numDataPoints = sum(iFragmentMask);

                DOFFragment = DOFFragment + (numDataPoints - numFragment);

            end % for

            % DoF: n - p
            % n: number of data points
            % p: number of independent fluxes
            DoF = DOFFragment - DOFModel;

            threshold = chi2inv(1 - alpha, DoF);

        end % caluclateThreshold

        %% Monte Carlo method
        function [fluxLB, fluxUB, output] = calculateCIMC(obj, config)
            % CALCULATECIMC Calculate the confidence interval using Monte Carlo method.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   options: (1, 1) struct
            %       The options for the Monte Carlo method.

            arguments
                obj (1, 1) FluxAnalysis
                config (1, 1) struct
            end % arguments

            tStart = tic;

            fluxLB = [];
            fluxUB = [];
            output = struct();

            % Notify the initial flux event
            msg = "Calculating confidence interval using Monte Carlo method. " + ...
                "It may take a while (Cancel button is not available).";
            notifyGeneralMessage(obj, "info", msg);

            % If the flux distribution is not calculated, return
            if obj.statusFlag(2) ~= 1
                msg = "Flux distribution is not calculated.";
                notifyGeneralMessage(obj, "error", msg);
                return;
            end % if

            % Set up the experimental conditions
            Lmax = config.iteration;
            SD = config.MIDSD;

            % MDV calculation
            numFlux = size(obj.resultFlux, 1);
            MDVExpTemp = obj.MDVExpFmincon;

            resultFluxBest = obj.resultFlux(:, 1);
            RHSTemp = obj.RHSFmincon;
            RHSTemp(obj.maskIndependent) = resultFluxBest(obj.maskRxnForBoundary);
            obj.RHSFmincon = RHSTemp;

            numMDVTemp = size(MDVExpTemp, 1);
            numLabelingTemp = size(MDVExpTemp, 2);
            MCMDV = nan(numMDVTemp, numLabelingTemp, Lmax);
            MCFlux = nan(numFlux, Lmax);

            parfor i = 1:Lmax

                % Corruppt randomly the MDV
                iMDV = MDVExpTemp + ...
                    randn(numMDVTemp, numLabelingTemp) * SD;

                % Save the MDV
                MCMDV(:, :, i) = iMDV;

                % Calculate the flux distribution
                [~, estimatedFlux, ~, ~, ~] = ...
                    calculateNonLinearOptimization(obj, iMDV);
                MCFlux(:, i) = estimatedFlux;

            end % for

            idxRev = obj.model.getIdxRev();
            fluxFwd = MCFlux;
            fluxFwd(idxRev(:, 1), :) = fluxFwd(idxRev(:, 1), :) - fluxFwd(idxRev(:, 2), :);
            fluxFwd(idxRev(:, 2), :) = [];

            % Change the sign of the fluxes for reversible reactions

            [fluxLB, fluxUB] = ...
                calculateConfidenceIntervalFromMonteCarlo(obj, fluxFwd, 0.95);

            output.MDV = MCMDV;
            output.flux = fluxFwd;
            output.iteration = Lmax;
            output.time = toc(tStart);

            msg = "Confidence interval calculated successfully." + ...
                " (Elapsed time: " + string(seconds(output.time), "hh:mm:ss") + ")";
            notifyGeneralMessage(obj, "info", msg);

        end % calculateCIMC

        function [LB, UB] = calculateConfidenceIntervalFromMonteCarlo(obj, flux, gamma)
            % CALCULATECIMC Calculate the confidence interval.
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   flux: (n, m) double
            %       The flux distribution.
            %       n: number of fluxes
            %       m: number of iterations (Lmax)
            %   gamma: (1, 1) double
            %       The confidence level.
            %       Default is 0.05 (95% confidence level).

            arguments
                obj (1, 1) FluxAnalysis
                flux (:, :) double
                gamma (1, 1) double {mustBeGreaterThanOrEqual(gamma, 0), ...
                                         mustBeLessThanOrEqual(gamma, 1)} = 0.95
            end % arguments

            flux = rmmissing(flux, 2);
            numFlux = size(flux, 1);
            numL = size(flux, 2);

            LB = nan(numFlux, numL);
            UB = nan(numFlux, numL);

            method = obj.config.CIConf.MC.calculationMethod;

            msg = "Calculating confidence interval using " + method + " method.";
            notifyGeneralMessage(obj, "info", msg);

            switch method
                case "discarding"

                    % Calculate the threshold
                    threshold = (1 - gamma) / 2;

                    for iL = 1:numL

                        iFlux = flux(:, 1:iL);
                        iThreshold = fix(threshold * iL) + 1;

                        for jFlux = 1:numFlux

                            % Sort the flux values
                            iFluxj = iFlux(jFlux, :);
                            iSortedFlux = sort(iFluxj, 2);

                            % Calculate the lower and upper bounds
                            if iThreshold <= length(iSortedFlux)
                                LB(jFlux, iL) = iSortedFlux(iThreshold);
                                UB(jFlux, iL) = iSortedFlux(end - iThreshold + 1);
                            else
                                LB(jFlux, iL) = NaN;
                                UB(jFlux, iL) = NaN;
                            end % if

                        end % for jFlux

                        % Cancel event
                        if obj.isCanceled
                            msg = "Confidence interval calculation canceled.";
                            notifyGeneralMessage(obj, "info", msg);
                            return;
                        end % if

                    end % for iL

                case "mean-varianced"

                    msg = "Mean-varianced method is not implemented yet.";
                    notifyGeneralMessage(obj, "error", msg);
                    return;

                otherwise

                    msg = "Unknown method for calculating confidence interval.";
                    notifyGeneralMessage(obj, "error", msg);
                    return;

            end % switch

        end % calculateCIMC

        %% Get functions
        function [rhsRtn, fluxRtn] = getRondomInitialPoint( ...
                ~, tmpS, tmpRhs, tmpUB, tmpLB, maskIndependent, iteration)
            % GETRANDO MINITIALPOINT Get a random initial point.
            %
            % Parameters
            % ----------
            %  obj: FluxAnalysis
            %      The FluxAnalysis object.
            %  tmpS: (n, r) double
            %      The stoichiometry matrix.
            %  tmpRhs: (r, 1) double
            %      The right-hand side vector.
            %  tmpUB: (r, 1) double
            %      The upper bound vector.
            %  tmpLB: (r, 1) double
            %      The lower bound vector.
            %  maskIndependent: (n, 1) logical
            %      The mask for independent reactions.
            %  iteration: (1, 1) double
            %      The number of iterations.
            %
            % Description
            % -----------
            % This function generate a rondom feasible flux balues.

            fluxRtn = nan(size(tmpS, 2), 0);
            rhsRtn = nan(size(tmpS, 2), 0);

            epsilon = 1e-6;

            numIndependent = sum(maskIndependent);

            for i = 1:iteration

                iRhs = tmpRhs;

                iRhs(end - numIndependent + 1:end) = ...
                    rand(numIndependent, 1) .* (tmpUB(maskIndependent) - tmpLB(maskIndependent)) + tmpLB(maskIndependent);

                iFlux = tmpS \ iRhs;

                if all(iFlux >= tmpLB - epsilon & iFlux <= tmpUB + epsilon)
                    % if sum(iFlux < tmpLB - epsilon) == 0 && sum(iFlux > tmpUB + epsilon) == 0
                    % Check if the flux distribution is feasible

                    fluxRtn = [fluxRtn, iFlux]; %#ok<AGROW>
                    rhsRtn = [rhsRtn, iRhs]; %#ok<AGROW>
                end % if

            end % for

        end % getRandomInitialPoint

        function EMU = getSubstrateEMU(obj, options)
            % GETSUBSTRATEEMU Get the substrate EMU using the EMU model.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
                options.experiment (1, 1) string = obj.expsList(1)
                options.useCustomEMU (1, 1) logical = false
                options.customPattern (1, :) cell = {}
            end % arguments

            obj.model.substrateEMUsAll()

            tableTracer = obj.exps.getTracerTable();
            tableTemplateTracer = obj.model.getLabelStructEMU();
            fieldNamesTableTemplateTracer = fieldnames(tableTemplateTracer);

            % Extract the necessary columns and rows
            tracer = tableTracer{options.experiment, :};

            if options.useCustomEMU
                tracer = options.customPattern;
                tracer = string(tracer);
            end % if

            [~, subsListIdx] = sort(tableTracer.Properties.VariableNames);
            tracer = tracer(:, subsListIdx);
            tracer = regexprep(tracer, "~.*", "");

            tracerList = obj.model.getTableLabelView();

            tracerPattern = nan(1, size(tracer, 2));

            for i = 1:length(tracer)

                tracerPattern(i) = find(strcmp(tracerList.Name, tracer(i)));

            end % for

            EMU = [];

            for i = 1:length(tracerPattern)

                iFieldName = fieldNamesTableTemplateTracer{tracerPattern(i)};
                iEMU = tableTemplateTracer.(iFieldName);
                EMU = [EMU; iEMU]; %#ok<AGROW>

            end % for

        end % getSubstrateEMU

        %% Export functions
        function exportGeneralInformation(obj)
            % EXPORTGENERALINFORMATION Export the general information.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            obj.result.status = obj.statusFlag;
            obj.result.ID = obj.HDF5FileName;
            obj.result.MDVExp = obj.MDVExp;
            obj.result.MDVFragList = obj.MDVFragList;
            obj.result.MDVFragMask = obj.MDVFragMask;

            if ~obj.isExport
                return;
            end % if

            % Write status
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/status", ...
                int8(obj.statusFlag), ...
                DataType = "int8" ...
            );

            % Write ID
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/ID", ...
                string(obj.HDF5FileName), ...
                DataType = "string" ...
            );

            % Write MDVExp
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/MDVExp", ...
                obj.MDVExp, ...
                DataType = "double" ...
            );

            % Write MDVFragList
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/MDVFragList", ...
                string(obj.MDVFragList), ...
                DataType = "string" ...
            );

            % Write MDVFragMask
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/MDVFragMask", ...
                int8(obj.MDVFragMask), ...
                DataType = "int8" ...
            );

        end % exportGeneralInformation

        function exportModelInformation(obj)
            % EXPORTMODELINFORMATION Export the model information.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            if ~obj.isExport
                return;
            end % if

            % Get the model information
            tableModel = obj.model.getModelTable();
            modelID = string(tableModel.Properties.RowNames);
            modelReaction = string(tableModel.Reaction);
            modelTransition = string(tableModel.Transition);
            modelIndependent = tableModel.Independent;
            tableModelRev = obj.model.getModelTableRev();
            modelRevID = string(tableModelRev.Properties.RowNames);
            modelReactionRev = string(tableModelRev.Reaction);
            modelTransitionRev = string(tableModelRev.Transition);
            modelIndependentRev = tableModelRev.Independent;

            obj.result.model.modelID = modelID;
            obj.result.model.modelReaction = modelReaction;
            obj.result.model.modelTransition = modelTransition;
            obj.result.model.modelIndependent = modelIndependent;
            obj.result.model.modelRevID = modelRevID;
            obj.result.model.modelReactionRev = modelReactionRev;
            obj.result.model.modelTransitionRev = modelTransitionRev;
            obj.result.model.modelIndependentRev = modelIndependentRev;

            % Write model information
            obj.writeHDF5File( ...
                obj.HDF5FilePath, ...
                "/model/modelID", ...
                modelID, ...
                DataType = "string" ...
            );

            obj.writeHDF5File( ...
                obj.HDF5FilePath, ...
                "/model/modelReaction", ...
                modelReaction, ...
                DataType = "string" ...
            );

            obj.writeHDF5File( ...
                obj.HDF5FilePath, ...
                "/model/modelTransition", ...
                modelTransition, ...
                DataType = "string" ...
            );

            obj.writeHDF5File( ...
                obj.HDF5FilePath, ...
                "/model/modelIndependent", ...
                int8(modelIndependent), ...
                DataType = "int8" ...
            );

            obj.writeHDF5File( ...
                obj.HDF5FilePath, ...
                "/model/modelRevID", ...
                modelRevID, ...
                DataType = "string" ...
            );

            obj.writeHDF5File( ...
                obj.HDF5FilePath, ...
                "/model/modelReactionRev", ...
                modelReactionRev, ...
                DataType = "string" ...
            );

            obj.writeHDF5File( ...
                obj.HDF5FilePath, ...
                "/model/modelTransitionRev", ...
                modelTransitionRev, ...
                DataType = "string" ...
            );

            obj.writeHDF5File( ...
                obj.HDF5FilePath, ...
                "/model/modelIndependentRev", ...
                int8(modelIndependentRev), ...
                DataType = "int8" ...
            );

        end % exportModelInformation

        function exportFluxVariability(obj, fluxLB, fluxUB)
            % EXPORTFVA Export the flux variability analysis results.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   fluxLB: (n, 1) double
            %       The lower bound of the flux distribution.
            %       n: number of reactions
            %   fluxUB: (n, 1) double
            %       The upper bound of the flux distribution.
            %       n: number of reactions

            % Get the current time in POSIX format
            unixTime = posixtime(datetime("now", "TimeZone", "UTC"));
            % Get the idnex of the reversible reactions
            % (2, n) double
            % | Forward reaction | Reverse reaction |
            % |                1 |                2 |
            % |                3 |                4 |
            % |                5 |                6 |
            % | ................ | ................ |
            idxRev = obj.model.getIdxRev();
            fluxLBFwd = fluxLB;
            fluxLBFwd(idxRev(:, 1)) = fluxLB(idxRev(:, 1)) - fluxUB(idxRev(:, 2));
            fluxLBFwd(idxRev(:, 2)) = [];
            fluxUBFwd = fluxUB;
            fluxUBFwd(idxRev(:, 1)) = fluxUB(idxRev(:, 1)) - fluxLB(idxRev(:, 2));
            fluxUBFwd(idxRev(:, 2)) = [];

            obj.result.fluxVariability.fluxLB = fluxLB;
            obj.result.fluxVariability.fluxUB = fluxUB;
            obj.result.fluxVariability.fluxLBFwd = fluxLBFwd;
            obj.result.fluxVariability.fluxUBFwd = fluxUBFwd;
            obj.result.fluxVariability.time = unixTime;
            obj.result.status = obj.statusFlag;

            if ~obj.isExport
                return;
            end % if

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/fluxVariability/fluxLB", ...
                fluxLB ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/fluxVariability/fluxUB", ...
                fluxUB ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/fluxVariability/fluxLBFwd", ...
                fluxLBFwd ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/fluxVariability/fluxUBFwd", ...
                fluxUBFwd ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/fluxVariability/time", ...
                int32(unixTime), ...
                DataType = "int32" ...
            );

            % Write status
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/status", ...
                int8(obj.statusFlag), ...
                DataType = "int8" ...
            );

        end % exportFVA

        function exportInitialFluxDistribution(obj, flux, rhs, RSS)
            % EXPORTINITIALFLUXDISTRIBUTION Export the initial flux distribution.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   flux: (n, m) double
            %       The flux distribution.
            %       n: number of reactions
            %       m: The number of fluxes
            %   rhs: (n, m) double
            %       The right-hand side vector.
            %       n: number of reactions
            %       m: The number of fluxes
            %   RSS: (1, m) double
            %       The residual sum of squares.
            %       m: The number of fluxes

            % Get the current time in POSIX format
            unixTime = posixtime(datetime("now", "TimeZone", "UTC"));
            % Get the idnex of the reversible reactions
            % (2, n) double
            % | Forward reaction | Reverse reaction |
            % |                1 |                2 |
            % |                3 |                4 |
            % |                5 |                6 |
            % | ................ | ................ |
            idxRev = obj.model.getIdxRev();
            fluxFwd = flux;
            fluxFwd(idxRev(:, 1), :) = flux(idxRev(:, 1), :) - flux(idxRev(:, 2), :);
            fluxFwd(idxRev(:, 2), :) = [];

            obj.result.initialFlux.flux = flux;
            obj.result.initialFlux.fluxFwd = fluxFwd;
            obj.result.initialFlux.rhs = rhs;
            obj.result.initialFlux.RSS = RSS;
            obj.result.initialFlux.time = unixTime;

            % status
            obj.statusFlag(1) = 1;
            obj.result.status = obj.statusFlag;

            if ~obj.isExport
                return;
            end % if

            % Export the flux distribution
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/initialFlux/flux", ...
                flux ...
            );

            % Export the forward flux distribution
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/initialFlux/fluxFwd", ...
                fluxFwd ...
            );

            % Export the right-hand side vector
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/initialFlux/rhs", ...
                rhs ...
            );

            % Export the residual sum of squares
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/initialFlux/RSS", ...
                RSS ...
            );

            % Export the time
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/initialFlux/time", ...
                int32(unixTime), ...
                DataType = "int32" ...
            );

            % Write status
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/status", ...
                int8(obj.statusFlag), ...
                DataType = "int8" ...
            );

        end % exportInitialFluxDistribution

        function exportFluxResult(obj, iteration, flux, RSS, MDV, exitfrag)
            % EXPORTFLUXRESULT Export the flux results.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   iteration: (1, 1) double
            %       The iteration number.
            %   flux: (n, m) double
            %       The flux distribution.
            %       n: number of reactions
            %       m: The number of fluxes
            %   rhs: (n, m) double
            %       The right-hand side vector.
            %       n: number of reactions
            %       m: The number of fluxes
            %   RSS: (1, m) double
            %       The residual sum of squares.
            %       m: The number of fluxes
            %   exitflag: (1, 1) double
            %       The exit flag of the optimization.
            %   output: (1, 1) struct
            %       The output of the optimization.

            % Get the current time in POSIX format
            unixTime = posixtime(datetime("now", "TimeZone", "UTC"));
            % Get the idnex of the reversible reactions
            % (2, n) double
            % | Forward reaction | Reverse reaction |
            % |                1 |                2 |
            % |                3 |                4 |
            % |                5 |                6 |
            % | ................ | ................ |
            idxRev = obj.model.getIdxRev();
            fluxFwd = flux;
            fluxFwd(idxRev(:, 1)) = flux(idxRev(:, 1)) - flux(idxRev(:, 2));
            fluxFwd(idxRev(:, 2)) = [];

            iteration = string(sprintf("%04d", iteration));
            fieldName = "fluxResult" + iteration;
            obj.result.(fieldName).flux = flux;
            obj.result.(fieldName).fluxFwd = fluxFwd;
            obj.result.(fieldName).RSS = RSS;
            obj.result.(fieldName).MDV = MDV;
            obj.result.(fieldName).exitflag = exitfrag;
            obj.result.(fieldName).time = unixTime;
            obj.result.status = obj.statusFlag;

            if ~obj.isExport
                return;
            end % if

            % Create data address
            dataAddress = "/fluxResult/" +iteration;

            % Export the flux distribution
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/flux", ...
                flux ...
            );

            % Export the forward flux distribution
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/fluxFwd", ...
                fluxFwd ...
            );

            % Export RSS
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/RSS", ...
                RSS ...
            );

            % Export MDV
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/MDV", ...
                MDV ...
            );

            % Export exitflag
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/exitflag", ...
                exitfrag ...
            );

            % Export the time
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/time", ...
                int32(unixTime), ...
                DataType = "int32" ...
            );

        end % exportFluxResults

        function exportFluxResultRSS(obj, RSS, idx, threshold)
            % EXPORTFLUXRESULTRSS Export the flux result RSS.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   RSS: (1, m) double
            %       The residual sum of squares.
            %       m: The number of fluxes
            %   idx: (1, 1) double
            %       The index of the flux result.
            %   threshold: (1, 1) double
            %       The threshold for the flux result.

            % Set status
            obj.statusFlag(2) = 1;

            obj.result.RSS = RSS;
            obj.result.RSSIdx = idx;
            obj.result.status = obj.statusFlag;
            obj.result.threshold = threshold;

            if ~obj.isExport
                return;
            end % if

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/RSS", ...
                RSS ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/RSSIndex", ...
                int32(idx), ...
                DataType = "int32" ...
            );

            % Write status
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/status", ...
                int8(obj.statusFlag), ...
                DataType = "int8" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                "/threshold", ...
                threshold ...
            );

        end % exportFluxResultRSS

        function exportConfidenceIntervalMC(obj, fluxLB, fluxUB, output)
            % EXPORTCONFIDENCEINTERVALMC Export the confidence interval using Monte Carlo method.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   fluxLB: (n, m) double
            %       The lower bound of the flux distribution.
            %       n: number of reactions
            %       m: number of iterations
            %   fluxUB: (n, m) double
            %       The upper bound of the flux distribution.
            %       n: number of reactions
            %       m: number of iterations
            %   output: (1, 1) struct
            %       The output of the Monte Carlo method.

            if ~obj.isExport
                return;
            end % if

            unixTime = posixtime(datetime("now", "TimeZone", "UTC"));

            % Set status
            obj.statusFlag(3) = 1;
            obj.result.status = obj.statusFlag;
            obj.result.CI.time = unixTime;
            obj.result.fluxLB = fluxLB(:, end);
            obj.result.fluxUB = fluxUB(:, end);
            obj.result.CI.fluxLB = fluxLB;
            obj.result.CI.fluxUB = fluxUB;

            obj.result.CI.algorithm = obj.config.CIConf.algorithm;
            obj.result.CI.iteration = obj.config.CIConf.MC.iteration;
            obj.result.CI.MIDSD = obj.config.CIConf.MC.MIDSD;
            obj.result.CI.optimizationProcedure = obj.config.CIConf.MC.optimizationProcedure;
            obj.result.CI.TT = obj.config.CIConf.MC.terminationTolerance;
            obj.result.CI.proximityThreshold = obj.config.CIConf.MC.proximityThreshold;
            obj.result.CI.certainThreshold = obj.config.CIConf.MC.certainThreshold;
            obj.result.CI.theNumberOfRuns = obj.config.CIConf.MC.theNumberOfRuns;
            obj.result.CI.calculationMethod = obj.config.CIConf.MC.calculationMethod;

            switch obj.config.CIConf.algorithm

                case "Monte Carlo"

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/fluxLB", ...
                        fluxLB(:, end) ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/fluxUB", ...
                        fluxUB(:, end) ...
                    );

                    % Export the confidence interval
                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/fluxLB", ...
                        fluxLB ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/fluxUB", ...
                        fluxUB ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/algorithm", ...
                        string(obj.config.CIConf.algorithm), ...
                        DataType = "string" ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/iteration", ...
                        int32(obj.config.CIConf.MC.iteration), ...
                        DataType = "int32" ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/MIDSD", ...
                        obj.config.CIConf.MC.MIDSD, ...
                        DataType = "double" ...
                    );

                    % Write config
                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/optimizationProcedure", ...
                        string(obj.config.CIConf.MC.optimizationProcedure), ...
                        DataType = "string" ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/TT", ...
                        obj.config.CIConf.MC.terminationTolerance, ...
                        DataType = "double" ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/proximityThreshold", ...
                        obj.config.CIConf.MC.proximityThreshold, ...
                        DataType = "double" ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/certainThreshold", ...
                        obj.config.CIConf.MC.certainThreshold, ...
                        DataType = "double" ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/theNumberOfRuns", ...
                        int32(obj.config.CIConf.MC.theNumberOfRuns), ...
                        DataType = "int32" ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/calculationMethod", ...
                        string(obj.config.CIConf.MC.calculationMethod), ...
                        DataType = "string" ...
                    );

                    % Fluxes and MDVs
                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/fluxes", ...
                        output.flux, ...
                        DataType = "double" ...
                    );

                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/MDV", ...
                        output.MDV, ...
                        DataType = "double" ...
                    );

                    % Write status
                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/status", ...
                        int8(obj.statusFlag), ...
                        DataType = "int8" ...
                    );

                    % Time
                    writeHDF5File( ...
                        obj, ...
                        obj.HDF5FilePath, ...
                        "/CI/time", ...
                        int32(unixTime), ...
                        DataType = "int32" ...
                    );

            end % switch

        end % exportConfidenceIntervalMC

        function exportNextLabelPatternGeneralInformation(obj)
            % EXPORTNEXTLABELPATTERNGENERALINFORMATION Export the next label pattern general information.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            if ~obj.isExport
                return;
            end % if

            suggestionCell = obj.config.suggestionTable;
            suggestionColName = obj.config.suggestionTableVarNames;

            baseAddress = "/nextLabelPattern/suggestionTable";

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                baseAddress + "/colName", ...
                string(suggestionColName), ...
                DataType = "string" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                baseAddress + "/data", ...
                suggestionCell, ...
                DataType = "string" ...
            );

        end % exportNextLabelPatternGeneralInformation

        function exportNextLabelPatternInitialFlux(obj, pattern, flux, tmpRhs, RSS)
            % EXPORTNEXTLABELPATTERNINITIALFLUX Export the next label pattern initial flux.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   pattern: (1, p) cell
            %       The label pattern.
            %   flux: (n, m) double
            %       The flux distribution.
            %       n: number of reactions
            %       m: The number of fluxes
            %   tmpRhs: (n, m) double
            %       The right-hand side vector.
            %       n: number of reactions
            %       m: The number of fluxes
            %   RSS: (1, m) double
            %       The residual sum of squares.
            %       m: The number of fluxes

            if ~obj.isExport
                return;
            end % if

            unixTime = posixtime(datetime("now", "TimeZone", "UTC"));
            patternStr = strjoin(pattern, "_");
            patternStr = matlab.lang.makeValidName(patternStr);

            idxRev = obj.model.getIdxRev();
            fluxFwd = flux;
            fluxFwd(idxRev(:, 1), :) = flux(idxRev(:, 1), :) - flux(idxRev(:, 2), :);
            fluxFwd(idxRev(:, 2), :) = [];

            obj.result.nextLabelPattern.(patternStr).flux = flux;
            obj.result.nextLabelPattern.(patternStr).fluxFwd = fluxFwd;
            obj.result.nextLabelPattern.(patternStr).rhs = tmpRhs;
            obj.result.nextLabelPattern.(patternStr).RSS = RSS;
            obj.result.nextLabelPattern.(patternStr).time = unixTime;
            obj.result.status = obj.statusFlag;

            dataAddress = "/nextLabelPattern/" + patternStr;

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/flux", ...
                flux, ...
                DataType = "double" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/fluxFwd", ...
                fluxFwd, ...
                DataType = "double" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/rhs", ...
                tmpRhs, ...
                DataType = "double" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/RSS", ...
                RSS, ...
                DataType = "double" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/time", ...
                int32(unixTime), ...
                DataType = "int32" ...
            );

        end % exportNextLabelPatternInitialFlux

        function exportNextLabelPatternCIMC(obj, pattern, fluxLB, fluxUB)
            % EXPORTNEXTLABELPATTERNCIMC Export the next label pattern confidence interval using Monte Carlo method.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   pattern: (1, p) cell
            %       The label pattern.
            %   fluxLB: (n, m) double
            %       The lower bound of the flux distribution.
            %       n: number of reactions
            %       m: number of iterations
            %   fluxUB: (n, m) double
            %       The upper bound of the flux distribution.
            %       n: number of reactions
            %       m: number of iterations

            if ~obj.isExport
                return;
            end % if

            unixTime = posixtime(datetime("now", "TimeZone", "UTC"));
            patternStr = strjoin(pattern, "_");
            patternStr = matlab.lang.makeValidName(patternStr);

            obj.result.nextLabelPattern.(patternStr).fluxLB = fluxLB(:, end);
            obj.result.nextLabelPattern.(patternStr).fluxUB = fluxUB(:, end);
            obj.result.nextLabelPattern.(patternStr).CI.fluxLB = fluxLB;
            obj.result.nextLabelPattern.(patternStr).CI.fluxUB = fluxUB;
            obj.result.nextLabelPattern.(patternStr).CI.time = unixTime;
            obj.result.status = obj.statusFlag;

            dataAddressBase = "/nextLabelPattern/" + patternStr;
            dataAddress = dataAddressBase + "/CI";

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddressBase + "/fluxLB", ...
                fluxLB(:, end), ...
                DataType = "double" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddressBase + "/fluxUB", ...
                fluxUB(:, end), ...
                DataType = "double" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/fluxLB", ...
                fluxLB, ...
                DataType = "double" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/fluxUB", ...
                fluxUB, ...
                DataType = "double" ...
            );

            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/time", ...
                int32(unixTime), ...
                DataType = "int32" ...
            );

        end % exportNextLabelPatternCIMC

        %% Notify functions
        function notifyGeneralMessage(obj, status, msg, dbstack)
            % NOTIFYINITIALFLUXEVENT Notify the initial flux event.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
                status (1, 1) string {mustBeMember(status, ["info", "warning", "error"])}
                msg (1, 1) string
                dbstack struct
            end % arguments

            % Event data
            type = "GeneralMsg";
            ed = struct;
            ed.status = status;
            ed.msg = msg;

            notify(obj, 'GeneralMsg', BatchProgressEventData(type, ed));
            logDisp(dbstack, msg, status);

        end % notifyInitialFluxEvent

        %% Other functions
        function cancel(obj)
            % CANCEL Cancel the calculation.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            obj.isCanceled = true;

        end % cancel

        function tf = isValidateData(obj)
            % VALIDATEDATA Validate the data.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
            end % arguments

            tf = isValidateEfflux(obj);

            tmpS = obj.model.getS();
            obj.SFmincon = table2array(tmpS);

            if ~tf
                return;
            end % if

        end % validateData

        function tf = isValidateEfflux(obj)
            % VALIDATEEFFLUX Validate the efflux.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
            end % arguments

            tf = true;

            info = obj.exps.getInfoTable();

            if isempty(info)
                msg = "No information available for efflux validation.";
                notifyGeneralMessage(obj, "error", msg);
                tf = false;
                return;
            end % if

            try
                tmpMu = info{obj.expsList, "mu"};
                tmpMu = mean(tmpMu, 1);
                obj.mu = tmpMu;
            catch
                msg = "Information table is no valid";
                notifyGeneralMessage(obj, "error", msg);
                tf = false;
                return;
            end

            if ~all(tmpMu > 0)
                msg = "No growth rate available for efflux validation.";
                notifyGeneralMessage(obj, "error", msg);
                tf = false;
                return;
            end % if

            tmpS = obj.model.getSBefore();
            RxnName = tmpS.Properties.RowNames;
            SType = obj.model.getSType();
            rxn = RxnName(strcmp(SType, "efflux"));
            rxn = string(rxn);
            substrate = repmat("", length(rxn), 1);
            % getSubstrateNameFromRxnID
            for i = 1:length(rxn)
                substrate(i) = obj.model.getSubstrateNameFromRxnID(rxn(i));
            end % for

            % Check if each substrate is identical
            if length(unique(substrate)) ~= length(substrate)
                msg = "Substrates was duplicated.";
                notifyGeneralMessage(obj, "error", msg);
                tf = false;
                return;
            end % if

            % Assign the substrate list to the object
            obj.subsList = substrate;

            effluxTable = obj.exps.getUptakeTable();
            effluxExtracted = effluxTable{obj.expsList, obj.subsList};
            effluxExtracted = mean(effluxExtracted, 1);

            if any(isnan(effluxExtracted))
                msg = "Some efflux values are NaN. Please check the experimental data.";
                notifyGeneralMessage(obj, "error", msg);
                tf = false;
                return;
            end % if

            obj.efflux = effluxExtracted';

            % Efflux free
            isPerturbate = obj.config.perturbateEfflux;

            if isPerturbate

                perturbateSubstrateName = obj.config.efflux.substrate;
                perturbateSubstrateSelection = obj.config.efflux.selection;
                perturbateSubstrateSD = obj.config.efflux.substrateSD;

                if isempty(perturbateSubstrateName)
                    msg = "No substrate selected for efflux perturbation.";
                    notifyGeneralMessage(obj, "error", msg);
                    tf = false;
                    return;
                end % if

                [~, ia, ib] = intersect(perturbateSubstrateName, obj.subsList);

                if isempty(ia)
                    msg = "No matching substrate found for efflux perturbation.";
                    notifyGeneralMessage(obj, "error", msg);
                    tf = false;
                    return;
                end % if

                extractedPerturbateSelection = perturbateSubstrateSelection(ia);
                extractedPerturbateSD = perturbateSubstrateSD(ia);
                extractedPerturbateSelection = extractedPerturbateSelection(ib);
                extractedPerturbateSD = extractedPerturbateSD(ib);

                obj.effluxSD = extractedPerturbateSD;
                obj.effluxFree = extractedPerturbateSelection;
                effluxFree = obj.effluxSD(obj.effluxFree); %#ok<PROP>

                if any(effluxFree <= 0) %#ok<PROP>
                    msg = "Efflux standard deviation must be positive for perturbation.";
                    notifyGeneralMessage(obj, "error", msg);
                    tf = false;
                    return;
                end % if

                if any(isnan(effluxFree)) %#ok<PROP>
                    msg = "Efflux standard deviation contains NaN values for perturbation.";
                    notifyGeneralMessage(obj, "error", msg);
                    tf = false;
                    return;
                end % if

            end % if isPerturbate

        end % function validateEfflux

        function tf = isValidateMDV(obj)
            % ISVALIDATEMDV Validate the MDV.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %
            % Returns:
            %   tf: (1, 1) logical
            %       True if the MDV is valid, false otherwise.

            arguments
                obj (1, 1) FluxAnalysis
            end % arguments

            tf = true;

            if isempty(obj.MDVExp)
                msg = "MDV experimental data is not available.";
                notifyGeneralMessage(obj, "error", msg);
                tf = false;
                return;
            end % if

            usedMDV = obj.MDVExp(obj.MDVFragMask, :);
            % MDV list
            MDVList = obj.MDVFragList;
            usedMDVList = MDVList(obj.MDVFragMask, :);

            % NaN check
            if any(isnan(usedMDV(:)))

                isnanListMDVNameList = usedMDVList(any(isnan(usedMDV), 2), :);
                % Remove empty strings
                isnanListMDVNameList = isnanListMDVNameList(isnanListMDVNameList ~= "");
                isnanListMDVNameList = unique(isnanListMDVNameList);
                isnanListStr = strjoin(isnanListMDVNameList, ", ");

                msg = "MDV experimental data contains NaN values in the following fragments: " + isnanListStr + ".";
                notifyGeneralMessage(obj, "error", msg);
                tf = false;
                return;
            end % if

        end % function isValidateMDV

        function setINSTMFA(obj)

            config = obj.config; %#ok<PROP>

            obj.isInstationary = config.isINSTMFA; %#ok<PROP>
            poolSize = config.INSTMFA.poolSize; %#ok<PROP>
            obj.poolsize = poolSize;
            obj.timePoints = config.INSTMFA.timePoints; %#ok<PROP>

        end % function setINSTMFA

    end % methods (Access = private)

end % classdef
