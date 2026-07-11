classdef ExperimentEditResult
    % EXPERIMENTEDITRESULT
    % Immutable result of saving editable experiment data.

    properties (SetAccess = private)
        Experiments
        Batch
        Messages (:, 1) string
        UpdatedTable table
    end

    methods

        function obj = ExperimentEditResult(options)

            arguments
                options.Experiments
                options.Batch
                options.Messages (:, 1) string = strings(0, 1)
                options.UpdatedTable table = table()
            end

            obj.Experiments = options.Experiments;
            obj.Batch = options.Batch;
            obj.Messages = options.Messages;
            obj.UpdatedTable = options.UpdatedTable;

        end % constructor

    end % methods

end % classdef
