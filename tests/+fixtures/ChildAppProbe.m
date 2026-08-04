classdef ChildAppProbe < handle

    events
        Applied
        Closed
    end

    methods

        function apply(obj)
            notify(obj, "Applied");
        end

        function close(obj)
            notify(obj, "Closed");
        end

    end

end
