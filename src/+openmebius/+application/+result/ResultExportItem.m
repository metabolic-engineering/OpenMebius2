classdef ResultExportItem

    properties (SetAccess = private)
        BatchID (1, 1) string
        BatchName (1, 1) string
        ExportLocation openmebius.domain.result.ResultLocation
        ExportDirectory (1, 1) string
    end

    methods

        function obj = ResultExportItem(options)

            arguments
                options.BatchID (1, 1) string
                options.BatchName (1, 1) string
                options.ExportLocation openmebius.domain.result.ResultLocation
            end

            obj.BatchID = options.BatchID;
            obj.BatchName = options.BatchName;
            obj.ExportLocation = options.ExportLocation;
            obj.ExportDirectory = options.ExportLocation.Directory;

        end

    end

end
