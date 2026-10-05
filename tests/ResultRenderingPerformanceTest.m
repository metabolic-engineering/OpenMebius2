classdef ResultRenderingPerformanceTest < matlab.unittest.TestCase
    properties
        Figure
        Axes
    end
    methods (TestMethodSetup)
        function setup(testCase)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(root, 'src'));
            testCase.Figure = uifigure('Visible', 'off');
            testCase.addTeardown(@() delete(testCase.Figure));
            testCase.Axes = uiaxes(testCase.Figure);
        end
    end
    methods (Test)
        function pathwayRetainsImageAndTextWhenHighlightChanges(testCase)
            ax = testCase.Axes;
            pixels = uint8(255 * ones(10, 20, 3));
            data = openmebius.presentation.model.PathwayPlotViewModel( ...
                Image = pixels, X = [1; 2], Y = [3; 4], Labels = ["10"; "20"], Highlight = [false; false]);
            openmebius.presentation.result.ResultPlotRenderer.pathway(ax, data, []);
            before = ax.Children;
            data = openmebius.presentation.model.PathwayPlotViewModel( ...
                Image = pixels, X = [1; 2], Y = [3; 4], Labels = ["11"; "20"], Highlight = [true; false]);
            openmebius.presentation.result.ResultPlotRenderer.pathway(ax, data, []);
            testCase.verifyEqual(ax.Children, before);
            labels = findobj(ax, 'Type', 'text', 'FontWeight', 'bold');
            testCase.verifyEqual(string(labels.String), "11");
            image = findobj(ax, 'Type', 'image');
            testCase.verifyEqual(image.CData, pixels);
            data = openmebius.presentation.model.PathwayPlotViewModel( ...
                Image = pixels, X = 1, Y = 3, Labels = "12", Highlight = false, IsDarkTheme = true);
            openmebius.presentation.result.ResultPlotRenderer.pathway(ax, data, []);
            testCase.verifyTrue(isvalid(image));
            testCase.verifyNumElements(findobj(ax, 'Type', 'text'), 1);
            testCase.verifyNotEqual(image.CData, pixels);
        end

        function monteCarloRetainsLinesAndUpdatesValues(testCase)
            ax = testCase.Axes;
            data = struct('LowerBounds', [1, 2, 3], 'UpperBounds', [5, 6, 7], 'BestFit', 4, 'Title', "R1");
            openmebius.presentation.result.ResultPlotRenderer.monteCarlo(ax, data);
            before = ax.Children;
            data.LowerBounds = [2, 3]; data.UpperBounds = [6, 7]; data.Title = "R2";
            openmebius.presentation.result.ResultPlotRenderer.monteCarlo(ax, data);
            testCase.verifyEqual(ax.Children, before);
            lower = findobj(ax, 'DisplayName', 'Flux LB');
            testCase.verifyEqual(lower.YData, [2, 3]);
            testCase.verifyEqual(string(ax.Title.String), "R2");
            cla(ax);
            openmebius.presentation.result.ResultPlotRenderer.monteCarlo(ax, data);
            testCase.verifyNumElements(findobj(ax, 'Type', 'line'), 3);
        end

        function histogramAndPieReuseTheirGraphics(testCase)
            ax = testCase.Axes;
            data = struct('RSS', [1; 2; 3; 4], 'Threshold', 3, 'Title', "A", 'UseLogScale', false);
            openmebius.presentation.result.ResultPlotRenderer.optimizationRSS(ax, data);
            before = ax.Children;
            data.RSS = [0; 10; 20]; data.UseLogScale = true;
            openmebius.presentation.result.ResultPlotRenderer.optimizationRSS(ax, data);
            testCase.verifyEqual(ax.Children, before);
            testCase.verifyEqual(ax.XScale, 'log');
            data.UseLogScale = false;
            openmebius.presentation.result.ResultPlotRenderer.optimizationRSS(ax, data);
            testCase.verifyEqual(ax.XScale, 'linear');
            pieData = struct('Counts', [2; 3], 'Labels', ["One"; "Two"], 'Title', "A");
            openmebius.presentation.result.ResultPlotRenderer.exitFlags(ax, pieData);
            before = ax.Children;
            pieData.Counts = [1; 4]; pieData.Labels = ["Changed"; "Two"];
            openmebius.presentation.result.ResultPlotRenderer.exitFlags(ax, pieData);
            testCase.verifyEqual(ax.Children, before);
            testCase.verifyNotEmpty(findobj(ax, 'String', 'Changed'));
        end

        function gridSearchRetainsGraphicsAcrossReactionSelection(testCase)
            ax = testCase.Axes;
            data = struct('X', [0; 1; 2], 'Y', [4; 2; 5], ...
                'TrialX', [0 0; 1 1; 2 2], 'TrialRSS', [4 5; 2 3; 5 6], ...
                'XLimits', [-0.2 2.2], 'YLimits', [0 10], ...
                'FVALowerBound', 0, 'FVAUpperBound', 2, 'ObjectiveThreshold', 4, ...
                'LowerBound', 0.3, 'UpperBound', 1.8, 'Title', "R1");
            openmebius.presentation.result.ResultPlotRenderer.gridSearch(ax, data);
            before = ax.Children;
            data.Y = [5; 3; 6]; data.LowerBound = NaN; data.Title = "R2";
            openmebius.presentation.result.ResultPlotRenderer.gridSearch(ax, data);
            testCase.verifyEqual(ax.Children, before);
            testCase.verifyEqual(findobj(ax, 'DisplayName', 'Minimum RSS').YData(:), data.Y);
            lower = findobj(ax, 'DisplayName', 'CI lower bound');
            testCase.verifyEqual(lower.Visible, matlab.lang.OnOffSwitchState.off);
        end

        function rangePlotReusesObjectsAndRemovesUnusedRows(testCase)
            ax = testCase.Axes;
            lower = array2table([0 0; 1 1], 'VariableNames', {'A', 'B'});
            upper = array2table([2 3; 4 5], 'VariableNames', {'A', 'B'});
            RangePlot(ax, upper, lower, Patterns = ["solid"; "crosshatch"]);
            group = findobj(ax, 'Tag', 'RangePlotGroup');
            before = group.Children;
            upper{1, 1} = 2.5;
            RangePlot(ax, upper, lower, Patterns = ["solid"; "crosshatch"]);
            testCase.verifyEqual(group.Children, before);
            RangePlot(ax, upper(1, 1), lower(1, 1));
            testCase.verifyTrue(isvalid(group));
            testCase.verifyNumElements(findobj(group, 'Type', 'rectangle'), 1);
            testCase.verifyNumElements(findobj(group, '-regexp', 'Tag', 'RangePlotLegendDummy_'), 1);
        end

        function indexUpdatesValuesAndGroupsStyles(testCase)
            tableObject = uitable(testCase.Figure, 'SelectionType', 'row');
            raw = table(["a"; "b"; "c"], ["A"; "B"; "C"], [1; NaN; 3], ...
                'VariableNames', {'ID', 'Name', 'RSS'});
            openmebius.presentation.result.ResultTableRenderer.updateIndexData(tableObject, raw, raw);
            tableObject.Selection = 2;
            raw.RSS(1) = 4;
            openmebius.presentation.result.ResultTableRenderer.updateIndexData(tableObject, raw, raw);
            testCase.verifyEqual(tableObject.Data.RSS(1), 4);
            testCase.verifyEqual(tableObject.Selection, 2);
            rules = struct('Rows', {1, 2, 3}, 'Columns', {1, 1, 1}, 'StyleKey', {"success", "success", "error"});
            openmebius.presentation.result.ResultTableRenderer.batchStyles(tableObject, rules, @(~) uistyle('FontWeight', 'bold'));
            testCase.verifyEqual(height(tableObject.StyleConfigurations), 2);
            for index = 1:numel(rules)
                rules(index).Target = "cell";
                rules(index).Value = "";
            end
            style = @(~) uistyle('FontColor', 'red');
            openmebius.presentation.result.ResultTableRenderer.resultStyles(tableObject, rules, style, false);
            testCase.verifyEqual(height(tableObject.StyleConfigurations), 2);
            openmebius.presentation.result.ResultTableRenderer.resultStyles(tableObject, rules, style, false);
            testCase.verifyEqual(height(tableObject.StyleConfigurations), 2);
            openmebius.presentation.result.ResultTableRenderer.resultStyles(tableObject, rules([]), style, false);
            testCase.verifyEmpty(tableObject.StyleConfigurations);
        end
    end
end
