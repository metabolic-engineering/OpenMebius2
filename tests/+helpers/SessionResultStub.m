classdef SessionResultStub < handle

    properties (SetAccess = private)
        Reporter (1, 1) function_handle = @(~) []
    end

    methods

        function setNotificationReporter(obj, reporter)
            obj.Reporter = reporter;
        end

        function report(obj, notification)
            obj.Reporter(notification);
        end

    end

end
