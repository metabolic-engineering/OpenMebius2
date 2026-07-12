classdef ResultExportPlan

    properties (SetAccess = private)
        OutputLocation openmebius.domain.result.ResultLocation
        BatchIDs (:, 1) string
        BatchNames (:, 1) string
        ExportDirectories (:, 1) string
    end

    methods

        function obj = ResultExportPlan(options)

            arguments
                options.OutputLocation openmebius.domain.result.ResultLocation
                options.BatchIDs (:, 1) string
                options.BatchNames (:, 1) string
                options.ExportDirectories (:, 1) string
            end

            obj.OutputLocation = options.OutputLocation;
            obj.BatchIDs = options.BatchIDs;
            obj.BatchNames = options.BatchNames;
            obj.ExportDirectories = options.ExportDirectories;

        end

        function n = count(obj)

            n = numel(obj.BatchIDs);

        end

        function location = exportLocation(obj, index)

            arguments
                obj
                index (1, 1) double {mustBeInteger, mustBePositive}
            end

            location = openmebius.domain.result.ResultLocation ...
                .fromDirectory(obj.ExportDirectories(index));

        end

        function item = exportItem(obj, index)

            arguments
                obj
                index (1, 1) double {mustBeInteger, mustBePositive}
            end

            exportLocation = obj.exportLocation(index);

            item = struct( ...
                "BatchID", obj.BatchIDs(index), ...
                "BatchName", obj.BatchNames(index), ...
                "ExportLocation", exportLocation, ...
                "ExportDirectory", exportLocation.Directory);

        end

    end

    methods (Static)

        function obj = build(batchIDs, batchNames, outputLocation, options)

            arguments
                batchIDs (:, 1) string
                batchNames (:, 1) string
                outputLocation openmebius.domain.result.ResultLocation
                options.AddDatetime (1, 1) logical = true
                options.Timestamp (1, 1) string = ...
                    string(datetime('now', 'Format', 'yyyyMMdd-HHmmss'))
            end

            exportDirectories = strings(numel(batchIDs), 1);

            for i = 1:numel(batchIDs)
                directoryName = ...
                    openmebius.application.result.ResultExportPlan ...
                    .directoryName( ...
                    batchNames(i), ...
                    batchIDs(i), ...
                    options.AddDatetime, ...
                    options.Timestamp);
                exportDirectories(i) = ...
                    outputLocation.childLocation(directoryName).Directory;
            end

            obj = openmebius.application.result.ResultExportPlan( ...
                OutputLocation = outputLocation, ...
                BatchIDs = batchIDs, ...
                BatchNames = batchNames, ...
                ExportDirectories = exportDirectories);

        end

    end

    methods (Static, Access = private)

        function name = directoryName( ...
                batchName, ...
                batchID, ...
                addDatetime, ...
                timestamp)

            name = string(batchName) + "_" + string(batchID);

            if addDatetime
                name = name + "_" + string(timestamp);
            end

        end

    end

end
