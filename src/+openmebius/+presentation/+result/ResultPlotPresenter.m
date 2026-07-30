classdef ResultPlotPresenter < handle
    % RESULTPLOTPRESENTER
    % Converts result table selection context into plot ViewModel.
    %
    % This class must not access UIAxes or UITable.

    properties (Access = private)
        PathwayPresenter
    end

    methods

        function obj = ResultPlotPresenter(options)

            arguments
                options.PathwayPresenter = ...
                    openmebius.presentation.model.ModelPresenter()
            end

            obj.PathwayPresenter = options.PathwayPresenter;

        end % constructor

        function viewModel = present(obj, model, result, context, options)

            arguments
                obj
                model
                result
                context struct
                options.IsDarkTheme (1, 1) logical = false
            end

            mode = ...
                openmebius.presentation.result.ResultViewMode.normalize( ...
                context.Mode);

            switch mode

                case "Overview"
                    viewModel = obj.presentOverview( ...
                        model, ...
                        result, ...
                        context, ...
                        IsDarkTheme = options.IsDarkTheme);

                case {"Details", "Comparison"}
                    viewModel = ...
                        openmebius.presentation.result.ResultPlotViewModel.none();

                otherwise
                    viewModel = ...
                        openmebius.presentation.result.ResultPlotViewModel.none();
            end

        end

    end

    methods (Access = private)

        function viewModel = presentOverview(obj, model, result, context, options)

            arguments
                obj
                model
                result
                context struct
                options.IsDarkTheme (1, 1) logical = false
            end

            if obj.isInvalidHandle(result)
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            if isempty(context.SelectedSubRows)
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            if isempty(context.MainTableData) || ...
                    ~istable(context.MainTableData)
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            if isempty(context.SubTableData) || ...
                    ~istable(context.SubTableData)
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            if ~any(string( ...
                    context.MainTableData.Properties.VariableNames) == "Flux")
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            selectedResultRow = context.SelectedSubRows(1);

            if ~any(string( ...
                    context.SubTableData.Properties.VariableNames) == "ID")
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            batchIDs = string(context.SubTableData.ID);

            if ~obj.isValidRow(selectedResultRow, numel(batchIDs))
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            fluxColumn = context.MainTableData.Flux;
            highlightReactionIDs = strings(0, 1);
            subPlot = struct();
            notification = [];
            rxnIDs = string(context.MainTableRowNames);
            rxnIDs = rxnIDs(:);

            if ~isempty(context.SelectedMainRows)
                selectedFluxRow = context.SelectedMainRows(1);

                if obj.isValidRow(selectedFluxRow, numel(rxnIDs))
                    rxnID = rxnIDs(selectedFluxRow);
                    highlightReactionIDs = rxnID;
                    ciData = getCIReaction( ...
                        result, batchIDs(selectedResultRow), rxnID);
                    [subPlot, notification] = ...
                        obj.presentConfidenceInterval(ciData, rxnID);
                end

            end

            pathwayViewModel = obj.PathwayPresenter.presentPathway( ...
                model, ...
                Labels = fluxColumn, ...
                HighlightReactionIDs = highlightReactionIDs, ...
                IsDarkTheme = options.IsDarkTheme);

            if isempty(notification) && ...
                    ~isempty(pathwayViewModel.Notification)
                notification = pathwayViewModel.Notification;
            end

            mainPlot = struct();
            mainPlot.Kind = "pathway";
            mainPlot.Pathway = pathwayViewModel;

            viewModel = ...
                openmebius.presentation.result.ResultPlotViewModel( ...
                Kind = openmebius.presentation.result.ResultPlotKind.OverviewFlux, ...
                MainPlot = mainPlot, ...
                SubPlot = subPlot, ...
                Notification = notification);

        end

        function [plotData, notification] = ...
                presentConfidenceInterval(obj, data, reactionID)

            plotData = struct();
            notification = [];

            if isempty(data)
                return
            end

            if ~isstruct(data) || ~isscalar(data) || ...
                    ~isfield(data, "CI") || ...
                    ~isstruct(data.CI) || ...
                    ~isfield(data.CI, "algorithm")
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                "Confidence interval data is invalid.");
                return
            end

            algorithm = string(data.CI.algorithm);

            if ~isscalar(algorithm)
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                    "Unsupported confidence interval algorithm: " + ...
                    join(algorithm, ", "));
                return
            end

            switch lower(algorithm)

                case "monte carlo"
                    [plotData, notification] = ...
                        obj.presentMonteCarloConfidenceInterval( ...
                        data, reactionID);

                case "grid search"
                    [plotData, notification] = ...
                        obj.presentGridSearchConfidenceInterval( ...
                        data, reactionID);

                otherwise
                    notification = openmebius.presentation.notification ...
                        .Notification.warning( ...
                        "Unsupported confidence interval algorithm: " + ...
                        algorithm);
            end

        end % presentConfidenceInterval

        function [plotData, notification] = ...
                presentMonteCarloConfidenceInterval( ...
                obj, data, reactionID)

            plotData = struct();
            notification = [];

            try
                [modelIDs, reactionNames] = ...
                    obj.resultReactionMetadata(data);
                reactionIndex = find(modelIDs == reactionID, 1);

                if isempty(reactionIndex)
                    notification = openmebius.presentation.notification ...
                        .Notification.warning( ...
                        "Reaction ID is not available in confidence " + ...
                        "interval data: " + reactionID);
                    return
                end

                lowerBounds = double(data.CI.fluxLB(reactionIndex, :));
                upperBounds = double(data.CI.fluxUB(reactionIndex, :));
                bestFit = double(data.fluxFwd(reactionIndex));
                plotTitle = reactionID;

                if reactionIndex <= numel(reactionNames) && ...
                        strlength(reactionNames(reactionIndex)) > 0
                    plotTitle = reactionNames(reactionIndex);
                end

            catch
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                "Confidence interval data is incomplete.");
                return
            end

            if isempty(lowerBounds) || ...
                    numel(lowerBounds) ~= numel(upperBounds) || ...
                    ~any(isfinite(lowerBounds)) || ...
                    ~any(isfinite(upperBounds)) || ...
                    ~isscalar(bestFit) || ~isfinite(bestFit)
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                "Confidence interval values are unavailable.");
                return
            end

            plotData.Kind = "monte-carlo-ci";
            plotData.LowerBounds = lowerBounds(:)';
            plotData.UpperBounds = upperBounds(:)';
            plotData.BestFit = bestFit;
            plotData.Title = plotTitle;

        end % presentMonteCarloConfidenceInterval

        function [plotData, notification] = ...
                presentGridSearchConfidenceInterval( ...
                obj, data, reactionID)

            plotData = struct();
            notification = [];

            try
                [modelIDs, reactionNames] = ...
                    obj.resultReactionMetadata(data);
                reactionIndex = find(modelIDs == reactionID, 1);

                if isempty(reactionIndex)
                    notification = openmebius.presentation.notification ...
                        .Notification.warning( ...
                        "Reaction ID is not available in confidence " + ...
                        "interval data: " + reactionID);
                    return
                end

                gridSearch = data.CI.gridSearch;
                fluxIndices = double(gridSearch.fluxIndices(:));
                profileIndex = find( ...
                    fluxIndices == reactionIndex, 1);

                if isempty(profileIndex) && ...
                        isfield(gridSearch, "reactionIDs")
                    profileIDs = string(gridSearch.reactionIDs(:));
                    profileIndex = find( ...
                        profileIDs == reactionID, 1);
                end

                if isempty(profileIndex)
                    notification = openmebius.presentation.notification ...
                        .Notification.warning( ...
                        "A grid-search profile is not available for " + ...
                        "reaction: " + reactionID);
                    return
                end

                rawX = double( ...
                    gridSearch.fixedFlux(profileIndex, :));
                rawY = double( ...
                    gridSearch.minimumRSS(profileIndex, :));
                trialRSS = reshape( ...
                    double(gridSearch.RSS(profileIndex, :, :)), ...
                    numel(rawX), []);
                objectiveThreshold = double( ...
                    gridSearch.objectiveThreshold);
                bestFit = double(data.fluxFwd(reactionIndex));
                lowerBound = NaN;
                upperBound = NaN;

                if numel(data.fluxLB) >= reactionIndex
                    lowerBound = double(data.fluxLB(reactionIndex));
                end

                if numel(data.fluxUB) >= reactionIndex
                    upperBound = double(data.fluxUB(reactionIndex));
                end

                plotTitle = reactionID;

                if reactionIndex <= numel(reactionNames) && ...
                        strlength(reactionNames(reactionIndex)) > 0
                    plotTitle = reactionNames(reactionIndex);
                end

            catch
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                "Grid-search confidence interval data is incomplete.");
                return
            end

            valid = isfinite(rawX) & isfinite(rawY);

            if ~any(valid) || ~isscalar(objectiveThreshold) || ...
                    ~isfinite(objectiveThreshold)
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                "Grid-search profile values are unavailable.");
                return
            end

            validX = rawX(valid);
            validY = rawY(valid);
            [profileX, ~, groups] = unique( ...
                validX(:), "sorted");
            profileRSS = accumarray( ...
                groups, validY(:), [], @min);
            plotData.Kind = "grid-search-profile";
            plotData.X = profileX;
            plotData.Y = profileRSS;
            plotData.TrialX = repmat(rawX(:), 1, size(trialRSS, 2));
            plotData.TrialRSS = trialRSS;
            plotData.ObjectiveThreshold = objectiveThreshold;
            plotData.LowerBound = lowerBound;
            plotData.UpperBound = upperBound;
            plotData.BestFit = bestFit;
            plotData.Title = plotTitle;

        end % presentGridSearchConfidenceInterval

        function [reactionIDs, reactionNames] = ...
                resultReactionMetadata(~, data)

            reactionIDs = string(data.model.modelID(:));
            reactionNames = string(data.model.modelReaction(:));
            reactionIDs(end + 1, 1) = "biomass";
            reactionNames(end + 1, 1) = "biomass";

        end % resultReactionMetadata

        function tf = isValidRow(~, row, rowCount)

            tf = isscalar(row) && isfinite(row) && ...
                row == fix(row) && row >= 1 && row <= rowCount;

        end % isValidRow

        function tf = isInvalidHandle(~, value)

            tf = isempty(value);

            if tf
                return
            end

            try
                tf = ~isvalid(value);
            catch
                tf = false;
            end

        end

    end

end
