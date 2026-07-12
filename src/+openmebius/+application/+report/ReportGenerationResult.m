classdef ReportGenerationResult

    properties (SetAccess = private)
        Report
        ResultLocation openmebius.domain.result.ResultLocation
        OutputPath (1, 1) string
        Messages (:, 1) string
    end

    methods

        function obj = ReportGenerationResult(options)

            arguments
                options.Report
                options.ResultLocation openmebius.domain.result.ResultLocation
                options.OutputPath (1, 1) string = ""
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Report = options.Report;
            obj.ResultLocation = options.ResultLocation;
            obj.OutputPath = options.OutputPath;
            obj.Messages = options.Messages;

        end

    end

end
