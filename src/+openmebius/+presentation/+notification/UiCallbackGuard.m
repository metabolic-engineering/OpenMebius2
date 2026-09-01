classdef UiCallbackGuard
    % UICALLBACKGUARD Routes uncaught UI callback errors to a reporter.

    methods (Static)

        function install(target, exceptionHandler)

            arguments
                target
                exceptionHandler (1, 1) function_handle
            end

            figures = openmebius.presentation.notification ...
                .UiCallbackGuard.findFigures(target);

            for figureIndex = 1:numel(figures)
                components = findall(figures{figureIndex});

                for componentIndex = 1:numel(components)
                    openmebius.presentation.notification ...
                        .UiCallbackGuard.guardComponent( ...
                        components(componentIndex), exceptionHandler);
                end

            end

        end % install

        function execute(callback, exceptionHandler, varargin)

            try

                if iscell(callback)
                    callbackFunction = callback{1};
                    callbackArguments = callback(2:end);
                    callbackFunction(varargin{:}, callbackArguments{:});
                else
                    callback(varargin{:});
                end

            catch exception

                try
                    exceptionHandler(exception);
                catch reportingException
                    fprintf( ...
                        2, ...
                        "Unexpected UI error: %s\n" + ...
                        "UI error reporting also failed: %s\n", ...
                        char(string(exception.message)), ...
                        char(string(reportingException.message)));
                end

            end

        end % execute

    end % methods (Static)

    methods (Static, Access = private)

        function figures = findFigures(target)

            figures = cell(0, 1);

            if isa(target, 'matlab.ui.Figure')
                figures{end + 1, 1} = target;
                return
            end

            propertyNames = properties(target);

            for propertyIndex = 1:numel(propertyNames)

                try
                    value = target.(propertyNames{propertyIndex});
                catch
                    continue
                end

                if isa(value, 'matlab.ui.Figure')
                    figures{end + 1, 1} = value; %#ok<AGROW>
                end

            end

        end % findFigures

        function guardComponent(component, exceptionHandler)

            try
                propertyNames = string(properties(component));
            catch
                return
            end

            callbackNames = propertyNames(endsWith(propertyNames, "Fcn"));

            for callbackIndex = 1:numel(callbackNames)
                callbackName = callbackNames(callbackIndex);
                marker = "OpenMebius2UiCallbackGuard_" + callbackName;

                try

                    if isappdata(component, char(marker))
                        continue
                    end

                    callback = component.(callbackName);

                    if ~openmebius.presentation.notification ...
                            .UiCallbackGuard.isSupportedCallback(callback)
                        continue
                    end

                    component.(callbackName) = @(varargin) ...
                        openmebius.presentation.notification ...
                        .UiCallbackGuard.execute( ...
                        callback, exceptionHandler, varargin{:});
                    setappdata(component, char(marker), true);
                catch
                    % Unsupported or read-only callbacks remain unchanged.
                end

            end

        end % guardComponent

        function tf = isSupportedCallback(callback)

            tf = isa(callback, 'function_handle') || ...
                (iscell(callback) && ~isempty(callback) && ...
                isa(callback{1}, 'function_handle'));

        end % isSupportedCallback

    end % methods (Static, Access = private)

end % classdef
