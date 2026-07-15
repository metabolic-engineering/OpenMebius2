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
        FluxVariabilityProblemFactory
        InitialPointGenerator
        MFAProblemFactory
        MFAIterationRunner
        MFAWorkflow
        MonteCarloConfidenceIntervalSolver
        MFAInputValidator
        MFAFitStatistics
        MFAExperimentalDataBuilder
        MFAConstraintBuilder
        MFAExperimentListNormalizer
        SubstrateEMUFactory
        SteadyStateMDVPredictor
        EffluxPenaltyFactory
        InstationaryInputFactory
        MFAProblem = []
        InstationaryInput = []
        MFAExperimentalData = []

        % File export
        isExport = true
        ResultLocation openmebius.domain.result.ResultLocation
        HDF5FileName = ""
        HDF5FilePath = ""
        MFAInputSnapshotWriter
        MFAResultCheckpointWriter
        NextLabelResultCheckpointWriter
        MFAResultCoordinator
        AnalysisRunRepository
        AnalysisRunLifecycle
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
                options.MFAInputSnapshotWriter = []
                options.MFAResultCheckpointWriter = []
                options.NextLabelResultCheckpointWriter = []
                options.MFAResultCoordinator = []
                options.ResultManifestRepository = ...
                    openmebius.infrastructure.result.ResultManifestRepository()
                options.FluxVariabilitySolver = ...
                    openmebius.mfa.FluxVariabilitySolver()
                options.FluxVariabilityProblemFactory = []
                options.InitialPointGenerator = ...
                    openmebius.mfa.InitialPointGenerator()
                options.MFAProblemFactory = ...
                    openmebius.mfa.MFAProblemFactory()
                options.SteadyStateSolver = ...
                    openmebius.mfa.SteadyStateSolver()
                options.MFAIterationRunner = []
                options.MFAWorkflow = openmebius.mfa.MFAWorkflow()
                options.MonteCarloConfidenceIntervalSolver = ...
                    openmebius.mfa.MonteCarloConfidenceIntervalSolver()
                options.MFAInputValidator = ...
                    openmebius.mfa.MFAInputValidator()
                options.MFAFitStatistics = ...
                    openmebius.mfa.MFAFitStatistics()
                options.MFAExperimentalDataBuilder = ...
                    openmebius.mfa.MFAExperimentalDataBuilder()
                options.MFAConstraintBuilder = ...
                    openmebius.mfa.MFAConstraintBuilder()
                options.MFAExperimentListNormalizer = ...
                    openmebius.mfa.MFAExperimentListNormalizer()
                options.SubstrateEMUFactory = ...
                    openmebius.mfa.SubstrateEMUFactory()
                options.SteadyStateMDVPredictor = ...
                    openmebius.mfa.SteadyStateMDVPredictor()
                options.EffluxPenaltyFactory = ...
                    openmebius.mfa.EffluxPenaltyFactory()
                options.InstationaryInputFactory = ...
                    openmebius.mfa.InstationaryInputFactory()
                options.AnalysisRunLifecycle = []
                options.Provenance (1, 1) struct = struct
            end

            resultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                resultInput);

            obj.ResultLocation = resultLocation;
            obj.HDF5FileName = ID;
            obj.HDF5FilePath = resultLocation.resultFile(ID);

            if isempty(options.MFAInputSnapshotWriter)
                obj.MFAInputSnapshotWriter = ...
                    openmebius.infrastructure.result.MFAInputSnapshotWriter( ...
                    Repository = options.Hdf5ResultRepository);
            else
                obj.MFAInputSnapshotWriter = ...
                    options.MFAInputSnapshotWriter;
            end

            if isempty(options.MFAResultCheckpointWriter)
                obj.MFAResultCheckpointWriter = ...
                    openmebius.infrastructure.result ...
                    .MFAResultCheckpointWriter( ...
                    Repository = options.Hdf5ResultRepository);
            else
                obj.MFAResultCheckpointWriter = ...
                    options.MFAResultCheckpointWriter;
            end

            if isempty(options.NextLabelResultCheckpointWriter)
                obj.NextLabelResultCheckpointWriter = ...
                    openmebius.infrastructure.result ...
                    .NextLabelResultCheckpointWriter( ...
                    Repository = options.Hdf5ResultRepository);
            else
                obj.NextLabelResultCheckpointWriter = ...
                    options.NextLabelResultCheckpointWriter;
            end

            obj.AnalysisRunRepository = ...
                openmebius.infrastructure.result.AnalysisRunRepository( ...
                Hdf5ResultRepository = options.Hdf5ResultRepository, ...
                ResultManifestRepository = options.ResultManifestRepository);

            if isempty(options.AnalysisRunLifecycle)
                obj.AnalysisRunLifecycle = ...
                    openmebius.application.analysis.AnalysisRunLifecycle( ...
                    Repository = obj.AnalysisRunRepository);
            else
                obj.AnalysisRunLifecycle = options.AnalysisRunLifecycle;
            end

            obj.FluxVariabilitySolver = options.FluxVariabilitySolver;
            obj.InitialPointGenerator = options.InitialPointGenerator;
            obj.MFAProblemFactory = options.MFAProblemFactory;

            if isempty(options.MFAIterationRunner)
                obj.MFAIterationRunner = ...
                    openmebius.mfa.MFAIterationRunner( ...
                    Solver = options.SteadyStateSolver);
            else
                obj.MFAIterationRunner = options.MFAIterationRunner;
            end

            obj.MFAWorkflow = options.MFAWorkflow;
            obj.MonteCarloConfidenceIntervalSolver = ...
                options.MonteCarloConfidenceIntervalSolver;
            obj.MFAInputValidator = options.MFAInputValidator;
            obj.MFAFitStatistics = options.MFAFitStatistics;
            obj.MFAExperimentalDataBuilder = ...
                options.MFAExperimentalDataBuilder;
            obj.MFAConstraintBuilder = options.MFAConstraintBuilder;

            if isempty(options.FluxVariabilityProblemFactory)
                obj.FluxVariabilityProblemFactory = ...
                    openmebius.mfa.FluxVariabilityProblemFactory( ...
                    ConstraintBuilder = obj.MFAConstraintBuilder);
            else
                obj.FluxVariabilityProblemFactory = ...
                    options.FluxVariabilityProblemFactory;
            end

            obj.MFAExperimentListNormalizer = ...
                options.MFAExperimentListNormalizer;
            obj.SubstrateEMUFactory = options.SubstrateEMUFactory;
            obj.SteadyStateMDVPredictor = ...
                options.SteadyStateMDVPredictor;
            obj.EffluxPenaltyFactory = options.EffluxPenaltyFactory;
            obj.InstationaryInputFactory = ...
                options.InstationaryInputFactory;
            obj.Provenance = options.Provenance;

            try
                options.Hdf5ResultRepository.assertResultDirectory( ...
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

            if isempty(options.MFAResultCoordinator)
                obj.MFAResultCoordinator = ...
                    openmebius.infrastructure.result.MFAResultCoordinator( ...
                    InputSnapshotWriter = obj.MFAInputSnapshotWriter, ...
                    ResultCheckpointWriter = ...
                    obj.MFAResultCheckpointWriter, ...
                    NextLabelCheckpointWriter = ...
                    obj.NextLabelResultCheckpointWriter, ...
                    HDF5FilePath = obj.HDF5FilePath, ...
                    IsExport = obj.isExport);
            else
                obj.MFAResultCoordinator = options.MFAResultCoordinator;
            end

            obj.model = model;
            obj.exps = experiments;

            if obj.model.isError || obj.exps.isError
                obj.isError = true;
                return;
            end

            obj.expsList = obj.MFAExperimentListNormalizer.normalize( ...
                expList);

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

            cleanupEffluxFreeModel = onCleanup( ...
                @() restoreEffluxFreeModel(obj));

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
                obj.subsEMUs{i} = ...
                    obj.SubstrateEMUFactory.fromExperiment( ...
                    obj.model, obj.exps, obj.expsList(i));
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

            if obj.config.isINSTMFA
                try
                    obj.InstationaryInput = ...
                        obj.InstationaryInputFactory.create( ...
                        obj.model, obj.config.INSTMFA);
                catch ME
                    msg = "Instationary 13C-MFA: " + string(ME.message);
                    notifyGeneralMessage(obj, "error", msg, dbstack());
                    obj.isError = true;
                    return;
                end
            end

            workflowResult = obj.MFAWorkflow.run( ...
                tmpRhs, ...
                @(rightHandSide) calculateConfiguredMFAIteration( ...
                obj, obj.MDVExpFmincon, rightHandSide), ...
                ProgressReporter = ...
                    @(iteration, total) ...
                    notifyMFAIterationProgress(obj, iteration, total), ...
                IterationCompleted = ...
                    @(iteration, iterationResult) ...
                    exportMFAIterationResult( ...
                    obj, iteration, iterationResult), ...
                CancellationRequested = @() obj.isCanceled, ...
                MDVMapper = @(mdv) arrangeMDV(obj, mdv));
            obj.resultRSS = workflowResult.ObjectiveValues;
            obj.resultFlux = workflowResult.Fluxes;
            obj.resultMDV = workflowResult.MDVs;

            if workflowResult.IsCanceled
                msg = "Nonlinear optimization canceled.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
                return;
            end

            idx = workflowResult.Order;

            minRSS = obj.resultRSS(1);
            % Calculate the threshold for chi-squared test
            threshold = obj.MFAFitStatistics.chiSquareThreshold( ...
                getDOF(obj.model), ...
                obj.MDVFragList, ...
                obj.MDVFragMask, ...
                0.05);
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

            maxEfflux = max(obj.efflux);
            rightHandSide = calculateRHS(obj);
            problem = obj.FluxVariabilityProblemFactory.create( ...
                obj.model, ...
                rightHandSide, ...
                maxEfflux, ...
                obj.subsList, ...
                obj.effluxFree, ...
                UseCustomBounds = options.customBoundary, ...
                LowerBounds = options.fluxLB, ...
                UpperBounds = options.fluxUB);

            if problem.UsedDefaultMaximumEfflux
                msg = "Maximum efflux is not set or non-positive. " + ...
                    "Using default value: " + ...
                    string(problem.MaximumEfflux) + ".";
                notifyGeneralMessage(obj, "warning", msg, dbstack());
            end

            if ~isempty(problem.FreeConstraintIDs)
                msg = "FVA will not fix efflux-free reactions: " + ...
                    strjoin(problem.FreeConstraintIDs, ", ") + ".";
                notifyGeneralMessage(obj, "info", msg, dbstack());
            end

            solverResult = obj.FluxVariabilitySolver.solve( ...
                problem.EqualityMatrix, ...
                problem.EqualityRightHandSide, ...
                problem.LowerBounds, ...
                problem.UpperBounds, ...
                problem.ReverseCounterpartIndices);
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
                obj.subsEMUs{i} = ...
                    obj.SubstrateEMUFactory.fromExperiment( ...
                    obj.model, obj.exps, obj.expsList(i));
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

        function rhs = calculateRHS(obj)
            % CALCULATERHS Calculate the right-hand side.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
            end % arguments

            obj.rhs = obj.MFAConstraintBuilder.buildRightHandSide( ...
                obj.model, ...
                obj.mu, ...
                obj.subsList, ...
                obj.efflux);
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

        function reportOptimizationMessage(obj, level, message)

            notifyGeneralMessage(obj, level, message, dbstack());

        end % reportOptimizationMessage

        function reportConfidenceIntervalMessage(obj, level, message)

            notifyGeneralMessage(obj, level, message, dbstack());

        end % reportConfidenceIntervalMessage

        function notifyMFAIterationProgress(obj, iteration, total)

            msg = "Calculating flux distribution (iteration " + ...
                string(iteration) + "/" + string(total) + ")";
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % notifyMFAIterationProgress

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

            EMU = obj.SubstrateEMUFactory.fromPattern( ...
                obj.model, obj.exps, pattern);

            % Store the EMU of the substrate
            obj.subsEMUs{end} = EMU;

            if obj.isCanceled
                msg = "Next flux experiment suggestion canceled.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
                return;
            end % if

            MDV = obj.SteadyStateMDVPredictor.predictLinearized( ...
                obj.model, obj.resultFlux(:, 1), obj.subsEMUs);
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

            MDVExpTemp = arrangeMDV(obj, obj.MDVExpFmincon, ...
                numExperiments = length(subsEMU));
            effluxPenalty = createEffluxPenalty(obj);
            evaluation = obj.MFAFitStatistics.evaluateFluxes( ...
                fluxes, ...
                MDVExpTemp, ...
                obj.MDVFragMask, ...
                @(flux) obj.SteadyStateMDVPredictor ...
                .predictLinearized(obj.model, flux, subsEMU), ...
                effluxPenalty, ...
                CancellationRequested = @() obj.isCanceled);
            RSS = evaluation.ObjectiveValues;
            idx = evaluation.Order;
            msg = "Number of valid flux distributions: " + ...
                string(evaluation.ValidCount);
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % calculateRSS

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

            MDVAll = obj.MFAExperimentalData.arrangeMDV( ...
                MDV, ...
                ExperimentCount = options.numExperiments);

        end % arrangeMDV

        function calculateLinearizedMDV(obj)
            % CALCULATELINEARIZEDMDV Create the linearized MDV for fmincon.

            obj.MFAExperimentalData = ...
                obj.MFAExperimentalDataBuilder.build( ...
                obj.model, ...
                obj.exps, ...
                obj.expsList, ...
                obj.config.MS);
            obj.MDVExp = obj.MFAExperimentalData.ExperimentalMDV;
            obj.MDVFragList = obj.MFAExperimentalData.FragmentLabels;
            obj.MDVFragMask = obj.MFAExperimentalData.FragmentMask;

            % Set the number of MDV and labeling experiments
            obj.numMDV = obj.MFAExperimentalData.FragmentCount;
            obj.numLabeling = obj.MFAExperimentalData.ExperimentCount;

        end % calculateLinearizedMDV

        %% Optimization functions

        function penalty = createEffluxPenalty(obj)
            % CREATEEFFLUXPENALTY Resolve selected efflux measurements.

            penalty = obj.EffluxPenaltyFactory.create( ...
                obj.model, ...
                obj.subsList, ...
                obj.efflux, ...
                obj.effluxSD, ...
                obj.effluxFree);

        end % createEffluxPenalty

        function objective = createSteadyStateObjective( ...
                obj, experimentalMDV, rightHandSide)
            % CREATESTEADYSTATEOBJECTIVE Build immutable run inputs.

            experimentalMDV = arrangeMDV( ...
                obj, ...
                experimentalMDV, ...
                numExperiments = length(obj.subsEMUs));
            objective = openmebius.mfa.SteadyStateObjective( ...
                Problem = obj.MFAProblem, ...
                RightHandSide = rightHandSide, ...
                Model = obj.model, ...
                SubstrateEMUs = obj.subsEMUs, ...
                ExperimentalMDV = experimentalMDV, ...
                FragmentMask = obj.MDVFragMask, ...
                EffluxPenalty = createEffluxPenalty(obj), ...
                MDVPredictor = obj.SteadyStateMDVPredictor);

        end % createSteadyStateObjective

        function objective = createInstationaryObjective( ...
                obj, experimentalMDV, rightHandSide)
            % CREATEINSTATIONARYOBJECTIVE Build immutable run inputs.

            objective = openmebius.mfa.InstationaryObjective( ...
                Problem = obj.MFAProblem, ...
                RightHandSide = rightHandSide, ...
                Model = obj.model, ...
                SubstrateEMU = obj.subsEMUs{1}, ...
                Input = obj.InstationaryInput, ...
                ExperimentalMDV = experimentalMDV, ...
                FragmentMask = obj.MDVFragMask, ...
                EffluxPenalty = createEffluxPenalty(obj));

        end % createInstationaryObjective

        function result = calculateConfiguredMFAIteration( ...
                obj, experimentalMDV, rightHandSide)
            % CALCULATECONFIGUREDMFAITERATION Run the configured MFA mode.

            if obj.config.isINSTMFA
                objective = createInstationaryObjective( ...
                    obj, experimentalMDV, rightHandSide);
                context = " for instationary MFA";
            else
                objective = createSteadyStateObjective( ...
                    obj, experimentalMDV, rightHandSide);
                context = "";
            end

            result = runAndReportMFAIteration( ...
                obj, objective, rightHandSide, context);

        end % calculateConfiguredMFAIteration

        function result = calculateMonteCarloMFAIteration( ...
                obj, experimentalMDV, rightHandSide)
            % CALCULATEMONTECARLOMFAITERATION Run one steady-state CI fit.

            objective = createSteadyStateObjective( ...
                obj, experimentalMDV, rightHandSide);
            result = runAndReportMFAIteration( ...
                obj, objective, rightHandSide, "");

        end % calculateMonteCarloMFAIteration

        function iterationResult = runAndReportMFAIteration( ...
                obj, objective, rightHandSide, context)
            % RUNANDREPORTMFAITERATION Run and report one MFA iteration.

            iterationResult = runConfiguredMFAIteration( ...
                obj, objective, rightHandSide);
            fval = iterationResult.ObjectiveValue;
            subject = "Nonlinear optimization" + context;

            if iterationResult.IsError || ~isfinite(fval)
                msg = subject + " failed.";

                if strlength(iterationResult.ErrorMessage) > 0
                    msg = msg + " " + iterationResult.ErrorMessage;
                end

                notifyGeneralMessage(obj, "error", msg, dbstack());
                return;
            end

            stepSizeMsg = "";
            optimizationOutput = iterationResult.Output;

            if isfield(optimizationOutput, ...
                    'fminconFiniteDifferenceStepSize')
                stepSizeMsg = " FiniteDifferenceStepSize: " + ...
                    string(optimizationOutput.fminconFiniteDifferenceStepSize) + ".";
            end

            msg = subject + " completed. RSS: " + ...
                string(fval) + "." + stepSizeMsg;
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % runAndReportMFAIteration

        function exportMFAIterationResult(obj, iteration, result)

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator.writeIteration( ...
                obj.result, ...
                obj.statusFlag, ...
                iteration, ...
                result, ...
                obj.model.getIdxRev());
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportMFAIterationResult

        function result = runConfiguredMFAIteration( ...
                obj, objective, rightHandSide)
            % RUNCONFIGUREDMFAITERATION Run one configured MFA iteration.
            %
            % GA-based hybrid optimization is intentionally disabled for now.
            % FMINCON starts from the supplied feasible initial flux vector.
            % Optionally, several FiniteDifferenceStepSize values are tried
            % and the best feasible FMINCON result is selected.

            method = getOptimizationMethod(obj);

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

            result = obj.MFAIterationRunner.run( ...
                obj.MFAProblem, ...
                rightHandSide, ...
                objective, ...
                solverOptions, ...
                MessageReporter = ...
                    @(level, message) ...
                    obj.reportOptimizationMessage(level, message));

        end % runConfiguredMFAIteration

        function method = getOptimizationMethod(obj)
            % GETOPTIMIZATIONMETHOD Return the normalized nonlinear optimizer name.

            method = "gradient-only";

            if isfield(obj.config, 'optimizationMethod') && ...
                    ~isempty(obj.config.optimizationMethod)
                method = lower(string(obj.config.optimizationMethod));
            end % if

        end % getOptimizationMethod











        %% Tools
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

            arguments
                obj (1, 1) FluxAnalysis
                config (1, 1) struct
            end % arguments

            fluxLB = [];
            fluxUB = [];
            output = struct;

            msg = "Calculating confidence interval using Monte Carlo " + ...
                "method. It may take a while " + ...
                "(Cancel button is not available).";
            notifyGeneralMessage(obj, "info", msg, dbstack());

            if obj.statusFlag(2) ~= 1
                msg = "Flux distribution is not calculated.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                return;
            end

            bestFlux = obj.resultFlux(:, 1);
            rightHandSide = createConfidenceIntervalRightHandSide( ...
                obj, bestFlux);

            try
                confidenceIntervalResult = ...
                    obj.MonteCarloConfidenceIntervalSolver.solve( ...
                    obj.MDVExpFmincon, ...
                    size(obj.resultFlux, 1), ...
                    config, ...
                    @(mdv) calculateMonteCarloMFAIteration( ...
                    obj, mdv, rightHandSide), ...
                    obj.model.getIdxRev(), ...
                    MessageReporter = ...
                    @(level, message) ...
                    reportConfidenceIntervalMessage( ...
                    obj, level, message), ...
                    CancellationRequested = @() obj.isCanceled);
            catch ME
                msg = "Confidence interval calculation failed. " + ...
                    string(ME.message);
                notifyGeneralMessage(obj, "error", msg, dbstack());
                return;
            end

            fluxLB = confidenceIntervalResult.LowerBounds;
            fluxUB = confidenceIntervalResult.UpperBounds;
            output.MDV = confidenceIntervalResult.PerturbedMDVs;
            output.flux = confidenceIntervalResult.Fluxes;
            output.iteration = ...
                confidenceIntervalResult.IterationCount;
            output.time = confidenceIntervalResult.ElapsedTime;

            if confidenceIntervalResult.IsCanceled
                msg = "Confidence interval calculation canceled.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
                return;
            end

            msg = "Confidence interval calculated successfully." + ...
                " (Elapsed time: " + ...
                string(seconds(output.time), "hh:mm:ss") + ")";
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % calculateCIMC

        %% Export functions
        function initializeRunMetadata(obj)

            if ~obj.isExport
                return
            end

            [metadata, isSuccess, msg] = ...
                obj.AnalysisRunLifecycle.start( ...
                obj.config, ...
                obj.HDF5FileName, ...
                obj.model, ...
                obj.expsList, ...
                obj.Provenance, ...
                obj.RunStartedAtUtc, ...
                obj.RandomStateAtStart, ...
                obj.ResultLocation, ...
                obj.HDF5FilePath);
            obj.AnalysisMetadata = metadata;

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

            errors = obj.AnalysisRunLifecycle.finish( ...
                obj.ResultLocation, ...
                obj.HDF5FilePath, ...
                obj.AnalysisMetadata, ...
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

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator.writeGeneral( ...
                obj.result, ...
                obj.statusFlag, ...
                obj.HDF5FileName, ...
                obj.MDVExp, ...
                obj.MDVFragList, ...
                obj.MDVFragMask);
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportGeneralInformation

        function exportModelInformation(obj)

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator.writeModel( ...
                obj.result, ...
                obj.statusFlag, ...
                obj.model.getModelTable(), ...
                obj.model.getModelTableRev());
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportModelInformation

        function exportFluxVariability(obj, fluxLB, fluxUB)

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator.writeFluxVariability( ...
                obj.result, ...
                obj.statusFlag, ...
                fluxLB, ...
                fluxUB, ...
                obj.model.getIdxRev());
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportFluxVariability

        function exportInitialFluxDistribution(obj, flux, rhs, RSS)

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator.writeInitialFlux( ...
                obj.result, ...
                obj.statusFlag, ...
                flux, ...
                rhs, ...
                RSS, ...
                obj.model.getIdxRev());
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportInitialFluxDistribution

        function exportFluxResultRSS(obj, RSS, idx, threshold)

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator.writeSummary( ...
                obj.result, obj.statusFlag, RSS, idx, threshold);
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportFluxResultRSS

        function exportConfidenceIntervalMC(obj, fluxLB, fluxUB, output)

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator ...
                .writeMonteCarloConfidenceInterval( ...
                obj.result, ...
                obj.statusFlag, ...
                fluxLB, ...
                fluxUB, ...
                obj.config.CIConf, ...
                output);
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportConfidenceIntervalMC

        function exportNextLabelPatternGeneralInformation(obj)

            [isSuccess, msg] = ...
                obj.MFAResultCoordinator.writeSuggestionTable( ...
                obj.config.suggestionTable, ...
                obj.config.suggestionTableVarNames);
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportNextLabelPatternGeneralInformation

        function exportNextLabelPatternInitialFlux( ...
                obj, pattern, flux, tmpRhs, RSS)

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator.writeNextLabelInitialFlux( ...
                obj.result, ...
                obj.statusFlag, ...
                pattern, ...
                flux, ...
                tmpRhs, ...
                RSS, ...
                obj.model.getIdxRev());
            handleResultWriteFailure(obj, isSuccess, msg);

        end % exportNextLabelPatternInitialFlux

        function exportNextLabelPatternCIMC( ...
                obj, pattern, fluxLB, fluxUB)

            [obj.result, obj.statusFlag, isSuccess, msg] = ...
                obj.MFAResultCoordinator ...
                .writeNextLabelConfidenceInterval( ...
                obj.result, ...
                obj.statusFlag, ...
                pattern, ...
                fluxLB, ...
                fluxUB);
            handleResultWriteFailure(obj, isSuccess, msg);

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

            validation = obj.MFAInputValidator.validateEfflux( ...
                obj.model, ...
                obj.exps, ...
                obj.expsList, ...
                obj.config);
            tf = validation.IsValid;

            if ~validation.IsValid
                notifyGeneralMessage( ...
                    obj, ...
                    "error", ...
                    validation.ErrorMessage, ...
                    dbstack());
                return;
            end

            obj.mu = validation.Value.GrowthRate;
            obj.subsList = validation.Value.SubstrateList;
            obj.efflux = validation.Value.Efflux;
            obj.effluxSD = ...
                validation.Value.EffluxStandardDeviation;
            obj.effluxFree = validation.Value.EffluxFree;

            if isfield(obj.config, "perturbateEfflux") && ...
                    obj.config.perturbateEfflux && ...
                    any(obj.effluxFree)
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

            validation = obj.MFAInputValidator.validateMDV( ...
                obj.MDVExp, ...
                obj.MDVFragList, ...
                obj.MDVFragMask);
            tf = validation.IsValid;

            if ~validation.IsValid
                notifyGeneralMessage( ...
                    obj, ...
                    "error", ...
                    validation.ErrorMessage, ...
                    dbstack());
            end

        end % function isValidateMDV


        function handleResultWriteFailure(obj, isSuccess, message)

            if isSuccess
                return;
            end

            obj.isError = true;
            notifyGeneralMessage(obj, "error", message, dbstack());

        end % handleResultWriteFailure

    end % methods (Access = private)

end % classdef
