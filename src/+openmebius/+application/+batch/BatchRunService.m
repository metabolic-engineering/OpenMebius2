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

        function status = run( ...
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
            status = obj.terminalStatus(analysis);

            if status ~= ""
                return
            end

            analysisConfig = analysis.getConfig();
            isSuggestNextFlux = analysisConfig.suggestNextFlux;

            if isSuggestNextFlux
                analysis.suggestNextFluxExperiment();
            end

            status = obj.terminalStatus(analysis);

            if status ~= ""
                return
            end

            if analysisConfig.isCalcCI && ~isSuggestNextFlux
                analysis.calculateConfidenceInterval();
            end

            status = obj.terminalStatus(analysis);

            if status == ""
                status = "finished";
            end

        end % run

    end % methods

    methods (Static, Access = private)

        function status = terminalStatus(analysis)

            if analysis.isCanceled
                status = "canceled";
            elseif analysis.isError
                status = "error";
            else
                status = "";
            end

        end % terminalStatus

        function deleteListeners(listeners)

            for i = 1:numel(listeners)
                if isvalid(listeners(i))
                    delete(listeners(i));
                end
            end

        end % deleteListeners

    end % methods (Static, Access = private)

end % classdef
