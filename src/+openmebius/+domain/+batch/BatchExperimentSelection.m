classdef BatchExperimentSelection
    % BATCHEXPERIMENTSELECTION Experiments selected by the batch editor.

    properties (SetAccess = private)
        Mode (1, 1) string
        Experiments (:, 1) string
        AddAsParallel (1, 1) logical
        BatchId (1, 1) string
    end

    methods

        function obj = BatchExperimentSelection(options)

            arguments
                options.Mode (1, 1) string {mustBeMember( ...
                                                options.Mode, ["parallel", "inst-mfa"])}
                options.Experiments (:, 1) string
                options.AddAsParallel (1, 1) logical = true
                options.BatchId (1, 1) string = ""
            end

            experiments = strip(options.Experiments(:));

            if isempty(experiments) || ...
                    any(ismissing(experiments) | experiments == "")
                error( ...
                    "OpenMebius2:BatchExperimentSelection:" + ...
                    "InvalidExperiments", ...
                "At least one non-empty experiment is required.");
            end

            experiments = unique(experiments, "stable");
            batchId = strip(options.BatchId);

            if options.Mode == "inst-mfa" && ...
                    (ismissing(batchId) || batchId == "")
                error( ...
                    "OpenMebius2:BatchExperimentSelection:" + ...
                    "MissingBatchId", ...
                "BatchId is required for INST-MFA editing.");
            end

            obj.Mode = options.Mode;
            obj.Experiments = experiments;
            obj.AddAsParallel = options.AddAsParallel;
            obj.BatchId = batchId;

        end % constructor

    end % methods

end % classdef
