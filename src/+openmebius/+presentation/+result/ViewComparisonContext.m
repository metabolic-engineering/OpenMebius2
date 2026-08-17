classdef ViewComparisonContext
    % VIEWCOMPARISONCONTEXT Dependencies and initial state for the app.

    properties (SetAccess = private)
        Presenter openmebius.presentation.result.ViewComparisonPresenter
        InitialCatalog openmebius.presentation.result ...
            .ViewComparisonCatalogViewModel
        InitialBatchIDs (:, 1) string
        Action openmebius.presentation.result.ViewComparisonAction
    end

    methods

        function obj = ViewComparisonContext(options)

            arguments
                options.Presenter (1, 1) openmebius.presentation.result ...
                    .ViewComparisonPresenter
                options.InitialCatalog (1, 1) openmebius.presentation ...
                    .result.ViewComparisonCatalogViewModel
                options.InitialBatchIDs (:, 1) string = strings(0, 1)
                options.Action (1, 1) openmebius.presentation.result ...
                    .ViewComparisonAction = openmebius.presentation.result ...
                    .ViewComparisonAction()
            end

            obj.Presenter = options.Presenter;
            obj.InitialCatalog = options.InitialCatalog;
            obj.InitialBatchIDs = options.InitialBatchIDs;
            obj.Action = options.Action;

        end % constructor

    end % methods

end % classdef
