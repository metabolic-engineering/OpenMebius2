classdef RunConfigEditorViewModel
    % RUNCONFIGEDITORVIEWMODEL Complete initial state for RunConfig.

    properties (SetAccess = private)
        Config openmebius.presentation.batch.RunConfigViewModel
        ControlState openmebius.presentation.batch.RunConfigControlState
        MSFragmentTable openmebius.presentation.batch.RunConfigTableViewModel
        EffluxTable openmebius.presentation.batch.RunConfigTableViewModel
        SuggestionTable openmebius.presentation.batch.RunConfigTableViewModel
        INSTMFATables openmebius.presentation.batch ...
            .RunConfigINSTMFATablesViewModel
        Notifications (1, :) cell
    end

    methods

        function obj = RunConfigEditorViewModel(options)

            arguments
                options.Config (1, 1) openmebius.presentation.batch ...
                    .RunConfigViewModel = openmebius.presentation.batch ...
                        .RunConfigViewModel()
                options.ControlState (1, 1) openmebius.presentation.batch ...
                    .RunConfigControlState = openmebius.presentation.batch ...
                        .RunConfigControlState()
                options.MSFragmentTable (1, 1) openmebius.presentation ...
                    .batch.RunConfigTableViewModel = openmebius ...
                        .presentation.batch.RunConfigTableViewModel()
                options.EffluxTable (1, 1) openmebius.presentation.batch ...
                    .RunConfigTableViewModel = openmebius.presentation ...
                        .batch.RunConfigTableViewModel()
                options.SuggestionTable (1, 1) openmebius.presentation ...
                    .batch.RunConfigTableViewModel = openmebius ...
                        .presentation.batch.RunConfigTableViewModel()
                options.INSTMFATables (1, 1) openmebius.presentation ...
                    .batch.RunConfigINSTMFATablesViewModel = openmebius ...
                        .presentation.batch.RunConfigINSTMFATablesViewModel()
                options.Notifications (1, :) cell = {}
            end

            obj.Config = options.Config;
            obj.ControlState = options.ControlState;
            obj.MSFragmentTable = options.MSFragmentTable;
            obj.EffluxTable = options.EffluxTable;
            obj.SuggestionTable = options.SuggestionTable;
            obj.INSTMFATables = options.INSTMFATables;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
