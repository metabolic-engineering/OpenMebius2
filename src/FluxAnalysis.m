classdef FluxAnalysis < openmebius.infrastructure.logging.MessageState

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
        FluxVariabilitySolver
        InitialPointGenerator
        MFAProblemFactory
        SteadyStateSolver
        MFAProblem = []

        % File export
        isExport = true
        ResultLocation openmebius.domain.result.ResultLocation
        HDF5FileName = ""
        HDF5FilePath = ""
        Hdf5ResultRepository
        AnalysisRunRepository
        Provenance = struct
        AnalysisMetadata = struct
        RunStartedAtUtc (1, 1) string = ""
        RandomStateAtStart = struct
        IsRunMetadataWritten (1, 1) logical = false

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
        effluxFreeRxnID = string([])
        effluxFreeOriginalIndependent = logical([])

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

        % Variables for the optimization
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
                resultInput, ...
                ID, ...
                controller, ...
                options ...
            )

            arguments
                model
                experiments
                expList
                config
                resultInput
                ID
                controller = []
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result.Hdf5ResultRepository()
                options.ResultManifestRepository = ...
                    openmebius.infrastructure.result.ResultManifestRepository()
                options.FluxVariabilitySolver = ...
                    openmebius.mfa.FluxVariabilitySolver()
                options.InitialPointGenerator = ...
                    openmebius.mfa.InitialPointGenerator()
                options.MFAProblemFactory = ...
                    openmebius.mfa.MFAProblemFactory()
                options.SteadyStateSolver = ...
                    openmebius.mfa.SteadyStateSolver()
                options.Provenance (1, 1) struct = struct
            end

            resultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                resultInput);

            obj.ResultLocation = resultLocation;
            obj.HDF5FileName = ID;
            obj.HDF5FilePath = resultLocation.resultFile(ID);
            obj.Hdf5ResultRepository = options.Hdf5ResultRepository;
            obj.AnalysisRunRepository = ...
                openmebius.infrastructure.result.AnalysisRunRepository( ...
                Hdf5ResultRepository = options.Hdf5ResultRepository, ...
                ResultManifestRepository = options.ResultManifestRepository);
            obj.FluxVariabilitySolver = options.FluxVariabilitySolver;
            obj.InitialPointGenerator = options.InitialPointGenerator;
            obj.MFAProblemFactory = options.MFAProblemFactory;
            obj.SteadyStateSolver = options.SteadyStateSolver;
            obj.Provenance = options.Provenance;

            try
                obj.Hdf5ResultRepository.assertResultDirectory( ...
                    resultLocation);
            catch
                obj.isError = true;
                updateMsg(obj, ...
                    "The directory " + resultLocation.Directory + ...
                    " does not exist.", ...
                    "Error", ...
                    obj.logLevel);
            end

            if ~obj.isError
                updateMsg(obj, ...
                    "The directory " + resultLocation.Directory + ...
                    " exists.", ...
                    "Info", ...
                    obj.logLevel);
            end

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
            obj.status = openmebius.infrastructure.logging.MessageState();

            if ~isempty(controller) && isa(controller, 'handle') && isvalid(controller)

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
            obj.RunStartedAtUtc = string(datetime( ...
                "now", ...
                "TimeZone", "UTC", ...
                "Format", "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"));
            obj.RandomStateAtStart = rng;
            initializeRunMetadata(obj);
            runMetadataCleanup = onCleanup(@() finalizeRunMetadata(obj));

            if obj.isError
                return
            end

            % Data validation
            if ~isValidateData(obj)
                % Notify the initial flux event
                msg = "Data validation failed.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                obj.isError = true;
                return;
            end % if

            cleanupEffluxFreeModel = onCleanup(@() restoreEffluxFreeModel(obj)); %#ok<NASGU>

            calculateLinearizedMDV(obj);

            if ~isValidateMDV(obj)
                % Notify the initial flux event
                msg = "Invalid MDV data (e.g. NaN values).";
                notifyGeneralMessage(obj, "error", msg, dbstack());
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
                notifyGeneralMessage(obj, "info", msg, dbstack());
            end % if

            obj.UB = fluxUB;
            obj.LB = fluxLB;

            % Export the result of FVA
            exportFluxVariability(obj, fluxLB, fluxUB);

            fluxRange = obj.UB - obj.LB;
            averageFlux = mean(fluxRange);
            msg = "Average flux range: " + string(averageFlux) + " mmol/g/h";
            notifyGeneralMessage(obj, "info", msg, dbstack());

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
                notifyGeneralMessage(obj, "info", msg, dbstack());
                return;
            elseif err
                % Notify the initial flux event
                msg = "Initial flux distribution calculation failed.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                obj.isError = true;
                return;
            else
                % Notify the initial flux event
                msg = "Initial flux distribution calculation completed.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
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
                notifyGeneralMessage(obj, "info", msg, dbstack());

                % Define the initial values for the optimization
                iterationRightHandSide = tmpRhs(:, i);

                if ~obj.config.isINSTMFA
                    [fval, estimatedFlux, estimatedMDV, exitflag, optimizationOutput] = ...
                        calculateNonLinearOptimization( ...
                        obj, ...
                        obj.MDVExpFmincon, ...
                        iterationRightHandSide);
                else

                    [err, msg] = obj.setINSTMFA();
                    msg = "Instationary 13C-MFA: " + msg;

                    if err
                        notifyGeneralMessage(obj, "error", msg, dbstack());
                        obj.isError = true;
                        return;
                    end

                    [fval, estimatedFlux, estimatedMDV, exitflag, optimizationOutput] = ...
                        calculateNonLinearOptimizationInstationary( ...
                        obj, ...
                        obj.MDVExpFmincon, ...
                        iterationRightHandSide);
                end

                exportFluxResult(obj, i, estimatedFlux, fval, estimatedMDV, exitflag, optimizationOutput);

                obj.resultRSS(i) = fval;
                obj.resultFlux(:, i) = estimatedFlux;
                obj.resultMDV(:, :, i) = arrangeMDV(obj, estimatedMDV);

                % Calcel the calculation
                if obj.isCanceled
                    msg = "Nonlinear optimization canceled.";
                    notifyGeneralMessage(obj, "info", msg, dbstack());
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
            elapsedTimeText = string(seconds(tStop), "hh:mm:ss");
            msg = "Flux calculation completed" + ...
                " (Elapsed time: " + elapsedTimeText + ", " + ...
                "RSS: " + string(minRSS) + ")";
            notifyGeneralMessage(obj, "info", msg, dbstack());

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
            runMetadataCleanup = onCleanup(@() finalizeRunMetadata(obj));

            msg = "Calculating confidence interval...";
            notifyGeneralMessage(obj, "info", msg, dbstack());

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
                    notifyGeneralMessage(obj, "info", msg, dbstack());

                otherwise
                    msg = "Unknown method for calculating confidence interval.";
                    notifyGeneralMessage(obj, "error", msg, dbstack());
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
            notifyGeneralMessage(obj, "info", msg, dbstack());

            SBefore = obj.model.getSBefore();
            numFlux = size(SBefore, 2);

            % Get maximum efflux of the flux
            maxEfflux = max(obj.efflux);

            if isempty(maxEfflux) || maxEfflux <= 0
                maxEfflux = 1000;
                msg = "Maximum efflux is not set or non-positive. Using default value: " + string(maxEfflux) + ".";
                notifyGeneralMessage(obj, "warning", msg, dbstack());
            end

            fluxUB = repmat(maxEfflux * 1000, numFlux, 1);
            fluxLB = repmat(-maxEfflux * 1000, numFlux, 1);

            if options.customBoundary
                fluxLB = options.fluxLB;
                fluxUB = options.fluxUB;
            end % if

            idxRevTable = obj.model.getIdxRev();
            maskIrrev = ~ismember(1:numFlux, idxRevTable);
            fluxLB(maskIrrev) = max(fluxLB(maskIrrev), 0);

            tmpRhs = calculateRHS(obj);
            tmpRhs = tmpRhs(1:size(SBefore, 1));

            RxnName = string(SBefore.Properties.VariableNames);
            idxRev = regexp(RxnName, "_rev$", "match");
            maskRev = ~cellfun(@isempty, idxRev);
            SBefore{:, maskRev} = 0;

            Aeq = table2array(SBefore);
            beq = tmpRhs;

            % Efflux-free reactions must not be fixed during FVA.  In some
            % model states the efflux rows can still remain in SBefore even
            % after the corresponding reactions have been promoted to
            % independent variables; remove those equality constraints
            % explicitly for the FVA LPs.
            maskEffluxFreeRows = getEffluxFreeConstraintRowMask(obj, SBefore);

            if any(maskEffluxFreeRows)
                Aeq(maskEffluxFreeRows, :) = [];
                beq(maskEffluxFreeRows) = [];

                msg = "FVA will not fix efflux-free reactions: " + ...
                    strjoin(string(SBefore.Properties.RowNames(maskEffluxFreeRows)), ", ") + ".";
                notifyGeneralMessage(obj, "info", msg, dbstack());
            end

            reverseCounterpartIndices = nan(numFlux, 1);
            reverseFluxIndices = find(maskRev);

            for iFlux = reshape(reverseFluxIndices, 1, [])
                reactionId = SBefore.Properties.VariableNames{iFlux};
                reverseCounterpartIndices(iFlux) = ...
                    obj.model.findCounterReaction(reactionId);
            end

            solverResult = obj.FluxVariabilitySolver.solve( ...
                Aeq, ...
                beq(:), ...
                fluxLB(:), ...
                fluxUB(:), ...
                reverseCounterpartIndices);
            UB = solverResult.UpperBounds;
            LB = solverResult.LowerBounds;
            err = solverResult.IsError;
            status = solverResult.ExitFlag;

            if err
                notifyGeneralMessage( ...
                    obj, ...
                    "error", ...
                    solverResult.ErrorMessage, ...
                    dbstack());
            end

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
            notifyGeneralMessage(obj, "info", msg, dbstack());

            try
                obj.MFAProblem = obj.MFAProblemFactory.create( ...
                    obj.model.getS(), ...
                    obj.model.getSType(), ...
                    obj.rhs(:), ...
                    obj.LB(:), ...
                    obj.UB(:));
            catch ME
                flux = [];
                rhs = [];
                RSS = [];
                err = true;
                msg = "Failed to create the MFA problem. " + ...
                    string(ME.message);
                notifyGeneralMessage(obj, "error", msg, dbstack());
                return
            end

            switch options.method

                case "random"
                    [flux, rhs] = calculateInitialFluxDistributionRandom( ...
                        obj, ...
                        iterationRate = options.iterationRate, ...
                        whileIteration = options.whileIteration, ...
                        maxTime = options.maxTime ...
                    );
                    msg = "Initial flux distribution calculated randomly.";
                    notifyGeneralMessage(obj, "info", msg, dbstack());

                case "hit-and-run"
                    [flux, rhs, err] = calculateInitialFluxDistributionHitAndRun( ...
                        obj, ...
                        iterationRate = options.iterationRate, ...
                        burnin = options.burnin, ...
                        thinning = options.thinning, ...
                        maxTime = options.maxTime, ...
                        seed = options.seed ...
                    );

                    if err
                        RSS = [];
                        return;
                    end

                    msg = "Initial flux distribution calculated using Hit-and-Run.";
                    notifyGeneralMessage(obj, "info", msg, dbstack());

                otherwise
                    error("Unknown method for initial flux distribution calculation.");
            end

            if obj.isCanceled
                msg = "Initial flux distribution calculation canceled.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
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
                notifyGeneralMessage(obj, "info", msg, dbstack());
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
            notifyGeneralMessage(obj, "info", msg, dbstack());

            % Notify the initial flux event
            msg = "Suggesting next flux experiment...";
            notifyGeneralMessage(obj, "info", msg, dbstack());

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
                notifyGeneralMessage(obj, "info", msg, dbstack());

                [iFluxLB, iFluxUB, ~] = calculateNextLabelPattern(obj, cellstr(pattern));

                exportNextLabelPatternCIMC(obj, pattern, iFluxLB, iFluxUB);

                if obj.isCanceled
                    msg = "Next flux experiment suggestion canceled.";
                    notifyGeneralMessage(obj, "info", msg, dbstack());
                    return;
                end % if

            end % for

            msg = "Next flux experiment suggested.";
            notifyGeneralMessage(obj, "info", msg, dbstack());

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

        function maskEffluxFreeRows = getEffluxFreeConstraintRowMask(obj, SBefore)
            % GETEFFLUXFREECONSTRAINTROWMASK Return efflux rows excluded from FVA.
            %
            % Efflux-free reactions are fitted through the objective function
            % using their experimental values and standard deviations.  They
            % must therefore not be fixed as equality constraints during FVA.

            arguments
                obj (1, 1) FluxAnalysis
                SBefore table
            end % arguments

            nRow = size(SBefore, 1);
            maskEffluxFreeRows = false(nRow, 1);

            if isempty(obj.effluxFree) || ~any(obj.effluxFree)
                return;
            end % if

            SType = string(obj.model.getSType());
            rowName = string(SBefore.Properties.RowNames);
            nType = min([nRow, length(SType)]);

            idxEffluxRows = find(SType(1:nType) == "efflux");
            freeSubstrate = obj.subsList(logical(obj.effluxFree(:)));

            for i = 1:length(idxEffluxRows)

                iRow = idxEffluxRows(i);
                iRxnID = rowName(iRow);
                iSubstrate = obj.model.getSubstrateNameFromRxnID(iRxnID);

                if any(freeSubstrate == iSubstrate)
                    maskEffluxFreeRows(iRow) = true;
                end % if

            end % for

        end % getEffluxFreeConstraintRowMask

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
            RxnName = string(tmpS.Properties.RowNames);
            SType = string(obj.model.getSType());

            idxBiomass = find(RxnName == "biomass", 1);

            tmpRhs = zeros(size(tmpS, 2), 1);
            tmpRhs(idxBiomass) = obj.mu;

            % Fixed effluxes are written to the RHS by matching the
            % efflux-row reaction ID to the substrate name. Effluxes selected
            % as free variables are removed from the efflux rows by
            % makeEffluxFree and are therefore left as independent variables.
            idxEffluxRows = find(SType(1:length(RxnName)) == "efflux");

            for i = 1:length(idxEffluxRows)

                iRow = idxEffluxRows(i);
                iRxnID = RxnName(iRow);
                iSubstrate = obj.model.getSubstrateNameFromRxnID(iRxnID);
                idxSubstrate = find(obj.subsList == iSubstrate, 1);

                if isempty(idxSubstrate)
                    continue;
                end

                tmpRhs(iRow) = obj.efflux(idxSubstrate);

            end

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
            generatorResult = obj.InitialPointGenerator.generateRandom( ...
                obj.MFAProblem, ...
                numInitalFluxReq, ...
                IterationsPerBatch = options.whileIteration, ...
                MaxTime = options.maxTime, ...
                CancellationRequested = @() obj.isCanceled, ...
                ProgressReporter = ...
                @(count, elapsed) obj.notifyRandomInitialPointProgress( ...
                count, elapsed));
            flux = generatorResult.Fluxes;
            rhs = generatorResult.RightHandSides;

            if generatorResult.IsCanceled
                notifyGeneralMessage( ...
                    obj, ...
                    "info", ...
                    "Initial flux distribution calculation canceled.", ...
                    dbstack());
            end

        end % calculateInitialFluxDistributionRandom

        function notifyRandomInitialPointProgress(obj, count, elapsedSeconds)

            elapsed = string(seconds(elapsedSeconds), "hh:mm:ss");
            msg = "Calculating initial flux distribution randomly" + ...
                " (Elapsed time: " + elapsed + ", " + ...
                "Found " + string(count) + ...
                " feasible flux distributions)";
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % notifyRandomInitialPointProgress

        function reportInitialPointMessage(obj, level, message)

            notifyGeneralMessage(obj, level, message, dbstack());

        end % reportInitialPointMessage

        function reportSteadyStateMessage(obj, level, message)

            notifyGeneralMessage(obj, level, message, dbstack());

        end % reportSteadyStateMessage

        function [flux, rhs, err] = calculateInitialFluxDistributionHitAndRun(obj, options)
            % CALCULATEINITIALFLUXDISTRIBUTIONHITANDRUN
            % Standard Hit-and-Run in z-space.
            %
            % v = vBase + B*x
            % x = x0 + N*z
            % v = v0 + G*z

            arguments
                obj (1, 1) FluxAnalysis
                options.iterationRate (1, 1) double = 100
                options.burnin (1, 1) double = 2000
                options.thinning (1, 1) double = 10
                options.maxStep (1, 1) double = 1e7
                options.maxTime (1, 1) double = 3600
                options.seed (1, 1) double = 0
                options.epsFeas (1, 1) double = 1e-8
                options.epsEq (1, 1) double = 1e-9
                options.minDirectionNorm (1, 1) double = 1e-12
                options.maxInvalidRange (1, 1) double = 100000
                options.maxZeroWidth (1, 1) double = 100000
            end

            iteration = obj.config.iteration;
            numReq = iteration * options.iterationRate;

            randomStream = RandStream.getGlobalStream();

            if options.seed ~= 0
                randomStream = RandStream("mt19937ar", ...
                    "Seed", options.seed);
            end

            generatorResult = obj.InitialPointGenerator.generateHitAndRun( ...
                obj.MFAProblem, ...
                numReq, ...
                iteration, ...
                BurnIn = options.burnin, ...
                Thinning = options.thinning, ...
                MaxStep = options.maxStep, ...
                MaxTime = options.maxTime, ...
                FeasibilityTolerance = options.epsFeas, ...
                EqualityTolerance = options.epsEq, ...
                MinimumDirectionNorm = options.minDirectionNorm, ...
                MaxInvalidRange = options.maxInvalidRange, ...
                MaxZeroWidth = options.maxZeroWidth, ...
                RandomStream = randomStream, ...
                CancellationRequested = @() obj.isCanceled, ...
                ProgressReporter = ...
                    @(level, message) ...
                    obj.reportInitialPointMessage(level, message));

            flux = generatorResult.Fluxes;
            rhs = generatorResult.RightHandSides;
            err = generatorResult.IsError || generatorResult.IsCanceled;

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
            notifyGeneralMessage(obj, "info", msg, dbstack());

            EMU = getSubstrateEMU(obj, ...
                "useCustomEMU", true, ...
                "customPattern", pattern);

            % Store the EMU of the substrate
            obj.subsEMUs{end} = EMU;

            if obj.isCanceled
                msg = "Next flux experiment suggestion canceled.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
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
                notifyGeneralMessage(obj, "info", msg, dbstack());
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
                RSS(i) = sum(iRSS, 1) + calculateEffluxRSS(obj, fluxes(:, i));

            end % for

            % Sort the RSS
            [RSS, idx] = sort(RSS, "ascend");

            % Count the number of valid flux distributions
            numValidFlux = sum(RSS < RSSInvalid);
            msg = "Number of valid flux distributions: " + string(numValidFlux);
            notifyGeneralMessage(obj, "info", msg, dbstack());

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
        function SSR = calculateObjectiveFunction( ...
                obj, independentFlux, MDVExpTemp, rightHandSide)
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

            tmpFlux = obj.MFAProblem.solveFlux( ...
                independentFlux, ...
                BaseRightHandSide = rightHandSide);

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

            SSR = SSR + calculateEffluxRSS(obj, tmpFlux);

        end % calculateObjectiveFunction

        function SSR = calculateObjectiveFunctionInstationary( ...
                obj, ...
                independentFlux, ...
                MDVExpTemp, ...
                rightHandSide ...
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

            tmpFlux = obj.MFAProblem.solveFlux( ...
                independentFlux, ...
                BaseRightHandSide = rightHandSide);
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
            SSR = SSR + calculateEffluxRSS(obj, tmpFlux);

        end % calculateObjectiveFunctionInstationary

        function [c, ceq] = calculateConstraints( ...
                obj, independentFlux, rightHandSide)
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

            if nargin < 3
                rightHandSide = obj.MFAProblem.RightHandSide;
            end

            c = -obj.MFAProblem.solveFlux( ...
                independentFlux, ...
                BaseRightHandSide = rightHandSide);
            ceq = [];

        end % calculateConstraints

        function RSS = calculateEffluxRSS(obj, flux)
            % CALCULATEEFFLUXRSS Calculate the RSS contribution of free effluxes.

            arguments
                obj (1, 1) FluxAnalysis
                flux (:, :) double
            end

            numFlux = size(flux, 2);
            RSS = zeros(1, numFlux);

            if isempty(obj.effluxFree) || ~any(obj.effluxFree)
                return;
            end

            selectedIdx = find(logical(obj.effluxFree(:)));
            rxnNames = string(obj.model.getSBefore().Properties.VariableNames);
            rxnIdx = nan(length(selectedIdx), 1);

            for i = 1:length(selectedIdx)

                iSubstrate = obj.subsList(selectedIdx(i));
                iRxnID = obj.model.findSubstrateRxnIDFromMetaboliteIrrev(iSubstrate);
                iRxnIdx = find(rxnNames == iRxnID, 1);

                if isempty(iRxnIdx)
                    error("Selected efflux reaction was not found in the stoichiometry matrix: %s.", iRxnID);
                end

                rxnIdx(i) = iRxnIdx;

            end

            effluxExp = obj.efflux(selectedIdx);
            effluxSDSelected = obj.effluxSD(selectedIdx);
            effluxSimulated = flux(rxnIdx, :);

            iRSS = ((effluxSimulated - effluxExp) ./ effluxSDSelected) .^ 2;
            RSS = sum(iRSS, 1);

        end % calculateEffluxRSS

        function [fval, estimatedFlux, estimatedMDV, exitflag, output] = ...
                calculateNonLinearOptimization( ...
                obj, MDVExpTemp, rightHandSide)
            % CALCULATENONLINEAROPTIMIZATION Calculate the nonlinear optimization.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            tmpInitialFlux = ...
                obj.MFAProblem.extractIndependentValues(rightHandSide);

            objectiveFcn = @(x) calculateObjectiveFunction( ...
                obj, x, MDVExpTemp, rightHandSide);

            [x, fval, exitflag, output] = ...
                runConfiguredNonlinearOptimizer( ...
                obj, ...
                objectiveFcn, ...
                tmpInitialFlux, ...
                rightHandSide ...
            );

            estimatedFlux = obj.MFAProblem.solveFlux( ...
                x, ...
                BaseRightHandSide = rightHandSide);
            estimatedMDV = calculateMDV(obj, estimatedFlux, obj.subsEMUs);

            if isnan(fval)
                msg = "Nonlinear optimization failed.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                return;
            else
                stepSizeMsg = "";

                if isfield(output, 'fminconFiniteDifferenceStepSize')
                    stepSizeMsg = " FiniteDifferenceStepSize: " + ...
                        string(output.fminconFiniteDifferenceStepSize) + ".";
                end % if

                msg = "Nonlinear optimization completed. " + ...
                    "RSS: " + string(fval) + "." + stepSizeMsg;
            end % if

            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % calculateNonLinearOptimization

        function [fval, estimatedFlux, estimatedMDV, exitflag, output] = ...
                calculateNonLinearOptimizationInstationary( ...
                obj, MDVExpTemp, rightHandSide)
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

            tmpInitialFlux = ...
                obj.MFAProblem.extractIndependentValues(rightHandSide);

            objectiveFcn = @(x) calculateObjectiveFunctionInstationary( ...
                obj, x, MDVExpTemp, rightHandSide);

            [x, fval, exitflag, output] = ...
                runConfiguredNonlinearOptimizer( ...
                obj, ...
                objectiveFcn, ...
                tmpInitialFlux, ...
                rightHandSide ...
            );

            estimatedFlux = obj.MFAProblem.solveFlux( ...
                x, ...
                BaseRightHandSide = rightHandSide);
            estimatedMDV = obj.model.calculateMDVTimeCourse( ...
                estimatedFlux, ...
                obj.subsEMUs{1}, ...
                obj.poolsize, ...
                obj.timePoints ...
            );

            if isnan(fval)
                msg = "Nonlinear optimization for instationary MFA failed.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                return;
            else
                stepSizeMsg = "";

                if isfield(output, 'fminconFiniteDifferenceStepSize')
                    stepSizeMsg = " FiniteDifferenceStepSize: " + ...
                        string(output.fminconFiniteDifferenceStepSize) + ".";
                end % if

                msg = "Nonlinear optimization for instationary MFA completed. " + ...
                    "RSS: " + string(fval) + "." + stepSizeMsg;
                notifyGeneralMessage(obj, "info", msg, dbstack());
            end % if

        end % calculateNonLinearOptimizationInstationary

        function [x, fval, exitflag, output] = runConfiguredNonlinearOptimizer( ...
                obj, objectiveFcn, initialFlux, rightHandSide)
            % RUNCONFIGUREDNONLINEAROPTIMIZER Run FMINCON with safeguards.
            %
            % GA-based hybrid optimization is intentionally disabled for now.
            % FMINCON starts from the supplied feasible initial flux vector.
            % Optionally, several FiniteDifferenceStepSize values are tried
            % and the best feasible FMINCON result is selected.

            method = getOptimizationMethod(obj);
            startFlux = initialFlux(:);

            if ismember(method, ["hybrid-ga-gradient", "hybrid", "ga-gradient"])
                msg = "Hybrid GA optimization is temporarily disabled. Using FMINCON only.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
            elseif ~ismember(method, ["gradient-only", "fmincon", "local"])
                msg = "Unknown optimizationMethod '" + method + "'. Using FMINCON only.";
                notifyGeneralMessage(obj, "warning", msg, dbstack());
            end % if

            [solverOptions, optionWarnings] = ...
                openmebius.mfa.SteadyStateOptions.fromBatchConfig( ...
                obj.config);

            for iWarning = 1:numel(optionWarnings)
                notifyGeneralMessage( ...
                    obj, "warning", optionWarnings(iWarning), dbstack());
            end

            solverResult = obj.SteadyStateSolver.solve( ...
                obj.MFAProblem, ...
                rightHandSide, ...
                objectiveFcn, ...
                solverOptions, ...
                InitialIndependentValues = startFlux, ...
                MessageReporter = ...
                    @(level, message) ...
                    obj.reportSteadyStateMessage(level, message));
            x = solverResult.IndependentValues;
            fval = solverResult.ObjectiveValue;
            exitflag = solverResult.ExitFlag;
            output = solverResult.Output;

        end % runConfiguredNonlinearOptimizer

        function method = getOptimizationMethod(obj)
            % GETOPTIMIZATIONMETHOD Return the normalized nonlinear optimizer name.

            method = "gradient-only";

            if isfield(obj.config, 'optimizationMethod') && ...
                    ~isempty(obj.config.optimizationMethod)
                method = lower(string(obj.config.optimizationMethod));
            end % if

        end % getOptimizationMethod

        function gaConfig = getGAConfig(obj, nVariables)
            % GETGACONFIG Read GA configuration with safe defaults.

            userConfig = struct;

            if isfield(obj.config, 'GA') && isstruct(obj.config.GA)
                userConfig = obj.config.GA;
            end % if

            gaConfig = struct;
            gaConfig.populationSize = max(4, round(readNumericConfig(obj, userConfig, 'populationSize', max(50, 4 * nVariables))));
            gaConfig.generations = max(1, round(readNumericConfig(obj, userConfig, 'generations', 40)));
            gaConfig.eliteCount = max(1, round(readNumericConfig(obj, userConfig, 'eliteCount', 2)));
            gaConfig.eliteCount = min(gaConfig.eliteCount, gaConfig.populationSize);
            gaConfig.tournamentSize = max(2, round(readNumericConfig(obj, userConfig, 'tournamentSize', 3)));
            gaConfig.crossoverFraction = min(1, max(0, readNumericConfig(obj, userConfig, 'crossoverFraction', 0.80)));
            gaConfig.mutationRate = min(1, max(0, readNumericConfig(obj, userConfig, 'mutationRate', 0.20)));
            gaConfig.mutationScale = max(0, readNumericConfig(obj, userConfig, 'mutationScale', 0.10));
            gaConfig.penaltyScale = max(0, readNumericConfig(obj, userConfig, 'penaltyScale', 1e6));
            gaConfig.feasibilityTolerance = max(0, readNumericConfig(obj, userConfig, 'feasibilityTolerance', 1e-8));
            gaConfig.functionTolerance = max(0, readNumericConfig(obj, userConfig, 'functionTolerance', 1e-9));
            gaConfig.stallGenerations = max(1, round(readNumericConfig(obj, userConfig, 'stallGenerations', 10)));
            gaConfig.seed = round(readNumericConfig(obj, userConfig, 'seed', 0));
            gaConfig.maxInitialSeeds = max(1, round(readNumericConfig(obj, userConfig, 'maxInitialSeeds', gaConfig.populationSize)));

        end % getGAConfig

        function value = readNumericConfig(~, userConfig, fieldName, defaultValue)
            % READNUMERICCONFIG Read a scalar numeric field from a struct.

            value = defaultValue;

            if isstruct(userConfig) && isfield(userConfig, fieldName) && ...
                    ~isempty(userConfig.(fieldName))
                candidate = userConfig.(fieldName);

                if isnumeric(candidate) || islogical(candidate)
                    value = double(candidate(1));
                end % if

            end % if

        end % readNumericConfig

        function [bestStart, gaOutput] = calculateGAStartPoint(obj, objectiveFcn, initialFlux)
            % CALCULATEGASTARTPOINT Search a FMINCON start point by GA.

            msg = "Initializing GA global-search stage for hybrid optimization...";
            notifyGeneralMessage(obj, "info", msg, dbstack());

            initialFlux = initialFlux(:);
            nVariables = length(initialFlux);
            gaConfig = getGAConfig(obj, nVariables);
            [lowerBound, upperBound, seedPool] = deriveGABoundsFromInitialPopulation(obj, initialFlux, gaConfig);
            variableSpan = upperBound - lowerBound;

            if gaConfig.seed > 0
                previousRandomState = rng;
                cleanupRandomState = onCleanup(@() rng(previousRandomState));
                rng(gaConfig.seed, 'twister');
            end % if

            population = initializeGAPopulation(obj, initialFlux, seedPool, lowerBound, upperBound, gaConfig);
            [score, rawScore, violation] = evaluateGAPopulation(obj, population, objectiveFcn, gaConfig);

            [bestPenaltyObjective, bestPenaltyIndex] = min(score);
            bestPenaltyFlux = population(:, bestPenaltyIndex);
            bestFeasibleObjective = inf;
            bestFeasibleFlux = initialFlux;
            feasible = violation <= gaConfig.feasibilityTolerance;

            if any(feasible)
                feasibleRawScore = rawScore;
                feasibleRawScore(~feasible) = inf;
                [bestFeasibleObjective, bestFeasibleIndex] = min(feasibleRawScore);
                bestFeasibleFlux = population(:, bestFeasibleIndex);
            end % if

            initialObjective = safeObjectiveEvaluation(obj, objectiveFcn, initialFlux);
            bestHistory = nan(gaConfig.generations, 1);
            stallCount = 0;
            previousBest = bestPenaltyObjective;
            performedGenerations = 0;

            for generation = 1:gaConfig.generations

                if obj.isCanceled
                    break;
                end % if

                performedGenerations = generation;
                [~, order] = sort(score, 'ascend');
                nextPopulation = zeros(nVariables, gaConfig.populationSize);
                nextPopulation(:, 1:gaConfig.eliteCount) = population(:, order(1:gaConfig.eliteCount));

                nextIndex = gaConfig.eliteCount + 1;

                while nextIndex <= gaConfig.populationSize

                    parent1 = population(:, tournamentSelect(obj, score, gaConfig.tournamentSize));
                    parent2 = population(:, tournamentSelect(obj, score, gaConfig.tournamentSize));

                    [child1, child2] = crossoverGAIndividuals(obj, parent1, parent2, gaConfig);
                    child1 = mutateGAIndividual(obj, child1, variableSpan, gaConfig);
                    child2 = mutateGAIndividual(obj, child2, variableSpan, gaConfig);
                    child1 = min(max(child1, lowerBound), upperBound);
                    child2 = min(max(child2, lowerBound), upperBound);

                    nextPopulation(:, nextIndex) = child1;
                    nextIndex = nextIndex + 1;

                    if nextIndex <= gaConfig.populationSize
                        nextPopulation(:, nextIndex) = child2;
                        nextIndex = nextIndex + 1;
                    end % if

                end % while

                population = nextPopulation;
                [score, rawScore, violation] = evaluateGAPopulation(obj, population, objectiveFcn, gaConfig);

                [currentBestPenaltyObjective, currentBestPenaltyIndex] = min(score);

                if currentBestPenaltyObjective < bestPenaltyObjective
                    bestPenaltyObjective = currentBestPenaltyObjective;
                    bestPenaltyFlux = population(:, currentBestPenaltyIndex);
                end % if

                feasible = violation <= gaConfig.feasibilityTolerance;

                if any(feasible)
                    feasibleRawScore = rawScore;
                    feasibleRawScore(~feasible) = inf;
                    [currentBestFeasibleObjective, currentBestFeasibleIndex] = min(feasibleRawScore);

                    if currentBestFeasibleObjective < bestFeasibleObjective
                        bestFeasibleObjective = currentBestFeasibleObjective;
                        bestFeasibleFlux = population(:, currentBestFeasibleIndex);
                    end % if

                end % if

                bestHistory(generation) = bestPenaltyObjective;

                if abs(previousBest - bestPenaltyObjective) <= gaConfig.functionTolerance * max(1, abs(previousBest))
                    stallCount = stallCount + 1;
                else
                    stallCount = 0;
                end % if

                previousBest = bestPenaltyObjective;

                if stallCount >= gaConfig.stallGenerations
                    break;
                end % if

            end % for

            if isfinite(bestFeasibleObjective)
                bestStart = bestFeasibleFlux;
            else
                bestStart = bestPenaltyFlux;
            end % if

            gaOutput = struct;
            gaOutput.enabled = true;
            gaOutput.method = "hybrid-ga-gradient";
            gaOutput.populationSize = gaConfig.populationSize;
            gaOutput.generations = performedGenerations;
            gaOutput.initialObjective = initialObjective;
            gaOutput.bestPenaltyObjective = bestPenaltyObjective;
            gaOutput.bestFeasibleObjective = bestFeasibleObjective;
            gaOutput.bestHistory = bestHistory(1:max(performedGenerations, 1));
            gaOutput.feasibilityTolerance = gaConfig.feasibilityTolerance;
            gaOutput.message = "GA global-search stage completed.";

            msg = "Hybrid optimization stage 1 (GA) completed. Initial RSS: " + ...
                string(initialObjective) + ", GA best feasible RSS: " + ...
                string(bestFeasibleObjective) + ", GA best penalized objective: " + ...
                string(bestPenaltyObjective) + ".";
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % calculateGAStartPoint

        function [lowerBound, upperBound, seedPool] = deriveGABoundsFromInitialPopulation(obj, initialFlux, gaConfig)
            % DERIVEGABOUNDSFROMINITIALPOPULATION Build GA search bounds.
            %
            % The hit-and-run initial flux distribution already generated by
            % OpenMebius2 is used as a data-driven box. This keeps the GA in
            % a physically meaningful region while preserving a global search
            % stage before FMINCON.

            initialFlux = initialFlux(:);
            seedPool = initialFlux;

            if ~isempty(obj.initialRhs) && ...
                    size(obj.initialRhs, 1) == ...
                    numel(obj.MFAProblem.IndependentMask)
                candidateSeeds = obj.MFAProblem.extractIndependentValues( ...
                    obj.initialRhs);
                validColumns = all(isfinite(candidateSeeds), 1);
                candidateSeeds = candidateSeeds(:, validColumns);

                if ~isempty(candidateSeeds)
                    candidateSeeds = candidateSeeds(:, 1:min(size(candidateSeeds, 2), gaConfig.maxInitialSeeds));
                    seedPool = [seedPool, candidateSeeds]; %#ok<AGROW>
                end % if

            end % if

            seedPool = seedPool(:, all(isfinite(seedPool), 1));

            if isempty(seedPool)
                seedPool = initialFlux;
            end % if

            lowerBound = min(seedPool, [], 2);
            upperBound = max(seedPool, [], 2);
            span = upperBound - lowerBound;
            globalScale = max([1; abs(seedPool(:)); abs(initialFlux(:))]);
            minWidth = max(1e-9, 1e-6 * max(1, abs(initialFlux)));
            degenerate = span < minWidth;
            lowerBound(degenerate) = initialFlux(degenerate) - max(1, 0.5 * globalScale);
            upperBound(degenerate) = initialFlux(degenerate) + max(1, 0.5 * globalScale);

            span = upperBound - lowerBound;
            padding = 0.05 * max(span, minWidth);
            lowerBound = lowerBound - padding;
            upperBound = upperBound + padding;

            invalid = ~isfinite(lowerBound) | ~isfinite(upperBound) | lowerBound >= upperBound;

            if any(invalid)
                fallbackWidth = max(1, 0.5 * globalScale);
                lowerBound(invalid) = initialFlux(invalid) - fallbackWidth;
                upperBound(invalid) = initialFlux(invalid) + fallbackWidth;
            end % if

        end % deriveGABoundsFromInitialPopulation

        function population = initializeGAPopulation(obj, initialFlux, seedPool, lowerBound, upperBound, gaConfig)
            % INITIALIZEGAPOPULATION Create the initial GA population.

            nVariables = length(initialFlux);
            population = zeros(nVariables, gaConfig.populationSize);
            seedCount = min(size(seedPool, 2), gaConfig.populationSize);
            population(:, 1:seedCount) = seedPool(:, 1:seedCount);

            if seedCount < gaConfig.populationSize
                span = upperBound - lowerBound;
                randomCount = gaConfig.populationSize - seedCount;
                population(:, seedCount + 1:gaConfig.populationSize) = ...
                    repmat(lowerBound, 1, randomCount) + ...
                    repmat(span, 1, randomCount) .* rand(nVariables, randomCount);
            end % if

            population = min( ...
                max(population, repmat(lowerBound, 1, gaConfig.populationSize)), ...
                repmat(upperBound, 1, gaConfig.populationSize) ...
            );

        end % initializeGAPopulation

        function [score, rawScore, violation] = evaluateGAPopulation(obj, population, objectiveFcn, gaConfig)
            % EVALUATEGAPOPULATION Evaluate objective plus constraint penalty.

            populationSize = size(population, 2);
            score = inf(1, populationSize);
            rawScore = inf(1, populationSize);
            violation = inf(1, populationSize);

            for i = 1:populationSize

                if obj.isCanceled
                    return;
                end % if

                currentFlux = population(:, i);
                rawScore(i) = safeObjectiveEvaluation(obj, objectiveFcn, currentFlux);

                try
                    [c, ceq] = calculateConstraints(obj, currentFlux);
                    violation(i) = sum(max(c(:), 0) .^ 2) + sum(abs(ceq(:)) .^ 2);
                catch
                    violation(i) = inf;
                end % try

                if isfinite(rawScore(i)) && isfinite(violation(i))
                    score(i) = rawScore(i) + gaConfig.penaltyScale * ...
                        max(1, abs(rawScore(i))) * violation(i);
                end % if

            end % for

        end % evaluateGAPopulation

        function objectiveValue = safeObjectiveEvaluation(~, objectiveFcn, flux)
            % SAFEOBJECTIVEEVALUATION Robust objective evaluation for GA.

            try
                objectiveValue = objectiveFcn(flux(:));
                objectiveValue = double(objectiveValue(1));
            catch
                objectiveValue = inf;
            end % try

            if ~isfinite(objectiveValue) || isnan(objectiveValue)
                objectiveValue = inf;
            end % if

        end % safeObjectiveEvaluation

        function selectedIndex = tournamentSelect(~, score, tournamentSize)
            % TOURNAMENTSELECT Select one individual by tournament selection.

            candidates = randi(length(score), tournamentSize, 1);
            [~, bestCandidateIndex] = min(score(candidates));
            selectedIndex = candidates(bestCandidateIndex);

        end % tournamentSelect

        function [child1, child2] = crossoverGAIndividuals(~, parent1, parent2, gaConfig)
            % CROSSOVERGAINDIVIDUALS Arithmetic crossover for real-valued genes.

            if rand() < gaConfig.crossoverFraction
                alpha = rand(size(parent1));
                child1 = alpha .* parent1 + (1 - alpha) .* parent2;
                child2 = alpha .* parent2 + (1 - alpha) .* parent1;
            else
                child1 = parent1;
                child2 = parent2;
            end % if

        end % crossoverGAIndividuals

        function individual = mutateGAIndividual(~, individual, variableSpan, gaConfig)
            % MUTATEGAINDIVIDUAL Gaussian mutation for real-valued genes.

            mutationMask = rand(size(individual)) < gaConfig.mutationRate;

            if any(mutationMask)
                mutationStep = gaConfig.mutationScale .* max(variableSpan, eps) .* randn(size(individual));
                individual(mutationMask) = individual(mutationMask) + mutationStep(mutationMask);
            end % if

        end % mutateGAIndividual

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

        function rightHandSide = ...
                createConfidenceIntervalRightHandSide(obj, bestFlux)

            baseRightHandSide = obj.MFAProblem.RightHandSide;

            if ~isempty(obj.initialRhs)
                baseRightHandSide = obj.initialRhs(:, end);
            end

            independentValues = ...
                bestFlux(obj.MFAProblem.BoundaryReactionMask);
            rightHandSide = obj.MFAProblem.composeRightHandSide( ...
                independentValues, ...
                BaseRightHandSide = baseRightHandSide);

        end % createConfidenceIntervalRightHandSide

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

            if isfield(config, "procedure")
                procedure = config.procedure;
            else
                procedure = "Single run";
            end

            switch procedure
                case "Single run"
                    [fluxLB, fluxUB, output] = ...
                        calculateCIMCSingleRun(obj, config);
                case "Multiple run"
                    [fluxLB, fluxUB, output] = ...
                        calculateCIMCMultiRun(obj, config);
                otherwise
                    msg = "Unknown procedure: " + string(procedure) + ...
                        ". Use 'Single' or 'Multi'.";
                    notifyGeneralMessage(obj, "error", msg, dbstack());
                    return;
            end % switch

        end % calculateCIMC

        function [fluxLB, fluxUB, output] = calculateCIMCSingleRun(obj, config)
            % CALCULATECIMCMULTIRUN Calculate the confidence interval using Monte Carlo method with multiple runs.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   config: (1, 1) struct
            %       The configuration for the Monte Carlo method.

            tStart = tic;

            fluxLB = [];
            fluxUB = [];
            output = struct();

            % Notify the initial flux event
            msg = "Calculating confidence interval using Monte Carlo method. " + ...
                "It may take a while (Cancel button is not available).";
            notifyGeneralMessage(obj, "info", msg, dbstack());

            % If the flux distribution is not calculated, return
            if obj.statusFlag(2) ~= 1
                msg = "Flux distribution is not calculated.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                return;
            end % if

            % Set up the experimental conditions
            Lmax = config.iteration;
            SD = config.MIDSD;

            % MDV calculation
            numFlux = size(obj.resultFlux, 1);
            MDVExpTemp = obj.MDVExpFmincon;

            resultFluxBest = obj.resultFlux(:, 1);
            optimizationRightHandSide = ...
                createConfidenceIntervalRightHandSide( ...
                obj, resultFluxBest);

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
                    calculateNonLinearOptimization( ...
                    obj, iMDV, optimizationRightHandSide);
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
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % calculateCIMCSingleRun

        function [fluxLB, fluxUB, output] = calculateCIMCMultiRun(obj, config)
            % CALCULATECIMCMULTIRUN Calculate the confidence interval using Monte Carlo method with multiple runs.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   config: (1, 1) struct
            %       The configuration for the Monte Carlo method.

            tStart = tic;

            fluxLB = [];
            fluxUB = [];
            output = struct();

            % Notify the initial flux event
            msg = "Calculating confidence interval using Monte Carlo method. " + ...
                "It may take a while (Cancel button is not available).";
            notifyGeneralMessage(obj, "info", msg, dbstack());

            % If the flux distribution is not calculated, return
            if obj.statusFlag(2) ~= 1
                msg = "Flux distribution is not calculated.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                return;
            end % if

            % Set up the experimental conditions
            Lmax = config.iteration;
            SD = config.MIDSD;

            % MDV calculation
            numFlux = size(obj.resultFlux, 1);
            MDVExpTemp = obj.MDVExpFmincon;

            resultFluxBest = obj.resultFlux(:, 1);
            optimizationRightHandSide = ...
                createConfidenceIntervalRightHandSide( ...
                obj, resultFluxBest);

            numMDVTemp = size(MDVExpTemp, 1);
            numLabelingTemp = size(MDVExpTemp, 2);
            MCMDV = nan(numMDVTemp, numLabelingTemp, Lmax);
            MCFlux = nan(numFlux, Lmax);

            trials = config.theNumberOfRuns;
            certainThreshold = config.certainThreshold;
            proximityThreshold = config.proximityThreshold;

            parfor i = 1:Lmax

                % Corruppt randomly the MDV
                iMDV = MDVExpTemp + ...
                    randn(numMDVTemp, numLabelingTemp) * SD;

                % Save the MDV
                MCMDV(:, :, i) = iMDV;

                msg = "Monte Carlo iteration: " + string(i) + "/" + string(Lmax);
                notifyGeneralMessage(obj, "info", msg, dbstack());

                temporaryFlux = [];
                temporaryRSS = [];
                numTrials = 1;
                bestRSS = inf;

                while numTrials <= trials || length(temporaryRSS) < certainThreshold

                    msg = "Monte Carlo iteration: " + string(i) + "/" + string(Lmax) + ...
                        ", Trial: " + string(numTrials) + "/" + string(trials);
                    notifyGeneralMessage(obj, "info", msg, dbstack());

                    % Calculate the flux distribution
                    [fval, estimatedFlux, ~, ~, ~] = ...
                        calculateNonLinearOptimization( ...
                        obj, iMDV, optimizationRightHandSide);

                    temporaryFlux = [temporaryFlux, estimatedFlux];
                    temporaryRSS = [temporaryRSS, fval];

                    proximity = calculateProximity(obj, bestRSS, fval);

                    if proximity < proximityThreshold || bestRSS == inf
                        temporaryFlux = [temporaryFlux, estimatedFlux];
                        temporaryRSS = [temporaryRSS, fval];
                        bestRSS = min(temporaryRSS);
                    end

                    numTrials = numTrials + 1;

                end % while

                minIdx = find(temporaryRSS == min(temporaryRSS), 1);
                MCFlux(:, i) = temporaryFlux(:, minIdx);

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
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % calculateCIMCMultiRun

        function epsilon = calculateProximity(~, rssOld, rssNew)
            % CALCULATEPROXIMITY Calculate the proximity threshold.
            %
            % Parameters
            % ----------
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.
            %   rssOld: (1, 1) double
            %       The RSS of the previous iteration.
            %   rssNew: (1, 1) double
            %       The RSS of the current iteration.
            %
            % Returns
            % -------
            %   epsilon: (1, 1) double
            %       The proximity.

            arguments
                ~
                rssOld (1, 1) double
                rssNew (1, 1) double
            end

            epsilon = abs(rssNew - rssOld) / rssOld;

        end % method calculateProximity

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
            notifyGeneralMessage(obj, "info", msg, dbstack());

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
                            notifyGeneralMessage(obj, "info", msg, dbstack());
                            return;
                        end % if

                    end % for iL

                case "mean-varianced"

                    msg = "Mean-varianced method is not implemented yet.";
                    notifyGeneralMessage(obj, "error", msg, dbstack());
                    return;

                otherwise

                    msg = "Unknown method for calculating confidence interval.";
                    notifyGeneralMessage(obj, "error", msg, dbstack());
                    return;

            end % switch

        end % calculateCIMC

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
        function initializeRunMetadata(obj)

            if ~obj.isExport
                return
            end

            metadata = ...
                openmebius.application.analysis.AnalysisMetadataFactory.create( ...
                obj.config, ...
                obj.HDF5FileName, ...
                obj.model, ...
                obj.expsList, ...
                obj.Provenance, ...
                obj.RunStartedAtUtc, ...
                obj.RandomStateAtStart);
            obj.AnalysisMetadata = metadata;
            [isSuccess, msg] = obj.AnalysisRunRepository.writeStarted( ...
                obj.ResultLocation, ...
                obj.HDF5FilePath, ...
                metadata);

            if ~isSuccess
                obj.isError = true;
                notifyGeneralMessage( ...
                    obj, ...
                    "error", ...
                    msg, ...
                    dbstack());
                return
            end

            obj.IsRunMetadataWritten = true;

        end % initializeRunMetadata

        function finalizeRunMetadata(obj)

            if ~obj.isExport || ~obj.IsRunMetadataWritten
                return
            end

            finishedAtUtc = string(datetime( ...
                "now", ...
                "TimeZone", "UTC", ...
                "Format", "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"));
            errors = obj.AnalysisRunRepository.writeCompleted( ...
                obj.ResultLocation, ...
                obj.HDF5FilePath, ...
                obj.AnalysisMetadata, ...
                finishedAtUtc, ...
                obj.isError, ...
                obj.isCanceled);

            if ~isempty(errors)
                obj.isError = true;
                for iError = 1:numel(errors)
                    notifyGeneralMessage( ...
                        obj, ...
                        "error", ...
                        errors(iError), ...
                        dbstack());
                end
            end

        end % finalizeRunMetadata

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

        function [stepSize, candidates, objectives, exitflags] = ...
                extractFminconStepSizeOutput(~, optimizationOutput)
            % EXTRACTFMINCONSTEPSIZEOUTPUT Extract FMINCON step-size search
            % diagnostics from the optimization output struct.

            stepSize = NaN;
            candidates = [];
            objectives = [];
            exitflags = [];

            if ~isstruct(optimizationOutput)
                return;
            end % if

            if isfield(optimizationOutput, 'fminconFiniteDifferenceStepSize') && ...
                    ~isempty(optimizationOutput.fminconFiniteDifferenceStepSize)
                stepSize = double(optimizationOutput.fminconFiniteDifferenceStepSize(1));
            end % if

            if ~isfield(optimizationOutput, 'fminconFiniteDifferenceStepSizeSearch') || ...
                    ~isstruct(optimizationOutput.fminconFiniteDifferenceStepSizeSearch)
                return;
            end % if

            searchOutput = optimizationOutput.fminconFiniteDifferenceStepSizeSearch;

            if isfield(searchOutput, 'candidates')
                candidates = double(searchOutput.candidates(:));
            end % if

            if isfield(searchOutput, 'objectives')
                objectives = double(searchOutput.objectives(:));
            end % if

            if isfield(searchOutput, 'exitflags')
                exitflags = double(searchOutput.exitflags(:));
            end % if

        end % extractFminconStepSizeOutput

        function exportFluxResult(obj, iteration, flux, RSS, MDV, exitfrag, optimizationOutput)
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

            if nargin < 7 || isempty(optimizationOutput)
                optimizationOutput = struct;
            end % if

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

            [finiteDifferenceStepSize, finiteDifferenceStepSizeCandidates, ...
                 finiteDifferenceStepSizeObjectives, finiteDifferenceStepSizeExitflags] = ...
                extractFminconStepSizeOutput(obj, optimizationOutput);

            obj.result.(fieldName).finiteDifferenceStepSize = finiteDifferenceStepSize;
            obj.result.(fieldName).finiteDifferenceStepSizeCandidates = finiteDifferenceStepSizeCandidates;
            obj.result.(fieldName).finiteDifferenceStepSizeObjectives = finiteDifferenceStepSizeObjectives;
            obj.result.(fieldName).finiteDifferenceStepSizeExitflags = finiteDifferenceStepSizeExitflags;
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

            % Export selected FMINCON finite-difference step size
            writeHDF5File( ...
                obj, ...
                obj.HDF5FilePath, ...
                dataAddress + "/finiteDifferenceStepSize", ...
                finiteDifferenceStepSize ...
            );

            if ~isempty(finiteDifferenceStepSizeCandidates)
                writeHDF5File( ...
                    obj, ...
                    obj.HDF5FilePath, ...
                    dataAddress + "/finiteDifferenceStepSizeCandidates", ...
                    finiteDifferenceStepSizeCandidates ...
                );

                writeHDF5File( ...
                    obj, ...
                    obj.HDF5FilePath, ...
                    dataAddress + "/finiteDifferenceStepSizeObjectives", ...
                    finiteDifferenceStepSizeObjectives ...
                );

                writeHDF5File( ...
                    obj, ...
                    obj.HDF5FilePath, ...
                    dataAddress + "/finiteDifferenceStepSizeExitflags", ...
                    finiteDifferenceStepSizeExitflags ...
                );
            end % if

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

        function restoreEffluxFreeModel(obj)
            % RESTOREEFFLUXFREEMODEL Restore reaction independence changed for efflux fitting.

            if isempty(obj.effluxFreeRxnID)
                return;
            end

            try

                for i = 1:length(obj.effluxFreeRxnID)
                    obj.model.setReactionIndependent( ...
                        obj.effluxFreeRxnID(i), ...
                        obj.effluxFreeOriginalIndependent(i) ...
                    );
                end

                obj.model.buildModel();

            catch ME
                msg = "Failed to restore efflux free model state: " + string(ME.message);
                logDisp(dbstack(), msg, "warning");
            end

        end % restoreEffluxFreeModel

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

            if ~tf
                return;
            end % if

            if isfield(obj.config, "perturbateEfflux") && obj.config.perturbateEfflux && any(obj.effluxFree)
                substrateFree = obj.subsList(logical(obj.effluxFree));
                obj.effluxFreeRxnID = strings(length(substrateFree), 1);
                obj.effluxFreeOriginalIndependent = false(length(substrateFree), 1);

                for i = 1:length(substrateFree)
                    iRxnID = obj.model.findSubstrateRxnIDFromMetaboliteIrrev(substrateFree(i));
                    obj.effluxFreeRxnID(i) = iRxnID;
                    obj.effluxFreeOriginalIndependent(i) = obj.model.getReactionIndependent(iRxnID);
                end

                obj.model.makeEffluxFree(substrateFree');
                msg = "Efflux reactions were set as free variables: " + strjoin(substrateFree, ", ") + ".";
                notifyGeneralMessage(obj, "info", msg, dbstack());
            end

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
                notifyGeneralMessage(obj, "error", msg, dbstack());
                tf = false;
                return;
            end % if

            try
                tmpMu = info{obj.expsList, "mu"};
                tmpMu = mean(tmpMu, 1);
                obj.mu = tmpMu;
            catch
                msg = "Information table is no valid";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                tf = false;
                return;
            end

            if ~all(tmpMu > 0)
                msg = "No growth rate available for efflux validation.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
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
                notifyGeneralMessage(obj, "error", msg, dbstack());
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
                notifyGeneralMessage(obj, "error", msg, dbstack());
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
                    notifyGeneralMessage(obj, "error", msg, dbstack());
                    tf = false;
                    return;
                end % if

                [~, ia, ib] = intersect(perturbateSubstrateName, obj.subsList);

                if isempty(ia)
                    msg = "No matching substrate found for efflux perturbation.";
                    notifyGeneralMessage(obj, "error", msg, dbstack());
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
                    notifyGeneralMessage(obj, "error", msg, dbstack());
                    tf = false;
                    return;
                end % if

                if any(isnan(effluxFree)) %#ok<PROP>
                    msg = "Efflux standard deviation contains NaN values for perturbation.";
                    notifyGeneralMessage(obj, "error", msg, dbstack());
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
                notifyGeneralMessage(obj, "error", msg, dbstack());
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
                notifyGeneralMessage(obj, "error", msg, dbstack());
                tf = false;
                return;
            end % if

        end % function isValidateMDV

        function [poolsize, err, msg] = alignINSTMFAPoolSize(obj, config)
            % ALIGNINSTMFAPOOLSIZE Align pool sizes to the EMU Cn metabolite order.

            poolsize = [];
            err = false;
            msg = "";

            modelMetabolites = string(obj.model.getMetaboliteTableMetabolite());
            modelMetabolites = modelMetabolites(:);
            inputPoolSize = double(config.INSTMFA.poolSize(:));

            if isempty(modelMetabolites)
                msg = "No model metabolites are available for INST-MFA pool-size alignment.";
                err = true;
                return;
            end % if

            if isfield(config.INSTMFA, "poolMetabolite") && ~isempty(config.INSTMFA.poolMetabolite)
                inputMetabolites = string(config.INSTMFA.poolMetabolite(:));

                if numel(inputMetabolites) ~= numel(inputPoolSize)
                    msg = "The number of INST-MFA pool-size metabolites does not match the number of pool-size values.";
                    err = true;
                    return;
                end % if

                poolsize = nan(numel(modelMetabolites), 1);

                for iMetabolite = 1:numel(modelMetabolites)
                    matchedIdx = find(inputMetabolites == modelMetabolites(iMetabolite), 1, "first");

                    if ~isempty(matchedIdx)
                        poolsize(iMetabolite) = inputPoolSize(matchedIdx);
                    end % if

                end % for iMetabolite

                missingMetabolites = modelMetabolites(isnan(poolsize));

                if ~isempty(missingMetabolites)
                    msg = "INST-MFA pool sizes are missing for: " + strjoin(missingMetabolites, ", ") + ".";
                    err = true;
                    return;
                end % if

                return;
            end % if

            if numel(inputPoolSize) ~= numel(modelMetabolites)
                msg = "The number of INST-MFA pool-size values does not match the number of model metabolites.";
                err = true;
                return;
            end % if

            poolsize = inputPoolSize;

        end % method alignINSTMFAPoolSize

        function [err, msg] = setINSTMFA(obj)

            config = obj.config;

            obj.isInstationary = config.isINSTMFA;
            [obj.poolsize, err, msg] = alignINSTMFAPoolSize(obj, config);

            if err
                notifyGeneralMessage(obj, "error", msg, dbstack());
                return;
            end % if

            obj.timePoints = double(config.INSTMFA.timePoints(:));

            if numel(obj.timePoints) < 2
                msg = "At least two time points are required for instationary 13C-MFA.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                err = true;
                return;
            end % if

            % NaN check
            if any(isnan(obj.poolsize)) || any(isnan(obj.timePoints))
                msg = "Pool sizes and time points must not contain NaN values.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                err = true;
                return;
            end % if

            if any(~isfinite(obj.poolsize)) || any(obj.poolsize <= 0)
                msg = "Pool sizes must be finite positive values for instationary 13C-MFA.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                err = true;
                return;
            end % if

        end % method setINSTMFA

        function [isSuccess, msg] = writeHDF5File(obj, pathFile, pathData, data, options)

            arguments
                obj
                pathFile (1, 1) string
                pathData (1, 1) string
                data
                options.DataType (1, 1) string = "double"
            end

            [isSuccess, msg] = obj.Hdf5ResultRepository.writeDataset( ...
                pathFile, ...
                pathData, ...
                data, ...
                DataType = options.DataType);

        end % writeHDF5File

    end % methods (Access = private)

end % classdef
