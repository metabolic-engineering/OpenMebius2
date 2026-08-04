classdef MSViewContext
    % MSVIEWCONTEXT Dependencies and initial state passed to MSView.

    properties (SetAccess = private)
        Presenter openmebius.presentation.experiment.MSViewPresenter
        InitialExperimentIndex (1, 1) double
        IsDarkTheme (1, 1) logical
        Action openmebius.presentation.experiment.MSViewAction
    end

    methods

        function obj = MSViewContext(options)

            arguments
                options.Presenter (1, 1) openmebius.presentation ...
                    .experiment.MSViewPresenter
                options.InitialExperimentIndex (1, 1) double { ...
                                                                  mustBeInteger, mustBePositive}
                options.IsDarkTheme (1, 1) logical = false
                options.Action (1, 1) openmebius.presentation ...
                    .experiment.MSViewAction = ...
                    openmebius.presentation.experiment.MSViewAction()
            end

            obj.Presenter = options.Presenter;
            obj.InitialExperimentIndex = ...
                options.InitialExperimentIndex;
            obj.IsDarkTheme = options.IsDarkTheme;
            obj.Action = options.Action;

        end % constructor

    end % methods

end % classdef
