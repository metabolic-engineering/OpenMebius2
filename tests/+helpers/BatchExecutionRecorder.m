classdef BatchExecutionRecorder < handle

    properties
        Progress cell = {}
        Checkpoints cell = {}
        MessageCount (1, 1) double = 0
        ResultCount (1, 1) double = 0
    end

    methods

        function recordProgress(obj, progress)

            obj.Progress{end + 1, 1} = progress;

        end

        function writeCheckpoint(obj, batchTable)

            obj.Checkpoints{end + 1, 1} = batchTable;

        end

        function recordMessage(obj, ~)

            obj.MessageCount = obj.MessageCount + 1;

        end

        function recordResult(obj, ~)

            obj.ResultCount = obj.ResultCount + 1;

        end

    end

end
