function RangePlot(ax, UB, LB, options)

    arguments
        ax (1, 1) matlab.graphics.axis.Axes
        UB table
        LB table
        options.Bestfit = table()
        options.BestfitColor = 'k'
        options.BestfitStyle string {mustBeMember(options.BestfitStyle, ["diamond", "triangle"])} = "diamond"
        options.BestfitTriangleMargin (1, 1) double = 0.04
        options.BestfitTriangleMarkerSize (1, 1) double = 8
        options.BestfitTriangleScale (1, 1) double = 1.0
        options.Colors = []
        options.Delta (1, 1) double = 0.9
        options.FontSize (1, 1) double = 12
        options.LegendNumColumns (1, 1) double = 4
        options.ReactionNames = []
        options.threshold double = 1e-6
        options.Debug logical = false
        options.NotificationReporter (1, 1) function_handle = @(~) []
    end

    dbg = options.Debug;

    if isempty(UB) || isempty(LB) || height(UB) == 0 || width(UB) == 0
        if dbg
            options.NotificationReporter( ...
                openmebius.core.notification.Message( ...
                    "RangePlot guard returned for empty bounds.", ...
                    "debug", ...
                    Code = "range-plot.empty-bounds", ...
                    Source = "RangePlot", ...
                    Audience = "developer", ...
                    Kind = "diagnostic"));
        end
        return;
    end

    nPattern = width(UB);
    nRxn = height(UB);

    if isempty(options.Colors)
        colors = lines(nPattern);
    elseif isnumeric(options.Colors) && size(options.Colors, 2) == 3
        colors = options.Colors;
    elseif isstring(options.Colors) || ischar(options.Colors) || iscell(options.Colors)
        colors = hex2rgb(options.Colors);
    else
        error("options.Colors must be RGB or Hex.");
    end

    if ~isempty(options.ReactionNames)
        yLabels = string(options.ReactionNames);
    elseif ~isempty(UB.Properties.RowNames)
        yLabels = string(UB.Properties.RowNames);
    else
        yLabels = "r" + string(1:nRxn);
    end

    yPlaces = 1:nRxn;
    yBounds = 0.5:1:(nRxn + 0.5);

    hasBestfitPattern = false;
    hasBestfitSingle = false;
    bestfitMat = [];
    bestfitVec = [];

    BF = options.Bestfit;

    if ~isempty(BF) && ~(istable(BF) && height(BF) == 0)

        if istable(BF)

            if ~isempty(BF.Properties.RowNames) && ~isempty(UB.Properties.RowNames)
                [tfRow, loc] = ismember(UB.Properties.RowNames, BF.Properties.RowNames);

                if all(tfRow)
                    BF = BF(loc, :);
                end

            end

            if width(BF) == 1
                tmp = BF{:, 1};

                if isnumeric(tmp) && numel(tmp) == nRxn
                    hasBestfitSingle = true;
                    bestfitVec = tmp(:);
                end

            else
                bfVars = string(BF.Properties.VariableNames);
                ubVars = string(UB.Properties.VariableNames);
                [tfCol, locCol] = ismember(ubVars, bfVars);

                if all(tfCol)
                    tmp = BF{:, locCol};

                    if isequal(size(tmp), [nRxn nPattern])
                        hasBestfitPattern = true;
                        bestfitMat = tmp;
                    end

                end

            end

        elseif isnumeric(BF)

            if size(BF, 2) == nPattern
                hasBestfitPattern = true;
                bestfitMat = BF;
            else
                hasBestfitSingle = true;
                bestfitVec = BF(:, 1);
            end

        end

    end

    tagData = "RangePlotGroup";
    tagBestfit = "RangePlotBestfitGroup";
    tagGrid = "RangePlotGridGroup";
    tagZero = "RangePlotZeroGroup";

    delete(findobj(ax, 'Type', 'hggroup', 'Tag', tagData));
    delete(findobj(ax, 'Type', 'hggroup', 'Tag', tagBestfit));
    delete(findobj(ax, 'Type', 'hggroup', 'Tag', tagGrid));
    delete(findobj(ax, 'Type', 'hggroup', 'Tag', tagZero));

    lgOld = legend(ax);

    if ~isempty(lgOld) && isvalid(lgOld)
        delete(lgOld);
    end

    gGrid = hggroup(ax, 'Tag', tagGrid);
    gZero = hggroup(ax, 'Tag', tagZero);
    g = hggroup(ax, 'Tag', tagData);
    gBestfit = hggroup(ax, 'Tag', tagBestfit);

    hold(ax, 'on');

    delta = options.Delta;
    useTriangleBestfit = options.BestfitStyle == "triangle";
    triMarkerSize = options.BestfitTriangleMarkerSize * options.BestfitTriangleScale;
    triMargin = options.BestfitTriangleMargin;

    bestfitColor = normalizeColor(options.BestfitColor);

    set(ax, ...
        'YTick', yPlaces, ...
        'YTickLabel', yLabels, ...
        'YDir', 'reverse', ...
        'FontSize', options.FontSize, ...
        'TickLabelInterpreter', 'none', ...
        'Box', 'off');

    ylim(ax, [0.5 nRxn + 0.5]);

    xMin = min(LB{:, :}, [], 'all');
    xMax = max(UB{:, :}, [], 'all');

    if hasBestfitPattern
        xMin = min(xMin, min(bestfitMat, [], 'all'));
        xMax = max(xMax, max(bestfitMat, [], 'all'));
    end

    if hasBestfitSingle
        xMin = min(xMin, min(bestfitVec, [], 'all'));
        xMax = max(xMax, max(bestfitVec, [], 'all'));
    end

    pad = 0.04 * max(1, (xMax - xMin));
    xlim(ax, [xMin - pad xMax + pad]);

    drawnow limitrate;

    triMarkerH = markerSizeToYDataHeight(ax, triMarkerSize);
    maxTriReserve = delta * 0.45;
    triReserve = min(triMargin + triMarkerH, maxTriReserve);
    triMarkerYCenterOffset = triReserve / 2;

    for iData = 1:nPattern

        for j = 1:nRxn

            start = LB{j, iData};
            stop = UB{j, iData};

            if start > stop && abs(start - stop) < options.threshold
                start = stop;
            end

            if useTriangleBestfit
                rowTop = yPlaces(j) - delta / 2;
                rowBottom = yPlaces(j) + delta / 2;

                barAreaTop = rowTop + triReserve;
                barAreaHeight = rowBottom - barAreaTop;

                barH = barAreaHeight / nPattern;
                barY = barAreaTop + (iData - 1) * barH;
            else
                barH = delta / nPattern;
                barY = yPlaces(j) - delta / 2 + (iData - 1) * barH;
            end

            rectangle(ax, ...
                'Position', [start barY stop - start barH], ...
                'FaceColor', colors(iData, :), ...
                'EdgeColor', 'none', ...
                'Parent', g);

            if hasBestfitPattern

                if useTriangleBestfit
                    plot(ax, ...
                        bestfitMat(j, iData), ...
                        yPlaces(j) - delta / 2 + triMarkerYCenterOffset, ...
                        'v', ...
                        'MarkerSize', triMarkerSize, ...
                        'LineWidth', 0.75, ...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceColor', colors(iData, :), ...
                        'HandleVisibility', 'off', ...
                        'Parent', gBestfit);
                else
                    plot(ax, bestfitMat(j, iData), ...
                        barY + barH / 2, ...
                        'd', ...
                        'MarkerSize', 5, ...
                        'LineWidth', 0.75, ...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceColor', colors(iData, :), ...
                        'HandleVisibility', 'off', ...
                        'Parent', gBestfit);
                end

            end

        end

    end

    if hasBestfitSingle

        for j = 1:nRxn

            if useTriangleBestfit
                plot(ax, ...
                    bestfitVec(j), ...
                    yPlaces(j) - delta / 2 + triMarkerYCenterOffset, ...
                    'v', ...
                    'MarkerSize', triMarkerSize, ...
                    'LineWidth', 0.75, ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', bestfitColor, ...
                    'HandleVisibility', 'off', ...
                    'Parent', gBestfit);
            else
                plot(ax, bestfitVec(j), ...
                    yPlaces(j), ...
                    'd', ...
                    'MarkerSize', 6, ...
                    'LineWidth', 0.75, ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', bestfitColor, ...
                    'HandleVisibility', 'off', ...
                    'Parent', gBestfit);
            end

        end

    end

    dummy = gobjects(nPattern, 1);

    for iData = 1:nPattern

        dummy(iData) = plot(ax, nan, nan, 's', ...
            'MarkerSize', 10, ...
            'MarkerFaceColor', colors(iData, :), ...
            'MarkerEdgeColor', 'none', ...
            'DisplayName', UB.Properties.VariableNames{iData}, ...
            'Parent', g);

        dummy(iData).Tag = sprintf("RangePlotLegendDummy_%04d", iData);

    end

    lgd = legend(ax, dummy, ...
        'Location', 'southoutside', ...
        'Orientation', 'vertical', ...
        'NumColumns', options.LegendNumColumns, ...
        'FontSize', options.FontSize);

    lgd.AutoUpdate = 'off';
    lgd.Box = 'off';
    lgd.Interpreter = 'none';

    grid(ax, 'off');

    gridColor = [0.75 0.75 0.75];
    gridLW = 1.2;

    xl = xlim(ax);
    yl = ylim(ax);

    for yb = yBounds
        line(ax, [xl(1) xl(2)], [yb yb], ...
            'Color', gridColor, ...
            'LineWidth', gridLW, ...
            'HandleVisibility', 'off', ...
            'Parent', gGrid);
    end

    for xt = ax.XTick

        if abs(xt) < 1e-12
            continue;
        end

        line(ax, [xt xt], [yl(1) yl(2)], ...
            'Color', gridColor, ...
            'LineWidth', gridLW, ...
            'HandleVisibility', 'off', ...
            'Parent', gGrid);
    end

    line(ax, [0 0], [yl(1) yl(2)], ...
        'Color', 'k', ...
        'LineWidth', 1.8, ...
        'HandleVisibility', 'off', ...
        'Parent', gZero);

    uistack(gGrid, 'bottom');
    uistack(gZero, 'top');
    uistack(g, 'top');
    uistack(gBestfit, 'top');

    xlabel(ax, 'Flux (mmol gDCW^{-1} h^{-1})', ...
        'FontSize', options.FontSize);

    title(ax, '');

    hold(ax, 'off');

end

function hData = markerSizeToYDataHeight(ax, markerSize)

    oldUnits = ax.Units;
    ax.Units = 'pixels';
    axPos = ax.Position;
    ax.Units = oldUnits;

    yl = ylim(ax);

    markerPixel = markerSize * get(groot, 'ScreenPixelsPerInch') / 72;
    hData = markerPixel / axPos(4) * diff(yl);

end

function rgb = normalizeColor(color)

    if isnumeric(color)
        rgb = color;
    elseif isstring(color) || ischar(color) || iscell(color)
        rgb = hex2rgb(color);
        rgb = rgb(1, :);
    else
        error("Color must be RGB or Hex.");
    end

end

function rgb = hex2rgb(hex)

    if ischar(hex) || isstring(hex)
        hex = cellstr(hex);
    end

    n = numel(hex);
    rgb = zeros(n, 3);

    for i = 1:n
        h = hex{i};

        if ~isempty(h) && h(1) == '#'
            h = h(2:end);
        end

        rgb(i, :) = sscanf(h, '%2x%2x%2x', [1 3]) / 255;
    end

end
