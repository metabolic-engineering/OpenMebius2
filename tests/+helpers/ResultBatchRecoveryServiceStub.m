classdef ResultBatchRecoveryServiceStub < handle

    properties
        RecoveredIDs (:, 1) string = strings(0, 1)
        Batch
        Result
        RecoverCount (1, 1) double = 0
    end

    methods

        function ids = recover(obj, batch, result)

            obj.RecoverCount = obj.RecoverCount + 1;
            obj.Batch = batch;
            obj.Result = result;
            ids = obj.RecoveredIDs;

        end

    end

end
