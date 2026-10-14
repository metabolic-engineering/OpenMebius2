classdef ResultArtifactRepositoryStub < handle

    properties
        DeletedBatchIds (:, 1) string = strings(0, 1)
        PreservedInheritance (:, 1) logical = false(0, 1)
    end

    methods

        function deletedFiles = deleteBatchArtifacts( ...
                obj, ~, batchId, options)

            arguments
                obj
                ~
                batchId
                options.PreserveInheritance logical = false
            end

            obj.DeletedBatchIds(end + 1, 1) = string(batchId);
            obj.PreservedInheritance(end + 1, 1) = options.PreserveInheritance;
            deletedFiles = strings(0, 1);

        end

    end

end
