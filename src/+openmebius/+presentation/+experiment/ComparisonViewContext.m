classdef ComparisonViewContext
    % COMPARISONVIEWCONTEXT Dependencies and initial state for ComparisonView.

    properties (SetAccess = private)
        Presenter openmebius.presentation.experiment.ComparisonViewPresenter
        InitialCatalog openmebius.presentation.experiment ...
            .ComparisonCatalogViewModel
        Mode (1, 1) string
        Action openmebius.presentation.experiment.ComparisonViewAction
    end

    methods

        function obj = ComparisonViewContext(options)

            arguments
                options.Presenter (1, 1) openmebius.presentation ...
                    .experiment.ComparisonViewPresenter
                options.InitialCatalog (1, 1) openmebius.presentation ...
                    .experiment.ComparisonCatalogViewModel
                options.Mode (1, 1) string {mustBeMember( ...
                                                options.Mode, "ms")} = "ms"
                options.Action (1, 1) openmebius.presentation ...
                    .experiment.ComparisonViewAction = ...
                    openmebius.presentation.experiment ...
                    .ComparisonViewAction()
            end

            obj.Presenter = options.Presenter;
            obj.InitialCatalog = options.InitialCatalog;
            obj.Mode = options.Mode;
            obj.Action = options.Action;

        end % constructor

    end % methods

end % classdef
