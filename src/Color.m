classdef Color < handle

    properties (SetAccess = private)

        cmthermal = ["#1c3f75", "#068fb9", "#f1e235", "#d64e8b", "#730e22"];
        cm = [];

    end % properties

    methods

        function obj = Color()

        end % constructor

        function hex = getColorValue(obj, values, options)

            arguments
                obj
                values (1, :) double
                options.color (1, :) string = "cmthermal"
                options.isDark (1, 1) logical = false
            end % arguments

            obj.setColorHex(256, "color", options.color, "isDark", options.isDark);

            % Replace nan values with 0
            minValues = min(values);
            values(isnan(values)) = minValues;

            hex = obj.cm(round(values * (length(obj.cm) - 1)) + 1);

        end % function

        function hex = getPresetColor(~, idx, name)

            tab10 = ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf"];
            pastel1 = ["#fbb4ae", "#b3cde3", "#ccebc5", "#decbe4", "#fed9a6", "#ffffcc", "#e5d8bd", "#fddaec", "#f2f2f2"];
            pastel2 = ["#b3e2cd", "#fdcdac", "#cbd5e8", "#f4cae4", "#e6f5c9", "#fff2ae", "#f1e2cc", "#cccccc"];

            switch name
                case "tab10"
                    palette = tab10;
                case "pastel1"
                    palette = pastel1;
                case "pastel2"
                    palette = pastel2;
                otherwise
                    error("Unknown preset color name: %s", name);
            end % switch

            hex = palette(mod(idx - 1, length(palette)) + 1);

        end % function

        function tf = isValidColorHex(~, names)

            arguments
                ~
                names (1, :) string
            end % arguments

            tf = true(length(names), 1);

            % pattern: #HEX only
            pattern = "^#[0-9A-Fa-f]{6}$";

            for i = 1:length(names)

                result = regexp(names(i), pattern, 'once');

                if isempty(result)
                    tf(i) = false;
                end % if

            end % for

        end % function isValidColorHex

        function cm = getColorHex(obj, n, options)

            arguments
                obj
                n (1, 1) double {mustBeInteger, mustBePositive} = 256
                options.color (1, :) string = "cmthermal"
                options.isDark (1, 1) logical = false
            end % arguments

            if isempty(obj.cm)
                obj.setColorHex(n, "color", options.color, "isDark", options.isDark);
            end % if

            cm = obj.cm;

        end % function

        function cm = getColorPalette(obj, n, options)

            arguments
                obj
                n (1, 1) double {mustBeInteger, mustBePositive} = 256
                options.color (1, :) string = "seaborn-colorblind"
                options.hex (1, 1) logical = true
            end % arguments

            switch options.color
                case "seaborn-colorblind"
                    palette = ["#0072B2", "#009E73", "#D55E00", "#CC79A7", "#F0E442", "#56B4E9"];
                    cm = repmat(palette, 1, ceil(n / length(palette)));
                otherwise
                    cm = obj.getColorHex(n);
            end % switch

            if ~options.hex
                cm = hex2rgb(cm);
            end % if

        end % function

        function plotColor(obj, n, options)

            arguments
                obj
                n (1, 1) double {mustBeInteger, mustBePositive} = 256
                options.color (1, :) string = "cmthermal"
                options.isDark (1, 1) logical = false
            end % arguments

            cmTemp = setColor(obj, n, "color", options.color, "isDark", options.isDark);

            figure('Color', 'w');
            colormap(cmTemp);
            colorbar( ...
                'Ticks', linspace(0, 1, length(cmTemp)), ...
                'TickLabels', linspace(0, 1, length(cmTemp)) ...
                );

        end % function

        function rgbDark = convertForDarkTheme(~, rgbLight)

            arguments
                ~
                rgbLight (1, 3) double {mustBeInRange(rgbLight, 0, 1)}
            end %

            hsv = rgb2hsv(rgbLight);

            hsv(3) = 0.9 - hsv(3);
            hsv(3) = max(0.2, min(hsv(3), 0.95));

            rgbDark = hsv2rgb(hsv);

        end % function convertForDarkTheme

        function hexDark = convertHexForDarkTheme(obj, hexLight)

            arguments
                obj
                hexLight (1, 1) string
            end % arguments

            rgbLight = hex2rgb(hexLight);
            rgbDark = convertForDarkTheme(obj, rgbLight);
            hexDark = rgb2hex(rgbDark);

        end % function convertHexForDarkTheme

    end % methods

    methods (Access = private)

        function cm = setColorHex(obj, n, options)

            arguments
                obj
                n (1, 1) double {mustBeInteger, mustBePositive} = 256
                options.color (1, :) string = "cmthermal"
                options.isDark (1, 1) logical = false
            end % arguments

            if options.color == "cmthermal"
                color = obj.cmthermal;
            else
                color = getCmThermalLight(obj);
            end % if

            cm = linearSegmentations(obj, n, color);

            if options.isDark

                for i = 1:n
                    cm(i, :) = obj.convertForDarkTheme(cm(i, :));
                end % for

            end % if

            % [a, b, c] --> #xxyyzz
            cm = cellfun(@(x) obj.rgb2hex(x), num2cell(cm, 2), 'UniformOutput', false);
            cm = string(cm);
            obj.cm = cm;

        end % function

        function cm = setColor(obj, n, options)

            arguments
                obj
                n (1, 1) double {mustBeInteger, mustBePositive} = 256
                options.color (1, :) string = "cmthermal"
                options.isDark (1, 1) logical = false
            end % arguments

            if strcmp(options.color, "cmthermal")
                color = obj.cmthermal;
            else
                color = getCmThermalLight(obj);
            end % if

            cm = linearSegmentations(obj, n, color);

            if options.isDark

                for i = 1:n
                    cm(i, :) = obj.convertForDarkTheme(cm(i, :));
                end % for

            end % if

        end % function

        function cm = linearSegmentations(obj, n, colors)

            arguments
                obj
                n (1, 1) double {mustBeInteger, mustBePositive}
                colors (1, :) string
            end % arguments

            numColor = length(colors);

            cm = zeros(n, 3);

            for i = 1:numColor - 1
                c1 = obj.hex2rgb(colors(i));
                c2 = obj.hex2rgb(colors(i + 1));
                cm((i - 1) * round(n / (numColor - 1)) + 1:i * round(n / (numColor - 1)), :) = obj.linearSegmentation(round(n / (numColor - 1)), c1, c2);
            end % for

        end % function

        function cm = linearSegmentation(~, n, c1, c2)

            arguments
                ~
                n (1, 1) double {mustBeInteger}
                c1 (1, 3) double {mustBeInRange(c1, 0, 1)}
                c2 (1, 3) double {mustBeInRange(c2, 0, 1)}
            end % arguments

            % Linear segmentation between two colors
            cm = zeros(n, 3);

            for i = 1:3
                cm(:, i) = linspace(c1(i), c2(i), n)';
            end % for

        end % function

        function rgb = hex2rgb(~, hex)
            % Convert hex color to RGB
            hex = char(hex);
            rgb = reshape(sscanf(hex(2:end), '%2x') ./ 255, 1, 3);
        end % function

        function hex = rgb2hex(~, rgb)
            % Convert RGB color to hex
            hex = ['#', sprintf('%02x%02x%02x', round(rgb * 255))];
        end % function

        function hsv = rgb2hsv(~, rgb)
            % Convert RGB color to HSV
            rgb = double(rgb);
            maxRGB = max(rgb, [], 2);
            minRGB = min(rgb, [], 2);
            delta = maxRGB - minRGB;
            hsv = zeros(size(rgb));
            hsv(:, 1) = acos((0.5 * ((rgb(:, 1) - rgb(:, 2)) + (rgb(:, 1) - rgb(:, 3)))) ./ (delta + eps));
            hsv(:, 2) = delta ./ (maxRGB + eps);
            hsv(:, 3) = maxRGB;
        end % function

        function rgb = hsv2rgb(~, hsv)
            % Convert HSV color to RGB
            c = hsv(:, 2) .* hsv(:, 3);
            x = c .* (1 - abs(mod(hsv(:, 1) / 60, 2) - 1));
            m = hsv(:, 3) - c;
            rgb = zeros(size(hsv));

            for i = 0:5
                idx = find(hsv(:, 1) >= i * 60 & hsv(:, 1) < (i + 1) * 60);
                rgb(idx, :) = [c(idx), x(idx), zeros(length(idx), 1)];
                rgb(idx, :) = rgb(idx, mod(i + [0, 1, 2], 3) + 1);
                rgb(idx, :) = rgb(idx, :) + m(idx);
            end % for

        end % function

        function hex = getCmThermalLight(obj)
            % Get the thermal color map
            cm = obj.cmthermal;
            cm = linearSegmentations(obj, 256, cm);

            hsv = rgb2hsv(cm);
            % Shift value to make it lighter
            hsv(:, 3) = hsv(:, 3) +255/255;
            hsv(hsv(:, 3) > 1, 3) = 1; % Ensure value is in range [0, 1]
            rgb = hsv2rgb(hsv);
            hex = cellfun(@(x) obj.rgb2hex(x), num2cell(rgb, 2), 'UniformOutput', false);
            hex = string(hex);

        end % function

    end % methods (private)

end % classdef
