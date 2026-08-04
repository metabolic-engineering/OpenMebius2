classdef MSViewAction
    % MSVIEWACTION Performs child-view export operations.

    methods

        function notification = exportTable( ...
                ~, data, columnNames, rowNames, filePath)

            arguments
                ~
                data table
                columnNames
                rowNames
                filePath (1, 1) string
            end

            try
                data.Properties.VariableNames = columnNames;
                data.Properties.RowNames = rowNames;
                writetable(data, filePath, WriteRowNames = true);
                notification = openmebius.presentation.notification ...
                    .Notification.success( ...
                    "MS data saved to " + filePath + ".");
            catch exception
                notification = openmebius.presentation.notification ...
                    .Notification.fromException( ...
                    exception, ...
                    Title = "File Save Error", ...
                    ShowAlert = true);
            end

        end % exportTable

    end % methods

end % classdef
