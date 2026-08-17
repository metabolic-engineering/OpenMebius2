classdef RunConfigINSTMFATablesViewModel
    % RUNCONFIGINSTMFATABLESVIEWMODEL INST-MFA table presentation result.

    properties (SetAccess = private)
        IsAvailable (1, 1) logical
        PoolTable openmebius.presentation.batch.RunConfigTableViewModel
        TimePointTable openmebius.presentation.batch.RunConfigTableViewModel
        Notifications (1, :) cell
    end

    methods

        function obj = RunConfigINSTMFATablesViewModel(options)

            arguments
                options.IsAvailable (1, 1) logical = false
                options.PoolTable (1, 1) openmebius.presentation.batch ...
                    .RunConfigTableViewModel = openmebius.presentation ...
                    .batch.RunConfigTableViewModel()
                options.TimePointTable (1, 1) openmebius.presentation ...
                    .batch.RunConfigTableViewModel = openmebius ...
                    .presentation.batch.RunConfigTableViewModel()
                options.Notifications (1, :) cell = {}
            end

            obj.IsAvailable = options.IsAvailable;
            obj.PoolTable = options.PoolTable;
            obj.TimePointTable = options.TimePointTable;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
