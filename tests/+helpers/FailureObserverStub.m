classdef FailureObserverStub < handle

    properties (SetAccess = private)
        Messages (:, 1) string = strings(0, 1)
    end

    methods

        function report(obj, message)

            obj.Messages(end + 1, 1) = string(message);

        end

    end

end
