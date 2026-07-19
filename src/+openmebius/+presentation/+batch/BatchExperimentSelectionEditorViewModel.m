classdef BatchExperimentSelectionEditorViewModel
    % BATCHEXPERIMENTSELECTIONEDITORVIEWMODEL RunAddBatch launch values.

    properties (SetAccess = private)
        IsAvailable (1, 1) logical
        ExperimentNames (:, 1) string
        Mode (1, 1) string
        BatchId (1, 1) string
        Notifications (1, :) cell
    end

    methods

        function obj = BatchExperimentSelectionEditorViewModel(options)

            arguments
                options.IsAvailable (1, 1) logical = false
                options.ExperimentNames (:, 1) string = strings(0, 1)
                options.Mode (1, 1) string = "inst-mfa"
                options.BatchId (1, 1) string = ""
                options.Notifications (1, :) cell = {}
            end

            obj.IsAvailable = options.IsAvailable;
            obj.ExperimentNames = options.ExperimentNames;
            obj.Mode = options.Mode;
            obj.BatchId = options.BatchId;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
