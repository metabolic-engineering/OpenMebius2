function RangePlot(ax, UB, LB, options)
    %RANGEPLOT Draw range plot on a given axes (uiaxes)
    %
    % Required
    %   ax : matlab.graphics.axis.Axes (uiaxes OK)
    %   UB : table (nRxn x nPattern)
    %   LB : table (nRxn x nPattern)
    %
    % Options (Name-Value or struct)
    %   Bestfit           table | []      (optional)
    %       - single : nRxn x 1  -> plot at group center (yPlaces)
    %       - pattern: nRxn x nPattern -> plot at each rectangle center
    %       - if table: align rows/cols by RowNames/VariableNames when possible
    %   BestfitColor      string | 1x3 double (single Bestfit marker face color)
    %   Colors            RGB (nPattern x 3) | Hex (string/cellstr)
    %   Delta             double           (default 0.9)
    %   FontSize          double           (default 12)
    %   LegendNumColumns  double           (default 4)
    %   ReactionNames     string | cellstr (optional)
    %   threshold         double           (default 1e-6)
    %   Debug             logical          (default false)

    arguments
        ax (1, 1) matlab.graphics.axis.Axes
        UB table
        LB table
        options.Bestfit table = table()
        options.BestfitColor = 'k'
        options.Colors = []
        options.Delta (1, 1) double = 0.9
        options.FontSize (1, 1) double = 12
        options.LegendNumColumns (1, 1) double = 4
        options.ReactionNames = []
        options.threshold double = 1e-6
        options.Debug logical = false
    end

    dbg = options.Debug;

    % ---------------- guard ----------------
    if isempty(UB) || isempty(LB) || height(UB) == 0 || width(UB) == 0
        if dbg; disp("---- RangePlot: guard return ----"); end
        return;
    end

    nPattern = width(UB);
    nRxn = height(UB);

    % ---------------- colors ----------------
    if isempty(options.Colors)
        colors = lines(nPattern);
    elseif isnumeric(options.Colors) && size(options.Colors, 2) == 3
        colors = options.Colors;
    elseif isstring(options.Colors) || ischar(options.Colors) || iscell(options.Colors)
        colors = hex2rgb(options.Colors);
    else
        error("options.Colors must be RGB or Hex.");
    end

    % ---------------- reaction names ----------------
    if ~isempty(options.ReactionNames)
        yLabels = string(options.ReactionNames);
    elseif ~isempty(UB.Properties.RowNames)
        yLabels = string(UB.Properties.RowNames);
    else
        yLabels = "r" + string(1:nRxn);
    end

    yPlaces = 1:nRxn; % 反応中心
    yBounds = 0.5:1:(nRxn + 0.5); % 反応間境界（グリッド用）

    % =========================================================
    % Bestfit handling
    % =========================================================
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

    % =====================================================
    % Clear old drawings
    % =====================================================
    tagData = "RangePlotGroup";
    tagGrid = "RangePlotGridGroup";
    tagZero = "RangePlotZeroGroup";

    delete(findobj(ax, 'Type', 'hggroup', 'Tag', tagData));
    delete(findobj(ax, 'Type', 'hggroup', 'Tag', tagGrid));
    delete(findobj(ax, 'Type', 'hggroup', 'Tag', tagZero));

    lgOld = legend(ax);
    if ~isempty(lgOld) && isvalid(lgOld); delete(lgOld); end

    gGrid = hggroup(ax, 'Tag', tagGrid); % grid (bottom)
    gZero = hggroup(ax, 'Tag', tagZero); % x=0
    g = hggroup(ax, 'Tag', tagData); % data (top)

    % =====================================================
    % Draw data
    % =====================================================
    hold(ax, 'on');
    delta = options.Delta;

    for iData = 1:nPattern

        for j = 1:nRxn
            start = LB{j, iData};
            stop = UB{j, iData};

            barY = yPlaces(j) - delta / 2 + (iData - 1) * (delta / nPattern);

            if start > stop && abs(start - stop) < options.threshold
                start = stop;
            end

            rectangle(ax, ...
                'Position', [start barY stop - start delta / nPattern], ...
                'FaceColor', colors(iData, :), ...
                'EdgeColor', 'none', ...
                'Parent', g);

            if hasBestfitPattern
                plot(ax, bestfitMat(j, iData), ...
                    barY + delta / (2 * nPattern), 'd', ...
                    'MarkerSize', 5, 'LineWidth', 0.75, ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', colors(iData, :), ...
                    'HandleVisibility', 'off', ...
                    'Parent', g);
            end

        end

    end

    if hasBestfitSingle

        for j = 1:nRxn
            plot(ax, bestfitVec(j), yPlaces(j), 'd', ...
                'MarkerSize', 6, 'LineWidth', 0.75, ...
                'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', options.BestfitColor, ...
                'HandleVisibility', 'off', ...
                'Parent', g);
        end

    end

    % =====================================================
    % Legend
    % =====================================================
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

    % =====================================================
    % Axes formatting
    % =====================================================
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
    pad = 0.04 * max(1, (xMax - xMin));
    xlim(ax, [xMin - pad xMax + pad]);

    % =====================================================
    % Custom grid (between reactions)
    % =====================================================
    grid(ax, 'off');
    gridColor = [0.75 0.75 0.75];
    gridLW = 1.2;

    xl = xlim(ax);
    yl = ylim(ax);

    % horizontal grid at reaction boundaries
    for yb = yBounds
        line(ax, [xl(1) xl(2)], [yb yb], ...
            'Color', gridColor, 'LineWidth', gridLW, ...
            'HandleVisibility', 'off', ...
            'Parent', gGrid);
    end

    % vertical grid
    for xt = ax.XTick
        if abs(xt) < 1e-12; continue; end
        line(ax, [xt xt], [yl(1) yl(2)], ...
            'Color', gridColor, 'LineWidth', gridLW, ...
            'HandleVisibility', 'off', ...
            'Parent', gGrid);
    end

    % x = 0 line
    line(ax, [0 0], [yl(1) yl(2)], ...
        'Color', 'k', 'LineWidth', 1.8, ...
        'HandleVisibility', 'off', ...
        'Parent', gZero);

    uistack(gGrid, 'bottom');
    uistack(gZero, 'top');
    uistack(g, 'top');

    xlabel(ax, 'Flux (mmol gDCW^{-1} h^{-1})', 'FontSize', options.FontSize);
    title(ax, '');
    hold(ax, 'off');

end

% =====================================================
% Local function : Hex -> RGB
% =====================================================
function rgb = hex2rgb(hex)

    if ischar(hex) || isstring(hex)
        hex = cellstr(hex);
    end

    n = numel(hex);
    rgb = zeros(n, 3);

    for i = 1:n
        h = hex{i};
        if ~isempty(h) && h(1) == '#'; h = h(2:end); end
        rgb(i, :) = sscanf(h, '%2x%2x%2x', [1 3]) / 255;
    end

end
