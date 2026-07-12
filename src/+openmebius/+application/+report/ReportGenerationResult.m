classdef ReportGenerationResult

    properties (SetAccess = private)
        Report
        ResultLocation openmebius.domain.result.ResultLocation
        Messages (:, 1) string
    end

    methods

        function obj = ReportGenerationResult(options)

            arguments
                options.Report
                options.ResultLocation openmebius.domain.result.ResultLocation
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Report = options.Report;
            obj.ResultLocation = options.ResultLocation;
            obj.Messages = options.Messages;

        end

    end

end
