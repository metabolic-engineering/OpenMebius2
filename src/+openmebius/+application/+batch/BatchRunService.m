classdef BatchRunService
    % BATCHRUNSERVICE Executes all analysis phases for one batch entry.

    properties (SetAccess = private)
        AnalysisFactory
    end

    methods

        function obj = BatchRunService(options)

            arguments
                options.AnalysisFactory = ...
                    openmebius.application.analysis.FluxAnalysisFactory()
            end

            obj.AnalysisFactory = options.AnalysisFactory;

        end % constructor

        function result = run( ...
                obj, model, experiments, experimentNames, config, ...
                resultInput, batchId, options)

            arguments
                obj (1, 1) openmebius.application.batch.BatchRunService
                model
                experiments
                experimentNames
                config (1, 1) struct
                resultInput
                batchId
                options.Controller = []
                options.Provenance (1, 1) struct = struct
                options.MessageReporter (1, 1) function_handle = @(~) []
                options.ResultReporter (1, 1) function_handle = @(~) []
            end

            analysis = obj.AnalysisFactory.create( ...
                model, ...
                experiments, ...
                experimentNames, ...
                config, ...
                resultInput, ...
                batchId, ...
                options.Controller, ...
                Provenance = options.Provenance);
            listeners = event.listener.empty(0, 1);
            listeners(end + 1, 1) = addlistener( ...
                analysis, ...
                'GeneralMsg', ...
                @(~, eventData) options.MessageReporter( ...
                    eventData.Notification));
            listeners(end + 1, 1) = addlistener( ...
                analysis, ...
                'FluxResult', ...
                @(~, eventData) options.ResultReporter(eventData));
            listenerCleanup = onCleanup(@() ...
                openmebius.application.batch.BatchRunService ...
                .deleteListeners(listeners));
            runCleanup = onCleanup(@() analysis.finalizeRun());

            analysis.calculateFluxDistribution();
            result = obj.terminalResult(analysis);

            if ~isempty(result)
                return
            end

            analysisConfig = analysis.getConfig();
            isSuggestNextFlux = analysisConfig.suggestNextFlux;

            if isSuggestNextFlux
                analysis.suggestNextFluxExperiment();
            end

            result = obj.terminalResult(analysis);

            if ~isempty(result)
                return
            end

            if analysisConfig.isCalcCI && ~isSuggestNextFlux
                analysis.calculateConfidenceInterval();
            end

            result = obj.terminalResult(analysis);

            if isempty(result)
                result = openmebius.application.batch ...
                    .BatchExecutionResult(true);
            end

        end % run

    end % methods

    methods (Static, Access = private)

        function result = terminalResult(analysis)

            if analysis.isCanceled
                result = openmebius.application.batch ...
                    .BatchExecutionResult(false, Canceled = true);
            elseif analysis.isError
                result = openmebius.application.batch ...
                    .BatchExecutionResult( ...
                        false, ...
                        ErrorMessage = "Batch analysis failed.");
            else
                result = [];
            end

        end % terminalResult

        function deleteListeners(listeners)

            for i = 1:numel(listeners)
                if isvalid(listeners(i))
                    delete(listeners(i));
                end
            end

        end % deleteListeners

    end % methods (Static, Access = private)

end % classdef
