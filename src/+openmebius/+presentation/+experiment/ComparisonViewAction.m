classdef ComparisonViewAction
    % COMPARISONVIEWACTION Performs comparison-view export operations.

    methods

        function notification = exportFigure(~, graphicsTarget, filePath)

            arguments
                ~
                graphicsTarget
                filePath (1, 1) string
            end

            try
                exportgraphics(graphicsTarget, filePath, Resolution = 300);
                notification = openmebius.presentation.notification ...
                    .Notification.success( ...
                    "Comparison image saved to " + filePath + ".");
            catch exception
                notification = openmebius.presentation.notification ...
                    .Notification.fromException( ...
                    exception, ...
                    Title = "Image Save Error", ...
                    ShowAlert = true);
            end

        end % exportFigure

    end % methods

end % classdef
