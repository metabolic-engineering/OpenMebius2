classdef FluxAnalysis < handle

    events

        GeneralMsg
        FluxResult

    end % events

    properties (Access = public)

        % Cancel flag
        isCanceled (1, 1) logical = false
        isError (1, 1) logical = false

    end % properties (Access = public)

    properties (SetAccess = private)

        %% Objects
        model % The EMU model object
        exps % The EMU experiments object
        config % The configuration object
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
        InputPreparation = []

    end % properties

    properties (Access = private)
        MessagePublisher
    end

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
                options.Composition (1, 1) ...
                    openmebius.application.analysis ...
                    .FluxAnalysisComposition = ...
                    openmebius.application.analysis ...
                    .FluxAnalysisComposition()
                options.Provenance (1, 1) struct = struct
            end

            obj.Provenance = options.Provenance;
            composition = options.Composition;
            obj.MessagePublisher = openmebius.presentation ...
                .notification.GeneralMessagePublisher();
            runtimeFactory = composition.RuntimeFactory;

            if isempty(runtimeFactory)
                runtimeFactory = openmebius.application.analysis ...
                    .FluxAnalysisRuntimeFactory();
            end

            runtime = runtimeFactory.create( ...
                resultInput, ...
                ID, ...
                composition, ...
                FailureReporter = ...
                @(message) handleAnalysisFailure(obj, message));
            obj.ResultLocation = runtime.ResultLocation;
            obj.HDF5FileName = runtime.ResultID;
            obj.HDF5FilePath = runtime.ResultFilePath;
            obj.isExport = runtime.IsExport;
            obj.isError = runtime.IsError;
            obj.Dependencies = runtime.Dependencies;
            obj.RunContext = runtime.RunContext;
            obj.ResultSession = runtime.ResultSession;
            obj.MessagePublisher.write( ...
                runtime.DirectoryMessageLevel, ...
                runtime.DirectoryMessage);

            obj.model = model;
            obj.exps = experiments;

            obj.expsList = obj.Dependencies ...
                .MFAExperimentListNormalizer.normalize( ...
                expList);

            obj.config = config;

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

            workflowResult = obj.Dependencies ...
                .FluxDistributionWorkflow.run( ...
                obj.model, ...
                obj.exps, ...
                obj.expsList, ...
                obj.config, ...
                obj.RunContext, ...
                obj.ResultSession, ...
                obj.HDF5FileName, ...
                MessageReporter = ...
                    @(level, message) ...
                    reportAnalysisMessage(obj, level, message), ...
                ProgressReporter = ...
                    @(iteration, total) ...
                    notifyMFAIterationProgress(obj, iteration, total), ...
                CancellationRequested = @() obj.isCanceled);
            obj.InputPreparation = workflowResult.InputPreparation;

            if workflowResult.IsCanceled
                obj.isCanceled = true;
                return
            end

            if workflowResult.IsError
                obj.isError = true;
                return
            end

            % Notify the result of the flux calculation
            eventData = openmebius.presentation.result ...
                .FluxResultEventMapper.fromSessionResult( ...
                obj.ResultSession.Result);
            notify(obj, 'FluxResult', eventData);

            tStop = toc(tStart);
            elapsedTimeText = string(seconds(tStop), "hh:mm:ss");
            msg = "Flux calculation completed" + ...
                " (Elapsed time: " + elapsedTimeText + ", " + ...
                "RSS: " + string(workflowResult.MinimumObjective) + ")";
            reportAnalysisMessage(obj, "info", msg);

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
            settings = openmebius.application.analysis ...
                .MFAConfidenceIntervalRunSettingsMapper ...
                .fromBatchConfig(obj.config);
            workflowResult = obj.Dependencies ...
                .ConfidenceIntervalApplicationWorkflow.run( ...
                obj.model, ...
                settings, ...
                obj.RunContext, ...
                obj.ResultSession, ...
                obj.InputPreparation, ...
                PersistResult = ~options.forNextSuggestion, ...
                MessageReporter = ...
                    @(level, message) ...
                    reportAnalysisMessage(obj, level, message), ...
                CancellationRequested = @() obj.isCanceled);
            fluxLB = workflowResult.LowerBounds;
            fluxUB = workflowResult.UpperBounds;
            output = workflowResult.Output;

            if workflowResult.IsCanceled
                obj.isCanceled = true;
            elseif workflowResult.IsError
                obj.isError = true;
            end

        end % calculateConfidenceInterval

        function [fluxLB, fluxUB, output] = suggestNextFluxExperiment(obj)
            % SUGGESTNEXTFLUXEXPERIMENT Suggest the next flux experiment.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            arguments
                obj (1, 1) FluxAnalysis
            end % arguments

            runMetadataCleanup = onCleanup(@() finalizeRun(obj));
            settings = openmebius.application.analysis ...
                .NextFluxExperimentRunSettingsMapper ...
                .fromBatchConfig(obj.config);
            workflowResult = obj.Dependencies ...
                .NextFluxExperimentWorkflow.run( ...
                obj.model, ...
                obj.exps, ...
                obj.expsList, ...
                settings, ...
                obj.RunContext, ...
                obj.ResultSession, ...
                obj.InputPreparation, ...
                MessageReporter = ...
                    @(level, message) ...
                    reportAnalysisMessage(obj, level, message), ...
                CancellationRequested = @() obj.isCanceled);
            fluxLB = workflowResult.LowerBounds;
            fluxUB = workflowResult.UpperBounds;
            output = workflowResult.Output;

            if workflowResult.IsCanceled
                obj.isCanceled = true;
            elseif workflowResult.IsError
                obj.isError = true;
            end

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

        function reportAnalysisMessage(obj, level, message)

            obj.MessagePublisher.report( ...
                level, ...
                message, ...
                @(eventData) notify(obj, 'GeneralMsg', eventData));

        end % reportAnalysisMessage

        function notifyMFAIterationProgress(obj, iteration, total)

            msg = "Calculating flux distribution (iteration " + ...
                string(iteration) + "/" + string(total) + ")";
            reportAnalysisMessage(obj, "info", msg);

        end % notifyMFAIterationProgress

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

        %% Other functions
        function cancel(obj)
            % CANCEL Cancel the calculation.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            obj.isCanceled = true;

        end % cancel

        function handleAnalysisFailure(obj, message)

            obj.isError = true;
            reportAnalysisMessage(obj, "error", message);

        end % handleAnalysisFailure

    end % methods (Access = private)

end % classdef
