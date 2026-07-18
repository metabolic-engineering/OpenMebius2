classdef MSViewContext
    % MSVIEWCONTEXT Dependencies and initial state passed to MSView.

    properties (SetAccess = private)
        Presenter openmebius.presentation.experiment.MSViewPresenter
        InitialExperimentIndex (1, 1) double
        IsDarkTheme (1, 1) logical
    end

    methods

        function obj = MSViewContext(options)

            arguments
                options.Presenter (1, 1) openmebius.presentation ...
                    .experiment.MSViewPresenter
                options.InitialExperimentIndex (1, 1) double { ...
                    mustBeInteger, mustBePositive}
                options.IsDarkTheme (1, 1) logical = false
            end

            obj.Presenter = options.Presenter;
            obj.InitialExperimentIndex = ...
                options.InitialExperimentIndex;
            obj.IsDarkTheme = options.IsDarkTheme;

        end % constructor

    end % methods

end % classdef
