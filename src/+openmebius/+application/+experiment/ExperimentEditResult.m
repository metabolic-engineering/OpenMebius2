classdef ExperimentEditResult
    % EXPERIMENTEDITRESULT
    % Immutable result of saving editable experiment data.

    properties (SetAccess = private)
        Experiments
        Batch
        Messages (:, 1) string
    end

    methods

        function obj = ExperimentEditResult(options)

            arguments
                options.Experiments
                options.Batch
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Experiments = options.Experiments;
            obj.Batch = options.Batch;
            obj.Messages = options.Messages;

        end % constructor

    end % methods

end % classdef
