classdef FluxAnalysis < handle

    events

        GeneralMsg
        FluxResult

    end % events

    properties (SetAccess = private)
        AnalysisController
    end % properties

    properties (Dependent, SetAccess = private)
        model
        exps
        config
        Dependencies
        RunContext
        ResultSession
        isExport
        ResultLocation
        HDF5FileName
        HDF5FilePath
        Provenance
        expsList
        isCanceled
        isError
        AnalysisRunScope
        RunSettings
        InputPreparation
    end

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

            composition = options.Composition;
            obj.MessagePublisher = openmebius.presentation ...
                .notification.GeneralMessagePublisher();
            runtimeFactory = composition.Execution.RuntimeFactory;

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
            obj.MessagePublisher.write( ...
                runtime.DirectoryMessageLevel, ...
                runtime.DirectoryMessage);
            obj.AnalysisController = ...
                composition.Execution.AnalysisControllerFactory.create( ...
                model, ...
                experiments, ...
                expList, ...
                config, ...
                runtime, ...
                options.Provenance);

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

            workflowResult = obj.AnalysisController ...
                .runFluxDistribution( ...
                MessageReporter = ...
                    @(level, message) ...
                    reportAnalysisMessage(obj, level, message), ...
                ProgressReporter = ...
                    @(iteration, total) ...
                    notifyMFAIterationProgress(obj, iteration, total));
            if workflowResult.IsCanceled
                return
            end

            if workflowResult.IsError
                return
            end

            % Notify the result of the flux calculation
            eventData = openmebius.presentation.result ...
                .FluxResultEventMapper.fromSessionResult( ...
                obj.AnalysisController.ResultSession.Result);
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

            workflowResult = obj.AnalysisController ...
                .calculateConfidenceInterval( ...
                PersistResult = ~options.forNextSuggestion, ...
                MessageReporter = ...
                    @(level, message) ...
                    reportAnalysisMessage(obj, level, message));
            fluxLB = workflowResult.LowerBounds;
            fluxUB = workflowResult.UpperBounds;
            output = workflowResult.Output;

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

            workflowResult = obj.AnalysisController ...
                .suggestNextFluxExperiment( ...
                MessageReporter = ...
                    @(level, message) ...
                    reportAnalysisMessage(obj, level, message));
            fluxLB = workflowResult.LowerBounds;
            fluxUB = workflowResult.UpperBounds;
            output = workflowResult.Output;

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

            config = obj.AnalysisController.Config;

        end % getConfig

        function value = get.RunSettings(obj)

            value = obj.AnalysisController.RunSettings;

        end

        function value = get.model(obj)

            value = obj.AnalysisController.Model;

        end

        function value = get.exps(obj)

            value = obj.AnalysisController.Experiments;

        end

        function value = get.config(obj)

            value = obj.AnalysisController.Config;

        end

        function value = get.Dependencies(obj)

            value = obj.AnalysisController.Dependencies;

        end

        function value = get.RunContext(obj)

            value = obj.AnalysisController.RunContext;

        end

        function value = get.ResultSession(obj)

            value = obj.AnalysisController.ResultSession;

        end

        function value = get.isExport(obj)

            value = obj.AnalysisController.IsExport;

        end

        function value = get.ResultLocation(obj)

            value = obj.AnalysisController.ResultLocation;

        end

        function value = get.HDF5FileName(obj)

            value = obj.AnalysisController.ResultID;

        end

        function value = get.HDF5FilePath(obj)

            value = obj.AnalysisController.ResultFilePath;

        end

        function value = get.Provenance(obj)

            value = obj.AnalysisController.Provenance;

        end

        function value = get.expsList(obj)

            value = obj.AnalysisController.ExperimentList;

        end

        function value = get.isCanceled(obj)

            value = obj.AnalysisController.IsCanceled;

        end

        function value = get.isError(obj)

            value = obj.AnalysisController.IsError;

        end

        function value = get.AnalysisRunScope(obj)

            value = obj.AnalysisController.RunScope;

        end

        function value = get.InputPreparation(obj)

            value = obj.AnalysisController.InputPreparation;

        end

        function finalizeRun(obj)
            % FINALIZERUN Refresh the analysis metadata after a run phase.

            obj.AnalysisController.finishRun();

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

            obj.AnalysisController.initializeRunScope( ...
                FailureReporter = ...
                @(message) reportAnalysisMessage( ...
                    obj, "error", message));

        end % initializeRunMetadata

        %% Other functions
        function cancel(obj)
            % CANCEL Cancel the calculation.
            %
            % Parameters:
            %   obj: FluxAnalysis
            %       The FluxAnalysis object.

            obj.AnalysisController.requestCancellation();

        end % cancel

        function handleAnalysisFailure(obj, message)

            obj.AnalysisController.recordFailure();
            reportAnalysisMessage(obj, "error", message);

        end % handleAnalysisFailure

    end % methods (Access = private)

end % classdef
