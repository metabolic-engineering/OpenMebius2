classdef ResultArtifactRepositoryStub < handle

    properties
        DeletedBatchIds (:, 1) string = strings(0, 1)
    end

    methods

        function deletedFiles = deleteBatchArtifacts( ...
                obj, ~, batchId)

            obj.DeletedBatchIds(end + 1, 1) = string(batchId);
            deletedFiles = strings(0, 1);

        end

    end

end
