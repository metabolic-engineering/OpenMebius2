classdef ResultExportResult

    properties (SetAccess = private)
        OutputLocation openmebius.domain.result.ResultLocation
        BatchIDs (:, 1) string
        BatchNames (:, 1) string
        Messages (:, 1) string
    end

    methods

        function obj = ResultExportResult(options)

            arguments
                options.OutputLocation openmebius.domain.result.ResultLocation
                options.BatchIDs (:, 1) string
                options.BatchNames (:, 1) string
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.OutputLocation = options.OutputLocation;
            obj.BatchIDs = options.BatchIDs;
            obj.BatchNames = options.BatchNames;
            obj.Messages = options.Messages;

        end

    end

end
