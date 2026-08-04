classdef AnalysisProvenanceBuilderStub < handle

    properties
        BatchIds (:, 1) string = strings(0, 1)
    end

    methods

        function provenance = build(obj, ~, batchId, ~, ~, experimentNames)

            obj.BatchIds(end + 1, 1) = string(batchId);
            provenance = struct( ...
                'batchId', string(batchId), ...
                'contentHash', "sha256:" + string(batchId), ...
                'experimentNames', string(experimentNames(:)));

        end

    end

end
