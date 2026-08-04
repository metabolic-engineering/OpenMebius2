classdef RawMSWorkbookExporter
    % RAWMSWORKBOOKEXPORTER Persists a mapped raw MS table.

    methods

        function export(~, msTable, filename)

            arguments
                ~
                msTable table
                filename (1, 1) string
            end

            try
                writetable( ...
                    msTable, ...
                    filename, ...
                    WriteRowNames = true, ...
                    Sheet = "MS");
            catch exception
                wrapped = MException( ...
                    "OpenMebius2:RawMSWorkbookExporter:WriteFailed", ...
                    "Error writing raw MS workbook: %s.", filename);
                throw(addCause(wrapped, exception));
            end

        end

    end

end
