classdef ResultOperationController < handle
    % RESULTOPERATIONCONTROLLER Runs result export and report use cases.

    properties (Access = private)
        ResultExportService
        ReportGenerationService
        ResultSuggestionService
        ResultRangePlotService
        ResultInformationService
        ResultDiffService
    end

    methods

        function obj = ResultOperationController(options)

            arguments
                options.ResultExportService = ...
                    openmebius.application.result.ResultExportService()
                options.ReportGenerationService = ...
                    openmebius.application.report.ReportGenerationService()
                options.ResultSuggestionService = ...
                    openmebius.application.result.ResultSuggestionService()
                options.ResultRangePlotService = ...
                    openmebius.application.result.ResultRangePlotService()
                options.ResultInformationService = ...
                    openmebius.application.result.ResultInformationService()
                options.ResultDiffService = ...
                    openmebius.application.result.ResultDiffService()
            end

            obj.ResultExportService = options.ResultExportService;
            obj.ReportGenerationService = ...
                options.ReportGenerationService;
            obj.ResultSuggestionService = ...
                options.ResultSuggestionService;
            obj.ResultRangePlotService = ...
                options.ResultRangePlotService;
            obj.ResultInformationService = ...
                options.ResultInformationService;
            obj.ResultDiffService = options.ResultDiffService;

        end % constructor

        function outcome = generateReport( ...
                obj, resultLocation, model, experiments, result, options)

            arguments
                obj
                resultLocation openmebius.domain.result.ResultLocation
                model
                experiments
                result
                options.IsDeployed (1, 1) logical = isdeployed
            end

            outcome = obj.execute( ...
                @() obj.ReportGenerationService.generate( ...
                resultLocation, ...
                model, ...
                experiments, ...
                result, ...
                IsDeployed = options.IsDeployed));

        end % generateReport

        function outcome = exportResults( ...
                obj, result, batchIDs, batchNames, outputLocation)

            arguments
                obj
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
                outputLocation openmebius.domain.result.ResultLocation
            end

            outcome = obj.execute( ...
                @() obj.ResultExportService.export( ...
                result, ...
                batchIDs, ...
                batchNames, ...
                outputLocation));

        end % exportResults

        function outcome = loadSuggestion( ...
                obj, result, batchIDs, batchNames)

            arguments
                obj
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
            end

            outcome = obj.execute( ...
                @() obj.ResultSuggestionService.load( ...
                result, batchIDs, batchNames));

        end % loadSuggestion

        function outcome = prepareRangePlot( ...
                obj, result, batchIDs, batchNames)

            arguments
                obj
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
            end

            outcome = obj.execute( ...
                @() obj.ResultRangePlotService.prepare( ...
                result, batchIDs, batchNames));

        end % prepareRangePlot

        function outcome = loadInformation( ...
                obj, result, batchIDs, batchNames, modelDegreesOfFreedom)

            arguments
                obj
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
                modelDegreesOfFreedom (1, 1) double
            end

            outcome = obj.execute( ...
                @() obj.ResultInformationService.load( ...
                result, ...
                batchIDs, ...
                batchNames, ...
                modelDegreesOfFreedom));

        end % loadInformation

        function outcome = compareSettings( ...
                obj, result, batchIDs, batchNames)

            arguments
                obj
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
            end

            outcome = obj.execute( ...
                @() obj.ResultDiffService.compare( ...
                result, batchIDs, batchNames));

        end % compareSettings

    end % methods

    methods (Access = private)

        function outcome = execute(~, command)

            try
                result = command();
                outcome = openmebius.application.result ...
                    .ResultOperationOutcome( ...
                    true, Result = result);
            catch exception
                outcome = openmebius.application.result ...
                    .ResultOperationOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end % execute

    end % methods (Access = private)

end % classdef
