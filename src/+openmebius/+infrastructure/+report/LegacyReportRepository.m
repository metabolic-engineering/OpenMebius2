classdef LegacyReportRepository < handle
    % LEGACYREPORTREPOSITORY
    % Creates and opens reports using the existing ReportResult class.

    methods

        function report = create(~, resultLocation, model, experiments, result)

            arguments
                ~
                resultLocation openmebius.domain.result.ResultLocation
                model
                experiments
                result
            end

            report = ReportResult( ...
                resultLocation, ...
                model, ...
                experiments, ...
                result, ...
                OpenAfterBuild = false);

        end % create

        function view(~, report)

            view(report);

        end % view

        function outputPath = outputPath(~, report, resultLocation)

            arguments
                ~
                report
                resultLocation openmebius.domain.result.ResultLocation
            end

            outputPath = resultLocation.summaryReportFile();

            if isobject(report) && ismethod(report, "getOutputPath")
                outputPath = string(report.getOutputPath());
                return
            end

            if isobject(report) && isprop(report, "OutputPath")
                outputPath = string(report.OutputPath);
            end

        end % outputPath

    end % methods

end % classdef
