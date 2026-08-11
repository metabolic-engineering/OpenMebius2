classdef MainAppViewBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function registeredCallbacksRemainThin(testCase)

            source = MainAppViewBoundaryTest.source();
            callbackStart = strfind( ...
                source, "% Callbacks that handle component events");
            callbackEnd = strfind(source, "% Component initialization");
            testCase.assertNotEmpty(callbackStart);
            testCase.assertNotEmpty(callbackEnd);
            callbackSource = extractBetween( ...
                source, callbackStart(1), callbackEnd(end) - 1);

            methods = regexp( ...
                    char(callbackSource), ...
                    ['(?ms)^        function\s+(?<Name>\w+)\([^\r\n]*' ...
                 '.*?^        end(?:\s*%[^\r\n]*)?\r?$'], ...
                'names');

                testCase.assertNotEmpty(methods);

                for methodIndex = 1:numel(methods)
                    expression = ...
                        ['(?ms)^        function\s+' methods(methodIndex).Name ...
                     '\([^\r\n]*.*?^        end(?:\s*%[^\r\n]*)?\r?$'];
                    methodSource = regexp( ...
                        char(callbackSource), expression, 'match', 'once');
                    lineCount = numel(splitlines(string(methodSource)));
                    testCase.verifyLessThanOrEqual( ...
                        lineCount, ...
                        15, ...

                        methods (methodIndex).Name + ...
                            " contains " + lineCount + " lines.");
                    end

                end

                function callbacksUseOnlyApplicationBoundaryForBusinessWork(testCase)

                    source = MainAppViewBoundaryTest.source();
                    callbackStart = strfind( ...
                        source, "% Callbacks that handle component events");
                    callbackEnd = strfind(source, "% Component initialization");
                    callbacks = extractBetween( ...
                        source, callbackStart(1), callbackEnd(end) - 1);

                    testCase.verifyFalse(contains(callbacks, "openmebius.domain."));
                    testCase.verifyFalse(contains(callbacks, "Repository"));
                    testCase.verifyFalse(contains(callbacks, "Workspace"));
                    testCase.verifyFalse(contains(callbacks, "IOModel"));
                    testCase.verifyFalse(contains(callbacks, "IOExps"));
                    testCase.verifyFalse(contains(callbacks, "IOResult"));

                end

                function themeDetectionUsesFigureThemeMetadata(testCase)

                    source = MainAppViewBoundaryTest.source();
                    methodStart = strfind( ...
                        source, "function isDark = isDarkTheme(app)");
                    methodEnd = strfind( ...
                        source, "end % function isDarkTheme");

                    testCase.assertNotEmpty(methodStart);
                    testCase.assertNotEmpty(methodEnd);
                    method = extractBetween( ...
                        source, methodStart(1), methodEnd(1));
                    testCase.verifyTrue(contains( ...
                        method, ...
                    "app.OpenMebius2UIFigure"));
                    testCase.verifyTrue(contains( ...
                        method, ".Theme.BaseColorStyle"));
                    testCase.verifyFalse(contains(method, ".Color"));

                end

            end

            methods (Static, Access = private)

                function source = source()
                    root = fileparts(fileparts(mfilename("fullpath")));
                    source = string(fileread( ...
                        fullfile(root, "src", "OpenMebius2_exported.m")));
                end

            end

        end
