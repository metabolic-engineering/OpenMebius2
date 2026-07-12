classdef ResultExportService < handle

    properties (Access = private)
        ResultExporter
    end

    methods

        function obj = ResultExportService(options)

            arguments
                options.ResultExporter = ...
                    openmebius.infrastructure.legacy.LegacyResultExportRepository()
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
            end

            openmebius.application.result.ResultExportService ...
                .validateResult(result);
            openmebius.application.result.ResultExportService ...
                .validateSelection(batchIDs, batchNames);
            openmebius.application.result.ResultExportService ...
                .validateOutputLocation(outputLocation);

            obj.ResultExporter.saveResult( ...
                result, ...
                batchIDs, ...
                batchNames, ...
                outputLocation, ...
                AddDatetime = options.AddDatetime);

            exportResult = ...
                openmebius.application.result.ResultExportResult( ...
                OutputLocation = outputLocation, ...
                BatchIDs = batchIDs, ...
                BatchNames = batchNames, ...
                Messages = ...
                openmebius.application.result.ResultExportService ...
                .createMessages(outputLocation, batchIDs));

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

        function messages = createMessages(outputLocation, batchIDs)

            messages = [
                        "Result export completed successfully."
                        "Exported result count: " + string(numel(batchIDs))
                        "Export directory: " + outputLocation.Directory
                       ];

        end

    end

end
