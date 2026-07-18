classdef RunConfigMainAppStub < handle

    properties
        batch
        exp = []
        UpdateCount (1, 1) double = 0
        TracerConfigApp = []
    end

    methods

        function obj = RunConfigMainAppStub(batch)

            obj.batch = batch;

        end

        function updateBatchTable(obj)

            obj.UpdateCount = obj.UpdateCount + 1;

        end

    end

end % classdef
