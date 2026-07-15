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
        Dependencies
        RunContext (1, 1) ...
            openmebius.application.analysis.MFAAnalysisRunContext
        ResultSession (1, 1) ...
            openmebius.application.analysis.MFAResultSession
        AnalysisRunScope = []

        % File export
        isExport = true
        ResultLocation openmebius.domain.result.ResultLocation
        HDF5FileName = ""
        HDF5FilePath = ""
        Provenance = struct

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
                options.InitialFluxWorkflow = []
                options.MFAProblemFactory = ...
                    openmebius.mfa.MFAProblemFactory()
                options.SteadyStateSolver = ...
                    openmebius.mfa.SteadyStateSolver()
                options.MFAIterationRunner = []
                options.MFAWorkflow = openmebius.mfa.MFAWorkflow()
                options.MonteCarloConfidenceIntervalSolver = ...
                    openmebius.mfa.MonteCarloConfidenceIntervalSolver()
                options.ConfidenceIntervalWorkflow = []
                options.NextLabelExperimentWorkflow = []
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
                options.RunContext = []
                options.Provenance (1, 1) struct = struct
            end

            resultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput( ...
                resultInput);

            obj.ResultLocation = resultLocation;
            obj.HDF5FileName = ID;
            obj.HDF5FilePath = resultLocation.resultFile(ID);

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

            obj.Dependencies = openmebius.application.analysis ...
                .FluxAnalysisDependencies( ...
                options, string(obj.HDF5FilePath), obj.isExport);
            obj.RunContext = obj.Dependencies.RunContext;
            obj.ResultSession = openmebius.application.analysis ...
                .MFAResultSession( ...
                Coordinator = ...
                obj.Dependencies.MFAResultCoordinator, ...
                FailureReporter = ...
                @(message) handleAnalysisFailure(obj, message));

            obj.model = model;
            obj.exps = experiments;

            if obj.model.isError || obj.exps.isError
                obj.isError = true;
                return;
            end

            obj.expsList = obj.Dependencies ...
                .MFAExperimentListNormalizer.normalize( ...
                expList);

            obj.config = config;
            obj.status = openmebius.infrastructure.logging.MessageState();

            if ~isempty(controller) && isa(controller, 'handle') && isvalid(controller)

                if isprop(controller, "CancelRequested") || any(strcmp(events(controller), "CancelRequested"))
                    addlistener(controller, 'CancelRequested', @(src, evt)obj.cancel());
                end

            end

        end % FluxAnalysis

        %% Main functions
        function calculateFluxDistribution(obj)
            % CALCULATEFLUXDISTRIBUTION Calculate the flux distribution.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            tStart = tic;
            initializeRunMetadata(obj);
            runMetadataCleanup = onCleanup(@() finalizeRun(obj));

            if obj.isError
                return
            end

            % Data validation
            [isDataValid, effluxFreeSession] = isValidateData(obj);

            if ~isDataValid
                % Notify the initial flux event
                msg = "Data validation failed.";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                obj.isError = true;
                return;
            end % if

            cleanupEffluxFreeModel = onCleanup( ...
                @() restoreEffluxFreeSession( ...
                obj, effluxFreeSession));

            calculateLinearizedMDV(obj);

            if ~isValidateMDV(obj)
                % Notify the initial flux event
                msg = "Invalid MDV data (e.g. NaN values).";
                notifyGeneralMessage(obj, "error", msg, dbstack());
                obj.isError = true;
                return;
            end % if

            experimentalData = obj.RunContext.ExperimentalData;
            obj.ResultSession.writeGeneral( ...
                obj.HDF5FileName, ...
                experimentalData.ExperimentalMDV, ...
                experimentalData.FragmentLabels, ...
                experimentalData.FragmentMask);
            obj.ResultSession.writeModel( ...
                obj.model.getModelTable(), ...
                obj.model.getModelTableRev());

            % Set the experimental values for the optimization
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

            obj.RunContext.setBounds(fluxLB, fluxUB);

            % Export the result of FVA
            obj.ResultSession.writeFluxVariability( ...
                fluxLB, fluxUB, obj.model.getIdxRev());

            fluxRange = obj.RunContext.UpperBounds - ...
                obj.RunContext.LowerBounds;
            averageFlux = mean(fluxRange);
            msg = "Average flux range: " + string(averageFlux) + " mmol/g/h";
            notifyGeneralMessage(obj, "info", msg, dbstack());

            % Construct the EMU of the substrate
            numExperiments = length(obj.expsList);
            substrateEMUs = cell(numExperiments, 1);

            for i = 1:numExperiments
                substrateEMUs{i} = ...
                    obj.Dependencies.SubstrateEMUFactory ...
                    .fromExperiment( ...
                    obj.model, obj.exps, obj.expsList(i));
            end % for

            obj.RunContext.setSubstrateEMUs(substrateEMUs);

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

            % Export the initial flux distribution
            obj.ResultSession.writeInitialFlux( ...
                flux, tmpRhs, RSS, obj.model.getIdxRev());

            if obj.config.isINSTMFA
                try
                    instationaryInput = ...
                        obj.Dependencies.InstationaryInputFactory ...
                        .create( ...
                        obj.model, obj.config.INSTMFA);
                    obj.RunContext.setInstationaryInput( ...
                        instationaryInput);
                catch ME
                    msg = "Instationary 13C-MFA: " + string(ME.message);
                    notifyGeneralMessage(obj, "error", msg, dbstack());
                    obj.isError = true;
                    return;
                end
            end

            workflowResult = obj.Dependencies.MFAWorkflow.run( ...
                tmpRhs, ...
                @(rightHandSide) runMFAIteration( ...
                obj, ...
                obj.RunContext.OptimizationMDV, ...
                rightHandSide, ...
                obj.RunContext.SubstrateEMUs, ...
                false), ...
                ProgressReporter = ...
                    @(iteration, total) ...
                    notifyMFAIterationProgress(obj, iteration, total), ...
                IterationCompleted = ...
                    @(iteration, iterationResult) ...
                    obj.ResultSession.writeIteration( ...
                    iteration, iterationResult, ...
                    obj.model.getIdxRev()), ...
                CancellationRequested = @() obj.isCanceled, ...
                MDVMapper = @(mdv) ...
                obj.RunContext.ExperimentalData.arrangeMDV(mdv));
            obj.RunContext.setWorkflowResult(workflowResult);

            if workflowResult.IsCanceled
                msg = "Nonlinear optimization canceled.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
                return;
            end

            idx = workflowResult.Order;

            minRSS = obj.RunContext.ObjectiveValues(1);
            % Calculate the threshold for chi-squared test
            threshold = obj.Dependencies.MFAFitStatistics ...
                .chiSquareThreshold( ...
                getDOF(obj.model), ...
                obj.RunContext.ExperimentalData.FragmentLabels, ...
                obj.RunContext.ExperimentalData.FragmentMask, ...
                0.05);
            obj.ResultSession.writeSummary( ...
                obj.RunContext.ObjectiveValues, idx, threshold);

            % Notify the result of the flux calculation
            notify(obj, 'FluxResult', BatchProgressEventData( ...
                "FluxResult", obj.ResultSession.Result));

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

            runMetadataCleanup = onCleanup(@() finalizeRun(obj));
            workflowResult = runConfidenceInterval( ...
                obj, ...
                obj.RunContext.OptimizationMDV, ...
                obj.RunContext.SubstrateEMUs);
            fluxLB = workflowResult.LowerBounds;
            fluxUB = workflowResult.UpperBounds;
            output = workflowResult.Output;

            if workflowResult.Method == "Monte Carlo" && ...
                    ~options.forNextSuggestion
                obj.ResultSession.writeMonteCarloConfidenceInterval( ...
                    fluxLB, fluxUB, obj.config.CIConf, output);
            end

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
            problem = obj.Dependencies.FluxVariabilityProblemFactory ...
                .create( ...
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

            solverResult = obj.Dependencies.FluxVariabilitySolver ...
                .solve( ...
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

            workflowResult = obj.Dependencies.InitialFluxWorkflow.run( ...
                obj.model, ...
                obj.config, ...
                obj.RunContext.RightHandSide(:), ...
                obj.RunContext.LowerBounds(:), ...
                obj.RunContext.UpperBounds(:), ...
                obj.RunContext.SubstrateEMUs, ...
                obj.RunContext.ExperimentalData, ...
                obj.RunContext.OptimizationMDV, ...
                obj.RunContext.ExperimentalData.FragmentMask, ...
                obj.Dependencies.SteadyStateMDVPredictor, ...
                createEffluxPenalty(obj), ...
                Method = options.method, ...
                ForNextSuggestion = options.forNextSuggestion, ...
                IterationRate = options.iterationRate, ...
                IterationsPerBatch = options.whileIteration, ...
                BurnIn = options.burnin, ...
                Thinning = options.thinning, ...
                MaxTime = options.maxTime, ...
                Seed = options.seed, ...
                MessageReporter = ...
                @(level, message) ...
                reportAnalysisMessage(obj, level, message), ...
                CancellationRequested = @() obj.isCanceled);
            obj.RunContext.setInitialResult(workflowResult);
            flux = workflowResult.Fluxes;
            rhs = workflowResult.RightHandSides;
            RSS = workflowResult.ObjectiveValues;
            err = workflowResult.IsError;
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

            [fluxLBExp, fluxUBExp, outputCI] = ...
                calculateConfidenceInterval( ...
                obj, forNextSuggestion = true);
            obj.ResultSession.writeMonteCarloConfidenceInterval( ...
                fluxLBExp, fluxUBExp, obj.config.CIConf, outputCI);

            if obj.isCanceled
                msg = "Next flux experiment suggestion canceled.";
                notifyGeneralMessage(obj, "info", msg, dbstack());
                return;
            end % if

            obj.ResultSession.writeSuggestionTable( ...
                obj.config.suggestionTable, ...
                obj.config.suggestionTableVarNames);

            % Split the fluxes (exclude the biomass reaction)
            lowerBounds = obj.model.getSplittedFlux( ...
                fluxLBExp(1:end - 1, end));
            upperBounds = obj.model.getSplittedFlux( ...
                fluxUBExp(1:end - 1, end));
            lowerBounds = [lowerBounds; fluxLBExp(end, end)];
            upperBounds = [upperBounds; fluxUBExp(end, end)];
            obj.RunContext.setBounds(lowerBounds, upperBounds);
            fluxRange = upperBounds - lowerBounds;
            averageFlux = mean(fluxRange);
            msg = "Average flux range: " + string(averageFlux) + " mmol/g/h";
            notifyGeneralMessage(obj, "info", msg, dbstack());
            obj.Dependencies.NextLabelExperimentWorkflow.run( ...
                obj.model, ...
                obj.exps, ...
                obj.expsList, ...
                obj.config, ...
                obj.RunContext.Fluxes(:, 1), ...
                ConfidenceIntervalFunction = ...
                @(mdv, emus) calculateCandidateConfidenceInterval( ...
                obj, mdv, emus), ...
                PatternCompleted = ...
                @(pattern, lower, upper) ...
                obj.ResultSession.writeNextLabelConfidenceInterval( ...
                pattern, lower, upper), ...
                MessageReporter = ...
                @(level, message) ...
                reportAnalysisMessage(obj, level, message), ...
                CancellationRequested = @() obj.isCanceled);

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

        function finalizeRun(obj)
            % FINALIZERUN Refresh the analysis metadata after a run phase.

            if ~isempty(obj.AnalysisRunScope)
                obj.AnalysisRunScope.finish( ...
                    obj.isError, obj.isCanceled);
            end

        end % finalizeRun

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

            rhs = obj.Dependencies.MFAConstraintBuilder ...
                .buildRightHandSide( ...
                obj.model, ...
                obj.mu, ...
                obj.subsList, ...
                obj.efflux);
            obj.RunContext.setRightHandSide(rhs);

        end % calculateRHS

        function reportAnalysisMessage(obj, level, message)

            notifyGeneralMessage(obj, level, message, dbstack());

        end % reportAnalysisMessage

        function notifyMFAIterationProgress(obj, iteration, total)

            msg = "Calculating flux distribution (iteration " + ...
                string(iteration) + "/" + string(total) + ")";
            notifyGeneralMessage(obj, "info", msg, dbstack());

        end % notifyMFAIterationProgress

        function calculateLinearizedMDV(obj)
            % CALCULATELINEARIZEDMDV Create the linearized MDV for fmincon.

            experimentalData = obj.Dependencies ...
                .MFAExperimentalDataBuilder.build( ...
                obj.model, ...
                obj.exps, ...
                obj.expsList, ...
                obj.config.MS);
            obj.RunContext.setExperimentalData(experimentalData);

        end % calculateLinearizedMDV

        %% Optimization functions

        function penalty = createEffluxPenalty(obj)
            % CREATEEFFLUXPENALTY Resolve selected efflux measurements.

            penalty = obj.Dependencies.EffluxPenaltyFactory.create( ...
                obj.model, ...
                obj.subsList, ...
                obj.efflux, ...
                obj.effluxSD, ...
                obj.effluxFree);

        end % createEffluxPenalty

        function result = runMFAIteration( ...
                obj, experimentalMDV, rightHandSide, ...
                substrateEMUs, forceSteadyState)

            result = obj.Dependencies.MFAIterationService.run( ...
                obj.model, ...
                obj.config, ...
                obj.RunContext, ...
                experimentalMDV, ...
                rightHandSide, ...
                obj.subsList, ...
                obj.efflux, ...
                obj.effluxSD, ...
                obj.effluxFree, ...
                SubstrateEMUs = substrateEMUs, ...
                ForceSteadyState = forceSteadyState, ...
                MessageReporter = ...
                @(level, message) ...
                reportAnalysisMessage(obj, level, message));

        end % runMFAIteration

        %% Confidence interval workflow
        function result = runConfidenceInterval( ...
                obj, experimentalMDV, substrateEMUs)

            result = obj.Dependencies.ConfidenceIntervalWorkflow.run( ...
                obj.config, ...
                experimentalMDV, ...
                obj.RunContext.Fluxes, ...
                obj.ResultSession.Status, ...
                obj.RunContext.Problem, ...
                obj.RunContext.InitialRightHandSides, ...
                obj.model.getIdxRev(), ...
                @(mdv, rightHandSide) ...
                runMFAIteration( ...
                obj, mdv, rightHandSide, substrateEMUs, true), ...
                MessageReporter = ...
                @(level, message) ...
                reportAnalysisMessage(obj, level, message), ...
                CancellationRequested = @() obj.isCanceled);

        end % runConfidenceInterval

        function [lowerBounds, upperBounds, output] = ...
                calculateCandidateConfidenceInterval( ...
                obj, experimentalMDV, substrateEMUs)

            workflowResult = runConfidenceInterval( ...
                obj, experimentalMDV, substrateEMUs);
            lowerBounds = workflowResult.LowerBounds;
            upperBounds = workflowResult.UpperBounds;
            output = workflowResult.Output;

        end % calculateCandidateConfidenceInterval

        %% Export functions
        function initializeRunMetadata(obj)

            obj.AnalysisRunScope = openmebius.application.analysis ...
                .AnalysisRunScope( ...
                obj.Dependencies.AnalysisRunLifecycle, ...
                obj.config, ...
                obj.HDF5FileName, ...
                obj.model, ...
                obj.expsList, ...
                obj.Provenance, ...
                obj.ResultLocation, ...
                string(obj.HDF5FilePath), ...
                IsExport = obj.isExport, ...
                FailureReporter = ...
                @(message) handleAnalysisFailure(obj, message));

        end % initializeRunMetadata

        function restoreEffluxFreeSession(~, session)

            if ~isempty(session)
                session.restore();
            end

        end % restoreEffluxFreeSession

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

        function [tf, effluxFreeSession] = isValidateData(obj)
            % VALIDATEDATA Validate the data.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
            end % arguments

            effluxFreeSession = [];
            validation = obj.Dependencies.MFAInputValidator ...
                .validateEfflux( ...
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
                effluxFreeSession = openmebius.application.analysis ...
                    .EffluxFreeModelSession( ...
                    obj.model, ...
                    substrateFree, ...
                    MessageReporter = ...
                    @(level, message) ...
                    reportAnalysisMessage(obj, level, message));
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

            validation = obj.Dependencies.MFAInputValidator ...
                .validateMDV( ...
                obj.RunContext.ExperimentalData.ExperimentalMDV, ...
                obj.RunContext.ExperimentalData.FragmentLabels, ...
                obj.RunContext.ExperimentalData.FragmentMask);
            tf = validation.IsValid;

            if ~validation.IsValid
                notifyGeneralMessage( ...
                    obj, ...
                    "error", ...
                    validation.ErrorMessage, ...
                    dbstack());
            end

        end % function isValidateMDV


        function handleAnalysisFailure(obj, message)

            obj.isError = true;
            notifyGeneralMessage(obj, "error", message, dbstack());

        end % handleAnalysisFailure

    end % methods (Access = private)

end % classdef
