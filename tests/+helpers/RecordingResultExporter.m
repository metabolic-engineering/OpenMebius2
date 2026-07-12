classdef RecordingResultExporter < handle

    properties
        WasCalled (1, 1) logical = false
        Result
        BatchIDs (:, 1) string = strings(0, 1)
        BatchNames (:, 1) string = strings(0, 1)
        OutputLocation openmebius.domain.result.ResultLocation
        ExportDirectories (:, 1) string = strings(0, 1)
    end

    methods

        function saveResult( ...
                obj, ...
                result, ...
                exportPlan)

            arguments
                obj
                result
                exportPlan openmebius.application.result.ResultExportPlan
            end

            obj.WasCalled = true;
            obj.Result = result;
            obj.BatchIDs = exportPlan.BatchIDs;
            obj.BatchNames = exportPlan.BatchNames;
            obj.OutputLocation = exportPlan.OutputLocation;
            obj.ExportDirectories = exportPlan.ExportDirectories;

        end

    end

end
