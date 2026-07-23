classdef ResultExportRepository < handle
    % RESULTEXPORTREPOSITORY Persists result export plans.

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

                exportItem = exportPlan.exportItem(iBatch);

                openmebius.infrastructure.result.ResultExportRepository ...
                    .createExportDirectory(exportItem.ExportLocation);

                result.saveResultData( ...
                    exportItem.BatchID, ...
                    exportItem.BatchName, ...
                    exportItem.ExportLocation, ...
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
