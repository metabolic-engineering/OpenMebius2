classdef ResultDarkThemeContrastTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function rssStylesMeetMinimumContrast(testCase)

            background = [0.2, 0.2, 0.2];
            passedColor = ...
                ResultDarkThemeContrastTest.defaultFontColor( ...
            "styleIsPassedDark");
            failedColor = ...
                ResultDarkThemeContrastTest.defaultFontColor( ...
            "styleIsNotPassedDark");

            testCase.verifyGreaterThanOrEqual( ...
                ResultDarkThemeContrastTest.contrastRatio( ...
                passedColor, background), ...
                4.5);
            testCase.verifyGreaterThanOrEqual( ...
                ResultDarkThemeContrastTest.contrastRatio( ...
                failedColor, background), ...
                4.5);

        end

    end

    methods (Static, Access = private)

        function color = defaultFontColor(propertyName)

            appClass = ?OpenMebius2_exported;

            properties = appClass.PropertyList;
                names = string({properties.Name});
                property = properties(names == propertyName);
                color = double(property.DefaultValue.FontColor);

            end

            function ratio = contrastRatio(foreground, background)

                foregroundLuminance = ...
                    ResultDarkThemeContrastTest.relativeLuminance(foreground);
                backgroundLuminance = ...
                    ResultDarkThemeContrastTest.relativeLuminance(background);
                lighter = max(foregroundLuminance, backgroundLuminance);
                darker = min(foregroundLuminance, backgroundLuminance);
                ratio = (lighter + 0.05) / (darker + 0.05);

            end

            function luminance = relativeLuminance(rgb)

                linear = rgb / 12.92;
                nonlinearMask = rgb > 0.04045;
                linear(nonlinearMask) = ...
                    ((rgb(nonlinearMask) + 0.055) / 1.055) .^ 2.4;
                luminance = dot(linear, [0.2126, 0.7152, 0.0722]);

            end

        end

    end
