classdef ReportGenerationService < handle

    properties (Access = private)
        ReportRepository
    end

    methods

        function obj = ReportGenerationService(options)

            arguments
                options.ReportRepository = ...
                    openmebius.infrastructure.report.ReportRepository()
            end

            obj.ReportRepository = options.ReportRepository;

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

            % IsDeployed is retained for API compatibility. Report generation
            % follows the same path in MATLAB and compiled applications.
            openmebius.application.report.ReportGenerationService ...
                .validateResultLocation(resultLocation);
            openmebius.application.report.ReportGenerationService ...
                .validateData("Model", model);
            openmebius.application.report.ReportGenerationService ...
                .validateData("Experiment", experiments);
            openmebius.application.report.ReportGenerationService ...
                .validateData("Result", result);

            report = obj.ReportRepository.create( ...
                resultLocation, ...
                model, ...
                experiments, ...
                result);

            outputPath = obj.ReportRepository.outputPath( ...
                report, ...
                resultLocation);
            messages = ...
                openmebius.application.report.ReportGenerationService ...
                .createMessages(outputPath);

            if options.OpenReport
                obj.ReportRepository.view(report);
            end

            generationResult = ...
                openmebius.application.report.ReportGenerationResult( ...
                Report = report, ...
                ResultLocation = resultLocation, ...
                OutputPath = outputPath, ...
                Messages = messages);

        end

    end

    methods (Static, Access = private)

        function validateResultLocation(resultLocation)

            if ~resultLocation.hasDirectory()
                error( ...
                    "OpenMebius2:Report:ResultDirectoryUnavailable", ...
                    "Result directory is not available.");
            end

            if ~resultLocation.directoryExists()
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

        function messages = createMessages(outputPath)

            messages = "Report generated successfully.";

            if outputPath ~= ""
                messages = [
                    messages
                    "Report output: " + outputPath
                    ];
            end

        end

    end

end
