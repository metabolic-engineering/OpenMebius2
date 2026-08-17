classdef ViewComparisonPresenter < handle
    % VIEWCOMPARISONPRESENTER Prepares catalog and plot UI data.

    properties (Access = private)
        Batch
        Result
        CatalogService
        RangePlotService
        Catalog openmebius.application.result.ResultComparisonCatalog
    end

    methods

        function obj = ViewComparisonPresenter(batch, result, options)

            arguments
                batch
                result
                options.CatalogService = openmebius.application.result ...
                    .ResultComparisonCatalogService()
                options.RangePlotService = openmebius.application.result ...
                    .ResultRangePlotService()
            end

            obj.Batch = batch;
            obj.Result = result;
            obj.CatalogService = options.CatalogService;
            obj.RangePlotService = options.RangePlotService;
            obj.Catalog = openmebius.application.result ...
                .ResultComparisonCatalog();

        end % constructor

        function viewModel = presentCatalog(obj)

            try
                obj.Catalog = obj.CatalogService.load( ...
                    obj.Batch, obj.Result);

                if obj.Catalog.count() == 0
                    notification = openmebius.presentation.notification ...
                        .Notification.warning( ...
                        "No analyzed batch with CI or FVA data is available.", ...
                        Title = "Comparison data unavailable");
                    viewModel = openmebius.presentation.result ...
                        .ViewComparisonCatalogViewModel( ...
                        Notifications = {notification});
                    return
                end

                viewModel = openmebius.presentation.result ...
                    .ViewComparisonCatalogViewModel( ...
                    IsAvailable = true, ...
                    BatchIDs = obj.Catalog.BatchIDs, ...
                    BatchNames = obj.Catalog.BatchNames, ...
                    ExperimentNames = obj.Catalog.ExperimentNames, ...
                    Contents = obj.Catalog.Contents);
            catch exception
                viewModel = openmebius.presentation.result ...
                    .ViewComparisonCatalogViewModel( ...
                    Notifications = { ...
                    obj.notificationFromException(exception)});
            end

        end % presentCatalog

        function viewModel = presentSelection(obj, batchIDs)

            arguments
                obj
                batchIDs (:, 1) string
            end

            try

                if isempty(batchIDs)
                    error( ...
                        "OpenMebius2:ResultRangePlot:SelectionRequired", ...
                        "Please select at least one batch to compare.");
                end

                batchNames = obj.Catalog.namesFor(batchIDs);
                result = obj.RangePlotService.prepare( ...
                    obj.Result, batchIDs, batchNames);
                reactionIDs = string(result.LowerBounds.Properties.RowNames);
                reactionLabels = result.ReactionNames;
                reactionNames = obj.reactionNames( ...
                    reactionIDs, reactionLabels);
                notifications = obj.informationNotifications( ...
                    result.Messages);

                viewModel = openmebius.presentation.result ...
                    .ViewComparisonPlotViewModel( ...
                    IsAvailable = true, ...
                    BatchIDs = batchIDs, ...
                    UpperBounds = result.UpperBounds, ...
                    LowerBounds = result.LowerBounds, ...
                    BestFits = result.BestFits, ...
                    ReactionIDs = reactionIDs, ...
                    ReactionNames = reactionNames, ...
                    ReactionLabels = reactionLabels, ...
                    Notifications = notifications);
            catch exception
                viewModel = openmebius.presentation.result ...
                    .ViewComparisonPlotViewModel( ...
                    Notifications = { ...
                    obj.notificationFromException(exception)});
            end

        end % presentSelection

    end % methods

    methods (Access = private)

        function notifications = informationNotifications(~, messages)

            messages = string(messages(:));
            notifications = cell(numel(messages), 1);

            for messageIndex = 1:numel(messages)
                notifications{messageIndex} = ...
                    openmebius.presentation.notification ...
                    .Notification.info(messages(messageIndex));
            end

        end % informationNotifications

        function names = reactionNames(~, ids, labels)

            ids = string(ids(:));
            labels = string(labels(:));
            names = labels;

            for reactionIndex = 1:numel(ids)
                prefix = ids(reactionIndex) + " : ";

                if startsWith(labels(reactionIndex), prefix)
                    names(reactionIndex) = extractAfter( ...
                        labels(reactionIndex), strlength(prefix));
                elseif labels(reactionIndex) == ids(reactionIndex)
                    names(reactionIndex) = "";
                end

            end

        end % reactionNames

        function notification = notificationFromException(~, exception)

            identifier = string(exception.identifier);
            message = string(exception.message);

            if startsWith(identifier, ...
                    "OpenMebius2:ResultComparison:") || ...
                    startsWith(identifier, ...
                    "OpenMebius2:ResultRangePlot:")
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                    message, Title = "Comparison data unavailable");
                return
            end

            notification = openmebius.presentation.notification ...
                .Notification.error( ...
                message, ...
                Title = "Comparison view failed", ...
                ShowAlert = true);

        end % notificationFromException

    end % methods (Access = private)

end % classdef
