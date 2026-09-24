classdef UiCallbackGuardTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function routesCallbackExceptionWithoutRethrowing(testCase)

            captured = MException.empty;
            figureHandle = uifigure(Visible = "off");
            cleanup = onCleanup(@() delete(figureHandle));
            button = uibutton(figureHandle);
            button.ButtonPushedFcn = @(~, ~) error( ...
                "OpenMebius2:Test:UiCallback", "callback failed");

            openmebius.presentation.notification.UiCallbackGuard ...
                .install(figureHandle, @recordException);
            callback = button.ButtonPushedFcn;
            callback(button, []);

            testCase.verifyNumElements(captured, 1);
            testCase.verifyEqual( ...
                string(captured.identifier), ...
                "OpenMebius2:Test:UiCallback");

            function recordException(exception)
                captured = exception;
            end

        end

        function guardsGeneratedCallbackOnAppDesignerApp(testCase)

            captured = MException.empty;
            experiments = helpers.MSViewExperimentsStub();
            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(experiments);
            context = openmebius.presentation.experiment.MSViewContext( ...
                Presenter = presenter, ...
                InitialExperimentIndex = 1);
            app = MSView_exported(context);
            cleanup = onCleanup(@() delete(app));
            experiments.Enrichment{:, :} = 0.5;
            experiments.EnrichmentErrors = false(1, 1);

            openmebius.presentation.notification.UiCallbackGuard ...
                .install(app, @recordException);
            app.TableTypeDropDown.Value = 'Enrichment';
            callback = app.TableTypeDropDown.ValueChangedFcn;
            callback(app.TableTypeDropDown, []);

            testCase.verifyNumElements(captured, 1);
            testCase.verifyEqual( ...
                string(captured.identifier), ...
                "OpenMebius2:MSViewTableViewModel:InvalidErrorMask");

            function recordException(exception)
                captured = exception;
            end

        end

    end

end % classdef
