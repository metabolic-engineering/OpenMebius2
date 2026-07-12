classdef ReportGenerationService < handle

    properties (Access = private)
        ReportFactory (1, 1) function_handle = ...
            @(resultLocation, model, experiments, result) ...
            ReportResult( ...
            resultLocation, model, experiments, result, ...
            OpenAfterBuild = false)
        ReportViewer (1, 1) function_handle = @(report) view(report)
    end

    methods

        function obj = ReportGenerationService(options)

            arguments
                options.ReportFactory (1, 1) function_handle = ...
                    @(resultLocation, model, experiments, result) ...
                    ReportResult( ...
                    resultLocation, model, experiments, result, ...
                    OpenAfterBuild = false)
                options.ReportViewer (1, 1) function_handle = ...
                    @(report) view(report)
            end

            obj.ReportFactory = options.ReportFactory;
            obj.ReportViewer = options.ReportViewer;

        end

        function generationResult = generate( ...
                obj, ...
                resultLocation, ...
                model, ...
                experiments, ...
                result, ...
                options)

            arguments
                obj
                resultLocation openmebius.domain.result.ResultLocation
                model
                experiments
                result
                options.IsDeployed (1, 1) logical = isdeployed
                options.OpenReport (1, 1) logical = true
            end

            openmebius.application.report.ReportGenerationService ...
                .validateRuntime(options.IsDeployed);
            openmebius.application.report.ReportGenerationService ...
                .validateResultLocation(resultLocation);
            openmebius.application.report.ReportGenerationService ...
                .validateData("Model", model);
            openmebius.application.report.ReportGenerationService ...
                .validateData("Experiment", experiments);
            openmebius.application.report.ReportGenerationService ...
                .validateData("Result", result);

            report = obj.ReportFactory( ...
                resultLocation, ...
                model, ...
                experiments, ...
                result);

            if options.OpenReport
                obj.ReportViewer(report);
            end

            generationResult = ...
                openmebius.application.report.ReportGenerationResult( ...
                Report = report, ...
                ResultLocation = resultLocation, ...
                Messages = "Report generated successfully.");

        end

    end

    methods (Static, Access = private)

        function validateRuntime(isDeployedRuntime)

            if isDeployedRuntime
                error( ...
                    "OpenMebius2:Report:UnavailableInDeployed", ...
                    "Report generation is not available in the deployed version.");
            end

        end

        function validateResultLocation(resultLocation)

            if resultLocation.Directory == ""
                error( ...
                    "OpenMebius2:Report:ResultDirectoryUnavailable", ...
                    "Result directory is not available.");
            end

            if ~isfolder(resultLocation.Directory)
                error( ...
                    "OpenMebius2:Report:ResultDirectoryNotFound", ...
                    "Result directory does not exist: %s", ...
                    resultLocation.Directory);
            end

        end

        function validateData(label, value)

            if isempty(value)
                error( ...
                    "OpenMebius2:Report:DataUnavailable", ...
                    "%s data is not available.", label);
            end

            if openmebius.application.report.ReportGenerationService ...
                    .hasErrorState(value)
                error( ...
                    "OpenMebius2:Report:DataUnavailable", ...
                    "%s data is not available.", label);
            end

        end

        function tf = hasErrorState(value)

            tf = false;

            if isstruct(value) && isfield(value, "isError")
                tf = logical(value.isError);
                return
            end

            if isobject(value) && isprop(value, "isError")
                tf = logical(value.isError);
            end

        end

    end

end
