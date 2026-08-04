classdef ViewSuggestion_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        RangePlotViewerUIFigure  matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        GridLayout2              matlab.ui.container.GridLayout
        UITable                  matlab.ui.control.Table
        GridLayout3              matlab.ui.container.GridLayout
        SaveButton               matlab.ui.control.Button
        GridLayout4              matlab.ui.container.GridLayout
        RangeAxes                matlab.ui.control.UIAxes
        GridLayout5              matlab.ui.container.GridLayout
        UITableFlux              matlab.ui.control.Table
        UITableRank              matlab.ui.control.Table
    end


    %% Public properties
    properties (Access = public)

        data
        dataLabel
        colorObj = Color();

        initialReactionName = [];
        initialIdx = [];
        initialBestfit = [];
        initialLB = [];
        initialUB = [];

        selectedIdx = [];

        sampleName (1, 1) string = "sample"
        batchID (1, 1) string = "ID"

    end

    properties (Access = private)
        NotificationPublisher (1, 1) function_handle = @(~) []
    end

    % Private methods
    methods (Access = private)

        function updateTable(app, options)

            arguments
                app
                options.isUpdate logical = true
            end % arguments

            if ~options.isUpdate

                data = app.data.data; %#ok<ADPROPLC>
                data = string(data); %#ok<ADPROPLC>

                colName = app.data.colName;

                numData = size(data, 1); %#ok<ADPROPLC>
                numFlux = length(app.data.bestfit);
                app.initialIdx = 1:numData;
                app.initialBestfit = app.data.bestfit;
                app.initialLB = nan(numFlux, numData);
                app.initialUB = nan(numFlux, numData);
                app.initialReactionName = app.data.rxn;

                rxnTF = updateFluxReaction(app, onlyBuild = true);

                dataLabel = strings(numData, 1); %#ok<ADPROPLC>

                for i = 1:numData

                    dataLabel(i) = strjoin(data(i, :), "_"); %#ok<ADPROPLC>
                    dataLabel(i) = matlab.lang.makeValidName(dataLabel(i)); %#ok<ADPROPLC>
                    app.initialLB(:, i) = app.data.(dataLabel(i)).fluxLB; %#ok<ADPROPLC>
                    app.initialUB(:, i) = app.data.(dataLabel(i)).fluxUB; %#ok<ADPROPLC>

                end % for i

                app.dataLabel = dataLabel; %#ok<ADPROPLC>
                app.dataLabel = ["FVA"; "Exp"; app.dataLabel];
                data = [strings(2, size(data, 2)); data]; %#ok<ADPROPLC>
                dataLabel = app.dataLabel; %#ok<ADPROPLC>
                colorHex = strings(numData + 2, 1);

                % CI
                app.initialLB = [app.data.FVALB, app.data.fluxLB, app.initialLB];
                app.initialUB = [app.data.FVAUB, app.data.fluxUB, app.initialUB];

                for i = 1:numData + 2

                    color = getPresetColor(app.colorObj, i, "tab10");
                    colorHex(i) = color;

                end % for i

                app.UITable.Data = [dataLabel, data, colorHex, repmat("", numData + 2, 1)]; %#ok<ADPROPLC>
                app.UITable.ColumnName = ["Label", colName, "Color", "Pattern"];
                app.UITable.ColumnEditable = [true, false(1, numel(colName)), true, true];

                colorHex = app.UITable.Data(:, app.UITable.ColumnName == "Color");

                % Flip reactions if they are negative fluxes
                negativeFluxIdx = app.initialBestfit < 0;
                app.initialBestfit(negativeFluxIdx) = -app.initialBestfit(negativeFluxIdx);
                reactionsToReverse = ...
                    string(app.initialReactionName(negativeFluxIdx));
                [reversedReactions, isReversible] = ...
                    openmebius.domain.model.ReactionExpression ...
                    .reverseReversible(reactionsToReverse);
                app.initialReactionName(negativeFluxIdx) = ...
                    reversedReactions;
                app.reportNonReversibleReactions( ...
                    reactionsToReverse(~isReversible));
                tmpUB = app.initialUB(negativeFluxIdx, :);
                app.initialUB(negativeFluxIdx, :) = -app.initialLB(negativeFluxIdx, :);
                app.initialLB(negativeFluxIdx, :) = -tmpUB;

                lbtable = array2table( ...
                    app.initialLB(rxnTF, :), ...
                    'RowNames', app.initialReactionName(rxnTF, :), ...
                    'VariableNames', app.dataLabel ...
                );
                ubtable = array2table( ...
                    app.initialUB(rxnTF, :), ...
                    'RowNames', app.initialReactionName(rxnTF, :), ...
                    'VariableNames', app.dataLabel ...
                );
                bestfitVec = app.initialBestfit(:);
                bestfittable = table(bestfitVec, ...
                    'RowNames', app.initialReactionName, ...
                    'VariableNames', {'Bestfit'});

                plotIdx = 1:numel(app.dataLabel);
                app.updateRankTable(rxnTF, plotIdx);

            else % if options.isUpdate

                if isempty(app.selectedIdx)
                    plotIdx = app.initialIdx;
                else
                    plotIdx = app.selectedIdx;
                end

                rxnTF = updateFluxReaction(app);

                colorHexAll = string(app.UITable.Data(:, app.UITable.ColumnName == "Color"));
                isValidColor = isValidColorHex(app.colorObj, colorHexAll);
                colorHex = colorHexAll(plotIdx);

                labelAll = string(app.UITable.Data(:, app.UITable.ColumnName == "Label"));
                app.dataLabel = labelAll;

                if any(~isValidColor)
                    app.publishNotification( ...
                        "error", ...
                        "One or more color codes are invalid. " + ...
                        "Please check the Color column.", ...
                        "view-suggestion.invalid-color", ...
                        "Invalid Color Code", ...
                    "action-required");
                    return;
                end

                lbtable = array2table( ...
                    app.initialLB(rxnTF, plotIdx), ...
                    'RowNames', app.initialReactionName(rxnTF, :), ...
                    'VariableNames', app.dataLabel(plotIdx) ...
                );
                ubtable = array2table( ...
                    app.initialUB(rxnTF, plotIdx), ...
                    'RowNames', app.initialReactionName(rxnTF, :), ...
                    'VariableNames', app.dataLabel(plotIdx) ...
                );
                bestfitVec = app.initialBestfit(rxnTF);
                bestfitVec = bestfitVec(:);

                bestfittable = table(bestfitVec, ...
                    'RowNames', app.initialReactionName(rxnTF), ...
                    'VariableNames', {'Bestfit'});

                app.updateRankTable(rxnTF, plotIdx);

            end % if ~options.isUpdate

            RangePlot( ...
                app.RangeAxes, ...
                ubtable, ...
                lbtable, ...
                Bestfit = bestfittable, ...
                BestfitColor = colorHex(1), ...
                BestfitStyle = "triangle", ...
                Colors = colorHex, ...
                ReactionNames = app.initialReactionName(rxnTF) ...
            );

        end % updateTable

        function rxnTF = updateFluxReaction(app, options)

            arguments
                app
                options.onlyBuild logical = false
            end % arguments

            if options.onlyBuild
                rxnNames = app.initialReactionName;
                rxnTF = true(size(rxnNames));

                tableData = table( ...
                    rxnNames, ...
                    rxnTF, ...
                    'VariableNames', {'Reaction', 'Show'} ...
                );
                tableData.Properties.VariableTypes = {'string', 'logical'};

                app.UITableFlux.Data = tableData;
                app.UITableFlux.ColumnName = tableData.Properties.VariableNames;
                app.UITableFlux.ColumnEditable = [false, true];

            else
                currentTable = app.UITableFlux.Data;
                rxnTF = currentTable.Show;
            end

        end % updateSelectedReaction

        function updateRankTable(app, rxnTF, plotIdx)
            %UPDATERANKTABLE Show mean CI width (UB-LB) for selected fluxes in UITableRank
            %
            % RowName : UITable の Label
            % Col     : ΔCI (mean of UB-LB across selected fluxes)
            % Sort    : ascending by ΔCI

            if isempty(plotIdx)
                app.UITableRank.Data = table();
                app.UITableRank.RowName = {};
                app.UITableRank.ColumnName = {};
                return;
            end

            % Label 列（RowNameに使う）
            labelAll = string(app.UITable.Data(:, app.UITable.ColumnName == "Label"));
            labelPlot = labelAll(plotIdx);

            % CI幅 = UB-LB（選択したflux行のみ）
            w = app.initialUB(rxnTF, plotIdx) - app.initialLB(rxnTF, plotIdx);

            % 列ごと（patternごと）に平均
            dCI = mean(w, 1, "omitnan").';

            % テーブル化して昇順ソート
            T = table(dCI, 'VariableNames', {'ΔCI'});
            T.Properties.RowNames = cellstr(labelPlot);

            T = sortrows(T, 'ΔCI', 'ascend');

            % UITableRank へ反映
            app.UITableRank.Data = T;
            app.UITableRank.ColumnName = T.Properties.VariableNames;
            app.UITableRank.RowName = T.Properties.RowNames;
            app.UITableRank.ColumnEditable = false;
        end % updateRankTable

        %% Public UI function
        function [ok, opts] = askSaveFigureOptions(app)
            %ASKSAVEFIGUREOPTIONS Modal dialog to choose export size, DPI, font and format
            %
            % opts fields:
            %   WidthPx
            %   HeightPx
            %   DPI
            %   FontSize
            %   FontName
            %   Format   ("png" | "pdf" | "svg" | "eps")

            ok = false;

            % ===============================
            % default values (px only)
            % ===============================
            opts = struct( ...
                'WidthPx', 1600, ...
                'HeightPx', 1200, ...
                'DPI', 600, ...
                'FontSize', 10, ...
                'FontName', 'Arial', ...
                'Format', 'png' ...
            );

            % ===============================
            % available fonts
            % ===============================
            fontList = unique(string(listfonts));
            fontList(fontList == "") = [];

            if ~any(fontList == opts.FontName)
                opts.FontName = fontList(1);
            end

            % ===============================
            % dialog
            % ===============================
            d = uifigure( ...
                'Name', 'Export Options', ...
                'WindowStyle', 'modal', ...
                'Position', [500 400 380 340], ...
                'Color', 'w');

            gl = uigridlayout(d, [7 2]);
            gl.RowHeight = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};
            gl.ColumnWidth = {'1x', '1x'};
            gl.Padding = [12 12 12 12];
            gl.RowSpacing = 6;
            gl.ColumnSpacing = 10;

            % ===============================
            % Width (px)
            % ===============================
            uilabel(gl, 'Text', 'Width (px)');
            efW = uieditfield(gl, 'numeric', ...
                'Value', opts.WidthPx, ...
                'Limits', [1 Inf]);

            % ===============================
            % Height (px)
            % ===============================
            uilabel(gl, 'Text', 'Height (px)');
            efH = uieditfield(gl, 'numeric', ...
                'Value', opts.HeightPx, ...
                'Limits', [1 Inf]);

            % ===============================
            % DPI
            % ===============================
            uilabel(gl, 'Text', 'DPI');
            efDPI = uieditfield(gl, 'numeric', ...
                'Value', opts.DPI, ...
                'Limits', [72 2400]);

            % ===============================
            % Font size
            % ===============================
            uilabel(gl, 'Text', 'Font Size');
            efFontSize = uieditfield(gl, 'numeric', ...
                'Value', opts.FontSize, ...
                'Limits', [6 40]);

            % ===============================
            % Font name
            % ===============================
            uilabel(gl, 'Text', 'Font');
            ddFont = uidropdown(gl, ...
                'Items', fontList, ...
                'Value', opts.FontName);

            % ===============================
            % File format
            % ===============================
            uilabel(gl, 'Text', 'Format');
            ddFormat = uidropdown(gl, ...
                'Items', {'png', 'pdf', 'svg', 'eps'}, ...
                'Value', opts.Format);

            % ===============================
            % Buttons
            % ===============================
            btnOK = uibutton(gl, ...
                'Text', 'OK', ...
                'ButtonPushedFcn', @(~, ~)onOK());
            btnOK.Layout.Row = 7;
            btnOK.Layout.Column = 1;

            btnCancel = uibutton(gl, ...
                'Text', 'Cancel', ...
                'ButtonPushedFcn', @(~, ~)onCancel());
            btnCancel.Layout.Row = 7;
            btnCancel.Layout.Column = 2;

            uiwait(d);

            % ======================================================
            % callbacks
            % ======================================================
            function onOK()
                opts.WidthPx = round(efW.Value);
                opts.HeightPx = round(efH.Value);
                opts.DPI = efDPI.Value;
                opts.FontSize = efFontSize.Value;
                opts.FontName = ddFont.Value;
                opts.Format = ddFormat.Value;

                ok = true;
                uiresume(d);
                delete(d);
            end

            function onCancel()
                uiresume(d);
                delete(d);
            end

        end % askSaveFigureOptions

        %% Public export function
        function exportRangePlot(app, outDir, saveOpt)
            %EXPORTRANGEPLOT Export RangePlot with font control and margin

            % ===============================
            % Export margin (px)
            % ===============================
            marginPx = struct( ...
                'Left', 120, ...
                'Right', 80, ...
                'Top', 80, ...
                'Bottom', 120 ...
            );

            figW = saveOpt.WidthPx + marginPx.Left + marginPx.Right;
            figH = saveOpt.HeightPx + marginPx.Top + marginPx.Bottom;

            % ===============================
            % Figure
            % ===============================
            fig = figure( ...
                'Visible', 'off', ...
                'Color', 'w', ...
                'Units', 'pixels', ...
                'Position', [100 100 figW figH]);

            % ===============================
            % Axes copy
            % ===============================
            ax2 = copyobj(app.RangeAxes, fig);

            axLeft = marginPx.Left / figW;
            axBottom = marginPx.Bottom / figH;
            axWidth = saveOpt.WidthPx / figW;
            axHeight = saveOpt.HeightPx / figH;

            set(ax2, ...
                'Units', 'normalized', ...
                'Position', [axLeft axBottom axWidth axHeight]);

            % ===============================
            % Apply EXPORT font (axes + labels)
            % ===============================
            set(ax2, ...
                'FontSize', saveOpt.FontSize, ...
                'FontName', saveOpt.FontName);

            ax2.XLabel.FontSize = saveOpt.FontSize;
            ax2.XLabel.FontName = saveOpt.FontName;

            ax2.YLabel.FontSize = saveOpt.FontSize;
            ax2.YLabel.FontName = saveOpt.FontName;

            drawnow;

            % ===============================
            % Legend rebuild (keep GUI order)
            % ===============================
            lgdOld = legend(ax2);

            if ~isempty(lgdOld) && isvalid(lgdOld)
                delete(lgdOld);
            end

            hDummy = findobj(ax2, 'Type', 'line', '-regexp', 'Tag', '^RangePlotLegendDummy_\d+$');

            if ~isempty(hDummy)
                tags = string(get(hDummy, 'Tag'));
                [~, idx] = sort(tags); % "...._0001" < "...._0002" ...
                    dummy = hDummy(idx);

            else
                hLine = findall(ax2, 'Type', 'line');
                keep = false(size(hLine));

                for k = 1:numel(hLine)
                    dn = "";
                    try , dn = string(hLine(k).DisplayName); catch, end
                    keep(k) = strlength(dn) > 0;
                end

                dummy = hLine(keep);
                dummy = flipud(dummy);
            end

            if ~isempty(dummy)
                lgd = legend(ax2, dummy, ...
                    'Location', 'southoutside', ...
                    'Orientation', 'horizontal', ...
                    'NumColumns', app.RangeAxes.Legend.NumColumns);
                lgd.AutoUpdate = 'off';
                lgd.Box = 'off';
                lgd.Color = 'none';
                lgd.Interpreter = 'none';
                lgd.FontSize = saveOpt.FontSize;
                lgd.FontName = saveOpt.FontName;
            end

            drawnow;

            % ===============================
            % Export
            % ===============================
            switch lower(saveOpt.Format)
                case 'png'
                    exportgraphics(ax2, fullfile(outDir, "RangePlot.png"), ...
                        'Resolution', saveOpt.DPI);

                case 'pdf'
                    exportgraphics(ax2, fullfile(outDir, "RangePlot.pdf"), ...
                        'ContentType', 'vector');

                case 'svg'
                    exportgraphics(ax2, fullfile(outDir, "RangePlot.svg"), ...
                        'ContentType', 'vector');

                case 'eps'
                    exportgraphics(ax2, fullfile(outDir, "RangePlot.eps"), ...
                        'ContentType', 'vector');
            end

            close(fig);

        end % exportRangePlot

        function exportExcelFile(app, outDir)
            %EXPORTEXCELFILE Export LB/UB/Bestfit to Excel

            excelPath = fullfile(outDir, "RangePlotData.xlsx");

            % ===============================
            % 対象インデックス
            % ===============================
            if isempty(app.selectedIdx)
                plotIdx = app.initialIdx;
            else
                plotIdx = app.selectedIdx;
            end

            rxnTF = app.UITableFlux.Data.Show;

            rxnNames = app.initialReactionName(rxnTF);
            patNames = app.dataLabel(plotIdx);

            LB = app.initialLB(rxnTF, plotIdx);
            UB = app.initialUB(rxnTF, plotIdx);
            BF = app.initialBestfit(rxnTF);

            nRxn = numel(rxnNames);
            nPat = numel(patNames);

            % ===============================
            % Sheet 1: Range (long format)
            % ===============================
            Reaction = strings(nRxn * nPat, 1);
            Pattern = strings(nRxn * nPat, 1);
            LBv = zeros(nRxn * nPat, 1);
            UBv = zeros(nRxn * nPat, 1);
            CIv = zeros(nRxn * nPat, 1);

            k = 1;

            for j = 1:nPat

                for i = 1:nRxn
                    Reaction(k) = rxnNames(i);
                    Pattern(k) = patNames(j);
                    LBv(k) = LB(i, j);
                    UBv(k) = UB(i, j);
                    CIv(k) = UB(i, j) - LB(i, j);
                    k = k + 1;
                end

            end

            T_range = table(Reaction, Pattern, LBv, UBv, CIv, ...
                'VariableNames', {'Reaction', 'Pattern', 'LB', 'UB', 'CI'});

            % ===============================
            % Sheet 2: Bestfit
            % ===============================
            T_bestfit = table(rxnNames(:), BF(:), ...
                'VariableNames', {'Reaction', 'Bestfit'});

            % ===============================
            % Sheet 3: CI summary (UITableRank 相当)
            % ===============================
            meanCI = mean(UB - LB, 1, 'omitnan');
            T_ci = table(patNames(:), meanCI(:), ...
                'VariableNames', {'Pattern', 'DeltaCI'});

            T_ci = sortrows(T_ci, 'DeltaCI', 'ascend');

            % ===============================
            % Write Excel
            % ===============================
            writetable(T_range, excelPath, 'Sheet', 'Range');
            writetable(T_bestfit, excelPath, 'Sheet', 'Bestfit');
            writetable(T_ci, excelPath, 'Sheet', 'CI_Summary');
        end % exportExcelFile

        function publishNotification( ...
                app, level, text, code, title, attention)

            emitter = openmebius.application.notification ...
                .NotificationEmitter( ...
                Publisher = app.NotificationPublisher, ...
                Source = "ViewSuggestion");
            emitter.report( ...
                level, ...
                text, ...
                Code = code, ...
                Title = title, ...
                Attention = attention);

        end % publishNotification

        function reportNonReversibleReactions(app, reactions)

            emitter = openmebius.application.notification ...
                .NotificationEmitter( ...
                Publisher = app.NotificationPublisher, ...
                Source = "ViewSuggestion");

            for reaction = reactions(:)'
                emitter.report( ...
                    "warning", ...
                    "The provided reaction is not reversible: " + ...
                    reaction, ...
                    Code = "model.reaction.not-reversible", ...
                    Audience = "developer", ...
                    Kind = "diagnostic");
            end

        end % reportNonReversibleReactions

        function renderLocalNotification(app, message)

            notification = openmebius.presentation.notification ...
                .Notification.fromMessage( ...
                message, ...
                Title = message.Title, ...
                ShowAlert = true);
            uialert( ...
                app.RangePlotViewerUIFigure, ...
                char(notification.Message), ...
                char(notification.Title), ...
                "Icon", char(notification.alertIcon()), ...
                "Interpreter", "none");

        end % renderLocalNotification

    end % private methods


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, data, notificationPublisher)

            app.sampleName = string(data.sampleName);
            app.batchID = string(data.batchID);
            app.data = data;

            if nargin >= 3 && ~isempty(notificationPublisher)
                app.NotificationPublisher = notificationPublisher;
            else
                app.NotificationPublisher = ...
                    @(message) app.renderLocalNotification(message);
            end

            updateTable(app, isUpdate = false);
        end

        % Key press function: RangePlotViewerUIFigure
        function RangePlotViewerUIFigureKeyPress(app, event)

            key = event.Key;

            % If the key is 'escape', close the app
            if strcmp(key, 'escape')
                delete(app)
            end
        end

        % Close request function: RangePlotViewerUIFigure
        function RangePlotViewerUIFigureCloseRequest(app, event)

            delete(app)

        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)

            % ---- 念のため最新状態で再描画 ----
            updateTable(app, isUpdate = true);

            % ---- 保存設定ダイアログ ----
            [ok, saveOpt] = app.askSaveFigureOptions();

            if ~ok
                return;
            end

            % ---- 保存先フォルダ選択 ----
            baseDir = uigetdir(pwd, "Select a folder to save the range plot");

            if isequal(baseDir, 0)
                return;
            end

            % ---- フォルダ名 ----
            ts = string(datetime("now", "Format", "yyyyMMdd-HHmmss"));
            folderName = app.sampleName + "_" + app.batchID + "_" + ts;
            folderName = regexprep(folderName, '[\\/:*?"<>|]', '_');

            outDir = fullfile(baseDir, folderName);

            if ~exist(outDir, "dir")
                mkdir(outDir);
            end

            % ---- Export 実行 ----
            app.exportRangePlot(outDir, saveOpt);
            app.exportExcelFile(outDir);

            % ---- 完了通知 ----
            app.publishNotification( ...
                "success", ...
                "Saved to:" + newline + outDir, ...
                "view-suggestion.saved", ...
                "Saved", ...
            "action-required");
        end

        % Selection changed function: UITable
        function UITableSelectionChanged(app, event)

            if isempty(app.UITable.Selection)
                app.selectedIdx = [];
            else
                app.selectedIdx = unique(app.UITable.Selection(:, 1));
            end

            updateTable(app, isUpdate = true);
        end

        % Display data changed function: UITable
        function UITableDisplayDataChanged(app, event)

            updateTable(app, isUpdate = true);
        end

        % Cell edit callback: UITable
        function UITableCellEdit(app, event)

            updateTable(app, isUpdate = true);
        end

        % Cell edit callback: UITableFlux
        function UITableFluxCellEdit(app, event)

            updateTable(app, isUpdate = true);
        end

        % Window key press function: RangePlotViewerUIFigure
        function RangePlotViewerUIFigureWindowKeyPress(app, event)

            key = event.Key;

            % If the key is 'escape', close the app
            if strcmp(key, 'escape')
                delete(app)
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create RangePlotViewerUIFigure and hide until all components are created
            app.RangePlotViewerUIFigure = uifigure('Visible', 'off');
            app.RangePlotViewerUIFigure.Position = [100 100 1200 640];
            app.RangePlotViewerUIFigure.Name = 'Range Plot Viewer';
            app.RangePlotViewerUIFigure.Icon = fullfile(pathToMLAPP, '+img', 'logo.png');
            app.RangePlotViewerUIFigure.CloseRequestFcn = createCallbackFcn(app, @RangePlotViewerUIFigureCloseRequest, true);
            app.RangePlotViewerUIFigure.WindowKeyPressFcn = createCallbackFcn(app, @RangePlotViewerUIFigureWindowKeyPress, true);
            app.RangePlotViewerUIFigure.KeyPressFcn = createCallbackFcn(app, @RangePlotViewerUIFigureKeyPress, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.RangePlotViewerUIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1.5x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1x'};
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 2;

            % Create UITableRank
            app.UITableRank = uitable(app.GridLayout5);
            app.UITableRank.ColumnName = '';
            app.UITableRank.RowName = {};
            app.UITableRank.Layout.Row = 2;
            app.UITableRank.Layout.Column = 1;

            % Create UITableFlux
            app.UITableFlux = uitable(app.GridLayout5);
            app.UITableFlux.ColumnName = '';
            app.UITableFlux.RowName = {};
            app.UITableFlux.CellEditCallback = createCallbackFcn(app, @UITableFluxCellEdit, true);
            app.UITableFlux.Layout.Row = 1;
            app.UITableFlux.Layout.Column = 1;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Padding = [0 0 0 0];
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 3;

            % Create RangeAxes
            app.RangeAxes = uiaxes(app.GridLayout4);
            app.RangeAxes.TickLabelInterpreter = 'none';
            app.RangeAxes.Layout.Row = 1;
            app.RangeAxes.Layout.Column = 1;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'1x', 'fit'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout2);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Padding = [0 0 0 0];
            app.GridLayout3.Layout.Row = 2;
            app.GridLayout3.Layout.Column = 1;

            % Create SaveButton
            app.SaveButton = uibutton(app.GridLayout3, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Layout.Row = 1;
            app.SaveButton.Layout.Column = 4;
            app.SaveButton.Text = 'Save';

            % Create UITable
            app.UITable = uitable(app.GridLayout2);
            app.UITable.ColumnName = '';
            app.UITable.RowName = {};
            app.UITable.CellEditCallback = createCallbackFcn(app, @UITableCellEdit, true);
            app.UITable.DisplayDataChangedFcn = createCallbackFcn(app, @UITableDisplayDataChanged, true);
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @UITableSelectionChanged, true);
            app.UITable.Layout.Row = 1;
            app.UITable.Layout.Column = 1;

            % Show the figure after all components are created
            app.RangePlotViewerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ViewSuggestion_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.RangePlotViewerUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.RangePlotViewerUIFigure)
        end
    end
end