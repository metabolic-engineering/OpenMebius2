classdef ExperimentImportResult
    % EXPERIMENTIMPORTRESULT
    % Immutable result of importing or reloading experiment data.

    properties (SetAccess = private)
        Experiments
        Batch
        Messages (:, 1) string
        ImportedFiles (:, 1) string
        SkippedFiles (:, 1) string
    end

    methods

        function obj = ExperimentImportResult(options)

            arguments
                options.Experiments
                options.Batch
                options.Messages (:, 1) string = strings(0, 1)
                options.ImportedFiles (:, 1) string = strings(0, 1)
                options.SkippedFiles (:, 1) string = strings(0, 1)
            end

            obj.Experiments = options.Experiments;
            obj.Batch = options.Batch;
            obj.Messages = options.Messages;
            obj.ImportedFiles = options.ImportedFiles;
            obj.SkippedFiles = options.SkippedFiles;

        end % constructor

    end % methods

end % classdef
