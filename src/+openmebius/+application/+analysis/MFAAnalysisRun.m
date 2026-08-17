classdef MFAAnalysisRun < handle

    properties (SetAccess = private)
        AnalysisController
    end % properties

    properties (Dependent, SetAccess = private)
        isCanceled
        isError
    end

    properties (Access = private)
        MessageReporter (1, 1) function_handle = @(~) []
        ResultReporter (1, 1) function_handle = @(~) []
        ProgressReporter (1, 1) function_handle = @(~, ~, ~) []
        ConfidenceIntervalProgressPhase (1, 1) string = "monte-carlo"
    end

    methods

        function obj = MFAAnalysisRun( ...
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
                options.MessageReporter (1, 1) function_handle = @(~) []
                options.ResultReporter (1, 1) function_handle = @(~) []
                options.ProgressReporter (1, 1) function_handle = ...
                    @(~, ~, ~) []
            end

            composition = options.Composition;
            obj.MessageReporter = options.MessageReporter;
            obj.ResultReporter = options.ResultReporter;
            obj.ProgressReporter = options.ProgressReporter;
            obj.ConfidenceIntervalProgressPhase = ...
                obj.confidenceIntervalProgressPhase(config);
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
            reportAnalysisMessage( ...
                obj, runtime.DirectoryMessageLevel, ...
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

        end % MFAAnalysisRun

        %% Main functions
        function calculateFluxDistribution(obj)
            % CALCULATEFLUXDISTRIBUTION Calculate the flux distribution.
            %
            % Parameters:
            %   obj: MFAAnalysisRun
            %       The current MFA analysis run.

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
            obj.ResultReporter( ...
                obj.AnalysisController.ResultSession.Result);

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
            %   obj: MFAAnalysisRun
            %       The current MFA analysis run.
            %   options.forNextSuggestion (1, 1) logical = false

            arguments
                obj (1, 1) openmebius.application.analysis.MFAAnalysisRun
                options.forNextSuggestion (1, 1) logical = false
            end % arguments

            runMetadataCleanup = onCleanup(@() finalizeRun(obj));

            workflowResult = obj.AnalysisController ...
                .calculateConfidenceInterval( ...
                PersistResult = ~options.forNextSuggestion, ...
                MessageReporter = ...
                @(level, message) ...
                reportAnalysisMessage(obj, level, message), ...
                ProgressReporter = @(completed, total) ...
                notifyConfidenceIntervalProgress( ...
                obj, completed, total));
            fluxLB = workflowResult.LowerBounds;
            fluxUB = workflowResult.UpperBounds;
            output = workflowResult.Output;

        end % calculateConfidenceInterval

        function [fluxLB, fluxUB, output] = suggestNextFluxExperiment(obj)
            % SUGGESTNEXTFLUXEXPERIMENT Suggest the next flux experiment.
            %
            % Parameters:
            %   obj: MFAAnalysisRun
            %       The current MFA analysis run.

            arguments
                obj (1, 1) openmebius.application.analysis.MFAAnalysisRun
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

        function value = get.isCanceled(obj)

            value = obj.AnalysisController.IsCanceled;

        end

        function value = get.isError(obj)

            value = obj.AnalysisController.IsError;

        end

        function finalizeRun(obj)
            % FINALIZERUN Refresh the analysis metadata after a run phase.

            obj.AnalysisController.finishRun();

        end % finalizeRun

    end % methods

    methods (Access = private)

        function reportAnalysisMessage(obj, level, message)

            obj.MessageReporter( ...
                openmebius.core.notification.Message( ...
                string(message), string(level)));

        end % reportAnalysisMessage

        function notifyMFAIterationProgress(obj, iteration, total)

            msg = "Calculating flux distribution (iteration " + ...
                string(iteration) + "/" + string(total) + ")";
            reportAnalysisMessage(obj, "info", msg);
            obj.ProgressReporter( ...
                "optimization", iteration, total);

        end % notifyMFAIterationProgress

        function notifyConfidenceIntervalProgress( ...
                obj, completed, total)

            obj.ProgressReporter( ...
                obj.ConfidenceIntervalProgressPhase, completed, total);

        end % notifyConfidenceIntervalProgress

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
            %   obj: MFAAnalysisRun
            %       The current MFA analysis run.

            obj.AnalysisController.requestCancellation();

        end % cancel

        function handleAnalysisFailure(obj, message)

            obj.AnalysisController.recordFailure();
            reportAnalysisMessage(obj, "error", message);

        end % handleAnalysisFailure

        function phase = confidenceIntervalProgressPhase(~, config)

            phase = "monte-carlo";

            if ~isstruct(config) || ~isscalar(config) || ...
                    ~isfield(config, 'CIConf') || ...
                    ~isstruct(config.CIConf) || ...
                    ~isfield(config.CIConf, 'algorithm')
                return
            end

            method = lower(strtrim(string(config.CIConf.algorithm)));

            if method == "grid search"
                phase = "grid-search";
            end

        end % confidenceIntervalProgressPhase

    end % methods (Access = private)

end % classdef
