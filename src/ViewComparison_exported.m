classdef ViewComparison_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        GridLayout      matlab.ui.container.GridLayout
        GridLayout3     matlab.ui.container.GridLayout
        GridLayout4     matlab.ui.container.GridLayout
        ColorUITable    matlab.ui.control.Table
        FluxUITable     matlab.ui.control.Table
        BatchUITable    matlab.ui.control.Table
        UIAxes          matlab.ui.control.UIAxes
        GridLayout2     matlab.ui.container.GridLayout
        SaveplotButton  matlab.ui.control.Button
        CloseButton     matlab.ui.control.Button
    end

    properties (Access = private)
        Presenter openmebius.presentation.result.ViewComparisonPresenter
        Action openmebius.presentation.result.ViewComparisonAction
        PlotViewModel
        StyleTable table = table()
        IsInitializing (1, 1) logical = false
        UIFontDropDown matlab.ui.control.DropDown
        UIFontSizeEditField matlab.ui.control.NumericEditField
        BestfitStyleDropDown matlab.ui.control.DropDown
        BestfitColorEditField matlab.ui.control.EditField
        BestfitSizeEditField matlab.ui.control.NumericEditField
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
            app.createDisplayOptionControls();

            app.BatchUITable.ColumnName = {'ID', 'Exp name', 'Contents'};
            app.BatchUITable.ColumnEditable = [false false false];
            app.BatchUITable.ColumnWidth = {'1x', '1x', 'fit'};
            app.BatchUITable.RowName = {};
            app.FluxUITable.ColumnName = {'ID', 'Reaction name'};
            app.FluxUITable.ColumnEditable = [false false];
            app.FluxUITable.ColumnWidth = {'fit', '1x'};
            app.FluxUITable.RowName = {};
            app.ColorUITable.ColumnName = {'Batch ID', 'Hex', 'Pattern'};
            app.ColorUITable.ColumnEditable = [false true true];
            app.ColorUITable.ColumnWidth = {'1x', 'fit', 'fit'};
            app.ColorUITable.RowName = {};
            app.ColorUITable.Tooltip = [ ...
                'Patterns: solid, outline, diagonal, ' ...
                'reverse-diagonal, crosshatch, dots'];

            cla(app.UIAxes);
            app.UIAxes.Color = 'white';
            app.UIAxes.TickLabelInterpreter = 'none';
            title(app.UIAxes, 'Flux range comparison');
            xlabel(app.UIAxes, 'Flux (mmol gDCW^{-1} h^{-1})');
            app.applyUIFont();

        end % configureComponents

        function createDisplayOptionControls(app)

            app.GridLayout2.ColumnWidth = ...
                {'1.5x', '0.7x', '1x', '1x', '0.7x', 'fit', 'fit'};
            fontList = unique(string(listfonts));
            fontList(fontList == "") = [];

            if isempty(fontList)
                fontList = "Arial";
            end

            defaultFont = "Arial";

            if ~any(fontList == defaultFont)
                defaultFont = fontList(1);
            end

            fontLayout = app.optionLayout(1, 'UI font');
            app.UIFontDropDown = uidropdown(fontLayout, ...
                'Items', cellstr(fontList), ...
                'Value', char(defaultFont), ...
                'ValueChangedFcn', ...
                @(~, event) app.displayOptionsChanged(event));
            app.UIFontDropDown.Layout.Row = 2;
            sizeLayout = app.optionLayout(2, 'Font size');
            app.UIFontSizeEditField = uieditfield( ...
                sizeLayout, ...
                'numeric', ...
                'Value', 10, ...
                'Limits', [6 72], ...
                'ValueChangedFcn', ...
                @(~, event) app.displayOptionsChanged(event));
            app.UIFontSizeEditField.Layout.Row = 2;
            styleLayout = app.optionLayout(3, 'Best fit');
            app.BestfitStyleDropDown = uidropdown( ...
                styleLayout, ...
                'Items', {'triangle', 'diamond', 'none'}, ...
                'Value', 'triangle', ...
                'ValueChangedFcn', ...
                @(~, event) app.displayOptionsChanged(event));
            app.BestfitStyleDropDown.Layout.Row = 2;
            colorLayout = app.optionLayout(4, 'Best fit color');
            app.BestfitColorEditField = uieditfield( ...
                colorLayout, ...
                'text', ...
                'Value', 'series', ...
                'Tooltip', 'Use "series" or a #RRGGBB color.', ...
                'ValueChangedFcn', ...
                @(~, event) app.bestfitColorChanged(event));
            app.BestfitColorEditField.Layout.Row = 2;
            markerSizeLayout = app.optionLayout(5, 'Marker size');
            app.BestfitSizeEditField = uieditfield( ...
                markerSizeLayout, ...
                'numeric', ...
                'Value', 8, ...
                'Limits', [1 40], ...
                'ValueChangedFcn', ...
                @(~, event) app.displayOptionsChanged(event));
            app.BestfitSizeEditField.Layout.Row = 2;

        end % createDisplayOptionControls

        function layout = optionLayout(app, column, labelText)

            layout = uigridlayout(app.GridLayout2, [2 1]);
            layout.RowHeight = {'fit', 'fit'};
            layout.ColumnWidth = {'1x'};
            layout.Padding = [2 0 2 0];
            layout.RowSpacing = 2;
            layout.Layout.Row = 1;
            layout.Layout.Column = column;
            label = uilabel(layout, ...
                'Text', labelText, ...
                'HorizontalAlignment', 'center');
            label.Layout.Row = 1;

        end % optionLayout

        function applyCatalog(app, viewModel)

            app.requestNotifications(viewModel.Notifications);
            batchData = table( ...
                viewModel.BatchIDs, ...
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
                colors, ...
                repmat("solid", count, 1), ...
                'VariableNames', {'BatchID', 'Hex', 'Pattern'});
            app.IsInitializing = true;
            app.BatchUITable.Selection = 1:count;
            app.IsInitializing = false;
            app.updateSelectedBatches();

        end % applyCatalog

        function updateSelectedBatches(app)

            if app.IsInitializing
                return
            end

            selectedRows = app.selectedRows(app.BatchUITable);
            batchData = app.BatchUITable.Data;

            if isempty(selectedRows) || isempty(batchData)
                app.ColorUITable.Data = table();
                app.clearPlotData();
                return
            end

            batchIDs = string(batchData.ID(selectedRows));
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
                return
            end

            app.ColorUITable.Data = app.StyleTable(indices, :);

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
                bestfitStyle = "triangle";
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
            fontSize = app.UIFontSizeEditField.Value;
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
                    FontSize = fontSize, ...
                    ReactionNames = reactionNames);
                title(app.UIAxes, 'Flux range comparison');
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

            if isempty(app.UIFontDropDown) || ...
                    isempty(app.UIFontSizeEditField)
                return
            end

            fontName = app.UIFontDropDown.Value;
            fontSize = app.UIFontSizeEditField.Value;
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
                colorObject = Color();
                isValid = all(isValidColorHex( ...
                    colorObject, reshape(string(data.Hex), 1, [])));
            elseif column == 3
                isValid = app.isValidPattern(string(data.Pattern(row)));
            end

            if ~isValid
                if column == 2
                    data.Hex(row) = string(event.PreviousData);
                elseif column == 3
                    data.Pattern(row) = string(event.PreviousData);
                end

                app.ColorUITable.Data = data;
                app.requestNotification( ...
                    openmebius.presentation.notification ...
                    .Notification.warning( ...
                    "Enter a #RRGGBB color and a supported pattern.", ...
                    Title = "Invalid plot style"));
                return
            end

            for styleIndex = 1:height(data)
                target = find( ...
                    app.StyleTable.BatchID == data.BatchID(styleIndex), 1);

                if ~isempty(target)
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
                'FontSize', app.UIFontSizeEditField.Value, ...
                'FontName', app.UIFontDropDown.Value, ...
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
            app.configureComponents();
            app.IsInitializing = false;
            app.applyCatalog(context.InitialCatalog);

        end % startupFcn

    end % methods (Access = private)

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1080 640];
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
            app.GridLayout3.ColumnWidth = {'1x', '1x', '2x'};
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
            app.UIAxes.Layout.Column = 3;

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
