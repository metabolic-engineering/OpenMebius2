classdef ResultPlotRenderer
    % Keeps graphics alive while the selected result/reaction changes.
    methods (Static)

        function clear(ax)
            hadState = isappdata(ax, 'OpenMebiusResultPlot');
            if hadState
                rmappdata(ax, 'OpenMebiusResultPlot');
            end
            if hadState || ~isempty(ax.Children)
                legend(ax, 'off');
                cla(ax, 'reset');
            end
            ax.Visible = 'on';
        end

        function pathway(ax, data, contextMenu)
            if isempty(data) || isempty(data.Image)
                openmebius.presentation.result.ResultPlotRenderer.clear(ax);
                return
            end
            state = openmebius.presentation.result.ResultPlotRenderer.begin(ax, "pathway");
            if ~state.Ready
                state.Image = image(ax, data.Image, 'HitTest', 'off');
                state.Labels = gobjects(0, 1);
                ax.Visible = 'off';
                axis(ax, 'image');
                title(ax, 'Metabolic Pathway');
                ax.HitTest = 'on';
                ax.PickableParts = 'all';
                ax.ContextMenu = contextMenu;
                state.Image.ContextMenu = contextMenu;
            end
            old = state.Data;
            if ~state.Ready || ~isequal(old.Image, data.Image) || ...
                    old.IsDarkTheme ~= data.IsDarkTheme
                pixels = data.Image;
                if data.IsDarkTheme
                    if isa(pixels, 'uint8')
                        pixels = im2double(pixels);
                    end
                    if size(pixels, 3) == 1
                        pixels = 1 - pixels;
                    elseif size(pixels, 3) == 3
                        hsv = rgb2hsv(pixels);
                        hsv(:, :, 3) = max(0.2, min(0.9 - hsv(:, :, 3), 0.95));
                        pixels = hsv2rgb(hsv);
                    end
                end
                state.Image.CData = pixels;
                state.Image.XData = [1, size(pixels, 2)];
                state.Image.YData = [1, size(pixels, 1)];
                ax.XLim = [0.5, size(pixels, 2) + 0.5];
                ax.YLim = [0.5, size(pixels, 1) + 0.5];
            end
            count = numel(data.Labels);
            if numel(state.Labels) > count
                delete(state.Labels(count + 1:end));
                state.Labels = state.Labels(1:count);
            end
            oldCount = numel(state.Labels);
            for index = oldCount + 1:count
                state.Labels(index, 1) = text(ax, 0, 0, '', 'FontSize', 14);
            end
            for index = 1:count
                label = state.Labels(index);
                position = [data.X(index), data.Y(index), 0];
                visible = isfinite(data.X(index)) && isfinite(data.Y(index));
                if ~state.Ready || index > oldCount || ...
                        ~isequaln(label.Position, position)
                    if visible
                        label.Position = position;
                    end
                    label.Visible = matlab.lang.OnOffSwitchState(visible);
                end
                if ~isequal(string(label.String), data.Labels(index))
                    label.String = data.Labels(index);
                end
                if ~state.Ready || index > oldCount || ...
                        old.IsDarkTheme ~= data.IsDarkTheme || ...
                        old.Highlight(index) ~= data.Highlight(index)
                    if data.Highlight(index)
                        label.Color = '#009E73';
                        label.FontWeight = 'bold';
                    else
                        label.Color = repmat(double(data.IsDarkTheme), 1, 3);
                        label.FontWeight = 'normal';
                    end
                end
            end
            state.Handles = [state.Image; state.Labels(:)];
            openmebius.presentation.result.ResultPlotRenderer.finish(ax, state, data);
        end

        function monteCarlo(ax, data)
            lower = double(data.LowerBounds(:)');
            upper = double(data.UpperBounds(:)');
            best = double(data.BestFit);
            finite = [lower(isfinite(lower)), upper(isfinite(upper)), best(isfinite(best))];
            if isempty(lower) || isempty(finite)
                openmebius.presentation.result.ResultPlotRenderer.clear(ax);
                return
            end
            state = openmebius.presentation.result.ResultPlotRenderer.begin(ax, "monte-carlo-ci");
            if state.Ready && isequaln(state.Data, data)
                return
            end
            if ~state.Ready
                hold(ax, 'on');
                state.Lines = [ ...
                    plot(ax, NaN, NaN, '-', 'Color', '#E69F00', 'LineWidth', 3, 'DisplayName', 'Best Fit'); ...
                    plot(ax, NaN, NaN, '-', 'Color', '#56B4E9', 'LineWidth', 3, 'DisplayName', 'Flux LB'); ...
                    plot(ax, NaN, NaN, '-', 'Color', '#009E73', 'LineWidth', 3, 'DisplayName', 'Flux UB')];
                hold(ax, 'off');
                xlabel(ax, 'Iteration'); ylabel(ax, 'Flux');
                legend(ax, 'show', 'Location', 'best');
            end
            x = 1:numel(lower);
            set(state.Lines(1), 'XData', x, 'YData', repmat(best, size(x)));
            set(state.Lines(2), 'XData', x, 'YData', lower);
            set(state.Lines(3), 'XData', x, 'YData', upper);
            margin = max(0.1 * (max(finite) - min(finite)), 0.1);
            ax.XLim = [0, numel(lower) + 1];
            ax.YLim = [min(finite) - margin, max(finite) + margin];
            % Bound tick count even for very long Monte Carlo histories.
            step = max(100, 100 * ceil(numel(lower) / 1000));
            ax.XTick = 0:step:numel(lower);
            title(ax, data.Title);
            state.Handles = state.Lines;
            openmebius.presentation.result.ResultPlotRenderer.finish(ax, state, data);
        end

        function gridSearch(ax, data)
            state = openmebius.presentation.result.ResultPlotRenderer.begin(ax, "grid-search-profile");
            if state.Ready && isequaln(state.Data, data)
                return
            end
            if ~state.Ready
                hold(ax, 'on');
                state.FVA = patch(ax, NaN, NaN, [0.75, 0.88, 0.78], ...
                    'EdgeColor', 'none', 'FaceAlpha', 0.35, 'DisplayName', 'FVA range');
                state.Trials = scatter(ax, NaN, NaN, 18, [0.7, 0.7, 0.7], 'filled', 'DisplayName', 'Trials');
                state.Profile = plot(ax, NaN, NaN, '-o', 'Color', '#0072B2', ...
                    'MarkerFaceColor', '#0072B2', 'LineWidth', 2.5, 'DisplayName', 'Minimum RSS');
                state.Threshold = yline(ax, 0, '--', 'Color', '#D55E00', 'LineWidth', 2, 'DisplayName', 'Objective threshold');
                state.Lower = xline(ax, 0, ':', 'Color', '#009E73', 'LineWidth', 1.5, 'DisplayName', 'CI lower bound');
                state.Upper = xline(ax, 0, ':', 'Color', '#CC79A7', 'LineWidth', 1.5, 'DisplayName', 'CI upper bound');
                hold(ax, 'off');
                xlabel(ax, 'Fixed flux'); ylabel(ax, 'RSS');
                grid(ax, 'on');
                legend(ax, 'show', 'Location', 'best');
            end
            ax.XLim = double(data.XLimits);
            ax.YLim = double(data.YLimits);
            lo = max(data.FVALowerBound, ax.XLim(1));
            hi = min(data.FVAUpperBound, ax.XLim(2));
            set(state.FVA, 'XData', [lo, hi, hi, lo], ...
                'YData', ax.YLim([1, 1, 2, 2]), 'Visible', matlab.lang.OnOffSwitchState(lo < hi));
            x = []; y = [];
            if isfield(data, 'TrialX') && isfield(data, 'TrialRSS')
                valid = isfinite(data.TrialX(:)) & isfinite(data.TrialRSS(:));
                x = data.TrialX(valid); y = data.TrialRSS(valid);
            end
            set(state.Trials, 'XData', x(:), 'YData', y(:));
            set(state.Profile, 'XData', data.X, 'YData', data.Y);
            openmebius.presentation.result.ResultPlotRenderer.constantLine(state.Threshold, data.ObjectiveThreshold);
            openmebius.presentation.result.ResultPlotRenderer.constantLine(state.Lower, data.LowerBound);
            openmebius.presentation.result.ResultPlotRenderer.constantLine(state.Upper, data.UpperBound);
            title(ax, data.Title);
            state.Handles = [state.FVA; state.Trials; state.Profile; state.Threshold; state.Lower; state.Upper];
            openmebius.presentation.result.ResultPlotRenderer.finish(ax, state, data);
        end

        function optimizationRSS(ax, data)
            state = openmebius.presentation.result.ResultPlotRenderer.begin(ax, "optimization-rss-histogram");
            if state.Ready && isequaln(state.Data, data)
                return
            end
            rss = double(data.RSS(:));
            rss = rss(isfinite(rss) & rss >= 0);
            if isempty(rss)
                openmebius.presentation.result.ResultPlotRenderer.clear(ax);
                return
            end
            if ~state.Ready
                hold(ax, 'on');
                state.Histogram = histogram(ax, rss, 'BinMethod', 'fd', ...
                    'FaceColor', '#0072B2', 'EdgeColor', 'none', 'DisplayName', 'RSS');
                state.Threshold = xline(ax, data.Threshold, '-', ...
                    'Color', '#D55E00', 'LineWidth', 2, 'DisplayName', 'Threshold');
                hold(ax, 'off');
                xlabel(ax, 'RSS'); ylabel(ax, 'Frequency'); grid(ax, 'on');
                legend(ax, 'show', 'Location', 'best');
            end
            useLog = isfield(data, 'UseLogScale') && data.UseLogScale && any(rss > 0);
            if useLog
                low = min(rss(rss > 0));
                if any(rss == 0)
                    low = max(low / 10, realmin('double'));
                    rss(rss == 0) = low;
                end
                [~, edges] = histcounts(log10(rss), 'BinMethod', 'fd');
                set(state.Histogram, 'Data', rss, 'BinEdges', 10 .^ edges);
                ax.XScale = 'log';
                ax.XLimMode = 'auto';
            else
                ax.XScale = 'linear';
                set(state.Histogram, 'Data', rss, 'BinMethod', 'fd');
            end
            maximum = max([rss; data.Threshold]);
            margin = 0.05 * maximum;
            if margin == 0
                margin = 0.05;
            end
            if useLog
                ax.XLim = [min(10 .^ edges), maximum + margin];
            else
                ax.XLim = [0, maximum + margin];
            end
            state.Threshold.Value = data.Threshold;
            state.Threshold.Visible = matlab.lang.OnOffSwitchState(~useLog || data.Threshold > 0);
            title(ax, data.Title);
            state.Handles = [state.Histogram; state.Threshold];
            openmebius.presentation.result.ResultPlotRenderer.finish(ax, state, data);
        end

        function exitFlags(ax, data)
            state = openmebius.presentation.result.ResultPlotRenderer.begin(ax, "optimization-exitflag-pie");
            if state.Ready && isequaln(state.Data, data)
                return
            end
            counts = double(data.Counts(:));
            if isempty(counts) || any(~isfinite(counts) | counts <= 0)
                openmebius.presentation.result.ResultPlotRenderer.clear(ax);
                return
            end
            if ~state.Ready || numel(state.Patches) ~= numel(counts)
                cla(ax); legend(ax, 'off');
                graphics = pie(ax, counts, cellstr(data.Labels));
                state.Patches = graphics(1:2:end);
                state.Labels = graphics(2:2:end);
                set(state.Patches, 'Tag', 'ExitflagPieSlice');
                axis(ax, 'equal');
            else
                edges = [0; cumsum(counts / sum(counts))] * 2 * pi;
                for index = 1:numel(counts)
                    angle = linspace(edges(index), edges(index + 1), ...
                        max(2, ceil(100 * counts(index) / sum(counts))));
                    set(state.Patches(index), 'XData', [0, cos(angle), 0], ...
                        'YData', [0, sin(angle), 0]);
                    midpoint = mean(edges(index:index + 1));
                    set(state.Labels(index), 'String', data.Labels(index), ...
                        'Position', [1.1 * cos(midpoint), 1.1 * sin(midpoint), 0]);
                end
            end
            title(ax, data.Title);
            state.Handles = [state.Patches(:); state.Labels(:)];
            openmebius.presentation.result.ResultPlotRenderer.finish(ax, state, data);
        end
    end

    methods (Static, Access = private)
        function state = begin(ax, kind)
            state = getappdata(ax, 'OpenMebiusResultPlot');
            if ~isempty(state) && state.Kind == kind && all(isgraphics(state.Handles))
                return
            end
            openmebius.presentation.result.ResultPlotRenderer.clear(ax);
            ax.XScale = 'linear'; ax.YScale = 'linear';
            ax.XColorMode = 'auto'; ax.YColorMode = 'auto';
            ax.XTickMode = 'auto'; ax.YTickMode = 'auto';
            ax.XTickLabelMode = 'auto'; ax.YTickLabelMode = 'auto';
            ax.XLabel.Visible = 'on'; ax.YLabel.Visible = 'on'; ax.Title.Visible = 'on';
            ax.FontSize = 16; ax.FontName = 'Arial';
            state = struct('Kind', kind, 'Ready', false, 'Data', [], 'Handles', gobjects(0, 1));
        end

        function finish(ax, state, data)
            state.Data = data;
            state.Ready = true;
            setappdata(ax, 'OpenMebiusResultPlot', state);
        end

        function constantLine(line, value)
            line.Visible = matlab.lang.OnOffSwitchState(isfinite(value));
            if isfinite(value)
                line.Value = value;
            end
        end
    end
end
