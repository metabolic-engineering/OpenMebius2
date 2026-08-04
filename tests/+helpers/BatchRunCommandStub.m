classdef BatchRunCommandStub < handle

    properties
        RunResult = openmebius.application.batch.BatchExecutionResult(true)
        RunException = []
        RunCalled (1, 1) logical = false
        CancelCalled (1, 1) logical = false
    end

    methods

        function result = run(obj, ~, ~)

            obj.RunCalled = true;

            if ~isempty(obj.RunException)
                throw(obj.RunException);
            end

            result = obj.RunResult;

        end

        function cancel(obj, ~)

            obj.CancelCalled = true;

        end

    end

end
