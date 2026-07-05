classdef BatchProgressViewModel

    properties (SetAccess = private)
        BatchId (1, 1) string
        Status (1, 1) string
        Rate (1, 1) double
        Message (1, 1) string
        StyleRules struct
        Notification
    end

    methods

        function obj = BatchProgressViewModel(options)

            arguments
                options.BatchId (1, 1) string = ""
                options.Status (1, 1) string = ""
                options.Rate (1, 1) double = 0
                options.Message (1, 1) string = ""
                options.StyleRules struct = struct( ...
                    "Rows", {}, ...
                    "Columns", {}, ...
                    "StyleKey", {})
                options.Notification = []
            end

            obj.BatchId = options.BatchId;
            obj.Status = options.Status;
            obj.Rate = max(0, min(1, options.Rate));
            obj.Message = options.Message;
            obj.StyleRules = options.StyleRules;
            obj.Notification = options.Notification;

        end % constructor

    end % methods

end % classdef
