classdef LegacyResultExportRepository < handle
    % Adapter for the legacy IOResult export implementation.

    methods

        function saveResult( ...
                ~, ...
                result, ...
                exportPlan)

            arguments
                ~
                result
                exportPlan openmebius.application.result.ResultExportPlan
            end

            for iBatch = 1:exportPlan.count()

                exportLocation = exportPlan.exportLocation(iBatch);

                openmebius.infrastructure.legacy.LegacyResultExportRepository ...
                    .createExportDirectory(exportLocation);

                result.saveResultData( ...
                    exportPlan.BatchIDs(iBatch), ...
                    exportPlan.BatchNames(iBatch), ...
                    exportLocation, ...
                    "xlsx");

            end

        end

    end

    methods (Static, Access = private)

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
