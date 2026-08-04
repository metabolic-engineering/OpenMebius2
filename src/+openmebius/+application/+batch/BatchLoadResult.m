classdef BatchLoadResult
    % BATCHLOADRESULT
    % Immutable result of loading a Batch object.

    properties (SetAccess = private)
        Batch
        Messages (:, 1) string
    end

    methods

        function obj = BatchLoadResult(options)

            arguments
                options.Batch
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Batch = options.Batch;
            obj.Messages = options.Messages;

        end % constructor

    end % methods

end % classdef
