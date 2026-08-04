classdef RunConfigContext
    % RUNCONFIGCONTEXT Dependencies and initial state for RunConfig.

    properties (SetAccess = private)
        Session
        Presenter
        Editor
        ConfigurationController
        ExperimentEditController
        ExperimentPresenter
        ExperimentSelectionController
        ExperimentSelectionPresenter
        ChildAppHost openmebius.presentation.lifecycle.ChildAppHost
    end

    methods

        function obj = RunConfigContext(options)

            arguments
                options.Session (1, 1) openmebius.application.batch ...
                    .BatchConfigurationSession
                options.Presenter (1, 1) openmebius.presentation.batch ...
                    .RunConfigPresenter
                options.Editor (1, 1) openmebius.presentation.batch ...
                    .RunConfigEditorViewModel
                options.ConfigurationController (1, 1) ...
                    openmebius.application.batch ...
                    .BatchConfigurationController
                options.ExperimentEditController (1, 1) ...
                    openmebius.application.experiment ...
                    .ExperimentEditController
                options.ExperimentPresenter (1, 1) ...
                    openmebius.presentation.experiment ...
                    .ExperimentPresenter
                options.ExperimentSelectionController (1, 1) ...
                    openmebius.application.batch ...
                    .BatchExperimentSelectionEditorController
                options.ExperimentSelectionPresenter (1, 1) ...
                    openmebius.presentation.batch ...
                    .BatchExperimentSelectionEditorPresenter
                options.ChildAppHost (1, 1) ...
                    openmebius.presentation.lifecycle.ChildAppHost = ...
                    openmebius.presentation.lifecycle.ChildAppHost()
            end

            obj.Session = options.Session;
            obj.Presenter = options.Presenter;
            obj.Editor = options.Editor;
            obj.ConfigurationController = ...
                options.ConfigurationController;
            obj.ExperimentEditController = ...
                options.ExperimentEditController;
            obj.ExperimentPresenter = options.ExperimentPresenter;
            obj.ExperimentSelectionController = ...
                options.ExperimentSelectionController;
            obj.ExperimentSelectionPresenter = ...
                options.ExperimentSelectionPresenter;
            obj.ChildAppHost = options.ChildAppHost;

        end % constructor

    end % methods

end % classdef
