classdef ResultExportService < handle

    properties (Access = private)
        ResultExporter
    end

    methods

        function obj = ResultExportService(options)

            arguments
                options.ResultExporter = ...
                    openmebius.infrastructure.result.ResultExportRepository()
            end

            obj.ResultExporter = options.ResultExporter;

        end

        function exportResult = export( ...
                obj, ...
                result, ...
                batchIDs, ...
                batchNames, ...
                outputLocation, ...
                options)

            arguments
                obj
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
                outputLocation openmebius.domain.result.ResultLocation
                options.AddDatetime (1, 1) logical = true
                options.Timestamp (1, 1) string = ...
                    string(datetime('now', 'Format', 'yyyyMMdd-HHmmss'))
            end

            openmebius.application.result.ResultExportService ...
                .validateResult(result);
            openmebius.application.result.ResultExportService ...
                .validateSelection(batchIDs, batchNames);
            openmebius.application.result.ResultExportService ...
                .validateOutputLocation(outputLocation);

            exportPlan = openmebius.application.result.ResultExportPlan ...
                .build( ...
                batchIDs, ...
                batchNames, ...
                outputLocation, ...
                AddDatetime = options.AddDatetime, ...
                Timestamp = options.Timestamp);

            obj.ResultExporter.saveResult( ...
                result, ...
                exportPlan);

            exportResult = ...
                openmebius.application.result.ResultExportResult( ...
                OutputLocation = exportPlan.OutputLocation, ...
                BatchIDs = exportPlan.BatchIDs, ...
                BatchNames = exportPlan.BatchNames, ...
                Messages = ...
                openmebius.application.result.ResultExportService ...
                .createMessages(exportPlan));

        end

    end

    methods (Static, Access = private)

        function validateResult(result)

            if isempty(result)
                error( ...
                    "OpenMebius2:ResultExport:ResultUnavailable", ...
                    "Result data is not available.");
            end

            if isstruct(result) && isfield(result, "isError") && result.isError
                error( ...
                    "OpenMebius2:ResultExport:ResultUnavailable", ...
                    "Result data is not available.");
            end

            if isobject(result) && isprop(result, "isError") && result.isError
                error( ...
                    "OpenMebius2:ResultExport:ResultUnavailable", ...
                    "Result data is not available.");
            end

        end

        function validateSelection(batchIDs, batchNames)

            if isempty(batchIDs)
                error( ...
                    "OpenMebius2:ResultExport:EmptySelection", ...
                    "Please select a result to save.");
            end

            if numel(batchIDs) ~= numel(batchNames)
                error( ...
                    "OpenMebius2:ResultExport:SelectionMismatch", ...
                    "Batch ID and names must have the same length.");
            end

        end

        function validateOutputLocation(outputLocation)

            if ~outputLocation.hasDirectory()
                error( ...
                    "OpenMebius2:ResultExport:OutputDirectoryUnavailable", ...
                    "Output directory is not available.");
            end

            if ~outputLocation.directoryExists()
                error( ...
                    "OpenMebius2:ResultExport:OutputDirectoryNotFound", ...
                    "Output directory does not exist: %s", ...
                    outputLocation.Directory);
            end

        end

        function messages = createMessages(exportPlan)

            messages = [
                "Result export completed successfully."
                "Exported result count: " + string(exportPlan.count())
                "Export directory: " + exportPlan.OutputLocation.Directory
                ];

        end

    end

end
