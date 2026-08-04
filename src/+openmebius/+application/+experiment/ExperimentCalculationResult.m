classdef ExperimentCalculationResult
    % EXPERIMENTCALCULATIONRESULT
    % Immutable result of recalculating MDV-derived experiment data.

    properties (SetAccess = private)
        Experiments
        Batch
        Messages (:, 1) string
        Warnings (:, 1) string
        HasCalculatedMDV (1, 1) logical
    end

    methods

        function obj = ExperimentCalculationResult(options)

            arguments
                options.Experiments
                options.Batch
                options.Messages (:, 1) string = strings(0, 1)
                options.Warnings (:, 1) string = strings(0, 1)
                options.HasCalculatedMDV (1, 1) logical = false
            end

            obj.Experiments = options.Experiments;
            obj.Batch = options.Batch;
            obj.Messages = options.Messages;
            obj.Warnings = options.Warnings;
            obj.HasCalculatedMDV = options.HasCalculatedMDV;

        end % constructor

    end % methods

end % classdef
