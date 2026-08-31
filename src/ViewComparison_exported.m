classdef ViewComparison_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        GridLayout3             matlab.ui.container.GridLayout
        GridLayout5             matlab.ui.container.GridLayout
        GridLayout10            matlab.ui.container.GridLayout
        BestfitSizeEditField    matlab.ui.control.NumericEditField
        BestfitSizeEditFieldLabel  matlab.ui.control.Label
        GridLayout9             matlab.ui.container.GridLayout
        BestfitColorEditField   matlab.ui.control.EditField
        BestfitColorEditFieldLabel  matlab.ui.control.Label
        GridLayout8             matlab.ui.container.GridLayout
        BestfitStyleDropDown    matlab.ui.control.DropDown
        BestfitStyleDropDownLabel  matlab.ui.control.Label
        GridLayout7             matlab.ui.container.GridLayout
        FontsizeEditField       matlab.ui.control.NumericEditField
        FontsizeEditFieldLabel  matlab.ui.control.Label
        GridLayout6             matlab.ui.container.GridLayout
        UIfontDropDown          matlab.ui.control.DropDown
        UIfontDropDownLabel     matlab.ui.control.Label
        GridLayout4             matlab.ui.container.GridLayout
        ColorUITable            matlab.ui.control.Table
        FluxUITable             matlab.ui.control.Table
        BatchUITable            matlab.ui.control.Table
        UIAxes                  matlab.ui.control.UIAxes
        GridLayout2             matlab.ui.container.GridLayout
        SaveplotButton          matlab.ui.control.Button
        CloseButton             matlab.ui.control.Button
    end

    properties (Access = private)
        Presenter openmebius.presentation.result.ViewComparisonPresenter
        Action openmebius.presentation.result.ViewComparisonAction
        PlotViewModel
        StyleTable table = table()
        CatalogBatchIDs (:, 1) string = strings(0, 1)
        InitialBatchIDs (:, 1) string = strings(0, 1)
        IsInitializing (1, 1) logical = false
    end

    events
        Closed
        NotificationRequested
    end

    methods (Access = private)

        function configureComponents(app)

            pathToMLAPP = fileparts(mfilename('fullpath'));
            app.UIFigure.Name = 'Flux Range Comparison';
            app.UIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.UIFigure.CloseRequestFcn = @(~, event) app.closeRequested(event);
            app.BatchUITable.SelectionType = 'row';
            app.FluxUITable.SelectionType = 'row';
            app.BatchUITable.SelectionChangedFcn = ...
                @(~, event) app.batchSelectionChanged(event);
            app.FluxUITable.SelectionChangedFcn = ...
                @(~, event) app.fluxSelectionChanged(event);
            app.ColorUITable.CellEditCallback = ...
                @(~, event) app.colorTableEdited(event);
            app.SaveplotButton.ButtonPushedFcn = ...
                @(~, event) app.savePlot(event);
            app.CloseButton.ButtonPushedFcn = ...
                @(~, event) app.closeRequested(event);
            app.configureDisplayOptionControls();

            app.BatchUITable.ColumnName = {'ID', 'Exp name', 'Contents'};
            app.BatchUITable.ColumnEditable = [false false false];
            app.BatchUITable.ColumnWidth = {'1x', '1x', 'fit'};
            app.BatchUITable.RowName = {};
            app.FluxUITable.ColumnName = {'ID', 'Reaction name'};
            app.FluxUITable.ColumnEditable = [false false];
            app.FluxUITable.ColumnWidth = {'fit', '1x'};
            app.FluxUITable.RowName = {};
            app.ColorUITable.ColumnName = ...
                {'Batch ID', 'Name', 'Hex', 'Pattern'};
            app.ColorUITable.ColumnEditable = [false true true true];
            app.ColorUITable.ColumnWidth = {'1x', '1x', 'fit', 'fit'};
            app.ColorUITable.RowName = {};
            app.ColorUITable.Tooltip = [ ...
                'Patterns: solid, outline, diagonal, ' ...
                'reverse-diagonal, crosshatch, dots'];

            cla(app.UIAxes);
            app.UIAxes.Color = 'white';
            app.UIAxes.TickLabelInterpreter = 'none';
            title(app.UIAxes, 'Flux range comparison');
            xlabel(app.UIAxes, 'Flux (mmol gDCW^{-1} h^{-1})');
            ylabel(app.UIAxes, '');
            app.applyUIFont();

        end % configureComponents

        function configureDisplayOptionControls(app)

            fontList = unique(string(listfonts));
            fontList(fontList == "") = [];

            if isempty(fontList)
                fontList = "Arial";
            end

            defaultFont = "Arial";

            if ~any(fontList == defaultFont)
                defaultFont = fontList(1);
            end

            app.UIfontDropDown.Items = cellstr(fontList);
            app.UIfontDropDown.Value = char(defaultFont);
            app.UIfontDropDown.ValueChangedFcn = ...
                @(~, event) app.displayOptionsChanged(event);
            app.FontsizeEditField.ValueChangedFcn = ...
                @(~, event) app.displayOptionsChanged(event);
            app.BestfitStyleDropDown.ValueChangedFcn = ...
                @(~, event) app.displayOptionsChanged(event);
            app.BestfitColorEditField.ValueChangedFcn = ...
                @(~, event) app.bestfitColorChanged(event);
            app.BestfitSizeEditField.ValueChangedFcn = ...
                @(~, event) app.displayOptionsChanged(event);

        end % configureDisplayOptionControls

        function applyCatalog(app, viewModel)

            app.requestNotifications(viewModel.Notifications);
            app.CatalogBatchIDs = viewModel.BatchIDs;
            displayBatchIDs = openmebius.presentation ...
                .IdentifierFormatter.short(viewModel.BatchIDs);
            batchData = table( ...
                displayBatchIDs, ...
                viewModel.ExperimentNames, ...
                viewModel.Contents, ...
                'VariableNames', {'ID', 'Experiment', 'Contents'});
            app.BatchUITable.Data = batchData;

            if ~viewModel.IsAvailable || isempty(batchData)
                app.clearComparison();
                return
            end

            colorObject = Color();
            count = height(batchData);
            colors = strings(count, 1);

            for batchIndex = 1:count
                colors(batchIndex) = getPresetColor( ...
                    colorObject, batchIndex, "tab10");
            end

            app.StyleTable = table( ...
                viewModel.BatchIDs, ...
                viewModel.BatchNames, ...
                colors, ...
                repmat("solid", count, 1), ...
                'VariableNames', {'BatchID', 'Name', 'Hex', 'Pattern'});
            [isSelected, selection] = ismember( ...
                app.InitialBatchIDs, app.CatalogBatchIDs);
            selection = unique(selection(isSelected), "stable");

            app.IsInitializing = true;
            app.BatchUITable.Selection = selection(:)';
            app.IsInitializing = false;
            app.updateSelectedBatches();

        end % applyCatalog

        function updateSelectedBatches(app)

            if app.IsInitializing
                return
            end

            selectedRows = app.selectedRows(app.BatchUITable);

            if isempty(selectedRows) || isempty(app.CatalogBatchIDs)
                app.ColorUITable.Data = table();
                app.ColorUITable.UserData = strings(0, 1);
                app.clearPlotData();
                return
            end

            batchIDs = app.CatalogBatchIDs(selectedRows);
            app.updateColorTable(batchIDs);
            viewModel = app.Presenter.presentSelection(batchIDs);
            app.requestNotifications(viewModel.Notifications);

            if ~viewModel.IsAvailable
                app.clearPlotData();
                return
            end

            app.applyPlotViewModel(viewModel);

        end % updateSelectedBatches

        function updateColorTable(app, batchIDs)

            if isempty(app.StyleTable) || ...
                    ~ismember("BatchID", ...
                    string(app.StyleTable.Properties.VariableNames))
                app.ColorUITable.Data = table();
                return
            end

            [isPresent, indices] = ismember(batchIDs, app.StyleTable.BatchID);

            if ~all(isPresent)
                app.ColorUITable.Data = table();
                app.ColorUITable.UserData = strings(0, 1);
                return
            end

            displayBatchIDs = openmebius.presentation ...
                .IdentifierFormatter.short(batchIDs);
            app.ColorUITable.Data = table( ...
                displayBatchIDs, ...
                app.StyleTable.Name(indices), ...
                app.StyleTable.Hex(indices), ...
                app.StyleTable.Pattern(indices), ...
                'VariableNames', {'BatchID', 'Name', 'Hex', 'Pattern'});
            app.ColorUITable.UserData = batchIDs;

        end % updateColorTable

        function applyPlotViewModel(app, viewModel)

            previouslySelected = strings(0, 1);

            if istable(app.FluxUITable.Data) && ...
                    ~isempty(app.FluxUITable.Data)
                previousRows = app.selectedRows(app.FluxUITable);

                if ~isempty(previousRows)
                    previouslySelected = string( ...
                        app.FluxUITable.Data.ID(previousRows));
                end

            end

            app.PlotViewModel = viewModel;
            app.IsInitializing = true;
            fluxData = table( ...
                viewModel.ReactionIDs, ...
                viewModel.ReactionNames, ...
                'VariableNames', {'ID', 'Reaction'});
            app.FluxUITable.Data = fluxData;
            [isSelected, selection] = ismember( ...
                previouslySelected, viewModel.ReactionIDs);
            selection = selection(isSelected);

            if isempty(selection)
                selection = 1:height(fluxData);
            end

            app.FluxUITable.Selection = selection(:)';
            app.IsInitializing = false;
            app.redrawPlot();

        end % applyPlotViewModel

        function redrawPlot(app)

            if isempty(app.PlotViewModel) || ...
                    ~app.PlotViewModel.IsAvailable
                return
            end

            reactionRows = app.selectedRows(app.FluxUITable);

            if isempty(reactionRows)
                cla(app.UIAxes);
                title(app.UIAxes, 'Select one or more fluxes');
                ylabel(app.UIAxes, '');
                return
            end

            batchIDs = app.PlotViewModel.BatchIDs;
            [stylesFound, styleRows] = ismember( ...
                batchIDs, app.StyleTable.BatchID);

            if ~all(stylesFound)
                return
            end

            styles = app.StyleTable(styleRows, :);
            lowerBounds = app.PlotViewModel.LowerBounds(reactionRows, :);
            upperBounds = app.PlotViewModel.UpperBounds(reactionRows, :);
            bestFits = app.PlotViewModel.BestFits;
            bestfitStyle = string(app.BestfitStyleDropDown.Value);

            if bestfitStyle == "none"
                bestFits = table();
                bestfitStyle = "diamond";
            elseif ~isempty(bestFits)
                bestFits = bestFits(reactionRows, :);
            end

            bestfitColors = styles.Hex;
            requestedBestfitColor = lower(strtrim( ...
                string(app.BestfitColorEditField.Value)));

            if requestedBestfitColor ~= "series"
                bestfitColors = repmat( ...
                    requestedBestfitColor, height(styles), 1);
            end

            reactionNames = app.PlotViewModel.ReactionNames(reactionRows);
            missingNames = strlength(strtrim(reactionNames)) == 0;
            reactionIDs = app.PlotViewModel.ReactionIDs(reactionRows);
            reactionNames(missingNames) = reactionIDs(missingNames);
            fontSize = app.FontsizeEditField.Value;
            markerSize = app.BestfitSizeEditField.Value;

            try
                app.UIAxes.Color = 'white';
                RangePlot( ...
                    app.UIAxes, ...
                    upperBounds, ...
                    lowerBounds, ...
                    Bestfit = bestFits, ...
                    BestfitColors = bestfitColors, ...
                    BestfitDiamondMarkerSize = markerSize, ...
                    BestfitStyle = bestfitStyle, ...
                    BestfitTriangleMarkerSize = markerSize, ...
                    Colors = styles.Hex, ...
                    Patterns = styles.Pattern, ...
                    SeriesNames = styles.Name, ...
                    FontSize = fontSize, ...
                    ReactionNames = reactionNames);
                title(app.UIAxes, 'Flux range comparison');
                ylabel(app.UIAxes, '');
                app.applyUIFont();
            catch exception
                app.requestNotification( ...
                    openmebius.presentation.notification ...
                    .Notification.fromException( ...
                    exception, ...
                    Title = "Comparison plot failed", ...
                    ShowAlert = true));
            end

        end % redrawPlot

        function displayOptionsChanged(app, ~)

            if app.IsInitializing
                return
            end

            app.redrawPlot();
            app.applyUIFont();

        end % displayOptionsChanged

        function bestfitColorChanged(app, event)

            value = lower(strtrim(string( ...
                app.BestfitColorEditField.Value)));
            isValid = value == "series";

            if ~isValid
                colorObject = Color();
                isValid = all(isValidColorHex( ...
                    colorObject, reshape(value, 1, [])));
            end

            if ~isValid
                app.BestfitColorEditField.Value = event.PreviousValue;
                app.requestNotification( ...
                    openmebius.presentation.notification ...
                    .Notification.warning( ...
                    "Use 'series' or a #RRGGBB best-fit color.", ...
                    Title = "Invalid best-fit color"));
                return
            end

            app.BestfitColorEditField.Value = char(value);
            app.displayOptionsChanged(event);

        end % bestfitColorChanged

        function applyUIFont(app)

            if isempty(app.UIfontDropDown) || ...
                    isempty(app.FontsizeEditField)
                return
            end

            fontName = app.UIfontDropDown.Value;
            fontSize = app.FontsizeEditField.Value;
            fontObjects = findall(app.UIFigure, '-property', 'FontName');

            for objectIndex = 1:numel(fontObjects)
                try
                    fontObjects(objectIndex).FontName = fontName;

                    if isprop(fontObjects(objectIndex), 'FontSize')
                        fontObjects(objectIndex).FontSize = fontSize;
                    end

                catch
                    % Some internal UI objects expose read-only font data.
                end

            end

        end % applyUIFont

        function colorTableEdited(app, event)

            if app.IsInitializing || isempty(event.Indices)
                return
            end

            data = app.ColorUITable.Data;
            row = event.Indices(1);
            column = event.Indices(2);
            isValid = true;

            if column == 2
                isValid = strlength(strtrim(string(data.Name(row)))) > 0;
            elseif column == 3
                colorObject = Color();
                isValid = all(isValidColorHex( ...
                    colorObject, reshape(string(data.Hex), 1, [])));
            elseif column == 4
                isValid = app.isValidPattern(string(data.Pattern(row)));
            end

            if ~isValid
                if column == 2
                    data.Name(row) = string(event.PreviousData);
                elseif column == 3
                    data.Hex(row) = string(event.PreviousData);
                elseif column == 4
                    data.Pattern(row) = string(event.PreviousData);
                end

                app.ColorUITable.Data = data;
                app.requestNotification( ...
                    openmebius.presentation.notification ...
                    .Notification.warning( ...
                    "Enter a name, #RRGGBB color, and a " + ...
                    "supported pattern.", ...
                    Title = "Invalid plot style"));
                return
            end

            rawBatchIDs = string(app.ColorUITable.UserData);

            for styleIndex = 1:height(data)
                target = find( ...
                    app.StyleTable.BatchID == rawBatchIDs(styleIndex), 1);

                if ~isempty(target)
                    app.StyleTable.Name(target) = ...
                        string(data.Name(styleIndex));
                    app.StyleTable.Hex(target) = string(data.Hex(styleIndex));
                    app.StyleTable.Pattern(target) = ...
                        string(data.Pattern(styleIndex));
                end

            end

            app.redrawPlot();

        end % colorTableEdited

        function tf = isValidPattern(~, pattern)

            allowed = [ ...
                "solid", "outline", "diagonal", ...
                "reverse-diagonal", "crosshatch", "dots"];
            tf = isscalar(pattern) && ismember(lower(pattern), allowed);

        end % isValidPattern

        function rows = selectedRows(~, tableObject)

            rows = zeros(0, 1);

            try
                selection = tableObject.Selection;

                if isempty(selection)
                    return
                end

                if isprop(tableObject, 'SelectionType') && ...
                        lower(string(tableObject.SelectionType)) == "row"
                    rows = selection(:);
                else
                    rows = selection(:, 1);
                end

                rows = unique(double(rows(:)), "stable");
                rows = rows(isfinite(rows) & rows >= 1);

                if istable(tableObject.Data)
                    rows = rows(rows <= height(tableObject.Data));
                else
                    rows = rows(rows <= size(tableObject.Data, 1));
                end

            catch
                rows = zeros(0, 1);
            end

        end % selectedRows

        function clearComparison(app)

            app.ColorUITable.Data = table();
            app.ColorUITable.UserData = strings(0, 1);
            app.CatalogBatchIDs = strings(0, 1);
            app.StyleTable = table();
            app.clearPlotData();

        end % clearComparison

        function clearPlotData(app)

            app.PlotViewModel = [];
            app.FluxUITable.Data = table();
            cla(app.UIAxes);
            app.UIAxes.Color = 'white';
            title(app.UIAxes, 'Select one or more analyzed batches');
            xlabel(app.UIAxes, 'Flux (mmol gDCW^{-1} h^{-1})');
            ylabel(app.UIAxes, '');
            app.applyUIFont();

        end % clearPlotData

        function batchSelectionChanged(app, ~)

            app.updateSelectedBatches();

        end % batchSelectionChanged

        function fluxSelectionChanged(app, ~)

            if ~app.IsInitializing
                app.redrawPlot();
            end

        end % fluxSelectionChanged

        function savePlot(app, ~)

            if isempty(app.PlotViewModel) || ...
                    ~app.PlotViewModel.IsAvailable || ...
                    isempty(app.selectedRows(app.FluxUITable))
                app.requestNotification( ...
                    openmebius.presentation.notification ...
                    .Notification.warning( ...
                    "Select batch and flux data before saving.", ...
                    Title = "Nothing to save"));
                return
            end

            [confirmed, options] = app.askSaveFigureOptions();

            if ~confirmed
                return
            end

            format = string(options.Format);
            defaultName = "FluxRangeComparison." + format;
            filter = {char("*." + format), ...
                char(upper(format) + " image")};
            [file, path] = uiputfile(filter, 'Save comparison plot', ...
                char(defaultName));

            if isequal(file, 0)
                return
            end

            filePath = string(fullfile(path, file));
            [~, ~, extension] = fileparts(filePath);

            if string(extension) == ""
                filePath = filePath + "." + format;
            end

            notification = app.Action.exportFigure( ...
                app.UIAxes, ...
                filePath, ...
                WidthPx = options.WidthPx, ...
                HeightPx = options.HeightPx, ...
                DPI = options.DPI, ...
                FontSize = options.FontSize, ...
                FontName = string(options.FontName), ...
                Format = format);
            app.requestNotification(notification);

        end % savePlot

        function [confirmed, options] = askSaveFigureOptions(app)

            confirmed = false;
            options = struct( ...
                'WidthPx', 1600, ...
                'HeightPx', 1200, ...
                'DPI', 300, ...
                'FontSize', app.FontsizeEditField.Value, ...
                'FontName', app.UIfontDropDown.Value, ...
                'Format', 'png');
            fontList = unique(string(listfonts));
            fontList(fontList == "") = [];

            if isempty(fontList)
                fontList = "Arial";
            elseif ~any(fontList == string(options.FontName))
                options.FontName = char(fontList(1));
            end

            dialog = uifigure( ...
                'Name', 'Export Options', ...
                'WindowStyle', 'modal', ...
                'Position', app.centeredDialogPosition(390, 330));
            layout = uigridlayout(dialog, [7 2]);
            layout.RowHeight = repmat({'fit'}, 1, 7);
            layout.ColumnWidth = {'1x', '1x'};
            layout.Padding = [14 14 14 14];
            layout.RowSpacing = 8;
            uilabel(layout, 'Text', 'Width (px)');
            widthField = uieditfield(layout, 'numeric', ...
                'Value', options.WidthPx, 'Limits', [1 Inf]);
            uilabel(layout, 'Text', 'Height (px)');
            heightField = uieditfield(layout, 'numeric', ...
                'Value', options.HeightPx, 'Limits', [1 Inf]);
            uilabel(layout, 'Text', 'Resolution (DPI)');
            dpiField = uieditfield(layout, 'numeric', ...
                'Value', options.DPI, 'Limits', [72 2400]);
            uilabel(layout, 'Text', 'Font size');
            fontSizeField = uieditfield(layout, 'numeric', ...
                'Value', options.FontSize, 'Limits', [6 72]);
            uilabel(layout, 'Text', 'Font');
            fontDropDown = uidropdown(layout, ...
                'Items', cellstr(fontList), ...
                'Value', options.FontName);
            uilabel(layout, 'Text', 'Format');
            formatDropDown = uidropdown(layout, ...
                'Items', {'png', 'pdf', 'svg'}, ...
                'Value', options.Format);
            okButton = uibutton(layout, ...
                'Text', 'OK', ...
                'ButtonPushedFcn', @(~, ~) accept());
            okButton.Layout.Row = 7;
            okButton.Layout.Column = 1;
            cancelButton = uibutton(layout, ...
                'Text', 'Cancel', ...
                'ButtonPushedFcn', @(~, ~) cancel());
            cancelButton.Layout.Row = 7;
            cancelButton.Layout.Column = 2;
            dialog.CloseRequestFcn = @(~, ~) cancel();
            uiwait(dialog);

            function accept()
                options.WidthPx = round(widthField.Value);
                options.HeightPx = round(heightField.Value);
                options.DPI = round(dpiField.Value);
                options.FontSize = fontSizeField.Value;
                options.FontName = fontDropDown.Value;
                options.Format = formatDropDown.Value;
                confirmed = true;
                uiresume(dialog);
                delete(dialog);
            end

            function cancel()
                uiresume(dialog);
                delete(dialog);
            end

        end % askSaveFigureOptions

        function position = centeredDialogPosition(app, width, height)

            parentPosition = app.UIFigure.Position;
            left = parentPosition(1) + (parentPosition(3) - width) / 2;
            bottom = parentPosition(2) + (parentPosition(4) - height) / 2;
            position = [left bottom width height];

        end % centeredDialogPosition

        function requestNotifications(app, notifications)

            for notificationIndex = 1:numel(notifications)
                app.requestNotification(notifications{notificationIndex});
            end

        end % requestNotifications

        function requestNotification(app, notification)

            eventData = openmebius.presentation.notification ...
                .NotificationEventData(notification);
            notify(app, "NotificationRequested", eventData);

        end % requestNotification

        function closeRequested(app, ~)

            notify(app, "Closed");
            delete(app);

        end % closeRequested

    end % methods (Access = private)

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, context)

            app.IsInitializing = true;
            app.Presenter = context.Presenter;
            app.Action = context.Action;
            app.InitialBatchIDs = context.InitialBatchIDs;
            app.configureComponents();
            app.IsInitializing = false;
            app.applyCatalog(context.InitialCatalog);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1280 640];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x', 'fit'};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 2;
            app.GridLayout2.Layout.Column = 1;

            % Create CloseButton
            app.CloseButton = uibutton(app.GridLayout2, 'push');
            app.CloseButton.Layout.Row = 1;
            app.CloseButton.Layout.Column = 7;
            app.CloseButton.Text = 'Close';

            % Create SaveplotButton
            app.SaveplotButton = uibutton(app.GridLayout2, 'push');
            app.SaveplotButton.Layout.Row = 1;
            app.SaveplotButton.Layout.Column = 6;
            app.SaveplotButton.Text = 'Save plot';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x', '2x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout3);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 4;

            % Create BatchUITable
            app.BatchUITable = uitable(app.GridLayout3);
            app.BatchUITable.ColumnName = '';
            app.BatchUITable.RowName = {};
            app.BatchUITable.Layout.Row = 1;
            app.BatchUITable.Layout.Column = 1;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout3);
            app.GridLayout4.ColumnWidth = {'1x'};
            app.GridLayout4.Padding = [0 0 0 0];
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 2;

            % Create FluxUITable
            app.FluxUITable = uitable(app.GridLayout4);
            app.FluxUITable.ColumnName = '';
            app.FluxUITable.RowName = {};
            app.FluxUITable.Layout.Row = 1;
            app.FluxUITable.Layout.Column = 1;

            % Create ColorUITable
            app.ColorUITable = uitable(app.GridLayout4);
            app.ColorUITable.ColumnName = '';
            app.ColorUITable.RowName = {};
            app.ColorUITable.Layout.Row = 2;
            app.ColorUITable.Layout.Column = 1;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout3);
            app.GridLayout5.ColumnWidth = {'1x'};
            app.GridLayout5.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};
            app.GridLayout5.Padding = [0 0 0 0];
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 3;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout5);
            app.GridLayout6.ColumnWidth = {'3x', '7x'};
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.Padding = [0 0 0 0];
            app.GridLayout6.Layout.Row = 1;
            app.GridLayout6.Layout.Column = 1;

            % Create UIfontDropDownLabel
            app.UIfontDropDownLabel = uilabel(app.GridLayout6);
            app.UIfontDropDownLabel.Layout.Row = 1;
            app.UIfontDropDownLabel.Layout.Column = 1;
            app.UIfontDropDownLabel.Text = 'UI font';

            % Create UIfontDropDown
            app.UIfontDropDown = uidropdown(app.GridLayout6);
            app.UIfontDropDown.Items = {};
            app.UIfontDropDown.Layout.Row = 1;
            app.UIfontDropDown.Layout.Column = 2;
            app.UIfontDropDown.Value = {};

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout5);
            app.GridLayout7.ColumnWidth = {'3x', '7x'};
            app.GridLayout7.RowHeight = {'1x'};
            app.GridLayout7.Padding = [0 0 0 0];
            app.GridLayout7.Layout.Row = 2;
            app.GridLayout7.Layout.Column = 1;

            % Create FontsizeEditFieldLabel
            app.FontsizeEditFieldLabel = uilabel(app.GridLayout7);
            app.FontsizeEditFieldLabel.Layout.Row = 1;
            app.FontsizeEditFieldLabel.Layout.Column = 1;
            app.FontsizeEditFieldLabel.Text = 'Font size';

            % Create FontsizeEditField
            app.FontsizeEditField = uieditfield(app.GridLayout7, 'numeric');
            app.FontsizeEditField.Limits = [6 72];
            app.FontsizeEditField.Layout.Row = 1;
            app.FontsizeEditField.Layout.Column = 2;
            app.FontsizeEditField.Value = 10;

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout5);
            app.GridLayout8.ColumnWidth = {'3x', '7x'};
            app.GridLayout8.RowHeight = {'1x'};
            app.GridLayout8.Padding = [0 0 0 0];
            app.GridLayout8.Layout.Row = 3;
            app.GridLayout8.Layout.Column = 1;

            % Create BestfitStyleDropDownLabel
            app.BestfitStyleDropDownLabel = uilabel(app.GridLayout8);
            app.BestfitStyleDropDownLabel.Layout.Row = 1;
            app.BestfitStyleDropDownLabel.Layout.Column = 1;
            app.BestfitStyleDropDownLabel.Text = 'Best fit';

            % Create BestfitStyleDropDown
            app.BestfitStyleDropDown = uidropdown(app.GridLayout8);
            app.BestfitStyleDropDown.Items = ...
                {'triangle', 'diamond', 'none'};
            app.BestfitStyleDropDown.Layout.Row = 1;
            app.BestfitStyleDropDown.Layout.Column = 2;
            app.BestfitStyleDropDown.Value = 'triangle';

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout5);
            app.GridLayout9.ColumnWidth = {'3x', '7x'};
            app.GridLayout9.RowHeight = {'1x'};
            app.GridLayout9.Padding = [0 0 0 0];
            app.GridLayout9.Layout.Row = 4;
            app.GridLayout9.Layout.Column = 1;

            % Create BestfitColorEditFieldLabel
            app.BestfitColorEditFieldLabel = uilabel(app.GridLayout9);
            app.BestfitColorEditFieldLabel.Layout.Row = 1;
            app.BestfitColorEditFieldLabel.Layout.Column = 1;
            app.BestfitColorEditFieldLabel.Text = 'Best fit color';

            % Create BestfitColorEditField
            app.BestfitColorEditField = uieditfield(app.GridLayout9, 'text');
            app.BestfitColorEditField.Tooltip = ...
                {'Use "series" or a #RRGGBB color.'};
            app.BestfitColorEditField.Layout.Row = 1;
            app.BestfitColorEditField.Layout.Column = 2;
            app.BestfitColorEditField.Value = 'series';

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout5);
            app.GridLayout10.ColumnWidth = {'3x', '7x'};
            app.GridLayout10.RowHeight = {'1x'};
            app.GridLayout10.Padding = [0 0 0 0];
            app.GridLayout10.Layout.Row = 5;
            app.GridLayout10.Layout.Column = 1;

            % Create BestfitSizeEditFieldLabel
            app.BestfitSizeEditFieldLabel = uilabel(app.GridLayout10);
            app.BestfitSizeEditFieldLabel.Layout.Row = 1;
            app.BestfitSizeEditFieldLabel.Layout.Column = 1;
            app.BestfitSizeEditFieldLabel.Text = 'Marker size';

            % Create BestfitSizeEditField
            app.BestfitSizeEditField = ...
                uieditfield(app.GridLayout10, 'numeric');
            app.BestfitSizeEditField.Limits = [1 40];
            app.BestfitSizeEditField.Layout.Row = 1;
            app.BestfitSizeEditField.Layout.Column = 2;
            app.BestfitSizeEditField.Value = 8;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ViewComparison_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
