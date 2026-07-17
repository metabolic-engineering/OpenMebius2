classdef BatchRunCommandStub < handle

    properties
        RunStatus (1, 1) string = "finished"
        RunException = []
        RunCalled (1, 1) logical = false
        CancelCalled (1, 1) logical = false
    end

    methods

        function status = run(obj, ~, ~)

            obj.RunCalled = true;

            if ~isempty(obj.RunException)
                throw(obj.RunException);
            end

            status = obj.RunStatus;

        end

        function cancel(obj, ~)

            obj.CancelCalled = true;

        end

    end

end
