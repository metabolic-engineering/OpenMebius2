classdef BatchRunService
    % BATCHRUNSERVICE Executes all analysis phases for one batch entry.

    properties (SetAccess = private)
        AnalysisFactory
    end

    methods

        function obj = BatchRunService(options)

            arguments
                options.AnalysisFactory = ...
                    openmebius.application.analysis.MFAAnalysisRunFactory()
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
                Provenance = options.Provenance, ...
                MessageReporter = options.MessageReporter, ...
                ResultReporter = options.ResultReporter);
            runCleanup = onCleanup(@() analysis.finalizeRun());

            analysis.calculateFluxDistribution();
            result = obj.terminalResult(analysis);

            if ~isempty(result)
                return
            end

            isSuggestNextFlux = logical(config.suggestNextFlux);

            if isSuggestNextFlux
                analysis.suggestNextFluxExperiment();
            end

            result = obj.terminalResult(analysis);

            if ~isempty(result)
                return
            end

            if logical(config.isCalcCI) && ~isSuggestNextFlux
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

    end % methods (Static, Access = private)

end % classdef
