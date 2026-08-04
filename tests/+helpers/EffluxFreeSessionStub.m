classdef EffluxFreeSessionStub < handle

    properties (SetAccess = private)
        IsRestored (1, 1) logical = false
        RestoreCount (1, 1) double = 0
    end

    methods

        function restore(obj)

            if obj.IsRestored
                return
            end

            obj.IsRestored = true;
            obj.RestoreCount = obj.RestoreCount + 1;

        end

    end

end
