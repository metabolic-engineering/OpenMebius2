classdef MassSpectrometryTemplateRepository < handle
    % MASSSPECTROMETRYTEMPLATEREPOSITORY Writes MS template workbooks.

    methods

        function write(~, outputPath, templateData, options)

            arguments
                ~
                outputPath (1, 1) string
                templateData
                options.SheetName (1, 1) string = "MS"
            end

            outputDirectory = string(fileparts(outputPath));

            if outputDirectory == ""
                outputDirectory = string(pwd);
            end

            temporaryPath = string(tempname(char(outputDirectory))) + ...
                ".xlsx";
            cleanup = onCleanup( ...
                @() openmebius.infrastructure.model ...
                .MassSpectrometryTemplateRepository ...
                .deleteIfExists(temporaryPath));

            try
                writematrix( ...
                    templateData, ...
                    temporaryPath, ...
                    Sheet = options.SheetName);
                [isMoved, message] = movefile( ...
                    temporaryPath, outputPath, "f");

                if ~isMoved
                    error( ...
                        "OpenMebius2:MSTemplate:ReplaceFailed", ...
                        "Failed to replace the template workbook: %s", ...
                        string(message));
                end

                clear cleanup
            catch cause
                exception = MException( ...
                    "OpenMebius2:MSTemplate:WriteFailed", ...
                    "Failed to export the MS template workbook: %s", ...
                    string(cause.message));
                exception = addCause(exception, cause);
                throw(exception);
            end

        end % write

    end % methods

    methods (Static, Access = private)

        function deleteIfExists(pathFile)

            if isfile(pathFile)
                delete(pathFile);
            end

        end % deleteIfExists

    end % methods (Static, Access = private)

end % classdef
