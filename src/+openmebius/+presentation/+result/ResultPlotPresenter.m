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

            if isempty(context.SelectedMainRows) || ...
                    isempty(context.SelectedSubRows)
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

            if ~any(context.MainTableData.Properties.VariableNames == "Flux")
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            selectedFluxRow = context.SelectedMainRows(1);
            selectedResultRow = context.SelectedSubRows(1);

            rxnIDs = string(context.MainTableRowNames);
            batchIDs = string(context.SubTableData.ID);

            if selectedFluxRow > numel(rxnIDs) || ...
                    selectedResultRow > numel(batchIDs)
                viewModel = ...
                    openmebius.presentation.result.ResultPlotViewModel.none();
                return
            end

            rxnID = rxnIDs(selectedFluxRow);
            batchID = batchIDs(selectedResultRow);

            fluxColumn = context.MainTableData.Flux;

            if numel(fluxColumn) > 1
                fluxColumn = fluxColumn(1:end - 1);
            end

            fluxLabels = obj.toFluxLabelCell(fluxColumn);

            modelTable = getModelTable(model);
            highlightMask = strcmp(modelTable.Properties.RowNames, rxnID);

            ciData = getCIReaction(result, batchID, rxnID);

            mainPlot = struct();
            mainPlot.Kind = "legacy-flux-pathway";
            mainPlot.Model = model;
            mainPlot.FluxLabels = fluxLabels;
            mainPlot.HighlightMask = highlightMask;
            mainPlot.IsDarkTheme = options.IsDarkTheme;

            subPlot = struct();
            subPlot.Kind = "legacy-ci-reaction";
            subPlot.Result = result;
            subPlot.Data = ciData;

            viewModel = ...
                openmebius.presentation.result.ResultPlotViewModel( ...
                Kind = openmebius.presentation.result.ResultPlotKind.OverviewFlux, ...
                MainPlot = mainPlot, ...
                SubPlot = subPlot);

        end

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
