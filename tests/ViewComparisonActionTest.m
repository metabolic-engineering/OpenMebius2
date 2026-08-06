classdef ViewComparisonActionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function exportsRequestedRasterSize(testCase)

            sourceFigure = figure('Visible', 'off');
            testCase.addTeardown(@() close(sourceFigure));
            sourceAxes = axes(sourceFigure);
            lower = array2table( ...
                [0 1], ...
                'VariableNames', {'A', 'B'}, ...
                'RowNames', {'r1'});
            upper = array2table( ...
                [1 2], ...
                'VariableNames', {'A', 'B'}, ...
                'RowNames', {'r1'});
            RangePlot(sourceAxes, upper, lower);
            outputPath = string(tempname) + ".png";
            testCase.addTeardown( ...
                @() ViewComparisonActionTest.deleteIfPresent( ...
                outputPath));
            action = openmebius.presentation.result ...
                .ViewComparisonAction();

            action.exportFigure( ...
                sourceAxes, ...
                outputPath, ...
                WidthPx = 800, ...
                HeightPx = 600, ...
                DPI = 100, ...
                FontSize = 11, ...
                FontName = "Arial", ...
                Format = "png");

            testCase.assertTrue(isfile(outputPath));
            information = imfinfo(outputPath);
            testCase.verifyEqual(information.Width, 800);
            testCase.verifyEqual(information.Height, 600);
            [~, ~, alpha] = imread(outputPath);
            testCase.verifyNotEmpty(alpha);
            testCase.verifyEqual(min(alpha, [], "all"), uint8(0));
            testCase.verifyGreaterThan(max(alpha, [], "all"), uint8(0));

        end

    end

    methods (Static, Access = private)

        function deleteIfPresent(path)

            if isfile(path)
                delete(path);
            end

        end

    end

end
