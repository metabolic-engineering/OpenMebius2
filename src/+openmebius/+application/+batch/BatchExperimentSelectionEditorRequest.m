classdef BatchExperimentSelectionEditorRequest
    % BATCHEXPERIMENTSELECTIONEDITORREQUEST Input for RunAddBatch.

    properties (SetAccess = private)
        ExperimentNames (:, 1) string
        Mode (1, 1) string
        BatchId (1, 1) string
    end

    methods

        function obj = BatchExperimentSelectionEditorRequest( ...
                experimentNames, mode, batchId)

            arguments
                experimentNames (:, 1) string
                mode (1, 1) string {mustBeMember( ...
                    mode, ["parallel", "inst-mfa"])}
                batchId (1, 1) string = ""
            end

            experimentNames = strip(experimentNames(:));
            batchId = strip(batchId);

            if isempty(experimentNames) || ...
                    any(ismissing(experimentNames) | ...
                        experimentNames == "")
                error( ...
                    "OpenMebius2:BatchExperimentSelectionEditorRequest:" + ...
                    "InvalidExperiments", ...
                    "At least one experiment is required.");
            end

            if mode == "inst-mfa" && ...
                    (ismissing(batchId) || batchId == "")
                error( ...
                    "OpenMebius2:BatchExperimentSelectionEditorRequest:" + ...
                    "MissingBatchId", ...
                    "Batch ID is required for INST-MFA editing.");
            end

            obj.ExperimentNames = unique(experimentNames, "stable");
            obj.Mode = mode;
            obj.BatchId = batchId;

        end % constructor

    end % methods

end % classdef
