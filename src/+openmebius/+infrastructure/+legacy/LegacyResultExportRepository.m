classdef LegacyResultExportRepository < handle
    % Adapter for the legacy IOResult export implementation.

    methods

        function saveResult( ...
                ~, ...
                result, ...
                batchIDs, ...
                batchNames, ...
                outputLocation, ...
                options)

            arguments
                ~
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
                outputLocation openmebius.domain.result.ResultLocation
                options.AddDatetime (1, 1) logical = true
            end

            for iBatch = 1:numel(batchIDs)

                batchID = batchIDs(iBatch);
                batchName = batchNames(iBatch);
                directoryName = ...
                    openmebius.infrastructure.legacy.LegacyResultExportRepository ...
                    .exportDirectoryName( ...
                    batchName, ...
                    batchID, ...
                    options.AddDatetime);
                exportLocation = outputLocation.childLocation(directoryName);

                openmebius.infrastructure.legacy.LegacyResultExportRepository ...
                    .createExportDirectory(exportLocation);

                result.saveResultData( ...
                    batchID, ...
                    batchName, ...
                    exportLocation, ...
                    "xlsx");

            end

        end

    end

    methods (Static, Access = private)

        function directoryName = exportDirectoryName( ...
                batchName, ...
                batchID, ...
                addDatetime)

            directoryName = string(batchName) + "_" + string(batchID);

            if addDatetime
                directoryName = directoryName + "_" + ...
                    string(datetime('now', 'Format', 'yyyyMMdd-HHmmss'));
            end

        end

        function createExportDirectory(exportLocation)

            if exportLocation.directoryExists()
                error( ...
                    "OpenMebius2:ResultExport:OutputDirectoryExists", ...
                    "Output directory already exists: %s", ...
                    exportLocation.Directory);
            end

            try
                mkdir(exportLocation.Directory);
            catch ME
                error( ...
                    "OpenMebius2:ResultExport:CreateDirectoryFailed", ...
                    "Failed to create the output directory: %s", ...
                    ME.message);
            end

        end

    end

end
