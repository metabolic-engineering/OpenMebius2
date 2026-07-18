classdef MassSpectrometryTemplateExportResult
    % MASSSPECTROMETRYTEMPLATEEXPORTRESULT Describes an exported workbook.

    properties (SetAccess = private)
        OutputPath (1, 1) string
        SheetName (1, 1) string
        Messages (:, 1) string
    end

    methods

        function obj = MassSpectrometryTemplateExportResult(options)

            arguments
                options.OutputPath (1, 1) string
                options.SheetName (1, 1) string = "MS"
                options.Messages (:, 1) string = string.empty(0, 1)
            end

            obj.OutputPath = options.OutputPath;
            obj.SheetName = options.SheetName;
            obj.Messages = options.Messages;

        end % constructor

    end % methods

end % classdef
