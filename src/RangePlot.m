function RangePlot(ax, UB, LB, options)

    arguments
        ax (1, 1) matlab.graphics.axis.Axes
        UB table
        LB table
        options.Bestfit = table()
        options.BestfitColor = 'k'
        options.BestfitColors = []
        options.BestfitDiamondMarkerSize (1, 1) double = 6
        options.BestfitStyle string {mustBeMember(options.BestfitStyle, ["diamond", "triangle"])} = "diamond"
        options.BestfitTriangleMargin (1, 1) double = 0.04
        options.BestfitTriangleMarkerSize (1, 1) double = 8
        options.BestfitTriangleScale (1, 1) double = 1.0
        options.Colors = []
        options.Delta (1, 1) double = 0.9
        options.FontSize (1, 1) double = 12
        options.LegendNumColumns (1, 1) double = 4
        options.Patterns = []
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

    patterns = normalizePatterns(options.Patterns, nPattern);

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

    if isempty(options.BestfitColors)
        bestfitColors = colors;
    elseif isnumeric(options.BestfitColors) && ...
            size(options.BestfitColors, 2) == 3
        bestfitColors = options.BestfitColors;
    elseif isstring(options.BestfitColors) || ...
            ischar(options.BestfitColors) || ...
            iscell(options.BestfitColors)
        bestfitColors = hex2rgb(options.BestfitColors);
    else
        error("options.BestfitColors must be RGB or Hex.");
    end

    if size(bestfitColors, 1) == 1 && nPattern > 1
        bestfitColors = repmat(bestfitColors, nPattern, 1);
    end

    if size(bestfitColors, 1) ~= nPattern
        error( ...
            "OpenMebius2:RangePlot:BestfitColorCountMismatch", ...
        "BestfitColors must contain one color per plotted series.");
    end

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

            drawIntervalPattern( ...
                ax, ...
                start, ...
                stop, ...
                barY, ...
                barH, ...
                colors(iData, :), ...
                patterns(iData), ...
                g);

            if hasBestfitPattern

                if useTriangleBestfit
                    plot(ax, ...
                        bestfitMat(j, iData), ...
                        yPlaces(j) - delta / 2 + triMarkerYCenterOffset, ...
                        'v', ...
                        'MarkerSize', triMarkerSize, ...
                        'LineWidth', 0.75, ...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceColor', bestfitColors(iData, :), ...
                        'HandleVisibility', 'off', ...
                        'Parent', gBestfit);
                else
                    plot(ax, bestfitMat(j, iData), ...
                        barY + barH / 2, ...
                        'd', ...
                        'MarkerSize', options.BestfitDiamondMarkerSize, ...
                        'LineWidth', 0.75, ...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceColor', bestfitColors(iData, :), ...
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
                    'MarkerSize', options.BestfitDiamondMarkerSize, ...
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

        [legendFaceColor, legendMarker] = ...
            legendPatternStyle(colors(iData, :), patterns(iData));
        dummy(iData) = plot(ax, nan, nan, legendMarker, ...
            'MarkerSize', 10, ...
            'MarkerFaceColor', legendFaceColor, ...
            'MarkerEdgeColor', colors(iData, :), ...
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

function patterns = normalizePatterns(patterns, count)

    if isempty(patterns)
        patterns = repmat("solid", count, 1);
        return
    end

    patterns = lower(strtrim(string(patterns(:))));

    if isscalar(patterns)
        patterns = repmat(patterns, count, 1);
    end

    if numel(patterns) ~= count
        error( ...
            "OpenMebius2:RangePlot:PatternCountMismatch", ...
        "Patterns must contain one value per plotted series.");
    end

    patterns(patterns == "" | patterns == "-") = "solid";
    patterns(patterns == "/") = "diagonal";
    patterns(patterns == "\") = "reverse-diagonal";
    patterns(patterns == "x") = "crosshatch";
    patterns(patterns == ".") = "dots";
    allowed = [ ...
                   "solid", "outline", "diagonal", ...
                   "reverse-diagonal", "crosshatch", "dots"];

    if any(~ismember(patterns, allowed))
        invalid = patterns(find(~ismember(patterns, allowed), 1));
        error( ...
            "OpenMebius2:RangePlot:InvalidPattern", ...
            "Unknown range pattern: %s.", invalid);
    end

end

function drawIntervalPattern( ...
        ax, startValue, stopValue, y, height, color, pattern, parent)

    width = stopValue - startValue;

    if abs(width) <= eps(max(1, abs(startValue)))
        line(ax, ...
            [startValue startValue], ...
            [y y + height], ...
            'Color', color, ...
            'LineWidth', 1.4, ...
            'HandleVisibility', 'off', ...
            'Parent', parent);
        return
    end

    if pattern == "solid"
        rectangle(ax, ...
            'Position', [startValue y width height], ...
            'FaceColor', color, ...
            'EdgeColor', 'none', ...
            'Parent', parent);
        return
    end

    rectangle(ax, ...
        'Position', [startValue y width height], ...
        'FaceColor', 'none', ...
        'EdgeColor', color, ...
        'LineWidth', 0.8, ...
        'Parent', parent);

    switch pattern
        case "diagonal"
            drawHatch(ax, startValue, stopValue, y, height, color, 1, parent);
        case "reverse-diagonal"
            drawHatch(ax, startValue, stopValue, y, height, color, -1, parent);
        case "crosshatch"
            drawHatch(ax, startValue, stopValue, y, height, color, 1, parent);
            drawHatch(ax, startValue, stopValue, y, height, color, -1, parent);
        case "dots"
            drawDots(ax, startValue, stopValue, y, height, color, parent);
    end

end

function drawHatch( ...
        ax, startValue, stopValue, y, height, color, direction, parent)

    offsets = -0.75:0.25:0.75;

    for offset = offsets
        uStart = max(0, -offset);
        uStop = min(1, 1 - offset);

        if uStart > uStop
            continue
        end

        vStart = uStart + offset;
        vStop = uStop + offset;

        if direction < 0
            vStart = 1 - vStart;
            vStop = 1 - vStop;
        end

        line(ax, ...
            startValue + [uStart uStop] * (stopValue - startValue), ...
            y + [vStart vStop] * height, ...
            'Color', color, ...
            'LineWidth', 0.65, ...
            'HandleVisibility', 'off', ...
            'Parent', parent);
    end

end

function drawDots(ax, startValue, stopValue, y, height, color, parent)

    [u, v] = meshgrid(0.15:0.2:0.85, [0.3 0.7]);
    plot(ax, ...
        startValue + u(:) * (stopValue - startValue), ...
        y + v(:) * height, ...
        '.', ...
        'Color', color, ...
        'MarkerSize', 5, ...
        'HandleVisibility', 'off', ...
        'Parent', parent);

end

function [faceColor, marker] = legendPatternStyle(color, pattern)

    marker = 's';

    if pattern == "solid"
        faceColor = color;
    else
        faceColor = 'none';
    end

    if pattern == "crosshatch"
        marker = 'x';
    elseif pattern == "dots"
        marker = 'o';
    end

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
    elseif (ischar(color) || (isstring(color) && isscalar(color))) && ...
            ~startsWith(string(color), "#")
        rgb = validatecolor(color);
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
