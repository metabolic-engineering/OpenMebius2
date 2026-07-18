classdef ResultPlotPresenter < handle
    % RESULTPLOTPRESENTER
    % Converts result table selection context into plot ViewModel.
    %
    % This class must not access UIAxes or UITable.

    methods

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

            if obj.isInvalidHandle(model) || obj.isInvalidHandle(result)
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
            modelTable = getModelTable(model);

            if ~istable(modelTable)
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            if numel(fluxColumn) > height(modelTable)
                fluxColumn = fluxColumn(1:height(modelTable));
            end

            fluxLabels = obj.toFluxLabelCell(fluxColumn);
            highlightMask = false(height(modelTable), 1);
            subPlot = struct();
            notification = [];
            rxnIDs = string(context.MainTableRowNames);
            rxnIDs = rxnIDs(:);

            if ~isempty(context.SelectedMainRows)
                selectedFluxRow = context.SelectedMainRows(1);

                if obj.isValidRow(selectedFluxRow, numel(rxnIDs))
                    rxnID = rxnIDs(selectedFluxRow);
                    highlightMask = strcmp( ...
                        string(modelTable.Properties.RowNames), rxnID);
                    ciData = getCIReaction( ...
                        result, batchIDs(selectedResultRow), rxnID);
                    [subPlot, notification] = ...
                        obj.presentConfidenceInterval(ciData, rxnID);
                end

            end

            mainPlot = struct();
            mainPlot.Kind = "legacy-flux-pathway";
            mainPlot.Model = model;
            mainPlot.FluxLabels = fluxLabels;
            mainPlot.HighlightMask = highlightMask;
            mainPlot.IsDarkTheme = options.IsDarkTheme;

            viewModel = ...
                openmebius.presentation.result.ResultPlotViewModel( ...
                Kind = openmebius.presentation.result.ResultPlotKind.OverviewFlux, ...
                MainPlot = mainPlot, ...
                SubPlot = subPlot, ...
                Notification = notification);

        end

        function [plotData, notification] = ...
                presentConfidenceInterval(~, data, reactionID)

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

            if ~isscalar(algorithm) || algorithm ~= "Monte Carlo"
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                        "Unsupported confidence interval algorithm: " + ...
                        join(algorithm, ", "));
                return
            end

            try
                modelIDs = string(data.model.modelID);
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
                reactionNames = string(data.model.modelReaction);
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

        end % presentConfidenceInterval

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

        function fluxCells = toFluxLabelCell(~, values)

            if isempty(values)
                fluxCells = {};
                return
            end

            if iscell(values)
                fluxCells = values(:);
                return
            end

            if isnumeric(values)
                fluxCells = arrayfun( ...
                    @(x) sprintf('%.2f', x), ...
                    values(:), ...
                    'UniformOutput', false);
                return
            end

            if isstring(values)
                fluxCells = cellstr(values(:));
                return
            end

            if ischar(values)
                fluxCells = cellstr(string(values));
                return
            end

            try
                fluxCells = cellstr(string(values(:)));
            catch
                fluxCells = {};
            end

        end

    end

end
